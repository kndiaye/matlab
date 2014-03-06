function varargout = yline(x,varargin)
%YLINE - Create a vertical line on a plot
%   [h] = yline(x)
%   Adds as many vertical lines on the current plot as there are values in  x.
%
%   See also: line, xline

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

y=max(abs(get(gca, 'Ylim')))*[-1 1];
%y=*10;
x=x(:);
x=[x*ones(1,2)]';
y=repmat(y,size(x,2),1)';

holdstate=ishold;
hold on;
h=line(x,y,varargin{:});
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
