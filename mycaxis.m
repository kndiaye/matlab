function [] = mycaxis(lims)
%MYCAXIS - One line description goes here.
%   [] = mycaxis(lims)
%   Works ALSO when there are contours in the plot
%   Example
%       >> mycaxis
%
%   See also: caxis

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2006 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2006-02-27 Creation
%                   
% ----------------------------- Script History ---------------------------------

caxis(lims)
ch=get(gca, 'Children');
if ~isempty(findobj(ch, 'type', 'hggroup'))
    dsip('contours')
end