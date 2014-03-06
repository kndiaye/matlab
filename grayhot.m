function [c]=grayhot(n)
%GRAYHOT - Gray-hot colormap
%   grayhot(n) returns a n-by-3 matrix
%   grayhot by itself is the same length as the current colormap
if nargin<1
    n=length(colormap);
end
b=([[n:-1:1]/n]'*[1 1 1]).^(300);
c=hot(n).*(1-b*.6)+ (b*.6);