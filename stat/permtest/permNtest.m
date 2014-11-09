%function [pv,S0,NP,PS,P]=permXtest(X,stat,dim_p,dim_m,NP,TimeBar,tails,varargin)
error('Not finished!')


function [pv,K0,P,PS]=permNtest(X,fun,varargin)
% permNtest - Generic N-way permutation test
%   [pv,K,P,PS] = permNtest(X,funstat,dimP,dimM,NP,TimeBar)
%
%   Performs a permutation test with the data analoguous to 
%   a one-way ANOVA testing the hypothesis H0: 
%       All groups X1, X2, ... have the same mean
%
%MANDATORY INPUTS:
%  X={X1 , ... Xi, ... Xn}: a cell array of [Ni x Ma x Mb...] data matrices.
%  Alternatively:
%         X can be a single data matrix. But the number of samples (ie subjects)
%         in each condition should be set using 'grp'
%         I.e.    X = [ X1 ; X2 ; X3]  
%               grp = [ size(X1,1) size(X2,1) size(X3,1) ];
%
%OPTIONAL INPUTS (use [] for default values):
%  funstat: the statistic function to use, eg. 
%  dimP: Permuted dimensions (ie. subjects). Default: first non singleton
%        If dim_p > 0 : within-subject permutations (used as default)
%        Use -dim_p for unpaired samples/subjects
%  dimM: Dimensions of data across which the maximum T-value is computed.
%        Default is: all dimensions besides the "permuted" dimensions
%        (typically: [2 3 ... ndims(X)])
%  NP: Number of random permutations. (Default: 10000)
%  TimeBar: if not 0, a progression time bar is displayed (default: 1)
%
%OUTPUTS:
%   pv: (Approximate) p-values of the observed data, computed from the permutations
%   K: [Ma x Mb...] Observed Fisher's discriminant values
%   P:  [NP x (N1+N2+...)] List of permutations used
%   PS: [ P x Ma x Mb... ] Matrix of permutation statistics (may be quite big!)
%
% See also: permttest
% Author: Karim N'Diaye, on advice from Jacques Martinerie, CNRS UPR640
% Created: Sep 2005

NPERMS=9999; % Max. number of permutations (instead of 10000 to have nice p values after division by (NP+1))
NMAX_GROUPS=36; % Max. number of groups : cf 'symbols' in dec2base
NMAX_SUBJECTS=1000; % Max number of subjects

%initialize parameters
nparams=nargin-2;
params=varargin(1:nparams);

if nparams<1
    dim_p=[]; 
else
    dim_p=params{1}; 
end
if nparams<2
    dim_m=[];
else
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
if TimeBar
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
% That is: 
%   X = [ Grp1 ; Grp2 ; ... ]
% N will keep track of the number of samples (ie. subjects) in each
% group: N(i)=size(Grp(i),1) etc. 
if iscell(X)
    Y=X;X=[];
    ndX=ndims(Y{1});
    dX1=setdiff(1:ndX,dim); % non permuted dims
    for i=1:length(Y)
        X=cat(1, X, permute(Y{i}, [dim dX1]));
        N(i)=size(Y{i},dim);
        Y{i}=[];
    end    
else
    ndX=ndims(X);
    dX1=setdiff(1:ndX,dim);
    % Put subjects in the first dimension
    X=permute(X, [dim grp dX1]);
    N=size(X,1)*ones(size(X,2));
end
sX=size(X);
if sum(N)>NMAX_SUBJECTS
    error('Too many subjects!')
end
if dim_p>0 & length(unique(N))>1
    error('Repeated measure design must have the same number of samples in each group')
end
NS=sum(N); % Total Number of samples 
NG=length(N); % Number of groups
if NG>NMAX_GROUPS
    error('Too many groups!')
end

% Default is to compute the maximum T value across all dimensions of the
% measurement data
if isempty(dim_m)
    dim_m=setdiff(1:ndX,dim);
end
dim_m=unique(dim_m(:))';
if max(dim_m)>ndX
    error('Wrong dimM dimensions!')
end
if ismember(dim_p,dim_m)
    error(sprintf('Wrong dimM dimensions: [%d] is already set as the permuted dimension!\n' , dim))
end
dim_m=dim_m+(dim_m<dim && dim_m>0);

% Define a practical shape for the measurement data 
% (so that the maximum across dimension(s) is easy to compute)
if dim_m==0    
    nsX=[sX(2:end) 1];
else
    X=permute(X,[1 dim_m setdiff(2:ndX, dim_m)]);
    nsX=[prod(sX(dim_m)) sX(setdiff(2:ndX, dim_m)) 1];
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

% List of pairwise comparisons between groups
pairs=nchoosek(1:NG,2);
npairs=size(pairs,1);
for j=1:npairs
    for k=1:2
        idx_pairs{j,k}=[1:N(pairs(j,k))]+sum([0 N([1:pairs(j,k)-1])]);
    end
end
for j=1:NG
    % Index of elements in each group
    idx_grp{j}=[1:N(j)]+sum([0 N([1:j-1])]); % index of the group elements
end
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
    Z=zeros([1 nsX]);        
    for j=1:npairs        
        Z=Z+abs(mean(Y(idx_pairs{j,1},:)) - mean(Y(idx_pairs{j,2},:))).^2;
    end    
    Z=Z./npairs;
    % Pooled variance:
    K=zeros([1 nsX]);
    for j=1:NG
        % within-group variance (weighted with group size)       
        K=K+var(Y(idx_grp{j},:),1)*N(j);
    end   
    % Generalized Fisher's discriminant:
    K=Z./K;
    clear Z; % save some memory space
    K=reshape(K,nsX);
    
    if i==0
        K0=K;
        sz=size(K0);
        S=zeros(sz);
        if nargout>3
            PS=zeros([NP sz(2:end) 1]);
        end        
    else
        K=max(K,[],1);        
        if nargout>3
            PS(i,:)=K(:)';
        end
        S=S+(repmat(K,[nsX(1) 1])>=abs(K0));
        if ishandle(htimer),try,if isequal(get(htimer, 'tag'), 'timebar'), timebar(htimer,i/NP),else,waitbar(i/NP,htimer);end;catch,end,end
    end    
end
% Compute p-values
pv=(S+1)/(NP+1);
if ~isequal(dim_m, 0)
    pv=reshape(pv, [sX([dim_m setdiff(2:ndX,dim_m)]) 1]);
    K0=reshape(K0, [sX([dim_m setdiff(2:ndX,dim_m)]) 1]);
    pv=ipermute(pv, [dim_m-1 setdiff(1:ndX-1, dim_m-1)]);
    K0=ipermute(K0, [dim_m-1 setdiff(1:ndX-1, dim_m-1)]);
else
    pv=reshape(pv, [1 sX(2:end) 1]);
    K0=reshape(K0, [1 sX(2:end) 1]);
end
if nargout>3
    PS=reshape(PS, [NP nsX(2:end)]);
end
if ishandle(htimer),try,close(htimer),end,end
return


% % Validated using normally distributed random values:
%
% X1=randn(50,1); 
% [p,K,P,PS]=permftest({X1,X1,X1+.3},-1); 
% % Gives (almost) equal p-values as:
% [pa,Fa]=myanova(cat(1,X1',X1',X1'+.3),1)
% 
% % Unequal number of samples:
% X3=randn(25,1)+.3;
% [p,K,P,PS]=permftest({X1,X3},-1);
% anova(1,[X1;X3], [ones(50,1);2*ones(25,1);])