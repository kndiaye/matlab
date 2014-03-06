function [y,nans]=sumnan(x,dim)
%SUMNAN   Sum once NaN values have been removed
%   [y,nans]=sumnan(x,dim)
%
%   If dim is negative
%       Do not include data if any NaN found along the dimension
%
%   Example:
%       a = cat(3,magic(5), cumsum(ones(5)));a([3 35])=NaN
%       sumnan(a,1)
%       sumnan(a,-2)
% see mean() for details

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2009
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2009-10-22 Creation
%
% ----------------------------- Script History ---------------------------------


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
y = sum(x,dim);
if nargin>1
    nans=logical(nans);
end