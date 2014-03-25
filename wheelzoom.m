function varargout = wheelzoom(action,varargin)
%wheelzoom - Control axes zoom using mouse wheel
%   wheelzoom(ha)
%   wheelzoom(ha,factor)
%
%   Example
%       >> wheelzoom(gca)
%
%   See also: 

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2005 
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% ----------------------------- Script History ---------------------------------
% KND  2005-12-15 Creation
%                   
% ----------------------------- Script History ---------------------------------

if nargin<1
    action='init';
elseif isa(varargin{1}, 'java') && isequal(get(varargin{1}, 'Type'), 'java.awt.event.MouseWheelEvent')
    action='wheel';
else 
    
end
out=eval(sprintf('action_%s(varargin{:});', action));
if nargout>0
    varargout=out;
end
return

function [varargout]=action_init(varargin)
if nargin<1
    ha=gca;
else
    ha=varargin{1};
end
if nargin<1
    ha=gca;
else
    ha=varargin{1};
end
if nargin<2
    wz.factor=1.5;
else
    wz.factor=varargin{2};
end

% Adapted from Nanne van der Zijpp's setMouseWheel
jobj=javax.swing.JLabel;
jobj.setOpaque(0);
[jobj,h] = javacomponent(jobj,[],get(ha,'Parent'));
% drawnow;
for i=1:100; % Number of attempts to get the RootPane
    RootPane=jobj.getRootPane; 
    pause(.01);
    if ~isempty(RootPane); break;end
end
delete(h);
% setappdata(ha,'RootPane',RootPane);
wz.RootPane=RootPane;
set(RootPane,'MouseWheelMovedCallback',str2func(sprintf('%s', mfilename)));
setappdata(ha,mfilename,wz);
varargout={{}};

function []=action_setfactor(ha,factor)
if nargin<2
    error('Wrong number of inputs. Needs axes handle & zoom factor')
end
wz=getappdata(ha,mfilename);
if isempty(wz)
   error('No WheelZoom for this axes handle!')
end 
wz.factor=factor;
setappdata(ha,mfilename,wz);

function [varargout]=action_wheel(varargin)
varargout={{}};
ha=overobj('axes');
if isempty(ha)
    return
end
wz=getappdata(ha,mfilename);
if isempty(wz)
    return
end
updown=get(varargin{1}, 'WheelRotation');
y=get(ha, 'Ylim');
y(3)=(y(2)+y(1))/2;
y(4:5)=wz.factor^updown*(y(2)-y(1))/2*[-1 +1];
if strmatch('on', get(varargin{1}, 'ControlDown'))
    % Control Button for pointer centered zooming
    c=get(gca, 'CurrentPoint');
    y(3)=c(3);
end
if strmatch('on', get(varargin{1}, 'ShiftDown'))
    % Shift Button for zero-centered zooming
    c=get(gca, 'CurrentPoint');
    y(3)=0;
    
end

% y=c(3)+wz.factor^updown*(y(2)-y(1))/2*[-1 +1];
%
set(ha, 'Ylim', y(3)+y(4:5))
