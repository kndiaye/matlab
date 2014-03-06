function [p,F,fx,varargout]=myanova(X,nf,rp,epsilon,SStype)
% myanova - N-way ANOVA
%   [p,F,fx]=myanova(X,nf)
%   [p,F,fx,epsilon,pomega2,df,dfe,SS,SSe,SSt,peta2]=...
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
%	epsilon: sphericity correction if applicable
%	pomega2: partial omega squared (unbiased estimator of effect size)
%   df: degrees of freedom for each effect
%   dfe: degrees of freedom of error for each effect
%   SS: sum of squares for each effect
%   SSe: sum of squares of error for each effect
%   SSt: Total sum of squares
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
%   Default: epsilon=1
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
% See also: myanovaeffects,

%
%   peta2: (biased) percentage of explained variance by each factor
%   omega2: (unbiased) percentage of explained variance by each factor

% Requires: f_cdf()

SS=[];
SSb=[];
sX=[size(X) 1];
nX=ndims(X);
if nargin<2
    error('Number of factors (nf) is mandatory')
end
if nargin<3
    rp=[];
end
if nargin<4
    epsilon=1;
end
if nargin<5
    SStype=[];
end

fx={};
for i=1:nf
    fx=[fx ; num2cell(nchoosek(1:nf,i),2)];
end
nfx=length(fx);

% Number of groups for each factor
ng=sX(1:nf);
% Number of groups
png=prod(ng);
% Number of replicates, ie. samples in each group
nr=sX(nf+1);
% Number of cells
pnc=prod(ng);
%Number of observations
pno=pnc*nr;
% Dimensions of (pseudo multivariate) dependent variables
svar=[sX(nf+2:end)];

% if ~isempty(rp) & ~all(ismember(1:nf,rp))
%     error('Mixed designs (split plot) ANOVA unavailable!')
% end
% if ~isempty(rp) & nf>2
%     error('Repeated measure ANOVA is only available for 2 factor designs!')
% end

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

% Number of groups in between subjects
pngb=1;
if ~isempty(rp)
    tmp=zeros(1,nf);
    tmp(rp)=1;
    rp=logical(tmp);
    pngb=prod(ng(~rp));
    png=png/pngb;
    % Factors within first, between next
    fxw = [find(rp) find(~rp)];
    % ngw = sX(pfxw);
end
if isempty(SStype)
    if isempty(rp)
        SStype=3;
        error('I dunno which SS type to choose...');
    elseif all(rp)
        SStype=2;
    else
        error('I dunno which SS type to choose...');
    end
end
% Within Group/Error stats
% i.e unmodeled error
mXe=mean(X,nf+1);
SSe=X-repmat(mXe,[ones(1,nf) nr 1]);
SSe=reshape(SSe, [pnc nr svar]).^2;
SSe=sum(sum(SSe));
if (nr<=1)
    error('myanova doesn''t work with 1 subject / group!')
end
dfe=png*(nr-1);
MSe=squeeze(SSe/dfe);
dfe=repmat(dfe, [nfx 1]);

% Population stats
dft=(pno)-1;
mX=reshape(mXe,pnc,[svar]);
mX=mean(mX,1);

if any(rp)
    % Between-Subject Error (to account for repeated measurements)
    mXr=permute(X, [nf+1 fxw nf+2:nX]);
    mXr=reshape(mXr,nr,png,pngb,[]);
    mXr=mean(mXr,2);
    sz=sX;
    sz(rp)=1;
    mXr=reshape(mXr,sz);
    SSr=sum(png*sum((reshape(mXr,[nr pngb svar]) - repmat(mX,[nr pngb 1])).^2));
    dfr=nr*pngb-1;
    %
    %     mXb=permute(X, [nf+1 fxw nf+2:nX]);
    %     mXb=reshape(mXb,nr*png,pngb,[svar]);
    %     mXb=mean(mXb,2);
    %     SSb = sum(pngb*sum((reshape(mXb,[nr png svar]) - repmat(mX,[nr png  1])).^2));
    %
    %     mXb=permute(X, [nf+1 fxw nf+2:nX]);
    %     mXb=reshape(mXb,nr*png,pngb,[svar]);
    %     mXb=mean(mXb);
    %     SSb = sum(nr*png*sum((reshape(mXb,[pngb svar]) - repmat(mX,[pngb  1])).^2));
    %
    %
    %     mXb=permute(X, [nf+1 fxw nf+2:nX]);
    %     mXb=reshape(mXb,nr,png,pngb,[]);
    %     mXr=mean(mXr,2);
    %     sz=sX;
    %     sz(rp)=1;
    %     mXr=reshape(mXr,sz);

    %    SSe=SSe-

end

% Outputs are:
%   [p,F,fx,1:epsilon,2:pomega2,3:df,4:dfe,5:SS,6:SSe,7:SSt,8:peta2]=...
if nargout >= 3+1
    varargout{1}=epsilon;
end
if nargout >= 3+2
    SSt=sum((reshape(X,pno, [])-repmat(mX,[pno 1])).^2);
end

df=zeros(nfx,1);
SS=zeros([nfx svar]);
F=zeros([nfx svar]);
p=zeros([nfx svar]);
for i=1:length(fx)
    j=fx{i};
    % Between groups stats for each factor
    df(i)=prod(ng(j)-1);
    mXb=permute(mXe, [j setdiff(1:nf,j) nf+1:nX]);
    % Number of levels for this factor
    nl=prod(ng(j));
    mXb=reshape(mXb,nl,pnc/nl,[svar]);
    mXb=mean(mXb,2);
    SS(i,:) = pno/nl      *sum((reshape(mXb, [nl svar]) - repmat(mX,[nl 1])).^2);
%   SSb=nr*png/prod(ng(j))*sum((reshape(mXb, prod(ng(j)), []) - repmat(mX,[prod(ng(j)) 1])).^2);

    
    if length(j)>1
        % Interactions:
        % we need to x  remove single factor variance from the Sum of Squares
        for k=1:i-1
            if all(ismember(fx{k}, j))
                SS(i,:)=SS(i,:)-SS(k,:);
            end
        end
    end
    MS=SS(i,:)./df(i);

    % Now corrects Error term to account for repeated measurements
    if any(rp(j))
        if length(j)==1
            dfe(i)=(nr-1)*df(i);
            mXer=permute(X, [nf+1 j setdiff(1:nf,j) nf+2:nX]);
            mXer=reshape(mXer,nr*nl,png/nl,[svar]);
            mXer=mean(mXer,2);
            SSe(i,:)=png/nl*sum((reshape(mXer, nr*nl, []) - repmat(mX,[nr*nl pngb 1])).^2);
            SSe(i,:)=SSe(i,:)-SSr-SS(i,:);
            %SSbe(i,:)=SSe;
        else
            % Interaction effects residuals
            %
            %   WARNING !!!!
            %
            % the following does NOT work for more-than-2-factors design!
            %
            dfe(i)=(png-sum(ng-1)-1)*(nr-1);
            mXer=reshape(X,pno,[]);
            SSe(i,:)=sum((mXer - repmat(mX,[nr*png 1])).^2);
            SSe(i,:)=SSe(i,:)-SSr-sum(SSe(1:nf,:))-sum(SS(1:nfx,:));
        end
        MSe=squeeze(SSe(i,:)./dfe(i));
    end
    % Apply d.f. correction if needed
    df(i)=df(i).*epsilon(i,:);
    dfe(i)=dfe(i).*epsilon(i,:);
    % Compute F-value and gets the probability
    F(i,:)=squeeze(MS)./MSe;
    p(i,:)=1-f_cdf(F(i,:),df(i),dfe(i));
    % Outputs (if requested) are:
    %   [p,F,fx,1:epsilon,2:pomega2,3:df,4:dfe,5:SS,6:SSe,7:SSt,8:peta2]=...
    if nargout >= 3+2  %3+6
        % We also need SSe to compute partial omega2 at the end
        varargout{6}(i,:)=SSe;
    end

end
% reshape data to match input
if prod(sX)>pno
    p=reshape(p,[nfx,sX(nf+2:end)]);
    F=reshape(F,[nfx,sX(nf+2:end)]);
end
% Process outputs
if nargout >= 3+2
    % partial omega squared
    SSe=varargout{6};
    MSe=SSe./dfe;
    varargout{2}=(SS-df.*MSe)./(SSt+(png-df).*MSe);
end
if nargout >= 3+3
    varargout{3}=df;
end
if nargout >= 3+4
    varargout{4}=dfe;
end
if nargout >= 3+5
    varargout{5}=SS;
end
% if nargout >= 3+6 : cf supra
if nargout >=  3+7
    % SSt = SS total
    varargout{7}=SSt;
end
if nargout >= 3+8
    % partial eta squared
    varargout{8}=SS./(SS+SSe);
end
if nargout >= 3+9
    % omega squared
    varargout{9}=(SS-df.*MSe)./(SSt+MSe);
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
    %    MS(nfx+3,:)=        MSr=squeeze(SSr/dfr);;
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
% %     'COND x Subj'            [19.9111]    [ 8]    [ 2.4889]          []          []
% %     'COND x TRIAL x Subj'    [35.4222]    [16]    [ 2.2139]          []          []


%% DATA Eysenck 1974
% http://web.uccs.edu/lbecker/Psy590/es.htm
% http://homepages.gold.ac.uk/aphome/GLM%20Simple%20Main%20Effects.html
% Counting    Rhyming Adjective Imagery   Intentional
X=[
    9   7   11  12  10
    8   9   13  11  19
    6   6   8   16  14
    8   6   6   11  5
    10  6   14  9   10
    4   11  11  23  11
    6   6   13  12  14
    5   3   13  10  15
    7   8   10  19  11
    7   7   11  11  11
    ];

% Eysenck 1974 OLD/YOUNG
%
X=urlread('http://forrest.psych.unc.edu/research/vista-frames/help/lecturenotes/lecture10/eysenck.xli');
X='DATA "Eysenck" :TITLE "Eysenck" :ABOUT "Eysenck study of recall ability of subjects who were young (Y - 18-30 years old) or old (O - 55-65 years old) for recall conditions involving Counting, Rhyming, Adjectives, Imagery or Intentional. From Howell, David C., (Ed. 3) p. 325." :VARIABLES (QUOTE ("Recall" "Age" "Condition")) :TYPES (QUOTE ("Numeric" "Category" "Category")) :LABELS (QUOTE ("Obs0" "Obs1" "Obs2" "Obs3" "Obs4" "Obs5" "Obs6" "Obs7" "Obs8" "Obs9" "Obs10" "Obs11" "Obs12" "Obs13" "Obs14" "Obs15" "Obs16" "Obs17" "Obs18" "Obs19" "Obs20" "Obs21" "Obs22" "Obs23" "Obs24" "Obs25" "Obs26" "Obs27" "Obs28" "Obs29" "Obs30" "Obs31" "Obs32" "Obs33" "Obs34" "Obs35" "Obs36" "Obs37" "Obs38" "Obs39" "Obs40" "Obs41" "Obs42" "Obs43" "Obs44" "Obs45" "Obs46" "Obs47" "Obs48" "Obs49" "Obs50" "Obs51" "Obs52" "Obs53" "Obs54" "Obs55" "Obs56" "Obs57" "Obs58" "Obs59" "Obs60" "Obs61" "Obs62" "Obs63" "Obs64" "Obs65" "Obs66" "Obs67" "Obs68" "Obs69" "Obs70" "Obs71" "Obs72" "Obs73" "Obs74" "Obs75" "Obs76" "Obs77" "Obs78" "Obs79" "Obs80" "Obs81" "Obs82" "Obs83" "Obs84" "Obs85" "Obs86" "Obs87" "Obs88" "Obs89" "Obs90" "Obs91" "Obs92" "Obs93" "Obs94" "Obs95" "Obs96" "Obs97" "Obs98" "Obs99")) :DATA (QUOTE (9 "O" "C" 8 "O" "C" 6 "O" "C" 8 "O" "C" 10 "O" "C" 4 "O" "C" 6 "O" "C" 5 "O" "C" 7 "O" "C" 7 "O" "C" 7 "O" "R" 9 "O" "R" 6 "O" "R" 6 "O" "R" 6 "O" "R" 11 "O" "R" 6 "O" "R" 3 "O" "R" 8 "O" "R" 7 "O" "R" 11 "O" "A" 13 "O" "A" 8 "O" "A" 6 "O" "A" 14 "O" "A" 11 "O" "A" 13 "O" "A" 13 "O" "A" 10 "O" "A" 11 "O" "A" 12 "O" "I" 11 "O" "I" 16 "O" "I" 11 "O" "I" 9 "O" "I" 23 "O" "I" 12 "O" "I" 10 "O" "I" 19 "O" "I" 11 "O" "I" 10 "O" "IN" 19 "O" "IN" 14 "O" "IN" 5 "O" "IN" 10 "O" "IN" 11 "O" "IN" 14 "O" "IN" 15 "O" "IN" 11 "O" "IN" 11 "O" "IN" 8 "Y" "C" 6 "Y" "C" 4 "Y" "C" 6 "Y" "C" 7 "Y" "C" 6 "Y" "C" 5 "Y" "C" 7 "Y" "C" 9 "Y" "C" 7 "Y" "C" 10 "Y" "R" 7 "Y" "R" 8 "Y" "R" 10 "Y" "R" 4 "Y" "R" 7 "Y" "R" 10 "Y" "R" 6 "Y" "R" 7 "Y" "R" 7 "Y" "R" 14 "Y" "A" 11 "Y" "A" 18 "Y" "A" 14 "Y" "A" 13 "Y" "A" 22 "Y" "A" 17 "Y" "A" 16 "Y" "A" 12 "Y" "A" 11 "Y" "A" 20 "Y" "I" 16 "Y" "I" 16 "Y" "I" 15 "Y" "I" 18 "Y" "I" 16 "Y" "I" 20 "Y" "I" 22 "Y" "I" 14 "Y" "I" 19 "Y" "I" 21 "Y" "IN" 19 "Y" "IN" 17 "Y" "IN" 15 "Y" "IN" 22 "Y" "IN" 16 "Y" "IN" 22 "Y" "IN" 22 "Y" "IN" 18 "Y" "IN" 21 "Y" "IN")) :DATASHEET-ARGUMENTS (QUOTE ((420 475) (511 120) 2 8)))';
X=strread(X, '%s', 'delimiter', ' ');
X=X(160:3:end-8)
X{1}(1)=[];
X=str2num(strvcat(X));
X=reshape(X,10,5,2);
X=permute(X,[3 2 1]); % AGE x COND x SUBJ


% Migraine Headache
% http://core.ecu.edu/psyc/wuenschk/SPSS/SPSS-Data.htm
X= [
    21	      22	       8	       6	       6
    20	      19	      10	       4	       9
    7	       5	       5	       4	       5
    25	      30	      13	      12	       4
    30	      33	      10	       8	       6
    19	      27	       8	       7	       4
    26	      16	       5	       2	       5
    13	       4	       8	       1	       5
    26	      24	      14	       8	      17
    ];
% Howell Table 14.3
X= [
    21	      22	       8	       6	       6
    20	      19	      10	       4	       4
    17	      15	       5	       4	       5
    25	      30	      13	      12	       17
    30	      27	      13	       8	       6
    19	      27	       8	       7	       4
    26	      16	       5	       2	       5
    17	      18	       8	       1	       5
    26	      24	      14	       8	       9
    ];


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


%
X = [
    92
    90
    92
    91
    90

    70
    70
    71
    70
    72

    90
    90
    92
    94
    91

    87
    82
    81
    84
    85

    66
    65
    67
    69
    71

    62
    59
    58
    60
    59

    88
    88
    83
    82
    88

    85
    85
    82
    84
    83
    ];
X=permute(reshape(X,[5 2 2 2]), [4 3 2 1]);


% http://www.ou.edu/faculty/M/Jorge.L.Mendoza-1/psy5013/twoway-repeated.sas
% [Traning]	[Males: Pre	Post FU6 FU12] [Females: Pre Post FU6 FU12]
X = [
    1	7	22	13	14  0   6   22  26
    1	25	10	17	24  0   16  12  15
    1	50	36	49	23  0   8   0   0
    1	16	38	34	24  15  14  22  8
    1	33	25	24	25  27  18  24  37
    1	10	7	23	26  0   0   0   0
    1	13	33	27	24  4   27  21  3
    1	22	20	21	11  26  9   9   12
    1	4	0	12	0   0   0   14  1
    1	17	16	20	10  0   0   12  0
    0	0	0	0	0   15  28  26  15
    0	69	56	14	36  0   0   0   0
    0	5	0	0	5   6   0   23  0
    0	4	24	0	0   0   0   0   0
    0	35	8	0	0   25  28  0   16
    0	7	0	9	37  36  22  14  48
    0	51	53	8	26  19  22  29  2
    0	25	0	0	15  0   0   5   14
    0	59	45	11	16  0   0   0   0
    0	40	2	33	16  0   0   0   0
    ];
X=reshape(X(:,2:end),[10,2,4 2]);
X=permute(X, [2 3 4 1]);
[p,F,fx,epsilon,pomega2,df,dfe,SS,SSe,SSt,peta2,omega2]=myanova(X,3,2)


% http://www.psych.northwestern.edu/help/systat/Syst.facmix.html
% subject	Smoking	High Stress	Low Stress
% 1 	light 	8	1
% 2 	light 	7	1
% 3 	heavy 	6	8
% 4 	heavy 	5	6
% 5 	light 	8	3
% 6 	light 	10	1
% 7 	heavy 	6	7
% 8 	light 	9	2
% 9 	heavy 	8	10
% 10 	light 	9	2
x=[
    1   8	1
    1   7	1
    2   6	8
    2 	5	6
    1  	8	3
    1 	10	1
    2 	6	7
    1 	9	2
    2 	8	10
    1 	9	2
    ];
%X=reshape(X,
[i,nl]=dgrouping([ [x(:,1);x(:,1)],[repmat(1,10,1);repmat(2,10,1)]]);
[i,nl]=dgrouping([ [[1:10]';[1:10]'] [x(:,1);x(:,1)],[repmat(1,10,1);repmat(2,10,1)]]);
X=NaN*zeros(nl);

%http://www.isogenic.info/html/example_2.html http://www.isogenic.info/html/example_2.html
% Strain    EROD    Treatm  Block
x=[
    1   18.7    1   1
    2   17.9    1   1
    3   19.2    1   1
    4   26.3    1   1
    1   7.7     2   1
    2   8.4     2   1
    3   9.8     2   1
    4   9.7     2   1
    1   16.7    1   2
    2   14.4    1   2
    3   12.0    1   2
    4   19.8    1   2
    1   6.4     2   2
    2   6.7     2   2
    3   8.1     2   2
    4   6.0     2   2
    ]
[i,nl]=dgrouping(x(:,[1 3 4]))
X=NaN*zeros(nl);
X(i)=x(:,2);
%In this case a three-way ANOVA with strain and treatment being fixed
%effects (determined by the experimentalist) and the block being a random
%factor (i.e. not a specific treatment).
%
% Source         DF        SS       MS      F      P
% Block           1       47.610  47.610  18.37 0.004
% Strain          3       32.962  10.988   4.24 0.053
% Trt             1      422.303 422.303 162.96 0.000
% Strain*Trt      3       40.343  13.448   5.19 0.034
% Error           7       18.140   2.591
% Total          15      561.358


% ABRDATA.TAB from OpenStat
% http://www.statpages.org/miller/openstat/Analyzing%20Data%20with%20Stats4U.pdf
% Row	Col	C1	C2	C3	C4
X=[
    1.00	1.00	18.00	14.00	12.00	6.00
    1.00	1.00	19.00	12.00	8.00	4.00
    1.00	1.00	14.00	10.00	6.00	2.00
    1.00	2.00	16.00	12.00	10.00	4.00
    1.00	2.00	12.00	8.00	6.00	2.00
    1.00	2.00	18.00	10.00	5.00	1.00
    2.00	1.00	16.00	10.00	8.00	4.00
    2.00	1.00	18.00	8.00	4.00	1.00
    2.00	1.00	16.00	12.00	6.00	2.00
    2.00	2.00	19.00	16.00	10.00	8.00
    2.00	2.00	16.00	14.00	10.00	9.00
    2.00	2.00	16.00	12.00	8.00	8.00
    ];
X=reshape(X(:,3:end), [3 2 2 4]);
X=permute(X,[2 3 4 1]);

% SOURCE DF SS MS F PROB.
% Between Subjects 11 181.000
% A Effects 1 10.083 10.083 0.978 0.352
% B Effects 1 8.333 8.333 0.808 0.395
% AB Effects 1 80.083 80.083 7.766 0.024
% Error Between 8 82.500 10.312
% Within Subjects 36 1077.000
% C Replications 3 991.500 330.500 152.051 0.000
% AC Effects 3 8.417 2.806 1.291 0.300
% BC Effects 3 12.167 4.056 1.866 0.162
% ABC Effects 3 12.750 4.250 1.955 0.148
% Error Within 24 52.167 2.174
% Total 47 1258.000

function [SS,df]=sumofsquares(X,f1,nf,mX)
sX=size(X);
f2=setdiff(1:nf+1,f1);
mXf = permute(X, [f1 f2 nf+2:ndims(X)]);
mXf = reshape(mXf,prod(sX(f1)),prod(sX(f2)),[]);
mXf = mean(mXf,1);
SS = mXf - repmat(mX,[1 prod(sX(f2)) 1])
%SS = reshape(SS, prod(sX(f2)), []).^2
SS = SS.^2
SS = sum(sum(SS,2),1);
df = prod(sX(f1))