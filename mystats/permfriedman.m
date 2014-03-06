function [p,S0,fx,P] = permfriedman(X,nf,dim_m,NP,rp)
%PERMFRIEDMAN - Permutation test based on Friedman's ANOVA
%   [pv,F,fx,P] = permfriedman(X,nf,dimM,NP,rp)
%
%   Performs permutation test based on Friedman's non-parametric N-wy ANOVA
%
%INPUTS:
%   X: Data matrix should be as follows:
%       X = [ factor1 x factor2 x ... x factorN x Subjects x ...]
%	nf: number of factors.
%	dimM: Dimensions of data over which the maximum T-value is to be found.
%         Default: all dimensions
%	NP: Number of permutations (may lead to exhaustive permutation,
%       for example if NP <= 2^N-1 using paired data)
%   rp: an array listing the repeated factors 
%       Default: full within subject design, ie rp=1:nf
%
%OUPUTS:
%   pv: p-values of the observed data, computed from the permutations
%	F: the F-values of the observed data
%	fx: a cell array listing the tested effects
%   P: List of permutations used
%
%   Example
%       permfriedmann(X,2)
%
%   See also; permtest2

% Author: Karim N'Diaye
% Created: Sep 2005
% Copyright 2005


NPERMS=1000; %Max. number of permutations

%initialize parameters
if nf>ndims(X)-1
    error('Error Number of factors and dimensions of X don''t match!')
end
if nargin<3
    dim_m=[];
end
if nargin<4
    NP=[];
end
if nargin<5
    rp=[1:nf];
end
rp=rp(:)';
if not(isempty(rp)) & ~all(ismember(1:nf, rp))
    error('Cannot deal with spli-plot (ie. mixed) designs')
end

sX=size(X);
ng=sX(1:nf);  % nb of groups in each factor
png=prod(ng); % nb of cells
nr=sX(nf+1);  % nb of subjects/repeated measures
nsX=[sX(nf+2:end) 1 1]; % shape of the data
ndX=ndims(X);

% Default is to compute the maximum F value across all dimensions
if isempty(dim_m)
    dim_m=1:ndX-nf-1;
end

within=0;
% Now compute the number of exhaustive permutations
Nexh=inf; % I don't want to think on how to compute the perms...

if isequal(rp,[1:nf])
    within=1;
end
exhaustive=0;
if isempty(NP)
    NP=NPERMS;
end

if NP>Nexh
    warning(sprintf('Cannot do %d permutations. For this dataset, the maximum is: %d.\nThis latter value will be used.',NP, Nexh));
    NP=Nexh;
    exhaustive=1;
end

if NP>NPERMS
    warning(sprintf('Too many permutations! Only %d will be performed.',NPERMS));
    NP = NPERMS;
    exhaustive=0;
end

% DEBUG:
% NP = min(500,NP);


% PERMUTATION LOOP
for i=0:NP
    if i==0
        % At the 0-th permutation, evaluate original data
        Y=X;
    else
        Y=reshape(X,[png*nr,nsX]);
        if within
            [ignore,P] = sort(rand(png,nr));
            P=P+repmat([0:png:png*(nr-1)],png,1);
        else
            P=randperm(png*nr);
        end        
        Y=Y(P(:),:);
        Y=reshape(X,[ng,nr,nsX]);
    end

    [p,Z,fx]=friedmantest(Y,nf,rp);
    

    if i==0
        nfx=length(fx);
        Z=reshape(Z,[nfx nsX]);
        S0=Z;
        sz=size(S0);
        % preallocate memory
        S=zeros(sz);
    else
        Z=reshape(Z,[nfx nsX]);
        if dim_m==0
            % keep Z as it is
        elseif ~isequal(dim_m,1:(ndX-nf-1))
            Z=submax(Z,dim_m+1);
        else
            Z=max(Z(:,:),[],2);
            Z=repmat(Z,[1 sz(2:end) 1]);
        end
        S=S+(Z>=S0);
    end
end
% Compute p-values
pv=(S+1)/(NP+1);

return

function [Z]=submax(Z,dims)
sZ=size(Z);
odims=setdiff(1:length(sZ),dims);
pdims=prod(sZ(dims));
Z=permute(Z, [dims odims]);
Z=reshape(Z,[pdims, sZ(odims) 1]);
Z=max(Z,[],1);
Z=repmat(Z,[pdims 1]);
Z=reshape(Z,[sZ(dims) sZ(odims) 1]);
Z=ipermute(Z, [dims odims]);
