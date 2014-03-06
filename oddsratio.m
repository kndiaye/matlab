function r = oddsratio(p,q)
%ODDSRATIO - Computes the odds ratio
%   [r] = oddsratio(p,q)
%
%   Example
%       >> oddsratio( 1/23 , 5/100 )
%
%   See also: 

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2008 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2008-04-30 Creation
%                   
% ----------------------------- Script History ---------------------------------

r=p.*(1-q)./q./(1-p);
