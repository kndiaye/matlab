function [X,mn,mx]=normminmax(X,dims)
% normminmax() - normalize a vector or a matrix to the [0 1] range
%[Y,nY]=NORMMINMAX(X) does a column-by-column normalization of data X
% Y: normalized data
if nargin<2 | isempty(dims)
    dims=1;
end
if ~isequal(dims,1)
    sX=[ size(X) 1 ]; 
    npX = setdiff(1:ndims(X), dims);
    pX=[dims npX];
    X=permute(X, pX);
    X=reshape(X, [ prod(sX(dims)) sX(npX) 1] );
end
X=X-repmat(min(X), [size(X,1) 1]);
X=X./repmat(max(X), [size(X,1) 1]);
if ~isequal(dims,1)
    X=reshape(X, [ sX(dims) sX(npX) 1] );
    X=ipermute(X, pX);
end