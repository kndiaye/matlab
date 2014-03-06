function [p,fx,F]=myanova(X,factors,repls)
% myanva - computes N-way ANOVA
% [p,fx,F]=myanova(X,factors,repls)
%   factors : dimensions of factors. default: [1 2]
%   repls   : replications. Default [3]
%   repts   : repeated measures. Default []
%
% 
% If X is typically a N1 x N2 x NS matrix of a given measure for
% 2 factors across NS subjects (or replications)
%   >> myanova(X) 
%   will say if any of the 2 factor or their interaction has a significnt
%   effect on X
%
% For p factors:
%   >> myanova(X,[1 2 ... p])
% (The replications is supposed to be the p+1 dimension)
%
% The function is vectorized so that for X a N1 x N2 x NS x M measures 
%   >> myanova(X)
% will return a [3 by M] matrix of p values
% Idem for p factors, and X a N1 x N2 x ... Np x NS x NM matrix

sX=size(X);

if nargin<2
    if ndims(X)==2
        factors=1;
    elseif ndims(X)==3
        factors=[1 2];
    end
end

if nargin<3
    repls=max(factors)+1;    
end

% Number of modalities for each factor
% i.e. degrees of freedom
df=sX(factors);
% Number of replications for each factor
Nrepls=sX(repls);

% 
% % Number of observations
% N=prod([df, Nrepls])
% dftot=N-1;

% List of effects/interactions
nf=length(factors);
fx={};
for i=1:nf
    fx=[fx ;num2cell(nchoosek(1:nf,i),2)];
end
nfx=length(fx);

% % Reshape X for latter easier use
% if prod(sX)>prod([df Nrepls])
%     X=
% end

N=prod([df Nrepls]);
SSw=N-prod(df(1:nf));

for i=1:nfx
    j=fx{i};
    
    if length(j)==1
        x=reshape(permute(X, [j 1:j-1 j+1:nf nf+1 nf+2]), df(j),prod(df)*Nrepls/df(j),[]);
        [p(i,:),F(i,:)]=anova1(x);  
    else
    end
end

% 
% for i=1:length(factors)
% 
%     mY{i}=mean(reshape(permute(X, [factors(i) 1:factors(i)-1 factors(i)+1:length(sX)]), df(i), N/df(i), []) ,2);
%     sY=[ df Nrepls ];
%     sY(factors(i))=1;
%     nY=prod(sY);
%     
%     sY=size(X);    
%     sY(factors(i))=[];
%     sY=[1 sY];
%     ssY=repmat(mY{i},sY)
%     ssY=permute(ssY, [2:factors(i) 1 factor(i)+1:ndims(ssY)]);
%     ssY=(X-ssY).^2
%     SSwithin= SSwithin + sum(reshape(ssY,N,[]),1)
%     
%     ssY=(squeeze(mY{i})-repmat(mX, df(i) ,1 )).^2 * nY
%     SSbetween= SSbetween + sum(ssY)       
%     
%     dfb=prod(df-1)
%     Vbetween=SSbetween/dfb
%     dfw=N-prod(df)
%     Vwithin=SSwithin/dfw
%     
%     % Test whether F [ dfbetween , dfwithin ] < x
%     F=Vbetween./Vwithin
%     p=1-f_cdf(F,dfb,dfw)
%     
% end
% 
% nfx=2;


% Reshape output to match input format
if length(sX)>repls+1
    p=reshape(p, [ nfx sX(repls+1:end) ]);
    F=reshape(F, [ nfx sX(repls+1:end) ]);    
end



function [p,F]=anova1(X,)
% Row-by-row One-way ANOVA
% X = [groups x replicates x ...]

% Number of groups
ng=size(X,1);
% Number of replicates, ie. samples in each group
nr=size(X,2);

% Between group stats
dfb=ng-1;
mXb=mean(X,2);
SSb=sum(sum((X-repmat(mXb,[1 nr 1])).^2,2),1);
MSb=SSb/dfb;

% Population stats
dft=ng*nr-1;
mX=mean(mXb,2);
SSt=sum(sum((X-repmat(mX,[ng nr 1])).^2));
MSt=SSt/dft;

% Within group stats
dfw=ng*(nr-1);
mXw=mean(X,2);
SSw=sum(sum((X-repmat(mXw,[1 nr 1])).^2,2),1);
MSw=SSw/dfw;

% SSb=SSt-SSw;
% MSb=SSb/dfb;

% Test whether F [ dfbetween , dfwithin ] < x
F=MSb./MSw;
p=1-f_cdf(F,dfb,dfw);
    
return

function [p,F]=anova1_ok(X)
% Row-by-row One-way ANOVA
% X = [groups x replicates x ...]

% Number of groups
ng=size(X,1);
% Number of replicates, ie. samples in each group
nr=size(X,2);

% Between group stats
dfb=ng-1;
mXb=mean(X,2);
SSb=sum(sum((X-repmat(mXb,[1 nr 1])).^2,2),1);
MSb=SSb/dfb;

% Population stats
dft=ng*nr-1;
mX=mean(mXb,2);
SSt=sum(sum((X-repmat(mX,[ng nr 1])).^2));
MSt=SSt/dft;

% Within group stats
dfw=ng*(nr-1);
mXw=mean(X,2);
SSw=sum(sum((X-repmat(mXw,[1 nr 1])).^2,2),1);
MSw=SSw/dfw;

% SSb=SSt-SSw;
% MSb=SSb/dfb;

% Test whether F [ dfbetween , dfwithin ] < x
F=MSb./MSw;
p=1-f_cdf(F,dfb,dfw);
    
return