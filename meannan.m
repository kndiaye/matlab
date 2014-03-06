function [y,nans]=meannan(x,dim,rep)
%MEANNAN   Average or mean value once NaN values have been removed
%   [y,nans]=meannan(x,dim)
%   [y,nans]=meannan(x,dim,rep)
%
%   If dim is negative
%       Do not include data if any NaN found along the complementary
%       dimensions (e.g., -1 will exclude from the averag any row
%       containing a NaN)
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
if nargin<3
    rep=0;
end
x(nans)=rep;
nans=double(nans);
if isequal(rep,0)
    y = sum(x,dim)./(size(x,dim)-sum(nans,dim));
else
    y = sum(x,dim)./size(x,dim);
end
if nargin>1
    nans=logical(nans);
end
