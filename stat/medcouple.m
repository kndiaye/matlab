function MC=medcouple(X,varargin)
% MC=medcouple(X) computes a robust measure of the skewness of X
% The medcouple was introduced by Brys et al. (2004)
%
Q2 = median(X(:,:));
h=@(xi,xj,Q2)((xj-Q2)-(Q2-xi))./(xj-xi);
sX=size(X);
Y=sort(X(:,:));
[nl,nc]=size(Y);
% % Y=reshape(Y,[nl 1 nc]);
MC=zeros([1 sX(2:end)]);
for i=1:nc
    xi=repmat(Y(:,i) ,[1 nl 1]);
    xj=repmat(Y(:,i)',[nl 1 1]);    
    k=xi<=Q2(i) & Q2(i)<=xj & xi~=xj;
    MC(i) = median(h(xi(k),xj(k),Q2(i)));
    if isnan(MC(i))
        error
    end
end
MC=reshape(MC,[1 sX(2:end)]);
