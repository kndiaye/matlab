function  M = nestingmatrix(nf,rp)
%NESTINGMATRIX - Compute nesting matrix for ANOVA
%   [M] = nestingmatrix(nf,rp)
% A matrix M of 0's and 1's specifying the nesting
% relationships among the grouping variables.  M(i,j)
% is 1 if variable i is nested in variable j.
%
%   Example
%       >> nestingmatrix
%
%   See also: 

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2007 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2007-02-08 Creation
%                   
% ----------------------------- Script History ---------------------------------
M=zeros(nf+1);
M(rp,nf+1)=1;


