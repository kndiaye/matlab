function  [] = plotlabel(h,t)
%PLOTLABEL - Add text label near each plot
%   [] = plotlabel(h) add a label near each point of the plot (default:
%   current plot)
%   [] = plotlabel(ax) add a label near each child of the axes

%   Example
%       >> plotlabel
%
%   See also: text

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2009
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2009-01-28 Creation
%
% ----------------------------- Script History ---------------------------------

if nargin<1
    h=gco;
    t=[];
end
if ~ishandle(h) & iscell(h)
    if nargin==2
        o=t;
    else
        o=gco;
    end
    t=h;
    h=o;
end

x=get(h,'XData');
y=get(h,'YData');
z=get(h,'ZData');
n=length(x);
if n>100
    error();
end
for i=1:n
    if isempty(z)
        if ~isempty(t)
            ht(i)=text(x(i),y(i),t{i});
        else            
            ht(i)=text(x(i),y(i),sprintf('%d [ %.2g ; %.2g ]', i, x(i),y(i)));
        end
    else
        if ~isempty(t)
            ht(i)=text(x(i),y(i),z(i),t{i});
        else
            ht(i)=text(x(i),y(i),z(i),sprintf('%d [ %.2g ; %.2g ; %.2g ]', i, x(i),y(i),z(i)));
        end
    end
end
set(ht, 'ButtonDownFcn', 'set(gcbo, ''Visible'', ''off'')');