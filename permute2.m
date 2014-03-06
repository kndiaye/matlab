function Y = permute2(X,p)
%PERMUTE2 - Easi(er) to use than permute
%   [Y] = permute2(X,p)
%
%   Example
%       >> permute2(rand(3,2,4), 3) will put 3rd dimension first followed
%          by the other ones 
%
%   See also: permute, nd2array

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2006 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2006-03-13 Creation
%                   
% ----------------------------- Script History ---------------------------------

ndx=ndims(X);
if all(p(:)>0)
Y=permute(X,[p(:)' setdiff(1:ndx,p(:))]);
elseif all(p(:)<0)
Y=ipermute(X,[p(:)' setdiff(1:ndx,p(:))]);
else
    error('Can''t handle negative and positive dimensions!');
end

