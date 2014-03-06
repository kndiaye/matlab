function [S]=skewness(X)
% skewness - computes skewness of a distribution
%   [S]=skewness(X) computes row-wise skewness
% The unbiased Fisher's skewness for finite samples, a.k.a. G1, is used.
%   skewness = n/(n-1)/(n-2) * sum( ((X-mean)/std)^3 ) 
% Note: 
%   Positive skewness reflects an asymmetrical distribution with tail in positive values.
%   Standard Error of skewness for normal distribution is: SES ~ sqrt(6/n)
%   i.e. if abs(skew) > 2*SES, your data are significantly skewed (2 is the
%   T value à.05)
%   
if isvector(X)
    X=X(:);
end
sz=[size(X) 1 ];
n=sz(1);
if n<3
    error('Skewness needs sample of size > 2')
end
S=sum((X-repmat(mean(X),n,1)).^3);
S=S./(var(X).^1.5);
S=S.*(n/(n-1)/(n-2));
    