function varargout = newdeal(func,X,dim,varargin)
%NEWDEAL - Deal a given dimension of X as arguments to a function
%   varargout = newdeal(func,X,dim,params)
%   For 2-D matrix, default is to deal columns (ie. dim = 2)
%   Otherwise (vectors, and N-D array, N>2) dim = first non singleton
%
% Example of use: 
%   PLOT3 wants coordinates as 3 separate arrays: XYZ(:,1) XYZ(:,2) XYZ(:,3)
%   newdeal(@plot3,XYZ)) does it in one go

if nargin<3
    dim = [];
end
if isempty(dim)    
    if ndims(X) == 2 && size(X,2)>1
        dim = 2;
    else
        [dim] = max([1 find(size(X)>1,1)]);
    end
end
X = num2cell(X,setdiff(1:ndims(X),dim));
        
if nargout == 0
    feval(func,X{:},varargin{:});
else
    [varargout{1:nargout}] = feval(func,X{:},varargin{:});
end
return
