function Z = ndmultiply(X,Y,dim)
%NDMULTIPLY  Multiply two (matching) dimensions of N-dimension matrices
%   Z = ndmultiply(X,Y,dimY)
%   Computes Z = X*W(:,:) where W is a permutation of Y placing dimY in
%   first position so that it match X second dimension 
%   i.e. size(X,2) == size(Y,dim)
%   The result Z is then permuted to match Y dimensions -- except dimY,
%   the one which has been multiplied and now equals to size(X,1)
%
%   If Y is an array and dim > 2 and X is a N-d array, N>=2, then the
%   multiplication is done "on the right side" of dimension dim of X
%   i.e. size(X,dim) == size(Y,1)
%
%   Example:
%       X=rand(3,4);Y=rand(2,4,7);
%       Z=ndmultiply(X,Y,2)
%       Z will be of size 2-by-3-by-7
%       Conversely, with:
%       X=rand(2,5); Y=rand(2,4,7);
%       ndmultiply(Y,X,1) is of size [5,4,7]
%
%   See also: nd2array

% Author: KND
% Created: Sep 2005
% Copyright 2005

if nargin<3
    dim=1;
end
if ndims(X)>=dim && ndims(Y)==2
    Z=X;
    X=Y';
    Y=Z;
end
if ndims(X) == 2 
    if dim > ndims(Y)
        error('Cannot perform multiplication on dimension dim=%d of Y',dim)
    end
else
    error('Wrong inputs, check dimensions!')
end
sY=size(Y);
try
    Z=X*nd2array(Y,dim);
catch
    warning('Data put in double format')
    Z=double(X)*double(nd2array(Y,dim));
end
Z=nd2array(Z, -dim, sY);
