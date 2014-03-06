function h = plot2d(XY, varargin)
%PLOT2D - Plot 2 data X,Y
%   [h] = plot2d(XY)
%
%   Example
%       >> plot2d(randn(1000,2),'.')
%
%   See also: plot, plot3d, plotnd() 

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2008 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2008-09-03 Creation
%                   
% ----------------------------- Script History ---------------------------------
h=plot(XY(:,1), XY(:,2), varargin{:});
