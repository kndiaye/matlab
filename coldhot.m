function c = coolhot(n)
%COOLHOT - Cool-hot colormap
%   [c] = coolhot(N)
%   Returns an N-by-3 matrix containing a "cool-black-hot" colormap.
%   Default: N=size of the current colormap
%
%   Example
%       >> coolhot
%
%   See also: activmap, grayhot, greyish

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2006 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2006-02-22 Creation
%                   
% ----------------------------- Script History ---------------------------------

if nargin < 1, n=size(get(gcf,'colormap'),1); end
n = ceil(n/2);
c=[flipud(fliplr(hot(n))); hot(n)];