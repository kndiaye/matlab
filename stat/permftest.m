function [pv,fx,F0,P,PS]=permftest(X,dimF,varargin)
% permftest - N-way permutation univariate test (within design only)
%   [pv,F,fx,P,PS] = permktest(X,dimF,dimP,dimM,NP,TimeBar)
%
%   Performs a permutation test with the data analoguous to
%   a one-way ANOVA testing the hypothesis H0:
%       All groups X1, X2, ... have the same mean
%
%MANDATORY INPUTS:
%   X is [ SUBJECT x FACTOR1 x FACTOR2 [...] x MEASURE1 x [...] ]
%   dimF: Dimensions of the factors (in the previous example, with 2 factors: [2 3]
%OPTIONAL INPUTS (use [] for default values):
%   dimP: Permuted dimensions (ie. subjects). Default: first non singleton
%   dimM: Dimensions of data across which the maximum F-value is computed.
%         E.g.Default is: all dimensions besides the "permuted" dimensions
%   NP: Number of random permutations. (Default: 10000)
%   TimeBar: if not 0, a progression time bar is displayed (default: 1)
%OUTPUTS:
%   pv: (Approximate) p-values of the observed data, computed from the permutations
%   fx: List of effects tested
%   F:  [ length(fx) x Ma x Mb...] Observed Fisher's discriminant values
%   P:  [NP x (N1+N2+...)] List of permutations used
%   PS: [ P x Ma x Mb... ] Matrix of permutation statistics (may be quite big!)
%
% See also: permttest, permktest
% Author: Karim N'Diaye, on advice from Jacques Martinerie, CNRS UPR640
% Created: Sep 2005


% We have something like:
% X= [ X(1)11 X(2


%  X={X1 , ... Xi, ... Xn}: a cell array of [Ni x Ma x Mb...] data matrices.
%  Alternatively:
%         X can be a single data matrix. But the number of samples (ie subjects)
%         in each condition should be set using 'grp'
%         I.e.    X = [ X1 ; X2 ; X3]
%               grp = [ size(X1,1) size(X2,1) size(X3,1) ];
%
%OPTIONAL INPUTS (use [] for default values):
%  dimP: Permuted dimensions (ie. subjects). Default: first non singleton
%        If dim_p > 0 : within-subject permutations (used as default)
%        Use -dim_p for unpaired samples/subjects
%  dimM: Dimensions of data across which the maximum T-value is computed.
%        Default is: all dimensions besides the "permuted" dimensions
%        (typically: [2 3 ... ndims(X)])
%  NP: Number of random permutations. (Default: 10000)
%  TimeBar: if not 0, a progression time bar is displayed (default: 1)
%


%   [pv   ...   ] = permktest(X,grp,dimP,dimM,NP,TimeBar)

NPERMS=9999; % Max. number of permutations (instead of 10000 to have nice p values after division by (NP+1))
NMAX_GROUPS=36; % Max. number of groups : cf 'symbols' in dec2base
NMAX_SUBJECTS=1000; % Max number of subjects

% Metrics to be used
% metrics='fisher discriminant';
metrics='euclidian distance';

% Variables used in this script:
% dim_p : subject (ie. samples, observation)  diemsion in the data X
% dim = abs(dim_p)
% dimF = factor dimensions in X (not their size)
% NL : number of levels for each factor, NL=size(X,dimF)
% N : number of obs in each cell (ie group)


%initialize parameters
% if iscell(X)
%     nparams=nargin-1;
%     params=varargin(1:nparams);
% else
%     N=varargin{1};
% end
nparams=nargin-2;
params=varargin(1:nparams);
if nparams<1
    dim_p=[];
else
    dim_p=params{1};
end
if nparams<2,
    dim_m=[];
else,
    dim_m=params{2};
end
if nparams<3
    NP=[];
else
    NP=params{3};
end
if nparams<4
    TimeBar=1;
else
    TimeBar=params{4};
end
if TimeBar %& 0
    try
        htimer = timebar('Permutation Statistics','Progress...');
    catch
        warning('Function timebar.m missing. Use waitbar instead')
        htimer = waitbar(0,'Permutation Statistics');
    end
else
    htimer = NaN;
end

if isempty(dim_p)
    if iscell(X)
        dim=find(size(X{1})>1);
    else
        dim=find(size(X)>1);
    end
    if isempty(dim)
        error('Input X has only singleton or null dimensions!')
    end
    dim=dim(1);
    dim_p=dim;
end
dim=abs(dim_p);

% We will reshape the data X so that groups and subjects make the first
% dimension of X.
% That is for a LETTER x NUMBER :
%   X = [ A1 ; B1 ; ... ; A2 ; B2 ... ]
% N(i,j,k...)  will keep track of the number of samples (ie. subjects) in each
% group: N(1,1)=size(A1) ; N(2,1)=size(B2) etc.

% if iscell(X)
%     Y=X;X=[];
%     ndX=ndims(Y{1});
%     dX1=setdiff(1:ndX,dim); % non permuted dims
%     for i=1:length(Y)
%         X=cat(1, X, permute(Y{i}, [dim dX1]));
%         N(i)=size(Y{i},dim);
%         Y{i}=[];
%     end
% else
ndX=ndims(X);
dX1=setdiff(1:ndX,[dim dimF]);
% Put subjects in the first dimension and factors in the following ones
X=permute(X, [dim dimF dX1]);
sX=size(X);
% Number of factors:
nf=length(dimF);
% Population in each cell:
N=sX(1)*ones(sX(dimF));
NL=sX(dimF); % Number of level in each factor
NG=prod(NL); % Number of cells
NS=sum(N(:)); % Total Number of samples
if NS>NMAX_SUBJECTS
    error('Too many subjects!')
end
if dim_p>0 & length(unique(N))>1
    error('Repeated measure design must have the same number of samples in each group')
end
if NG>NMAX_GROUPS
    error('Too many groups!')
end

% Default is to compute the maximum T value across all dimensions of the
% measurement data
if isempty(dim_m)
    dim_m=setdiff(1:ndX,[dim dimF]);
end
dim_m=unique(dim_m(:))';
if max(dim_m)>ndX
    error('Wrong dimM dimensions!')
end
if ismember(dim_p,dim_m)
    error(sprintf('Wrong dimM dimensions: [%d] is already set as the permuted dimension!\n' , dim))
end
% Reindex dimensions in the new X configuration:
if ~isempty(dim_m)
    dim_m=dim_m+(dim_m<dim)+sum(repmat(dim_m, length(dimF),1) <repmat(dimF', size(dim_m)));
end
dimF=2:(nf+1);

% Define a practical shape for the measurement data
% (so that the maximum across dimension(s) is easy to compute)
dX1=[sX(dim_m) 1];
X=reshape(X, [sum(N(:)) dX1]);
if dim_m==0
    nsX=[1 sX((nf+1):end)];
else
    nsX=[prod(sX(dim_m)) sX(setdiff((nf+2):ndX, dim_m)) 1];
end

% Now compute the number of exhaustive permutations
if dim_p>0
    % Paired case:
    Nexh=factorial(NG)^(N(1))-1;
else
    % Unpaired case:
    n=cumprod(1:max(N(:))); % hand made factorial
    Nexh=factorial(NS)/prod(n(N(:)))-1;
end

% Set the number of perms to be computed
exhaustive=0;
if isempty(NP)
    if Nexh <= NPERMS
        NP=Nexh;
        exhaustive=1;
    else
        NP=NPERMS;
        exhaustive=0;
    end
end

if NP>Nexh
    warning(sprintf('Cannot do %d permutations. For this dataset, the maximum is: %d.',NP, Nexh));
elseif NP==Nexh;
    exhaustive=1;
end

% if NP>NPERMS
%     warning(sprintf('Too many permutations! Only %d will be performed.',NPERMS));
%     NP = NPERMS;
%     exhaustive=0;
% end

% WARNING:
% Creating the exhaustive list of permutations is rather painful and
% quite uninteresteing as we may pretty often be well above 10'000 perms
% (e.g. 3 groups of 6 subjects lead to 46656 perms in a within design!)
% Therefore:
exhaustive=0;

% List of permutations/randomizations
if dim_p>0
    % paired permutations
    if exhaustive
        % compute exhaustive list of perms
        % Within subject perms:
        % Would be: P1=flipud(fliplr(perms(1:NG)));
        % Between subject perms:
        % Something like: P=dec2basen(1:NP,NG,N(1))+1;
        error('no exhaustive search available!')
    else
        % within-subject & between-groups random permutations:
        [ignore,P]=sort(rand(NP,N(1),NG),3);
        % so that, with: group=a, b,...n & subject=1,2,...N
        % P(i,:)= [ a1,a2,...,aN    b1,b2, ... nN ]
        P=(P-1)*N(1)+repmat(reshape(repmat([1:N(1)]',[1,NG]),[1, N(1), NG]), [NP,1]);
    end
else
    % non-paired perms
    if exhaustive % do all possible perms
        error('no exhaustive search available!')
    else % non exhaustive
        [ignore,P]=sort(rand(NP,NS),2);
    end
end

% List of effects and interactions between factors
fx={};
for i=1:nf
    fx=[fx ; num2cell(nchoosek(1:nf,i),2)];
end
nfx=size(fx,1);

% This works only for within design!
idx=reshape(1:NS,[N(1) NL]);

% Now we make up the indices of each group in the first column of X
for i=1:nfx
    % For each effect, we will test, we list all possible pairs of groups
    % Examples:
    %   one factor with 3 levels(1,2,3): 1 vs 2, 1 vs 3, 2 vs 3
    %   2 factors, 3 by 2 interaction: A1/A2 A1/A3 A1/B1 A1/B2 A2/A3 ... B1/B2
    % 
    ngrps{i}=prod(NL(fx{i}));
    %First, all pairs in a given effect (fx{i})
    pairs{i}=nchoosek(1:ngrps{i},2);
    npairs=size(pairs{i},1);
    for j=1:npairs
        % In each pair, get the indices of the first group then those of
        % the second
        for k=1:2
            idx_pairs{i}{j,k}=subarray(idx, [{[] ; -1}  [ num2cell(ind2sub2(NL(fx{i}),pairs{i}(j,k)));  num2cell(fx{i}+1)]]);
        end
    end
    for j=1:ngrps{i}
        % Index of elements in each group
        idx_grp{i}{j}=subarray(idx, [{[] ; -1}  [ num2cell(ind2sub2(NL(fx{i}),j));  num2cell(fx{i}+1)]]);
    end

end
% 
% for j=fx{i} % factor
%     for k=1:NL(j) % level
%         idx_group{i}{j,k}=[1:N(fx{i}(k))]
%     end
%     idx_pairs{j,k}=[1:N(pairs(j,k))]+sum([0 N([1:pairs(j,k)-1])]);
% end
% for j=1:NG
%     % Index of elements in each group
%     idx_grp{j}=[1:N(j)]+sum([0 N([1:j-1])]); % index of the group elements
% end


%
% PERMUTATION LOOP
%
for i=0:NP

    if i==0
        % At the 0-th permutation, evaluate original data
        Y=X;
    else
        Y=X(P(i,:),:);
    end

    % Generalized K-class Fisher's linear discriminant criterion :
    % R. A. Fisher. The statistical utilization of multiple measurements. Ann. Eugen., 8:376-386, 1938.
    % C. R. Rao. The utilization of multiple measurements in problems of biological classification. J. Roy. Stat. Soc. ser. B, 10:159-203, 1948.

    % Between group disparity
    Z=zeros([nfx nsX]);
    % Pooled variance:
    K=zeros([nfx nsX]);    
    switch lower(metrics)
        case 'fisher discriminant'
            for ifx=1:nfx
                npairs=size(pairs{ifx},1);
                for j=1:npairs
                    Z(ifx,:)=Z(ifx,:)+abs(mean(Y(idx_pairs{ifx}{j,1},:)) - mean(Y(idx_pairs{ifx}{j,2},:))).^2;
                end
                Z(ifx,:)=Z(ifx,:)./npairs;
                for j=1:ngrps{ifx}
                    % within-group variance (weighted with group size)
                    K(ifx,:)=K(ifx,:)+var(Y(idx_grp{ifx}{j},:),1)*N(j);
                end
                % Generalized Fisher's discriminant:
                K(ifx,:)=Z(ifx,:)./K(ifx,:);
            end
        case 'euclidian distance'
            [K,K]=myanova(permute(reshape(Y,sX),[dimF,1,(nf+2):ndX]),nf,1:nf);
    end

    clear Z; % save some memory space
    K=reshape(K,[nfx nsX]);

    if i==0
        F0=K;
        sz=size(F0);
        S=zeros(sz);
        if nargout>3
            PS=zeros([NP sz(1) sz(3:end) 1]);
        end
    else
        K=max(K,[],2);
        if nargout>3
            PS(ifx, i,:)=K(:,:)';
        end
        S=S+(repmat(K,[1 nsX(1)])>=abs(F0));
        if ishandle(htimer),try,if isequal(get(htimer, 'tag'), 'timebar'), timebar(htimer,i/NP),else,waitbar(i/NP,htimer);end;catch,end,end
    end
    clear K;
end
% Compute p-values
pv=(S+1)/(NP+1);
pv=reshape(pv, [nfx sX([dim_m setdiff(2:ndX,[dimF dim_m])]) 1]);
F0=reshape(F0, [nfx sX([dim_m setdiff(2:ndX,[dimF dim_m])]) 1]);
if ~isequal(dim_m, 0)
    % permute back to put dimension across which the statistics maximum is
    % computed at their original places
    pv=ipermute(pv, [1 dim_m-nf setdiff(nf:ndX-nf, dim_m-nf)]);
    F0=ipermute(F0, [1 dim_m-nf setdiff(nf:ndX-nf, dim_m-nf)]);
end
if nargout>3
    PS=reshape(PS, [NP nsX(2:end)]);
end
if ishandle(htimer),try,close(htimer),end,end
return


%% Validation using normally distributed random values:
%
% Simulate a design with 2 additive factor
% x=randn(100,4,2);x=x+cumsum(cumsum(ones(size(x)), 3),2)/10;
%
% Parametric 2 way ANOVA (indepentent samples)
% myanova(permute(x, [2 3 1 4 5]),2)
% 
%   [1]:   0.0013
%   [2]:   0.0009
%   [1x2]: 0.2255
%
% anova2(permute(x, [2  3 1]), 2) give the same
% 
% Repeated measures:
% myanova(permute(x, [2 3 1 4 5]),2,1:2)
%     0.0017 , 0.0017  , 0.2212
%
% Permutation test yields:
% permftest(x, [2 3], -1, [],999)
%    0.0040    0.0020    0.0010


