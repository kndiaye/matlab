function [pv,S0,S,P]=mypermtest(X,X2,dim_p,dim_m,NP,tails)
% mypermtest - permutation test
%   [pv,S,T,P]=mypermtest(X1,X2,dimP,dimM,NP)
%   [pv]=mypermtest(X,ns,dim,NP,ftest[abstmax],fparams)
%
%Inputs:
%  X1,X2: Data matrices.
%         If only X1 is given, the permutation dimension (dim_p) should be given.
%  Alternatively:
%         X can be a single data matrix. But the number of samples (ie subjects)
%         in the first condition should be set using: ns
%         I.e.   X = [ X1 ; X2 ]  &  ns=size(X1,1)
%  dimP: Permuted dimensions (ie. subjects). Default: first non singleton
%        If dim_p > 0 : paired permutations (default)
%        Use dim_p < 0 for unpaired samples.
%  dimM: Dimensions of data over which the maximum T-value is to be found.
%        Default: all dimensions
%  NP: Number of permutations (may lead to exhaustive permutation,
%      for example if NP <= 2^N-1 using paired data)
%
%Outputs:
%   pv: thresholds at the given p-values, computed from the permutations
%   T: observed T-values
%   S: T-values from the permutations
%   P: permutations used

% NOT YET:
%   tails ; one/two tailed tests

%  ftest: function applied on data.
%         Default is 'maxabst', i.e. compute the maximum (two-tailed) T-value
%  fparams: cell array indicating the parameters passed to the function
%           when called

NMAX_UNPAIRED=15; %  maximum number of observations for exhaustive search for unpaired samples
NMAX_PAIRED=30;  %  maximum number of observations for exhaustive search in paired samples
NPERMS=10000; %Max. number of permutations

%initialize parameters
if nargin<3
    dim=find(size(X)>1);
    if isempty(dim)
        error('Input X has only singleton or null dimensions!')
    end
    dim=dim(1);
    dim_p=dim;
else
    dim=abs(dim_p);
end


% ORIGINAL OBSERVATIONS
sX=size(X);
nX=length(sX);
X=permute(X, [dim setdiff(1:nX,dim)]);
% the shape of the measurement data
nsX=size(X);
nsX(1)=[];
ndX=ndims(X);

if nargin<4
    dim_m=1:ndX-1;
end

if prod(size(X2))>1
    X2=permute(X2, [dim setdiff(1:nX,dim)]);
    sX2=size(X2);
    if ~isequal(sX(setdiff(1:nX,dim)), sX2(2:end))
        error('X1 and X2 should be of the same size in the non-permuted dimensions!')
    end
    X=cat(1,X,X2);
    N=[sX(dim) sX2(1)];
    clear sX2;
elseif prod(size(X2))==1
    N=[X2 sX(dim)-X2];
else
    error('Check inputs!')
end
clear X2;

% Now compute the number of exhaustive permutations
if dim_p>0
    % We compute only one half of the permutations for paired samples
    Nexh=2^(N(1)-1)-1;
else
    Nexh=factorial(N(1)+N(2))/(factorial(N(1))*factorial(N(2)))-1;
end

exhaustive=0;
if nargin<5
    if (dim_p>0 & (N(1)+N(2))<NMAX_PAIRED ) | ...
            (dim_p<0 & (N(1)+N(2))<NMAX_UNPAIRED )
        NP=Nexh;
        exhaustive=1;    
    else
        NP=NPERMS;
        exhaustive=0;
    end
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
NP = min(500,NP);

% List of permutations/randomizations
if dim_p>0
    % paired permutations
    if exhaustive
        % compute exhaustive list of perms
        P=sprintf(sprintf('%%0%dd',N(1)), str2num(dec2bin(1:NP)));
        P=reshape(P==49, [N(1),NP])';
    else
        % non exhaustive
        P=round(rand(NP,N(1)));                
    end
    P=[P 1-P].*N(1)+repmat(1:N(1), [NP,2]);
else
    % non-paired perms
    if exhaustive
        % all possible perms
        p=nchoosek(1:(N(1)+N(2)),N(1));
        p(1,:)=[]; % the 1st is not a permutation
        for i=1:NP
            P(i,:)=[p(i,:) setdiff(1:(N(1)+N(2)),p(i,:))];
        end
        clear p
    else
        % non exhaustive
        for i=1:NP
            P(i,:)=randperm(N(1)+N(2));
        end
    end
end

% PERMUTATION LOOP
for i=0:NP
    if i==0
        % At the 0-th permutation, evaluate original data
        Y=X;
    else
        Y=X(P(i,:),:);
    end
    
    Z=mean(Y(1:N(1),:))-mean(Y(N(1)+(1:N(2)),:));
    Z= Z ./ sqrt( std(Y(1:N(1),:)).^2/N(1) + std(Y(N(1)+(1:N(2)),:)).^2/N(2));
    Z= abs(Z);
    Z=reshape(Z,nsX);
    
    if i==0        
        S0=Z;
        sz=size(S0);
        % preallocate memory
        S=zeros([NP,sz]);
    else
        if ~isequal(dim_m,1:(ndX-1))
            Z=submax(Z,dim_m);            
        else
            Z=max(Z(:));
        end
        S(i,:)=Z(:);
    end
    
end


% Compute pvalues based on permutation statistics
pv=(sum(repmat(shiftdim(S0, -1),[NP 1])<=S)+1)/(NP+1);
pv=shiftdim(pv, 1);

return


% FORGET THE REST!

% S=sort(S);

for pp=1:length(pthres)
    Thd(pp,:) = S(ceil((length(S)*(1-pthres(pp)))),:);
end
S0=S0(1,:);

return

function [Z]=submax(Z,dims)
sZ=size(Z);
odims=setdiff(1:length(sZ),dims);
pdims=prod(sZ(dims));
Z=permute(Z, [dims odims]);
Z=reshape(Z,[pdims, sZ(odims) 1]);
Z=abs(Z);
Z=max(Z,[],1);
Z=repmat(Z,[pdims 1]);
Z=reshape(Z,[sZ(dims) sZ(odims) 1]);
Z=ipermute(Z, [dims odims]);



return

%
% OLDIES
%


function [Z]=pseudoT(Y1,Y2)
% default function: max of pseudo-t
% sqrt((std_PA_orig.*std_PA_orig/JA)+(std_PB_orig.*std_PB_orig/JB));
Z=(mean(Y1)-mean(Y2)) ./ sqrt( std(Y1).*std(Y1)/size(Y1,1) + std(Y2).*std(Y2)/size(Y2,1) );

function [Z]=maxabst(Y1,Y2,dims)
[Z]=pseudoT(Y1,Y2);
% remove the 1st (subjects) dimension:
Z=shiftdim(Z,1);
sZ=size(Z);
odims=setdiff(1:length(sZ),dims);
pdims=prod(sZ(dims));
Z=permute(Z, [dims odims]);
Z=reshape(Z,[pdims, sZ(odims) 1]);
Z=abs(Z);
Z=max(Z,[],1);
Z=repmat(Z,[pdims 1]);
Z=reshape(Z,[sZ(dims) sZ(odims) 1]);
Z=ipermute(Z, [dims odims]);


return


% EX:
% X=rand(3,5)+cumsum(ones(3,5))
% [th,o,ss]=mypermtest(X,1,2,[.05],500,'myanova', {1})

if nargin<7
    fparams={};
end
if nargin<8
    ftest='maxabst';
    % Matlab's inline calls are slow !
    % f=inline('mean(x)/std(x)','x');
    
    % Maximum of T values will be search along all measurement dimensions
    fparams={1:(ndims(X)-1)};   
end


if singleinput
    Y=reshape(Y,[N(1)+N(2) nsX]);
    Y=ipermute(Y, [dim setdiff(1:nX,[dim])]);
    Z=feval(ftest,Y,fparams{:});
else
    Y1=reshape(Y(1:N(1),:), [N(1), nsX]);
    Y2=reshape(Y(N(1)+(1:N(2)),:), [N(2), nsX]);
    Z=feval(ftest,Y1,Y2,fparams{:});
end

