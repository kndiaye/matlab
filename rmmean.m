function X = rmmean(X,dim)
%RMMEAN - Remove mean value from data
%   [Y] = rmmean(X,dim)
%
%   See also: mean

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2006 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2006-01-11 Creation
%                   
% ----------------------------- Script History ---------------------------------

if nargin<2
    dim = min(find(size(X)>1));
    if isempty(dim), dim = 1; end
end
sX=ones(ndims(X),1);
sX(dim)=size(X,dim);
X=X-repmat(mean(X,dim), sX);