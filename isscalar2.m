function t = isscalar(x)
%ISSCALAR True for scalar input.
%
%   ISSCALAR(X) returns 1 if it's argument is a scalar and 0 otherwise.
%   Note that this function does not consider the empty matrix a scalar.

%   Author:      Peter J. Acklam
%   Time-stamp:  2002-03-03 13:50:54 +0100
%   E-mail:      pjacklam@online.no
%   URL:         http://home.online.no/~pjacklam
error(nargchk(1, 1, nargin));
t = numel(x)==1;
% t = all(size(x) == 1);
