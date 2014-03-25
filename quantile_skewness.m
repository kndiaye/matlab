function S = quantile_skewness(X,N,varargin)
%   S = quantile_skewness(X,N) compute (inter) quantile skewness
% Typically, N=4, the quartile skewness introduced in Bowley (1920) and
% Moors et al. (1996), but one may also use N=8 (octile skewness) which is
% more sensitive but less robust to outliers. 
%
% 2013-03_01: KND.
if nargin<2
    N=3;
elseif N<=0 || N==1 || N==2
    error('N should be an integer >2')
elseif N<1
    N=1./N;
elseif ~isequal(N,round(N))
    error('N should be integer')
end
Q2= quantile(X,.5);
Q3 = quantile(X,1-1/N);
Q1 = quantile(X,1/N);
S = ((Q3-Q2)-(Q2-Q1))./(Q3-Q1);
