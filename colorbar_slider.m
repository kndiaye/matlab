function varargout = colorbar_slider(action,varargin)
%COLORBAR_SLIDER - Add a GUI slider next to the colorbar
%   [h] = colorbar_slider([ha])
%   [h] = colorbar_slider('init',ha)
%       Adds a slider on the side of the specified colorbar
%       (default: current colorbar, added if none) 
%
%   Example
%       >> colorbar_slider
%
%   See also: 

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2006 
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% ----------------------------- Script History ---------------------------------
% KND  2006-01-03 Creation
%                   
% ----------------------------- Script History ---------------------------------

if nargin<1
    ha=colorbar;
    varargin={ha};
    action='init';
elseif nargin==1 || isnumeric(action)    
    ha=action;
    action='init';
    if ishandle(ha)
        if ~strmatch('Colorbar', get(ha, 'tag'))
            ha=colorbar(ha);
        end
        varargin=[{ha} varargin ];
    end
end
        
try
    varargout={eval(sprintf('action_%s(varargin{:});',action))};
catch
    eval(sprintf('action_%s(varargin{:});',action)); 
end


function [h]=action_init(ha,varargin)
pos=get(ha, 'Position');
h=findobj(get(ha,'parent'), 'tag', mfilename);

if ~isempty(h)
    if all(all(getappdata(h, 'CurrentColormap')==colormap))
        colormap(ha,getappdata(h, 'BaseColormap') )
        delete(h)
    end
end

h=uicontrol('style', 'slider', 'units', get(ha,'units'),'tag', mfilename);
% Check orientation of colorbar 
if isempty(get(ha, 'Xtick')) 
    % vertical colorbar
    if strmatch('right',get(ha, 'YAxisLocation'))
        set(h, 'Position',pos*[1 0 -0.5 0;0 1 0 0; 0 0 .5 0; 0 0 0 1]')
    else
        set(h, 'Position',pos*[1 0 +1.5 0;0 1 0 0; 0 0 .5 0; 0 0 0 1]')
    end
    set(h, 'Min',min(get(ha, 'YLim')), 'max',max(get(ha, 'YLim')),'value',min(get(ha, 'YLim')))
else
    % horizontal colorbar
    if strmatch('top',get(ha, 'XAxisLocation'))
        set(h, 'Position',pos*[1 0 0 0;0 1 0 -0.5; 0 0 1 0; 0 0 0 .5]')
    else
        set(h, 'Position',pos*[1 0 0 0;0 1 0 +1.5; 0 0 1 0; 0 0 0 .5]')
    end
    set(h, 'Min',min(get(ha, 'XLim')), 'max',max(get(ha, 'XLim')),'value',min(get(ha, 'XLim')))
end
% set(h, 'SliderStep', (get(h,'Max')-get(h,'Min')).*[1/100 1/10]);
set(h, 'UserData', ha);
setappdata(h, 'Colorbar', ha);
setappdata(h, 'Figure', get(ha,'Parent'));
setappdata(h, 'BaseColormap', colormap);
setappdata(h, 'BaseColor', [.6 .6 .6]);
setappdata(h, 'CurrentColormap', colormap);
set(h, 'Callback', sprintf('%s(''slide'', gcbo);', mfilename));
return


function [h]=action_slide(h,varargin)
x=get(h, 'Value');
h=action_value(h,x);

function [h]=action_value(h,x)
cmap=getappdata(h, 'BaseColormap');
n=round((x-get(h,'Min'))/(get(h,'Max')-get(h,'Min'))*size(cmap,1));
cmap(1:n,:)=repmat(getappdata(h,'BaseColor'), n,1);
colormap(getappdata(h,'Colorbar'),cmap);
setappdata(h, 'CurrentColormap', colormap);