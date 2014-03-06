function [p,F,fx,SS,df,MS]=myanova(X,nf,rp)
% myanova - N-way ANOVA
%   [p,F,fx]=myanova(X,nf,rp)
%   Performs a N-way anova on X:
%       nf: number of factors
%       rp: an array listing the repeated factors
%   OUTPUTS:
%       p: the Null hypothesis probability
%       F: the F-values 
%       fx: a cell array listing the tested effects.
%   Input data should be as follows:
%       X = [ factor1 x factor2 x ... x factorN x replicates x ...]
%   This function is vectorized, ie. anova is computed for each value in X
%   after the 'replicates' (i.e. subject) dimension.
%
%   Ex: 
%       2 tasks by 3 condition for 10 subjects, within subject design:
%       >> [p,F,fx]=myanova(X,2,1:2)
%               p: 3x1 array 
%               F: 3x1 array
%               fx: 3x1 cells: { 1 , 2 , [ 1 2 ]}
%
% Requires: f_cdf() function

sX=size(X);
nX=ndims(X);

% Number of groups for each factor
ng=sX(1:nf);
png=prod(ng);
% Number of replicates, ie. samples in each group
nr=sX(nf+1);

if nargin<3
    rp=[];
end
if ~isempty(rp) & ~all(ismember(1:nf,rp))
    error('Mixed designs (split plot) ANOVA unavailable!')
end  
if ~isempty(rp) & nf>2
    error('Repeated measure ANOVA is only available for 2 factor designs!')
end  
    
% Within group stats
dfw=png*(nr-1);
mXw=mean(X,nf+1);
SSw=X-repmat(mXw,[ones(1,nf) nr 1]);
SSw=reshape(SSw, png*nr, []).^2;
SSw=sum(SSw);
MSw=squeeze(SSw/dfw);

% Population stats
dft=(png*nr)-1;
mX=reshape(mXw, png, []);
mX=mean(mX,1);
% These are not used afterwards
SSt=sum((reshape(X, png*nr, [])-repmat(mX,[png*nr 1])).^2);
MSt=squeeze(SSt/dft);

if ~isempty(rp)
    % Correct Within Error term to account for repeated measurements
    dfr=(nr-1);
    mXr=permute(X, [nf+1 1:nf nf+2:nX]);
    mXr=reshape(mXr,nr,png,[]);
    mXr=mean(mXr,2);
    SSr=png*sum((reshape(mXr, nr, []) - repmat(mX,[nr 1])).^2);
    SSw=SSt-SSr;
end

fx={};
for i=1:nf
    fx=[fx ; num2cell(nchoosek(1:nf,i),2)];
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
            % the following does NOT work for higher than 2 factor design!
            % 
            dfe=(png-sum(ng-1)-1)*(nr-1)            
            mXe=reshape(X,png*nr,[]);
            SSe=sum((mXe - repmat(mX,[nr*png 1])).^2)
            SSe=SSe-SSr-sum(SSbe(1:nf,:))-sum(SS(1:nf,:))
        end
        MSe=squeeze(SSe/dfe);
        MSr=squeeze(SSr/dfr);
        F(i,:)=squeeze(MSb)./MSe;
        p(i,:)=1-f_cdf(F(i,:),dfb,dfe);
    else
        F(i,:)=squeeze(MSb)./MSw;
        p(i,:)=1-f_cdf(F(i,:),dfb,dfw);
    end 
    if nargout>4
        df(i,:)=dfb;
    end
    if nargout>5
        MS(i,:)=MSb;
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


% Examples from ZAR, pp. 250 sqq.
%
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


% http://www.richland.edu/james/lecture/m170/ch13-2wy.html
% SS = 512.8667  449.4667   143.1333  136.0000  1241.4667
% F  = 3.682 3.056 2.641
X=[
    106, 110 , 95, 100 , 94, 107 , 103, 104 , 100, 102;
    110, 112 , 98, 99 , 100, 101 , 108, 112 , 105, 107;
    94, 97, 	86, 87 	98, 99 	99, 101 	94, 98];
X=cat(3,X(:,1:2:end),X(:,2:2:end))
