function [S]=kurtosis(X)
% kurtosis - computes sample kurtosis of a distribution
%   [S]=kurtosis(X) computes row-wise kurtosis
% The unbiased Fisher's equation for finite samples, a.k.a, G2 is used.
% Note: 
%   Positive kurtosis reflects sharp distribution.
%   Standard Error of kurtosis for normal distribution is ~ sqrt(24/n)

if isvector(X)
    X=X(:);
end
sz=[size(X) 1 ];
n=sz(1);
if n<4
    error('Kurtosis needs sample of size > 3')
end
S=sum((X-repmat(mean(X),n,1)).^4);
S=S./(var(X).^2);
S=(n*(n+1)/(n-1)/(n-2)/(n-3)).*S - 3*(n-1).^2/(n-2)/(n-3);
