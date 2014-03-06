function  rho = spearmann(X,Y)
%SPEARMANN - One line description goes here.
%   [rho] = spearmann(X,Y)
%
%   Example
%       >> spearmann
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
% KND  2009-10-16 Creation
%                   
% ----------------------------- Script History ---------------------------------

d=diff(tiedranks(X));
rho = 1 - 6*sum(d.^2)./(n*(n.^2 - 1));
