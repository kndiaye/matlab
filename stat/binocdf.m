function y = binocdf(x,n,p)
%BINOCDF Binomial cumulative distribution function.
%	Y=BINOCDF(X,N,P) returns the binomial cumulative distribution
%	function with parameters N and P at the values in X.
%
%	The size of Y is the common size of the input arguments. A scalar input  
%	functions as a constant matrix of the same size as the other inputs.	 
%
%	The algorithm uses the cumulative sums of the binomial masses.

%	Reference:
%	   [1]  M. Abramowitz and I. A. Stegun, "Handbook of Mathematical
%	   Functions", Government Printing Office, 1964, 26.1.20.

%	B.A. Jones 1-12-93
%	Copyright (c) 1993 by The MathWorks, Inc.
%	$Revision: 1.1 $  $Date: 1993/05/24 18:53:29 $

if nargin < 3, 
    error('Requires three input arguments.'); 
end 

scalarnp = (prod(size(n)) == 1 & prod(size(p)) == 1);

%[errorcode x n p] = distchck(3,x,n,p);

% if errorcode > 0
%     error('The arguments must be the same size or be scalars.');
% end

% Initialize Y to 0.
y=zeros(size(x));

% Y = 1 if X >= N
k = find(x >= n);
if any(k);
    y(k) = ones(size(k));
end 

% Compute Y when 0 < X < N.
xx = floor(x);
k = find(xx >= 0 & xx < n);

% Accumulate the binomial masses up to the maximum value in X.
if any(k)
    val = min(max(max(n)),max(max(xx)));
    if scalarnp
        tmp = cumsum(binopdf(0:val,n(1),p(1)));
        y(k) = tmp(xx(k) + 1);
    else
     i = [0:val]';
        compare = i(:,ones(size(k)));
        index(:) = xx(k);
        index = index(:,ones(size(i)))';
        nbig(:) = n(k);
        nbig = nbig(:,ones(size(i)))';
        pbig(:) = p(k);
        pbig = pbig(:,ones(size(i)))';
        y0 = binopdf(compare,nbig,pbig);
        indicator = find(compare > index);
        y0(indicator) = zeros(size(indicator));
        y(k) = sum(y0);
    end
end

% Make sure that round-off errors never make P greater than 1.
k = find(y > 1);
if any(k)
    y(k) = ones(size(k));
end

% Return NaN if any arguments are outside of their respective limits.
k1 = find(n < 0 | p < 0 | p > 1 | round(n) ~= n | x < 0); 
if any(k1)
    y(k1) = NaN * ones(size(k1)); 
end



function y = binopdf(x,n,p)
% BINOPDF Binomial probability density function.
%	Y = BINOPDF(X,N,P) returns the binomial probability density 
%	function with parameters N and P at the values in X.
%	Note that the density function is zero unless X is an integer.
%
%	The size of Y is the common size of the input arguments. A scalar input  
%	functions as a constant matrix of the same size as the other inputs.	 

%	Reference:
%	   [1]  M. Abramowitz and I. A. Stegun, "Handbook of Mathematical
%	   Functions", Government Printing Office, 1964, 26.1.20.

%	Copyright (c) 1993 by The MathWorks, Inc.
%	$Revision: 1.1 $  $Date: 1993/05/24 18:53:34 $


if nargin < 3, 
    error('Requires three input arguments');
end

% [errorcode x n p] = distchck(3,x,n,p);
% 
% if errorcode > 0
%     error('The arguments must be the same size or be scalars.');
% end
% 
% Initialize Y to zero.
y = zeros(size(x));
 
% Binomial distribution is defined on positive integers less than N.
k = find(x >= 0  &  x == round(x)  &  x <= n);
if any(k),
    nk = round(exp(gammaln(n(k) + 1) - gammaln(x(k) + 1) - gammaln(n(k) - x(k) + 1)));
 y(k) = nk .* p(k) .^x(k) .* (1 - p(k)) .^ (n(k) - x(k));
end

k1 = find(n < 0 | p < 0 | p > 1 | round(n) ~= n); 
if any(k1)
    y(k1) = NaN * ones(size(k1)); 
end

