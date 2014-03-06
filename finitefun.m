function [y,nonfinite]=finitefun(x,D,fun,varargin)
%FINITEFUN   Apply a function on finite values, discarding NaN, Inf...
%   [y,nonfinite]=finitefun(X,D,fun,...) apply (vectorized) function 'fun'
%   along dimension D, on the finite values only in an array X
%
%   If D > 0 
%       Apply function along dimension D, ignoring non-finite values
%   If D < 0 
%       Do not include complementary dimensions of the data array if any
%       nonfinite found along the given dimension (ie. discard the whole
%       hyperplan)
%
%   Example:
%       a = cat(3,magic(5), cumsum(ones(5)));a([3 35])=[ NaN Inf ]
%       finitefun(a,1,@mean)
%       meannan(a,-2)
% 
%See also: meannan() 

nonfinite=~isfinite(x);
dim = abs(D);
x = nd2array(x,dim);
nonfinite(any(nonfinite(:,:),2),:)=1;
if dim < 0
    dim=-dim;
    otherdims = setdiff(1:ndims(x),dim);
    permdims = [dim otherdims];
    nonfinite=permute(nonfinite,permdims);
    nonfinite(any(nonfinite(:,:),2),:)=1;    
    nonfinite=ipermute(nonfinite,permdims);
end
x(nonfinite)=0;
nonfinite=double(nonfinite);
y = sum(x,dim)./(size(x,dim)-sum(nonfinite,dim));
if nargin>1
    nonfinite=logical(nonfinite);
end