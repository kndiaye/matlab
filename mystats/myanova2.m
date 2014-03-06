function [p,F,fx,SS,df,MS]=myanova(X,nf)
% myanova - N-way ANOVA
%   [p,F,fx]=myanova(X,nf)
%   Performs a N-way anova (nf is the number of factors) on X
%   Ouputs p is the Null hypothesis probability, F is the F-value
%   where:
%       X = [group1 x group2 x ... x groupN x replicates x ...]
%   This function is vectorized, ie. anova is computed for each value in X
%   after the 'replicates' dimension.

sX=size(X);
nX=ndims(X);

% Number of groups for each factor
ng=sX(1:nf);
png=prod(ng);
% Number of replicates, ie. samples in each group
nr=sX(nf+1);

% Within group stats
dfw=prod(ng)*(nr-1);
mXw=mean(X,nf+1);
SSw=X-repmat(mXw,[ones(1,nf) nr 1]);
SSw=reshape(SSw, png*nr, []).^2;
SSw=sum(SSw);
MSw=squeeze(SSw/dfw);

% Population stats
dft=prod(ng)*nr-1;
mX=reshape(mXw, png, []);
mX=mean(mX,1);
SSt=sum((reshape(X, png*nr, [])-repmat(mX,[png*nr 1])).^2);
MSt=squeeze(SSt/dft);

fx={};
for i=1:nf
    fx=[fx ;num2cell(nchoosek(1:nf,i),2)];
end
nfx=length(fx);

for i=1:length(fx)  
    j=fx{i};
    % Between groups stats for each factor
    dfb=prod(ng(j)-1);
    mXb=permute(mXw, [j setdiff(1:nf,j) nf+1:nX]);
    mXb=reshape(mXb, prod(ng(j)),png/prod(ng(j)), []);
    mXb=mean(mXb,2);
    SSb=nr*png/prod(ng(j))*sum((reshape(mXb, prod(ng(j)), []) - repmat(mX,[prod(ng(j)) 1])).^2);    
    if length(j)>1
        % Multiple factors
        % Subtract crossed terms from the Sum of squares
        for k=1:i-1
            if all(ismember(fx{k}, j))
                SSb=SSb-SS(k,:);
            end
        end
    end
    SS(i,:)=SSb;
    MSb=SSb./dfb;
    if nargout>4
        df(i,:)=dfb;
    end
    if nargout>5
        MS(i,:)=MSb;
    end
    
    F(i,:)=squeeze(MSb)./MSw;
    p(i,:)=1-f_cdf(F(i,:),dfb,dfw);
end


if prod(sX)>png*nr
    p=reshape(p,[nfx,sX(nf+2:end)]);
    F=reshape(F,[nfx,sX(nf+2:end)]);    
end
if nargout>3
    SS(nfx+1,:)=SSw;
    SS(nfx+2,:)=SSt;
end
if nargout>4
    df(nfx+1,:)=dfw;
    df(nfx+2,:)=dft;
end
if nargout>5
    MS(nfx+1,:)=MSw;
    MS(nfx+2,:)=MSt;
end

return
