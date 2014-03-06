function y = stderr(x,dim,ci)
%stderr - Standard error (of the sample mean).
%   For vectors, STDERR(X) returns the standard error around the mean. For
%   ND arrays, it is computed for the first non-singleton dimension. 
%   The standard error is the (unbiased) standard deviation divided by the
%   size of the sample: SE=SD/sqrt(N)
%
%   STDERR(X,DIM) computes std err on the given dimension. 

% NOT YET:
%   STDERR(X,DIM,P) computes confidence interval at P percent

if nargin<2,
  if isempty(x), y = 0/0; return; end % Empty case without dim argument
  dim = min(find(size(x)~=1));
  if isempty(dim), dim = 1; end
end
if nargin<3, ci = []; end

n=size(x,dim);

% Avoid dividing by zero for scalar case
if n==1, y = zeros(size(x)); y(isnan(x))=NaN; return, end

tile = ones(1,max(ndims(x),dim));
tile(dim) = n;

xc = x - repmat(sum(x,dim)/n,tile);  % Remove mean
y = sum(conj(xc).*xc,dim)/(n-1)/n;
y=sqrt(y);
return

% NOT YET
if not(isempty(ci))
    ci=tcdf(1);
end