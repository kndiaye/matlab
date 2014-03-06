function Y = positivepart(X)
%POSITIVEPART - Output the positive part
%   [Y] = positivepart(X)
%   Y is zero where X <= 0

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2006 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2006-02-08 Creation
%                   
% ----------------------------- Script History ---------------------------------
Y=X.*(X>0);
