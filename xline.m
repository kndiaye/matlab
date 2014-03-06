function varargout = hline(y,varargin)
%HLINE - Create a horizontal line on a plot
%   [h] = hline(y)
%   Adds as many horizontal lines on the current plot as there are values in y.
%
%   See also: line, vline

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2006 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2006-02-02 Creation
%                   
% ----------------------------- Script History ---------------------------------

x=max(abs(get(gca, 'Xlim')))*[-1 1];
%x=x*10;
y=y(:);
y=[y*ones(1,2)]';
x=repmat(x,size(y,2),1)';

holdstate=ishold;
hold on;
h=line(x,y);
if ~holdstate
    hold off;
end
LineStyles={'-', ':', '--', '-.'};
for i=1:length(h);
    set(h(i), 'LineStyle', LineStyles{ceil(i/size(get(gca, 'ColorOrder'),1))});
end
if nargout==0
    return
end
varargout={h};
