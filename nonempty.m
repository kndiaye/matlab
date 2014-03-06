function [S,loc] = nonempty(S);
%nonempty - Non empty cells from a cell array
%   nonempty(S) is a full column vector of the non-empty cells of S.
%   This gives the s, but not the i and j, from [i,j,s] = find(isempty(S)).
%   Warning! Even if S is a multidimensional cell array, nonempty() outputs
%   a single column vector of cells.
%   Example
%       >> nonempty({ [] , 'a' , 3 , '' , {} , 'last' })
%
%   See also: NONZEROS

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2007
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% -------------------------- Script History -------------------------------
% KND  2007-10-04 Creation
%                   
% -------------------------- Script History -------------------------------
loc = find(~cellfun('isempty',S));
S=S(loc);

