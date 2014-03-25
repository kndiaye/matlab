function [r]=reldiff(X,N,D,mode)
% reldiff - relative difference (A-B)/(abs(A)+abs(B))
% r = reldiff(X)
% r = reldiff(X,N,D)
%   Divide the N-th order difference by the sum of absolute values along
%   dimension D.
% r = reldiff(X,N,D,mode)
%   mode = 'sum' (default) as above
%          'mean' the difference is divided by the average (of the absolute
%          values) 
%          'first' the difference is divided by the absolute value of the
%          first member
% See also: DIFF

if nargin<3
    mode='sum';
end
if nargin<2
    N=[];
end
if isempty(N)
    N=1;
end
if nargin<3
    D=[];
end
if isempty(D)
    % Get the first non-singleton dimension
    D=find(size(X)~=1);
    D=D(1);
end
if N>1
    X=reldiff(X,N-1,D);
    N=1;
end
nX=size(X,D);
r=diff(X,N,D);
X=abs(X);
<<<<<<< .mine

switch mode
    case 'sum'
        r = r ./ (subarray(X,1:nX-1,D) + subarray(X,2:nX,D));
    case 'mean'
        r = r ./ (subarray(X,1:nX-1,D) + subarray(X,2:nX,D))*2;
    case 'first'
        r = r ./ (subarray(X,1:nX-1,D));        
    case 'second'
        r = r ./ (subarray(X,2:nX,D));
    otherwise
        error
end
return
=======

switch mode
    case 'sum'
        r = r ./ (subarray(X,1:nX-1,D) + subarray(X,2:nX,D));
    case 'mean'
        r = r ./ (subarray(X,1:nX-1,D) + subarray(X,2:nX,D))*2;
    case 'first'
        r = r ./ (subarray(X,1:nX-1,D));        
    case 'second'
        r = r ./ (subarray(X,2:nX,D));
    otherwise
        error
end
return>>>>>>> .r687
