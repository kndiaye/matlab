function [p,F,fx,varargout]=myanova(X,nf,rp,epsilon)
% myanova - N-way ANOVA
%   [p,F,fx]=myanova(X,nf)
%   [p,F,fx,epsilon,df,dfe,SS,SSe,SSt]=...
%   Performs a N-way beween subjects anova on X
%
%INPUTS:
%       X = [ factor1 x factor2 x ... x factorN x replicates x ...]
%   This function is vectorized, ie. anova is computed for each value in X
%   after the 'replicates' (i.e. subject) dimension.
%       nf: number of factors
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
%       To specifiy repeated factors in a within-subject design    
%       rp: an array listing the repeated factors
%
%   [...]=myanova(X,nf,rp,epsilon)
%   Correct for non-spherical data using epsilon (expanded to match the
%   size of measures, if necessary). If epsilon=NaN, epsilon(s) will be
%   computed using Greenhouse-Geisser or Huynh-Feldt (if eGG>.7)
%
%   Ex:
%       2 tasks by 3 condition for 10 subjects, within subject design:
%       >> [p,F,fx]=myanova(X(1:2,1:3,1:10),2,1:2)
%               p: 3x1 array
%               F: 3x1 array
%               fx: 3x1 cells: { 1 , 2 , [ 1 2 ]}
%
% Requires: f_cdf()

sX=[size(X) 1];
nX=ndims(X);
if nargin<2
    error('Number of factors (nf) is mandatory')
end
% Number of groups for each factor
ng=sX(1:nf);
% Nb of cells
png=prod(ng);
% Number of replicates, ie. samples in each group
nr=sX(nf+1);
%Size of dependent variables (DV)
szd=[size(X) ones(1,nf)];
szd=szd(nf+2:end);
% Number of DV
pszd=prod(szd);

if nargin<3
    rp=[];
end
if ~isempty(rp) & ~all(ismember(1:nf,rp))
    error('Mixed designs (split plot) ANOVA unavailable!')
end
if ~isempty(rp) & nf>3
    error('Repeated measure ANOVA is only available for 2 factor designs!')
end
if nargin<4
    epsilon=1;
end

% Within Group/Error stats
mXw=sum(X,nf+1)./sX(nf+1);
SSw=X-repmat(mXw,[ones(1,nf) nr 1]);
SSw=reshape(SSw, [png*nr, szd]);
SSw=sum(SSw.^2);
if (nr>1)
    dfw=png*(nr-1);
    MSw=squeeze(SSw/dfw);
else
    error('(my)anova doesn''t work with 1 subject / group!')
end

% Population stats
%Total number of freedom
dft=(png*nr)-1;
mX=reshape(mXw, [png, szd]);
% Mean value of DV per subject
mX=sum(mX,1)./png;

% Useful value:
sX2=sum(reshape(X, [png*nr, szd]),1).^2./(png*nr);

% These are not used afterwards
SSt=sum(reshape(X, [png*nr, szd]).^2,1);
SSt=SSt-sX2;
MSt=squeeze(SSt/dft);

error
unterminated program!!!

if ~isempty(rp)
    % Correct Within Error term to account for repeated measurements
    dfr=(nr-1);
    mXr=permute(X, [nf+1 1:nf nf+2:nX]);
    mXr=reshape(mXr,nr,png,pszd);
    mXr=mean(mXr,2);
    % SSr=png*sum((reshape(mXr, nr, szd) - repmat(mX,[nr 1])).^2);
    SSr=png*(sum(reshape(mXr, nr, szd).^2,1) - mX2);
    SSw=SSt-SSr;
end

fx={};
for i=1:nf
    fx=[fx ; num2cell(nchoosek(1:nf,i),2)];
end
nfx=length(fx);

% Sphericity checking
if isnan(epsilon)
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

% [p,F,fx,epsilon(1),df(2),dfe(3),SS(4),SSe(5),SSt(6)]=...
if nargout >  3
    varargout{1}=epsilon;
end
if nargout >  8
    varargout{6}=SSt;
end

for i=1:length(fx)
    j=fx{i};
    % Between groups stats for each factor
    dfb=prod(ng(j)-1);
    mXb=permute(mXw, [j setdiff(1:nf,j) nf+1:nX]);
    mXb=reshape(mXb, prod(ng(j)),png/prod(ng(j)), []);
    mXb=mean(mXb,2);
    SSb=nr*png/prod(ng(j))*sum((reshape(mXb, prod(ng(j)), []) - repmat(mX,[prod(ng(j)) 1])).^2);
    if length(j)>1
        % Interaction:
        % we need to remove single factor variance from the Sum of Squares
        for k=1:i-1
            if all(ismember(fx{k}, j))
                SSb=SSb-SS(k,:);
            end
        end
    end
    SS(i,:)=SSb;
    MSb=SSb./dfb;

    if not(isempty(rp))
        % Correct Error term to account for repeated measurements
        if length(j)==1
            dfe=(nr-1)*dfb;
            mXe=permute(X, [nf+1 j setdiff(1:nf,j) nf+2:nX]);
            mXe=reshape(mXe,nr*prod(ng(j)),png/prod(ng(j)),[]);
            mXe=mean(mXe,2);
            SSe=png/prod(ng(j))*sum((reshape(mXe, nr*prod(ng(j)), []) - repmat(mX,[nr*prod(ng(j)) 1])).^2);
            SSe=SSe-SSr-SSb;
            SSbe(i,:)=SSe;
        else
            % Interaction effects residuals
            %
            %   WARNING !!!!
            %
            % the following does NOT work for more-than-2-factors design!
            %
            dfe=(png-sum(ng-1)-1)*(nr-1);
            mXe=reshape(X,png*nr,[]);
            SSe=sum((mXe - repmat(mX,[nr*png 1])).^2);
            SSe=SSe-SSr-sum(SSbe(1:nf,:))-sum(SS(1:nfx,:));
        end
        MSe=squeeze(SSe/dfe);
        MSr=squeeze(SSr/dfr);
        dfb=dfb.*epsilon(i,:);
        dfe=dfe.*epsilon(i,:);
        F(i,:)=squeeze(MSb)./MSe;
        p(i,:)=1-f_cdf(F(i,:),dfb,dfe);
    else
        dfb=dfb.*epsilon(i,:);
        dfw=dfw.*epsilon(i,:);
        F(i,:)=squeeze(MSb)./MSw;
        p(i,:)=1-f_cdf(F(i,:),dfb,dfw);
    end
    % [p,F,fx,epsilon(1),df(2),dfe(3),SS(4),SSe(5),SSt(6)]=...
    if nargout>4
        varargout{2}(i,:)=dfb;
    end
    if nargout>5
        if not(isempty(rp))
            varargout{3}(i,:)=dfe;
        else
            varargout{3}(i,:)=dfw;
        end
    end
    if nargout>6
        varargout{4}(i,:)=SSb;
    end
    if nargout>7
        if not(isempty(rp))
            varargout{5}(i,:)=SSe;
        else
            varargout{5}(i,:)=SSw;
        end
    end
end

if prod(sX)>png*nr
    p=reshape(p,[nfx,sX(nf+2:end)]);
    F=reshape(F,[nfx,sX(nf+2:end)]);
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

%% RESSOURCES
% http://www.brown.edu/Research/LCE/Fall2004/Within%20subjs.pdf
%

%% EXAMPLES
%
% from Zar, 1999, pp. 250 sqq.
% Ex. 12.5 repeated measure ANOVA
X= [
    164 152 178
    202 181 222
    143 136 132
    210 194 216
    228 219 245
    173 159 182
    161 157 165
    ]';
% F= 727/57.94 = 12.6

% http://www.richland.edu/james/lecture/m170/ch13-2wy.html
% SS = 512.8667  449.4667   143.1333  136.0000  1241.4667
% F  = 3.682 3.056 2.641
X=[
    106, 110 , 95, 100 , 94, 107 , 103, 104 , 100, 102;
    110, 112 , 98, 99 , 100, 101 , 108, 112 , 105, 107;
    94, 97, 	86, 87 	98, 99 	99, 101 	94, 98];
X=cat(3,X(:,1:2:end),X(:,2:2:end))




% % http://www.linguistics.ucla.edu/faciliti/facilities/statistics/fromoac.htm
% X=[  8  9  8   8  9   7   10  9  10;  9  10 9  10  9  13   8   9   9;  8  7  7  12  7   9   10  9   7;  6  8  9   8 10  10   12  9   10;  7  6  7  11 12   8   8   11  9];
% X=reshape(X,5,3,3);
%
% % COND TRIAL SUBJECT
% X=permute(X,[3 2 1]);
%
% [p,F]=myanova(X,2,1:2)
% l=factorlabels(X)
% rm_anova2(X(:), l(:,3),l(:,1),l(:,2),{'COND', 'TRIAL'})
% %     'Source'                 'SS'         'df'    'MS'         'F'         'p'     
% %     'COND'                   [24.8444]    [ 2]    [12.4222]    [4.0216]    [0.0618]
% %     'TRIAL'                  [ 0.3111]    [ 2]    [ 0.1556]    [0.0625]    [0.9399]
% %     'COND x TRIAL'           [ 1.6889]    [ 4]    [ 0.4222]    [0.1907]    [0.9397]
% %     'COND x Subj'            [24.7111]    [ 8]    [ 3.0889]          []          []
% %     'COND x Subj'            [19.9111]    [ 8]    [ 2.4889]          []          []
% %     'COND x TRIAL x Subj'    [35.4222]    [16]    [ 2.2139]          []          []

    