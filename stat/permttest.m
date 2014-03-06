function [pv,S0,P,PS]=permttest(X,X2,dim_p,dim_m,NP,TimeBar,tails)
% permttest - Two-sided permutation pseudo T-test
%   [pv,T,P,PS] = permtest2(X1,X2,dimP,dimM,NP,TimeBar,tails)
%   [pv ...     ] = permtest2(X ,N1,dimP,...)
%
%   Performs a two-sided permutation pseudo T-test with the data, testing
%   the following HO hypothesis:
%           mean(X1) = mean(X2)
%
%MANDATORY INPUTS:
%  X1,X2: [N1 x Ma x Mb...] and [ N2 x Ma x Mb x...] Multidimensional matrices
%         of Ni samples/subjects for each group, eg. [ Subjects x Channel x Time ]
%  Alternatively:
%         X can be a single data matrix. But the number of samples (ie subjects)
%         in the first group should be set using 'N1'
%         I.e.   X = [ X1 ; X2 ]  &  N1=size(X1,1)
%         If N1<0 , define the dimension of the two samples   
%
%OPTIONAL INPUTS (use [] for default values):
%  dimP: Permuted dimensions (ie. subjects). Default: first non singleton
%        If dim_p > 0 : paired permutations (default)
%        Use negative dim_p for unpaired samples/subjects
%  dimM: Dimensions of data across which the maximum T-value is computed.
%        For multidimensional data, eg. [ Subject x Channel x Time ],
%        control of Family-wise Error Rate requires to compute T-value
%        across all dimensions (starting after the permuted one. 
%        Default is: all dimensions besides the "permuted" dimensions
%        (typically: [2 3 ... ndims(X)])
%  NP: Number of permutations (may be reduced if bigger than the number of permutations,
%      for example if NP > 2^N-1 using paired data)
%      If not specify, permttest uses 10000 (at most). 
%      Set NP=inf so to enforce exhaustive permutations, ie. all possible permutations
%      (this may lead to HUGE numbers of permutations, avoid with unpaired tests)
%  TimeBar: 1 (default) or 0. To display a progress bar.
%  tails: 1- (one: X1>X2) or 2- (two: X1<X2 or X1>X2) tailed test (default: 2)
%
%OUTPUTS:
%   pv: (Approximate) p-values of the observed data, computed from the permutations
%   T: [Ma x Mb...] Observed pseudo T-values
%   P:  [NP x (N1+N2)] List of permutations used
%   PS: [P x Ma x Mb... ] Matrix of permutation statistics (may be quite big!)
%
% Author: Karim N'Diaye, CNRS UPR640
% Created: Sep 2005

% NOT YET:

% P-value normalization:
%        To normalize distribution on a given dimension, use negative
%        values in dimM. E.g. to normalize across space: dimM=[1 -2] or [ 1 2 -2] 
%        (order/repetition has no importance)
%        See: Pantazis et al., NeuroImage, 2005
%
%  tails: 1 for one-sided [ X1>X2 ]
%         2 (default) two-sided test [ X1<X2 OR X1>X2 ]
%  ftest: function applied on data.
%         Default is 'maxabst', i.e. compute the maximum (two-tailed) T-value
%  fparams: cell array indicating the parameters passed to the function
%           when called

NMAX_UNPAIRED=15; %  maximum number of observations for exhaustive search for unpaired samples
NMAX_PAIRED=30;  %  maximum number of observations for exhaustive search in paired samples
NMAX_SUBJECTS=1000; % Max number of subjects
NPERMS=9999; % Default number of permutations

%initialize parameters
if nargin<3
    dim_p=[];
end
if nargin<4
    dim_m=[];
end
if nargin<5
    NP=[];
end
if nargin<6
    TimeBar=1; % KJ, default is off now...
end
if nargin<7
    tails=[];
end

if isempty(tails)
    tails=2;
end
if ~isequal(tails,1) && ~isequal(tails,2)
    error('Tails can be 1 or 2')
end

if isempty(dim_p)
        dim=find(size(X)>1);
    if isempty(dim)
        error('Input X has only singleton or null dimensions!')
    end
    dim=dim(1);
    dim_p=dim;
end
dim=abs(dim_p);

% ORIGINAL OBSERVATIONS
% Data in X (and possibly in X2) will be concatenated (if needed) and
% reshaped so that folowing computations are made easier.
ndX=ndims(X);
dX1=setdiff(1:ndX,dim);
sX0=size(X);
% Put subjects in the first dimension
X=permute(X, [dim dX1]);
sX=size(X);
if numel(X2)>1 % X2 is a matrix
    X2=permute(X2, [dim dX1]);
    sX2=size(X2);
    if ~isequal(sX(2:end), sX2(2:end))
        error('X1 and X2 should be of the same size in the non-permuted dimensions!')
    end
    if dim_p>0 & sX(1) ~= sX2(1)
        error('X1 and X2 should have the same number of observations/subjects for paired data!')
    end
    X=cat(1,X,X2);
    N=[sX(1) sX2(1)];
    clear sX2;
elseif numel(X2)==1 
    if X2>0
        % X2 is the number of samples in the first group
        N=[X2 sX0(1)-X2];
    elseif sX0(-X2)==2
        % X2 is the dimension defining the two samples
        pX2=1:ndims(X);
        pX2(-X2+(-X2<dim))=[];
        X=permute(X, [1 -X2+(-X2<dim) pX2(2:end)]);
        N=[sX0(dim_p) sX0(dim_p)];
        sX2=[size(X) 1];
        X=reshape(X,[N(1)+N(2) sX(3:end) 1]);
        sX( -X2+(-X2<dim))=1;
    else
        error('Sample defining dimension should have only two levels, ie two groups')
    end
else
    error('Check inputs!')
end
clear X2;
if sum(N)>NMAX_SUBJECTS
    error('Too many subjects!')
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
dim_m=dim_m+(dim_m<dim & dim_m>0);

% Define a practical shape for the measurement data 
% (so that the maximum across dimension is easy to compute)
if dim_m==0    
    nsX=[1 sX(2:end)];
else
    X=permute(X,[1 dim_m setdiff(2:ndX, dim_m)]);
    nsX=[prod(sX(dim_m)) sX(setdiff(2:ndX, dim_m)) 1];
end

% Now compute the number of exhaustive permutations
if dim_p>0
    if tails==2
    % We compute only one half of the permutations for paired samples
    Nexh=2^(N(1)-1)-1;
    else
        Nexh=2^(N(1))-1;
    end
else
    Nexh=factorial(N(1)+N(2))/(factorial(N(1))*factorial(N(2)))-1;
end

exhaustive=0;
if isempty(NP)
    if (dim_p>0 && (N(1)+N(2))<NMAX_PAIRED ) || ...
            (dim_p<0 && (N(1)+N(2))<NMAX_UNPAIRED )
        NP=Nexh;
        exhaustive=1;    
    else
        NP=NPERMS;
        exhaustive=0;
    end
else
    if NP<Nexh & NP<NPERMS
		if TimeBar
			warning(sprintf('You are under-sampling! For this dataset, the possible number of permutations is: %d.',Nexh));
		end
	elseif isequal(NP, inf)
		if TimeBar
			disp(sprintf('You have requested exhaustive permutations: %d.',Nexh));
		end
		NP=Nexh;
		exhaustive=1;
	elseif NP>Nexh
		if TimeBar
			warning(sprintf('You are over-sampling! For this dataset, the maximum number of permutations is: %d.',Nexh));
		end
    elseif NP==Nexh;
        exhaustive=1;
    end
end
% if NP>NPERMS
%     warning(sprintf('Too many permutations! Only %d will be performed.',NPERMS));
%     NP = NPERMS;
%     exhaustive=0;
% end
% DEBUG:
% NP = min(500,NP);


% List of permutations
if dim_p>0
    % paired permutations
    if exhaustive
        % compute exhaustive list of perms
        P=49==(dec2bin(1:NP,N(1)));
    else
        % non exhaustive
        P=round(rand(NP,N(1)));                
    end
    P=[P 1-P].*N(1)+repmat(1:N(1), [NP,2]);
else
    % non-paired perms
    if exhaustive % do all possible perms
        p=nchoosek(1:(N(1)+N(2)),N(1));
        p(1,:)=[]; % the 1st is not a permutation
        for i=1:NP
            P(i,:)=[p(i,:) setdiff(1:(N(1)+N(2)),p(i,:))];
        end
        clear p
    else % non exhaustive        
        [ignore,P]=sort(rand(NP,N(1)+N(2)),2);
    end
end

if TimeBar
    try
        htimer = timebar('Permutation Statistics','Progress...');
    catch
        warning('Function timebar.m missing. waitbar.m is used instead')
        htimer = waitbar(0,'Permutation Statistics');    end
else
    htimer = NaN;
end

% PERMUTATION LOOP
for i=0:NP
    if i==0
        % At the 0-th permutation, evaluate original data
        Y=X;
    else
        Y=X(P(i,:),:);
    end
    
%     Z=mean(Y(1:N(1),:),1)-mean(Y(N(1)+(1:N(2)),:),1);
%     Z= Z ./ sqrt( std(Y(1:N(1),:),[],1).^2/N(1) + std(Y(N(1)+(1:N(2)),:),[],1).^2/N(2));    
    Z=tvalue(Y(1:N(1),:),Y(N(1)+(1:N(2)),:));
    Z=reshape(Z,nsX);
    
    if i==0
        S0=Z;
        sz=size(S0);
        S=zeros(sz);
        if nargout>3
			pack;
            PS=zeros([NP sz(2:end) 1],'single');
        end
    else
        if tails==2
            Z=abs(Z);
        end
        Z=max(Z,[],1);        
        if nargout>3
            PS(i,:)=Z(:)';
        end
        if tails==2
            S=S+(repmat(Z,[nsX(1) 1])>=abs(S0));
        else
            S=S+(repmat(Z,[nsX(1) 1])>=S0);
        end
        if ishandle(htimer),try,if isequal(get(htimer, 'tag'), 'timebar'), timebar(htimer,i/NP),else,waitbar(i/NP,htimer);end;catch,end,end
    end
end

% Compute p-values
pv=(S+1)/(NP+1);
if ~isequal(dim_m, 0)
    pv=reshape(pv, [sX([dim_m setdiff(2:ndX,dim_m)]) 1]);
    S0=reshape(S0, [sX([dim_m setdiff(2:ndX,dim_m)]) 1]);
    if ndX>2
        pv=ipermute(pv, [dim_m-1 setdiff(1:ndX-1, dim_m-1)]);
        S0=ipermute(S0, [dim_m-1 setdiff(1:ndX-1, dim_m-1)]);
    end
else
    pv=reshape(pv, [sX(2:end) 1]);
    S0=reshape(S0, [sX(2:end) 1]);
end
if nargout>3
    PS=reshape(PS, [NP nsX(2:end)]);
end
if ishandle(htimer),try,close(htimer),end,end
return


% Validation:
X1=randn(100,1);
X=X1+0.2+randn(size(X1));
% Paired case:
[p,K,P,PS]=permttest(X1,X,1,[],999,0);p
myttest(X1,X,1,'pttest')
% Unpaired (unequal variance)
[p,K,P,PS]=permttest(X1,X,-1,[],999,0);p
myttest(X1,X,1,'uttest')