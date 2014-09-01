function [s,loc] = finites(S,dim)
%finitess - Finite matrix elements.
%   finites(S) is a full column vector of the non-nans elements of S.
%   This gives the s, but not the i and j, from [i,j,s] = find(isnan(S)).
%   Warning! If S is a matrix, outputs a single column vector
%   Example
%       >> histk
%
%   See also: NONZEROS, NUMREP, NONNANS, ISFINITE

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2006 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2006-02-07 Creation
%                   
% ----------------------------- Script History ---------------------------------
loc=find(isfinite(S));
s=S(loc);
