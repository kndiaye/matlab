function  X = cellcat(C)
%CELLCAT - Concatenate cell array content
%   [X] = cellcat(C) is equivalent to X=[C{:}]
%
%   See also: cell2mat()

% Author: K. N'Diaye (kndiaye01<at>gmail.com)
% Copyright (C) 2011 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2011-04-08 Creation
%                   
% ----------------------------- Script History ---------------------------------

X = [C{:}];