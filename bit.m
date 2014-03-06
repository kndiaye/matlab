function [v]=bit(x,n,b)
% bit - get the n-th bit of a number x
%   [v]=bit(x,n,b)
%   b cannot yet be other than 2
if nargin<3
    b=2;
elseif ~isequal(b,2)
    error('Only base-2 bits available ')
end
v=rem(floor(x(:)*pow2(-(n))),2);
return

