function [y,nans]=meanfinite(x,dim)
%MEANFINITE   Average or mean value once NaN values have been removed
%   [y,nans]=meannan(x,dim)
%
%   If dim is negative
%       Do not include data if any NaN found along the dimension
%
%   Example:
%       a = cat(3,magic(5), cumsum(ones(5)));a([3 35])=NaN
%       meannan(a,1)
%       meannan(a,-2)
% see mean() for details

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
x(nans)=0;
nans=double(nans);
y = sum(x,dim)./(size(x,dim)-sum(nans,dim));
if nargin>1
    nans=logical(nans);
end