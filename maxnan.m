function [y,i,nans]=maxnan(x,dim)
%MAXNAN   Find maximum dismissing NaN values
%   [y,i,nans]=maxnan(x)
%   [y,i,nans]=maxnan(x,dim)
%   returns an array 
%   If dim is negative
%       Do not include data if any NaN found along the dimension
%
%   Example:
%       a = cat(3,magic(5), cumsum(ones(5)));
%       a([3 35])=NaN % arbitrarily set some elements to NaN
%       maxnan(a,1)
%       maxnan(a,-2)
%
% See also: max()

if nargin==1,
    dim = min(find(size(x)~=1));
    if isempty(dim), dim = 1; end
end
nans=isnan(x);
if dim < 0
    dim=-dim;
    otherdims = setdiff(1:ndims(x),dim);
    permdims = [dim otherdims];
    nans=permute(nans,permdims);
    nans(any(nans(:,:),2),:)=1;    
    nans=ipermute(nans,permdims);
end
x(nans)=-Inf;

%nans=double(nans);

[y,i] = max(x,[],dim);
y(all(nans,dim)) = NaN;
 