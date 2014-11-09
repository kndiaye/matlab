function [p,F,fx,varargout]=myanova(X,nf,rp,epsilon,verbose,posthoc)
% myanova - N-way ANOVA
%   [p,F,fx]=myanova(X,nf)
%   [p,F,fx,epsilon,df,dfe,SS,SSe,SSt]=...
%   Performs a N-way beween subjects anova on X
%
%INPUTS:
%       X = [ factor1 x factor2 x ... x factorN x replicates x ...]
%       nf: number of factors
%   This function is vectorized, ie. ANOVA is computed for each value in X
%   beyond the 'replicates' (i.e. subject) dimension, which is (nf+1).
%
%OUTPUTS:
%	p: the Null hypothesis probability
%	F: the F-values
%	fx: a cell array listing the tested effects.
%	eta: percentage of explained variance by each factor
%	epsilon: sphericity correction if applicable
%
%OPTIONAL INPUTS:
%   [...]=myanova(X,nf,rp)
%       To specifiy repeated/within-subject factors in a within-subject design
%       rp: an array listing the dimensions of repeated factors
%
%   [...]=myanova(X,nf,rp,epsilon)
%   Correct for non-spherical data using epsilon (expanded to match the
%   size of measures, if necessary). If epsilon=NaN, epsilon(s) will be
%   computed using Greenhouse-Geisser correction or Huynh-Feldt (if eGG>.7)
%   To apply no correction, set epsilon=1 (default)
%
%   [...]=myanova(X,nf,rp,epsilon,verbose)
%   verbose = 1 will display a table of results
%
%   Examples:
%
%       X(1:2,1:3,1:10) = data from 2 tasks by 3 condition for 10 subjects,
%		both factors (dimensions 1 and 2) are within-subject factors:
%       >> [p,F,fx]=myanova(X,2,1:2)
%               p: 3x1 array
%               F: 3x1 array
%               fx: 3x1 cells: { 1 , 2 , [ 1 2 ]}
%
%       X(1:3,1:4,1:10) = data from 3 groups of 10 subjects performing 4 tasks
%		only the second factor (dimension 2 of X) is a within-subject variable:
%       >> [p,F,fx]=myanova(X,2,[2])
%               p: 3x1 array
%               F: 3x1 array
%               fx: 3x1 cells: { 1 , 2 , [ 1 2 ]}
%
% Requires: f_cdf()

% ----------------------------- Script History ---------------------------------
% KND  2007...2008  many changes... 
% KND  2008-08-27 Corrected version (at last!)
%                   
% ----------------------------- Script History ---------------------------------

% Version 2.0 - 27-Aug-2008
sX=[size(X) 1];
nX=ndims(X);
if nargin<2
    error('Number of factors (nf) is mandatory')
end
if ~isscalar(nf)
    error('Number of factors should be a scalar');
end
if nargin<3
    rp=[];
end

% Number of groups for each factor:
ng=sX(1:nf);
% Number of cells:
nc=prod(ng);
% Number of replicates, ie. samples in each group:
nr=sX(nf+1);
%Total number of observations:
no=nc*nr;
% Dimensions of (univariate) dependent variables:
svar=[sX(nf+2:end)];
if ~isempty(rp) && nr<2
    error('You must have more than one observation per cell or more than one subject per condition')
end
% if (nr<=1)
%     error('myanova doesn''t work with 1 subject / group!')
% end

if nargin<3
    rp=[];
end
 if ~isempty(rp) & ~all(ismember(1:nf,rp))
     error('Mixed designs (split plot) ANOVA unavailable!')
 end
% if ~isempty(rp) & nf>2
%     error('Repeated measure ANOVA is only available for 2 factor designs!')
% end
if nargin<4
    epsilon=1;
end
if nargin<5 || isempty(verbose)
    % No display for massively univariate data...
    verbose = (nargout==0) & prod([1 svar])<10;
end
if isempty(epsilon)
    epsilon=NaN;
end
if nargin<6
    posthoc=[];
end

fx={};
for i=1:nf
    fx=[fx ; num2cell(nchoosek(1:nf,i),2)];
end
nfx=length(fx);

% Posthoc tests
if isempty(posthoc)
    % No display for massively univariate data...
    if verbose 
        posthoc = 1;
    else
        posthoc = 0;
    end
end
if iscell(posthoc)
    posthoc_fx = posthoc;
    posthoc=1;
elseif isequal(posthoc,1)
    posthoc_fx = cell(nfx,1 );
end

% Within Group/Error stats
% Mean in each cell
mXw=mean(X,nf+1);
% Residual Error of the model
SSe=X-repmat(mXw,[ones(1,nf) nr 1]);
SSe=reshape(SSe, nc*nr, []).^2;
SSe=sum(SSe);
dfe=nc*(nr-1);
MSe=squeeze(SSe/dfe);
% pre-allocate sum of squares of effects and errors:
SSbe=repmat(SSe,nfx,1);
SS=NaN.*SSbe;
%keeps the full model unexplained variance for later
MSw=MSe;
dfw=dfe;

% Population stats
dft=(nc*nr)-1;
% Grand mean value
mX=reshape(mXw, nc, []);
mX=mean(mX,1);
% Correction factor:
% cX=mX.^2./(nc*nr);

% These are not used afterwards
SSt=sum((reshape(X, nc*nr, [])-repmat(mX,[nc*nr 1])).^2);
% MSt=squeeze(SSt/dft);

if ~isempty(rp)
    % Correct Within Error term to account for repeated measurements
    dfr=(nr-1);
    mXr=permute(X, [nf+1 1:nf nf+2:nX]);
    mXr=reshape(mXr,nr,nc,[]);
    mXr=mean(mXr,2);
    SSr=nc*sum((reshape(mXr, nr, []) - repmat(mX,[nr 1])).^2);
end



% Sphericity checking
if isnan(epsilon) % | ischar(epsilon)
    % check for sphericity first
    if all(ng<=2)
        epsilon=1;
    else
        [eGG,eHF]=sphericity(X,nf);
        epsilon=eGG;
        epsilon(eGG>.7)=eHF(eGG>.7);    
        epsilon(ng==2)=1;
        epsilon=min(epsilon,1);
    end
end
if numel(epsilon)==1;
    epsilon=epsilon*ones(nfx,prod(sX(nf+2:end)));
elseif length(epsilon(:))==nfx
   epsilon=epsilon(:)*ones(1,prod(sX(nf+2:end)));
end
varargout{1} = epsilon;

% Number of groups in between subjects
if ~isempty(rp)
    tmp=zeros(1,nf);
    tmp(rp)=1;
    rp=logical(tmp);
    % number of cells for between-subject factors
    ncb=prod(ng(~rp));
    nc=nc/ncb;
    % Order factors so that within ones come first, followed by the between    
    % fxw = [find(rp) find(~rp)];
    % ngw = sX(pfxw);
else
    rp=logical(zeros(1,nf));
end


% % Within Group/Error stats
% % i.e unmodeled error
% mXe=mean(X,nf+1);
% SSe=X-repmat(mXe,[ones(1,nf) nr 1]);
% SSe=reshape(SSe, [nc nr svar]).^2;
% SSe=sum(sum(SSe));
% MSe=squeeze(SSe/dfe);


% Population stats
dft=(no)-1;
% mX=reshape(mXe,nc,[svar]);
%     varargout{1}=epsilon;
% end
if nargout >  8 || verbose==1
    varargout{6}=SSt;
end

for i=1:length(fx)
    j=fx{i};
    % Between groups stats for each factor
    % Dimensions of the factors pooled through factor j
    nj=setdiff(1:nf,j);
    % Nb of cells for effect j
    ncj = prod(ng(j));
    % Nb of cells pooled by effect j
    nbj = nc./ncj;
    % Degrees of freedom for this effect    
    dfb=prod(ng(j)-1);
    mXb=permute(mXw, [j nj nf+1:nX]);
    mXb=reshape(mXb,ncj,nbj,[]);
    mXb=mean(mXb,2);
    SSb=nr*nbj*sum((reshape(mXb,ncj, []) - repmat(mX,[ncj 1])).^2);
    
    if length(j)>1  
        % Interaction:
        % we need to remove the variance due to embedded effects from the
        % Sum of Squares of the current interaction effect
        for k=1:i-1
            if all(ismember(fx{k}, j))
                SSb=SSb-SS(k,:);
            end
        end
    end
    % Keep track of the SS of the current effect
    SS(i,:)=SSb;
    MSb=SSb./dfb;

    dfe=nc*(nr-1);    
    if any(rp(j))
        % Correct Error term to account for repeated measurements
        dfe=(nr-1)*dfb;
        mXe=permute(X, [nf+1 j nj nf+2:nX]);
        mXe=reshape(mXe,nr*ncj,nbj,[]);
        mXe=mean(mXe,2);
        % Unexplained variance for this effect:
        SSe=nbj*sum((reshape(mXe, nr*ncj, []) - repmat(mX,[nr*ncj 1])).^2);
        % Subtract replication/subject variance and the effect itself
        SSe=SSe-SSr-SSb;
        for k=1:i-1
            %remove embedded factors effects and error terms
            if all(ismember(fx{k}, j))
                SSe=SSe-SS(k,:)-SSbe(k,:);
            end
        end
        SSbe(i,:)=SSe;
    end
    MSe=squeeze(SSbe(i,:)/dfe);
    %         % MSr=squeeze(SSr/dfr);
    %     else
    %         dfw=nc*(nr-1);
    %     MSw=squeeze(SSw/dfw);
    %
    %         dfe=dfw;
    %         MSe=MSw;
    %     end
    dfb=dfb.*epsilon(i,:);
    dfe=dfe.*epsilon(i,:);
    F(i,:)=squeeze(MSb)./MSe;
    p(i,:)=1-f_cdf(F(i,:),dfb,dfe);
    %         dfb=dfb.*epsilon(i,:);
    %         dfw=dfw.*epsilon(i,:);
    %         F(i,:)=squeeze(MSb)./MSw;
    %         p(i,:)=1-f_cdf(F(i,:),dfb,dfw);
    %     end
    % [p,F,fx,epsilon(1),df(2),dfe(3),SS(4),SSe(5),SSt(6)]=...
    if nargout>4 || verbose==1
        varargout{2}(i,:)=dfb;
    end
    if nargout>5 || verbose==1
        %if any(rp)
            varargout{3}(i,:)=dfe;
        %else
        %    varargout{3}(i,:)=dfw;
        %end
    end
    if nargout>6 || verbose==1
        varargout{4}(i,:)=SSb;
    end
    if nargout>7 || verbose==1
        %if any(rp)
            varargout{5}(i,:)=SSe;
        %else
        %    varargout{5}(i,:)=SSw;
        %end
    end
end

if prod(sX)>nc*nr
    p=reshape(p,[nfx,sX(nf+2:end)]);
    F=reshape(F,[nfx,sX(nf+2:end)]);
end

if verbose
    [ignore,df,dfe,SSb,SSe,SSt]=deal(varargout{:});
    MS=SS./df;

    %Display results
    fprintf([repmat('-',1,80) '\n']  );
    fprintf(['%' num2str(max(cellfun('length', fx))*2+15) 's   \t| df  \t|    SS   \t|    MS   \t|    F  \t| p\n'], 'ANOVA results');
    fprintf([repmat('-',1,80) '\n']  );
    for j=1:min(size(p,2),6)
            if size(p,2)>1
            fprintf('MULTIDIMENSIONAL DATA: [%d] ...\n',j)
            end

        for i=1:length(fx)
            if i<=nf
                label=sprintf('Factor #%d',i);
            else
                label=['Interaction ' sprintf('%d*',fx{i})];
                label=label(1:end-1);
            end
            label=sprintf([ '%' num2str(max(cellfun('length', fx))*2+15) 's'],label);
            fprintf('%s:  \t % 3.3g \t% 8.4g\t% 8.4g\t% 8.4g\t  %g\n',...
                label,df(i),SS(i,j),MS(i,j),F(i,j),p(i,j));
            if any(rp) || i==nfx
                label=sprintf([ '%' num2str(length(label)) 's'],'Error');
                fprintf('%s:  \t % 3.3g \t% 8.4g\t% 8.4g\n',...
                    label,dfe(i),SSe(i,j),SSe(i,j)./dfe(i));
            end
        end        

        if any(rp)
            MS_r=SSr./dfr;
            label=sprintf([ '%' num2str(length(label)) 's'],'Subj/Repl');
            fprintf('%s:  \t % 3.3g \t% 8.4g\t% 8.4g',...
                label,dfr,SSr(j),MS_r(j));
            % The following is wrong:
            % MSw is not the correct error term for the subj effect
            % F_r=squeeze(MS_r)./MSw;
            % p_r=1-f_cdf(F_r,dfr,dfw);
            % fprintf('\t% 8.4g\t  %g\n',...
            %                 F_r(j),p_r(j));
            fprintf('\n');
        end
        
        label=sprintf([ '%' num2str(max(cellfun('length', fx))*2+15) 's'],'Total');
        fprintf('%s:  \t % 3.3g \t% 8.4g\n',...
            label,dft,SSt(j));
        if size(p,2)>1
            fprintf([repmat('. ',1,40) '\n'])
        end
            
    end
    if j<size(p,2)
        fprintf('\n')
        fprintf('    etc.\n')
        fprintf('\n')
        fprintf([repmat('. ',1,40) '\n'])
    end
    fprintf([repmat('-',1,80) '\n']  );
    if nf <= 2 && max(ng) <= 6
        % Plot data
        try
            figure
            for i=1:min(prod(svar),9)*(verbose==true)
                if prod(svar)>1
                    subplot(3,3,i);
                end
                if nf==2
                    barerrorbar(X(:,:,:,i));
                else
                     barerrorbar(X(:,:,i));
                end
                xlabel('Factor 1');
                if prod(svar)>1
                    title(sprintf('Unviariate dimension %d',i));
                end
            end
        catch
            warning('Can''t display error-bars');
        end
    end
end



return


if nargout>3
    SS(nfx+1,:)=SSt;
    SS(nfx+2,:)=SSw;
    SS(nfx+3,:)=SSr;
    SS(nfx+4,:)=SSe;
end
if nargout>4
    df(nfx+1,:)=dft;
    df(nfx+2,:)=dfw;
    df(nfx+3,:)=dfr;
    df(nfx+4,:)=dfe;
end
if nargout>5
    MS(nfx+1,:)=MSt;
    MS(nfx+2,:)=MSw;
    MS(nfx+3,:)=MSr;
    MS(nfx+4,:)=MSe;
end


return


function [SS]= sumofsquares(X,j,nf,ncj,nbj,nX,mXw)        
    % Between groups stats for a given factor j
    % ncj. Nb of cells for effect j
    %ncj = prod(ng(j));
    % nbj: Nb of cells pooled by effect j
    %nbj = nc./ncj;    
    mXb=permute(mX, [j setdiff(1:nf,j) nf+1:nX]);
    mXb=reshape(mXb,ncj,nbj,[]);
    mXb=mean(mXb,2);
    SS=nr*nbj*sum((reshape(mXb,ncj, []) - repmat(mX,[ncj 1])).^2);
    
return


%% RESSOURCES
% http://www.brown.edu/Research/LCE/Fall2004/Within%20subjs.pdf
%

%% EXAMPLES
%
% from Zar, 1999, pp. 250 sqq.
% Ex. 12.5 (repeated measure one-way ANOVA)
X= [
    164 152 178
    202 181 222
    143 136 132
    210 194 216
    228 219 245
    173 159 182
    161 157 165
    ]';
% F = (1454/2)/(695.3/12) = 727/57.94 = 12.6


% BETWEEN SUBJECT DESIGN WITH 2 REPLICATES
% ========================================
% http://www.richland.edu/james/lecture/m170/ch13-2wy.html
% SS = 512.8667  449.4667   143.1333  136.0000  1241.4667
% F observed = 28.283   12.393   1.973
% F critique = 3.682 3.056 2.641
X=[
    106, 110 , 95, 100 , 94, 107 , 103, 104 , 100, 102;
    110, 112 , 98, 99 , 100, 101 , 108, 112 , 105, 107;
    94, 97, 	86, 87 	98, 99 	99, 101 	94, 98];
X=cat(3,X(:,1:2:end),X(:,2:2:end))
[p,F]=myanova(X,2,[])



% % http://www.linguistics.ucla.edu/faciliti/facilities/statistics/fromoac.htm
X=[  8  9  8   8  9   7   10  9  10;  9  10 9  10  9  13   8   9   9;  8  7  7  12  7   9   10  9   7;  6  8  9   8 10  10   12  9   10;  7  6  7  11 12   8   8   11  9];
X=reshape(X,5,3,3);
%
% % COND TRIAL SUBJECT
X=permute(X,[3 2 1]);
%
[p,F]=myanova(X,2,1:2)
% l=factorlabels(X)
% rm_anova2(X(:), l(:,3),l(:,1),l(:,2),{'COND', 'TRIAL'})
% %     'Source'                 'SS'         'df'    'MS'         'F'         'p'
% %     'COND'                   [24.8444]    [ 2]    [12.4222]    [4.0216]    [0.0618]
% %     'TRIAL'                  [ 0.3111]    [ 2]    [ 0.1556]    [0.0625]    [0.9399]
% %     'COND x TRIAL'           [ 1.6889]    [ 4]    [ 0.4222]    [0.1907]    [0.9397]
% %     'COND x Subj'            [24.7111]    [ 8]    [ 3.0889]          []          []
% %     'TRIAL x Subj'           [19.9111]    [ 8]    [ 2.4889]          []          []
% %     'COND x TRIAL x Subj'    [35.4222]    [16]    [ 2.2139]          []          []



% http://lib.stat.cmu.edu/DASL/Datafiles/airpullutionfiltersdat.html
%    1.  NOISE = Noise level reading (decibels)
%    2. SIZE = Vehicle size: 1 small 2 medium 3 large
%    3. TYPE = 1 standard silencer 2 Octel filter
%    4. SIDE = 1 right side 2 left side of car
%    and 3 replicates

x=[
    810	1	1	1
    820	1	1	1
    820	1	1	1
    840	2	1	1
    840	2	1	1
    845	2	1	1
    785	3	1	1
    790	3	1	1
    785	3	1	1
    835	1	1	2
    835	1	1	2
    835	1	1	2
    845	2	1	2
    855	2	1	2
    850	2	1	2
    760	3	1	2
    760	3	1	2
    770	3	1	2
    820	1	2	1
    820	1	2	1
    820	1	2	1
    820	2	2	1
    820	2	2	1
    825	2	2	1
    775	3	2	1
    775	3	2	1
    775	3	2	1
    825	1	2	2
    825	1	2	2
    825	1	2	2
    815	2	2	2
    825	2	2	2
    825	2	2	2
    770	3	2	2
    760	3	2	2
    765	3	2	2
    ];
[i,nl]=dgrouping(x(:,2:end));
X(i)=x(:,1);
X=reshape(X,nl);

% One way ANOVA from Loftus & Masson, 1994
% Exposure Duration Per Word (sec)
% 1 Sec 2 Sec 5 Sec
X= [
    10 13 13
    6 8 8
    11 14 14
    22 23 25
    16 18 20
    15 17 17
    1 1 4
    12 15 17
    9 12 12
    8 9 12
    ]';
% M1 = 11.0 M2 = 13.0 M3 = 14.2

% Two-way ANOVA from Cousineau 2007
X= [
    550 580 610
    605 635 655
    660 690 710
    ]';


% Cousineau ?
X= [
    150.   44.   71.   59.   132.   74.   1.
    335.   270.   156.   160.   118.   230.   1.
    149.   52.   91.   115.   43.   154.   1.
    159.   31.   127.   212.   71.   224.   1.
    159.   0.   35.   75.   71.   34.   1.
    292.   125.   184.   246.   225.   170.   1.
    297.   187.   66.   96.   209.   74.   1.
    170.   37.   42.   66.   114.   81.   1.
    346.   175.   177.   192.   239.   140.   2.
    426.   329.   236.   76.   102.   232.   2.
    359.   238.   183.   123.   183.   30.   2.
    272.   60.   82.   85.   101.   98.   2.
    200.   271.   263.   216.   241.   227.   2.
    366.   291.   263.   144.   220.   180.   2.
    371.   364.   270.   308.   219.   267.   2.
    497.   402.   294.   216.   284.   255.   2.
    282.   186.   225.   134.   189.   169.   3.
    317.   31.   85.   120.   131.   205.   3.
    362.   104.   144.   114.   115.   127.   3.
    338.   132.   91.   77.   108.   169.   3.
    263.   94.   141.   142.   120.   195.   3.
    138.   38.   16.   95.   39.   55.   3.
    329.   62.   62.   6.   93.   67.   3.
    292.   139.   104.   184.   193.   122.   3.
    ];
X=reshape(X(:,1:6),[8,3,6]);
X=permute(X,[1 3 2]);


% Cousineau 2005; TQPM
% Simulated data of a 2-by-5 exp with 16 subjects
X=str2num(urlread('http://www.tqmp.org/Content/vol01-1/p042/p042.dat'));
X=reshape(X(:,end),[16,5,2]);
X=permute(X,[3 2 1]);
myanova(X,2,1:2)
% all the variances are homogeneous and spherical, Tabachnik & Fidell, 1996
% Mauchly s W = 0.74, p > .50 for factor 2 
% and W = 0.68, p > .50 for the interaction;    
% this test cannot be performed for factor 1 since it has only two levels
% but we generated the data such that it is also homogenous.
% The Greenhouse Geiser and the Huynh Feldt epsilons are close to 1 so that
% we don t need to use corrections (Huynh, 1978, Rouanet and Lepine, 1970). 

% Effect name  SS        dl   MS         F     p<0.001
% Factor 1    10621       1   10621     76.8     *** 
% Error        2073      15     135    
% Factor 2    11784       4    8196     16.4     ***
% Error        4378      60      72.9    
% Interaction  2250       4     562      6.52    *** 
% Error        5171      60      86.2    
% Subject: F(1, 15) = 710, p < .001)

% Analyzed using SPSS15:;
% Tests of Between-Subjects Effects
% Dependent Variable: X 
% Source	 	Type III Sum of Squares	df      Mean Square	F	Sig.
% Intercept	Hypothesis	66283627.628	1       66283627.628	710.851	.000
%               Error	1398682.399     15  	93245.493(a)			
% fx1	Hypothesis      10621.640       1       10621.640       76.829	.000
%       Error           2073.752    	15      138.250(b)			
% fx2	Hypothesis      4784.064        4       1196.016        16.389	.000
%       Error           4378.604        60      72.977(c)			
% Subject	Hypothesis	1398682.399 	15      93245.493       745.749	.000
%           Error       1314.799        10.515	125.036(d)			
% fx1 * fx2	Hypothesis	2250.918        4   	562.729         6.529	.000
%           Error       5171.445    	60      86.191(e)			
% fx1 * Subject	Hypothesis	2073.752	15      138.250         1.604	.100
%               Error       5171.445	60  	86.191(e)			
% fx2 * Subject	Hypothesis	4378.604	60      72.977      	.847	.739
%               Error       5171.445	60      86.191(e)			
% fx1*fx2*Subj	Hypothesis	5171.445	60      86.191          .       .
%               Error       .000        0       .(f)			
% (a)	 MS(Subject)
% (b)	 MS(fx1 * Subject)
% (c)	 MS(fx2 * Subject)
% (d)	1.000 MS(fx1 * Subject) +  MS(fx2 * Subject) -  MS(fx1 * fx2 * Subject)
% (e)	 MS(fx1 * fx2 * Subject)
% (f)	 MS(Error)




% Loftus & Masson 1994
% Reported in Cousineau 2005
% X(2*5*6) = R vs U | SOA 50/100/200/400 | SUBJ(6)
X= [
    1 450 462 12 460 482 22 460 497 37 480 507 27
    2 510 492 -18 515 530 15 520 534 14 504 550 46
    3 492 508 16 512 522 10 503 553 50 520 539 19
    4 524 532 8 530 543 13 517 546 29 503 553 50
    5 420 409 -11 424 452 28 431 468 37 446 472 26
    6 540 550 10 538 528 -10 552 575 23 562 598 36
    ];
X=reshape(X(:,2:end),6,3,4);
X=permute(X(:,1:2,:),[2 3 1]);


% Loftus % Masson
% TABLE 2: Hypothetical Subject Means for a Within-Subject Design
%				Raw data							Normalized data
% Subject 	Incongruous Congruous Neutral Mi   Incongruous Congruous Neutral Mi
X= [
	1   784 632 651 689.0     848.0 696.0 715.0 753.0
	2   853 702 689 748.0     858.0 707.0 694.0 753.0
	3   622 598 606 608.7     766.3 742.3 750.3 753.0
	4   954 873 855 894.0     813.0 732.0 714.0 753.0
	5   634 600 595 609.7     777.3 743.3 738.3 753.0
	6   751 729 740 740.0     764.0 742.0 753.0 753.0
	7   918 877 893 896.0     775.0 734.0 750.0 753.0
	8   894 801 822 839.0     808.0 715.0 736.0 753.0
	];

X=reshape(X(:,2:4),8,3);
X=permute(X,[2 1]);
myanova(X,1,1)
% 
% ANOVA
% Source 		df 	SS 		MS 		F
%                                           
% Subjects 		7 	280,178
% Conditions 	2 	27,984 	13,992 	13.08
% S * C 		14 	14,972 	1,069
% Total 		23 	323,133


clc;
for i=1:2; for j=1:3; for k=1:5; for l=1:10;
                xx(i,j,k,l)=randn;
                fprintf('%d\t%d\t%d\t%d\t%f\n', i,j,k,l,xx(i,j,k,l));
end;end;end;end