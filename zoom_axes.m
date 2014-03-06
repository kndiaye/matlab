function [nL,hAxes] = zoom_axes(zoom_factor,hAxesVector,zoomPoint)
%ZOOM_AXES - Apply zoom to axes
%   [nL,hAxes] = zoom_axes(zoom_factor,hAxes) applies the value given in
%   zoom_factor to the specified axes (default: current axes).
%   zoom_factor = [ zX zY zZ ], if only one value is given apply zoom to
%   all dimensions; if two values are given apply only to x and y.
%
%   Example
%       >> zoom_axes
%
%   See also: axes

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2009
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2009-09-09 Creation
%
% ----------------------------- Script History ---------------------------------

if nargin<1
    help(mfilename)
    return
end
if nargin<2
     hAxesVector = gca;
end
if numel(zoom_factor) == 1
        zoom_factor(2) = zoom_factor(1);
end
if numel(zoom_factor) == 2
    zoom_factor(3) = 1;
end

if nargin<3
    zoomPoint = [];
end

m = 1-2.*(zoom_factor < 0);

currLim = axis(hAxesVector);
currXLim = get(hAxesVector,'XLim');
currYLim = get(hAxesVector,'YLim');
if ~iscell(currLim)
    currLim = {currLim};
    currXLim = {currXLim};
    currYLim = {currYLim};
end
newXLim = cell(size(currXLim));
newYLim = cell(size(currYLim));
newLim = cell(size(currLim));

for i=1:numel(hAxesVector)
    
    hAxes = hAxesVector(i);
    limits = getappdata(hAxes,'zoom_zoomOrigAxesLimits');
    if isempty(limits)
        axis(hAxes, 'tight');
        limits = axis(hAxes);        
    end
    maxbounds = objbounds(hAxes);
    % Use current bounds, g161225, 163055
    if isempty(maxbounds)
        maxbounds = axis(hAxes);
    end
    boundXLim = maxbounds(1:2);
    boundYLim = maxbounds(3:4);
    isXLog = strcmpi(get(hAxes,'XScale'),'log');
    isYLog = strcmpi(get(hAxes,'YScale'),'log');
    if isXLog
        currXLim{i} = log10(currXLim{i});
    end
    if isYLog
        currYLim{i} = log10(currYLim{i});
    end
    newXLim{i} = currXLim{i};
    newYLim{i} = currYLim{i};
    dx = diff(currXLim{i});
    dy = diff(currYLim{i});
    if isempty(zoomPoint)    
        center_x = currXLim{i}(1)+dx/2;
        center_y = currYLim{i}(1)+dy/2;
    else
        center_x = zoomPoint(i,1);
        center_y = zoomPoint(i,2);
    end
    zoomConstraint = 'none';

    if ~any(isinf(currXLim{i})) && (strcmpi(zoomConstraint,'horizontal') || strcmp(zoomConstraint,'none'))
        xmin = limits(1);
        xmax = limits(2);
        newdx = dx *m(:,1).*(1/zoom_factor(:,1));
        newdx = min(newdx,xmax-xmin);
        % Limit zoom.
        center_x = max(center_x,xmin + newdx/2);
        center_x = min(center_x,xmax - newdx/2);
        newXLim{i} = [max(xmin,center_x-newdx/2) min(xmax,center_x+newdx/2)];

        % Check for log axes and return to linear values.
        if isXLog
            newXLim{i} = 10.^newXLim{i}(1:2);
        end
    end

    % Calculate new y-limits
    if ~any(isinf(currYLim{i})) && (strcmpi(zoomConstraint,'vertical') || strcmp(zoomConstraint,'none'))
        ymin = limits(3);
        ymax = limits(4);
        % newdy = dy * (1/zoom_factor(:,2).^(m(:,2)+1));
        newdy = dy *m(:,2).*(1/zoom_factor(:,2));
        newdy = min(newdy,ymax-ymin);
        % Limit zoom.
        center_y = max(center_y,ymin + newdy/2);
        center_y = min(center_y,ymax - newdy/2);
        newYLim{i} = [max(ymin,center_y-newdy/2) min(ymax,center_y+newdy/2)];

        % Check for log axes and return to linear values.
        if isYLog
            newYLim{i} = 10.^newYLim{i}(1:2);
        end
    end

    %Check for strangeness in the limits:
    if newXLim{i}(1) >= newXLim{i}(2)
        newXLim{i} = currXLim{i};
    end
    if newYLim{i}(1) >= newYLim{i}(2)
        newYLim{i} = currYLim{i};
    end
    newLim{i} = [newXLim{i},newYLim{i}];

    axis(hAxes,newLim{i});
end
return
%       [ '[ cell2mat(x2cell(argouts('...
%         ' ''ind2sub( size(getappdata(gca, ''''Traces'''')),nonzeros(idxmember(findobj(gca, ''''Visible'''', ''''off'''') , getappdata(gca,''''Traces''''))))'' ,'...
%         ' ndims(getappdata(gca,''Traces''))))) ]' ]);
