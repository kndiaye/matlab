function [i,v] = imax(x,varargin)
%IMAX - Retrieves the index of the maximum value across multiple dimensions
%   [I,V] = imax(X);
%   [I,V] = imax(X,[],dim)
%   I is the index (in the given dimension) of the maximum
%   V is/are the values
%   
%   Example:
%       >> imax(magic(3), [], [1 2])
%           ans= 3 2
%          I.e. the maximum of the magic square is on the 3rd row and 2nd column 
%
%   See also: max2

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2006 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2006-02-20 Creation
%                   
% ----------------------------- Script History ---------------------------------


[v,i]=max2(x,varargin{:});