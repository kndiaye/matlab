function  A = textalign(A,alignment)
%TEXTALIGN - One line description goes here.
%   [B] = textalign(A, 'left'|'right'|'center')
%
%   Example
%       >> textalign
%
%   See also:

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2009
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2009-09-15 Creation
%
% ----------------------------- Script History ---------------------------------

CharOutput = false;
szA = size(A);
if ~iscell(A)
    CharOutput = true;
    A = cellstr(A);
end
for i=1:numel(A)
    A{i} = fliplr(A{i});
end
A = strvcat(A);
A = fliplr(A);
if ~CharOutput
    A = cellstr(A);
    A = reshape(A,szA);
end
return
B=fliplr(deblank(fliplr(A)));