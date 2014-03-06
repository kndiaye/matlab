function [varargout] = ccaxis(clim)
%CCAXIS - Contour compatible CAXIS
%   [] = ccaxis(clim)
%   Works ALSO when there are contours in the plot
%   Example
%       >> ccaxis([0 1])
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

caxis(clim)
ha=gca;
ch=get(gca, 'Children');
peers=findobj(get(gcf, 'Children'),'type','axes');
hcont=findobj(ch, 'type', 'hggroup');
if ~isempty(hcont)    
    cb=findobj(peers, 'tag', 'Colorbar');
    for i=length(cb):-1:1
        hcb=handle(cb);
        if  ~isequal(double(hcb.axes),ha)
            cb(i)=[];
        end
    end
    if isempty(cb)
        cb=colorbar;
    end
    for i=1:length(cb)
        child=get(cb,'children');
        set(cb, 'YLim', clim);
        set(child, 'ydata', clim);
    end
    axes(ha)
    delete(cb(~ismember(cb,peers)))
end
varargout={hcont};    