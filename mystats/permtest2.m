function [Thd,S0,S]=mypermtest(X,X2,dimS,dimT,pS,pT,NP)
% permtest2 - BrainStorm data permutation test
%   [thd,obs]=mypermtest(F1,F2,dimS,dimT,pS,pT)
%
%Inputs:
%   F1,F2: data matrices. 
%   dimS: subject dimension (negative: unpaired test)
%   dimT: Time dimension
%   pS: threshold for subject-wise pemutation on temporal extent [0.05]
%   pT: threshold for sample-by-sample significance [0.05]
%
%Outputs:
%   thd: thresholds at the given p-values, computed from the permutations
%   obs: observed value in the original data
%   stt: statistics
%initialize parameters

if nargin<5
    p1=.05;
end
if nargin<6
    pT=.05;
end
if nargin<7
    NP = 500;  % max number of permutations
end
Nmax=12;  %  maximum number of observations for Fisher statistic

if dimS<0
    error('Unpaired testing not implemented yet!')
end

% ORIGINAL OBSERVATIONS
sX=size(X);
nX=length(sX);
X=permute(X, [dimS dimT setdiff(1:nX,[dimS dimT])]);
X2=permute(X2, [dimS dimT setdiff(1:nX,[dimS dimT])]);       
X=cat(1,X,X2);     
N= [sX(dimS) ; size(X2,dimS) ];
clear X2;
% the shape of the measurement data
nsX=[size(X) 1];
nsX(1)=[];
np=size(X,1);
nt=sX(dimT);

if max(N(:,1))<Nmax
    NP=factorial(N(1)+N(2))/(factorial(N(1))*factorial(N(2)))-1;
end

pT=max([pT;1./NP],[],1);

% FIRST PERMUTATION LOOP
% Sample-by-sample difference
for i=0:NP
    if i==0
        % At the 0-th permutation, evaluate original data
        Y=X;
    else                
        Y=X(randperm(np),:);        
    end    
    
    Y1=reshape(Y(1:N(1),:), [N(1), nsX]);
    Y2=reshape(Y(N(1)+(1:N(2)),:), [N(1), nsX]);
    Z=abstmax(Y1,Y2,[]);        
    if i==0
        S0=Z;
        % preallocate memory
        S=zeros([NP,size(S0)]);
    else
        S(i,:)=Z(:)';
    end
end
% Compute thresholds based on permutation statistics
S1=S;
S=sort(S);
for pp=1:length(pT)
    Thd(pp,:) = S(ceil((length(S)*(1-pT(pp)))),:);   
end
S0=reshape(S0,[1 nsX]);
Thd=reshape(Thd,[1 nsX]);
S1=reshape(S1,[NP nsX]);

% SECOND PERMUTATION LOOP
% On temporal extent
V0=S0>Thd;

if 0 % look in previous permutations 
V=S1>repmat(Thd, [NP,1]);
for i=1:NP
    p=max(piecemeal(V(i,:)));
    if isempty(p),p=0;end
    S2(i)=p;    
end
end

if 1
for i=1:NP
    p=max(piecemeal(V0(randperm(nt))));
    if isempty(p),p=0;end
    S2(i)=p;
end
end
    




 return


function [Z]=tmax(Y1,Y2)
% default function: max of pseudo-t 
% sqrt((std_PA_orig.*std_PA_orig/JA)+(std_PB_orig.*std_PB_orig/JB));
Z=(mean(Y1)-mean(Y2)) ./ sqrt( std(Y1).*std(Y1)/size(Y1,1) + std(Y2).*std(Y2)/size(Y2,1) );

function [Z]=abstmax(Y1,Y2,dims)
[Z]=tmax(Y1,Y2);
Z=shiftdim(Z,2);
Z=abs(Z);
sZ=size(Z);
Z=reshape(Z,[prod(sZ(dims)), sZ(setdiff(1:length(sZ),dims))]);
Z=max(Z,[],1);



% EX:
% X=rand(3,5)+cumsum(ones(3,5))
% [th,o,ss]=mypermtest(X,1,2,[.05],500,'myanova', {1})