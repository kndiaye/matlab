function [] = explorer(action, varargin)
%EXPLORER - One line description goes here.
%   [] = explorer( ... )
%
%   Example
%       >> explorer
%
%   See also:

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2009
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2009-11-05 Creation
%
% ----------------------------- Script History ---------------------------------

if nargin<1
    error('Nothing to do!')
elseif nargin==1 || isnumeric(action)
    varargin=[{action} varargin ];
    action='init';
end

try
    varargout={eval(sprintf('action_%s(varargin{:});',action))};
catch
    eval(sprintf('action_%s(varargin{:});',action));
end
return

%% Initialize the plots
function [ha]=action_init(varargin)
if isstruct(varargin{1})
    F=getfield(varargin{1},'F');
    R=getfield(varargin{1},'R');
elseif nargin==1
    F=varargin{1};
else
    if isstruct(varargin{2})
        F=varargin{1};
        R=varargin{2};
        EOG = structmatch(R.Channel, 'Type', 'OTHER');
    else
        F=varargin{1};
        EOG = varargin{2};
    end
end

if iscell(F)
    EOG=F{2};
    F=F{1};
end

elec_sel = 1:size(F,1);

G=F;
if exist('R', 'var')
    elec_selection =   structmatch(R.Channel,'Type','EEG',0);  
    F=subarray(F,elec_selection,1);
end
F=abs(F);

figure(1)
clf
ha(1)= subplot(2,2,1)
h{1} = plot(squeeze(rootmeansquare(F)));
set(h{1}, 'ButtonDownFcn', 'explorer(''hide'', gcbo)')


ha(2)= subplot(2,2,2)
h{2} = plot(squeeze(max(F)));
title('Max across sensors (for each trial)')
set(h{2}, 'ButtonDownFcn', 'explorer(''hide'', gcbo)')

ha(3)= subplot(2,2,3)
h{3} = plot(max(F,[],3)');
title('Max across trials (for each sensor)')
set(h{3}, 'ButtonDownFcn', 'explorer(''hide'', gcbo)')

set(ha, 'Ylim', [0 4e-4])
for i=ha(:)'
    axes(i)
    vline(1050);
    vline(1383);
end

if 0
    for i=1:size(F,3)
        h{4}(i) = subplot(20,20,211+mod(i-1,10)+20*floor((i-1)/10))
        plot(G([ 1:2 imax(max(G(:,:,i),[],2)) imax(max(-G(:,:,i),[],2)) ],:,i)')
        hold on
        if exist('EOG', 'var')
            plot(EOG(:,:,i)')
        end
        axis off
        %pause
    end
end

drawnow
s.F = F;
s.h = h;
s.ha=ha;
s.hui = [];
setappdata(gcf,mfilename,s)
set(ha, 'Units' ,'normalized')

if ~exist('R', 'var')
return
end

%% Electrode list

EEG = structmatch(R.Channel, 'Type', 'EEG');
p = get(ha(1),'position')
p(1) = [.05];p(3) = [.05];
hui.electrodelist = uicontrol('style', 'list', 'Units', 'normalized', 'Position', p)
set(hui.electrodelist, 'String', {R.Channel.Name})
% Multiple selection
set(hui.electrodelist, 'Max',2)
set(hui.electrodelist, 'Value',find(elec_selection))
% Button:
hui.electrodepush = uicontrol('style', 'pushbutton', 'Units', 'normalized', 'Position', [p(1) p(2)-.03 p(3) 0.025])
set(hui.electrodepush, 'String', 'Plot')
set(hui.electrodepush, 'Callback', [mfilename '(''replot_elec'',gcbo,gcbf)'])
% Textbox:
hui.electrodetxt = uicontrol('style', 'edit', 'Units', 'normalized', 'Position', [p(1) p(2)+p(4)+.005 p(3) 0.025])
set(hui.electrodetxt, 'String', '')
set(hui.electrodetxt, 'Callback', [mfilename '(''filter_elec'',gcbo,gcbf)'])

%% Trial list
p = get(ha(3),'position')
p(1) = [.05];p(3) = [.05];
hui.triallist = uicontrol('style', 'list', 'Units', 'normalized', 'Position', p)
set(hui.triallist, 'String', num2str([1:size(F,3)]'))
% Multiple selection
set(hui.triallist, 'Max',2)

p(2) = p(2)-.03; p(4) = 0.025;
hui.trialpush = uicontrol('style', 'pushbutton', 'Units', 'normalized', 'Position', p)
set(hui.trialpush, 'String', 'Plot')

s.hui = hui;
setappdata(gcf,mfilename,s)

return

%% Action HIDE
function action_hide(varargin)
s=getappdata(gcf,mfilename);
h=s.h;
ha = s.ha;

o   = varargin{2};

fprintf('click: ');

ax = find([ha] == get(o,'parent'));

i = find(o==h{ax});

fprintf('hiding: trace #%d on plot #%d\n', i, ax);
set(h{ax}(i), 'Visible', 'off');

% bads:
b{1} = cell2mat(cellfun2('isequal', get(h{3}, 'Visible'), 'off'));
b{3} = [ ...
    cell2mat(cellfun2('isequal', get(h{1}, 'Visible'), 'off')) | ...
    cell2mat(cellfun2('isequal', get(h{2}, 'Visible'), 'off')) ];

fprintf('bad electrodes: %s\n', sprintf('%d ', find(b{1})));
fprintf('bad trials....: %s\n', sprintf('%d ', find(b{3})));

axis(h{4}(b{3}), 'on');
set(h{4}(b{3}), 'xtick', [], 'Ytick', [])


F=s.F;

subplot(2,2,1)
hold on
delete(h{1})
h{1} = plot(squeeze(rootmeansquare(F(~b{1},:,:))));
set(h{1}(b{3}), 'visible' , 'off')
set(h{1}, 'ButtonDownFcn', 'explorer(''hide'', gcbo)')

subplot(2,2,2)
hold on
delete(h{2})
h{2} = plot(squeeze(max(F(~b{1},:,:))));
set(h{2}(b{3}), 'visible' , 'off')
set(h{2}, 'ButtonDownFcn', 'explorer(''hide'', gcbo)')

subplot(2,2,3)
hold on
delete(h{3})
h{3} = plot(max(F,[],3)');
set(h{3}, 'ButtonDownFcn', 'explorer(''hide'', gcbo)')
set(h{3}(b{1}), 'visible' , 'off')

s.h=h;
setappdata(gcf,mfilename,s)

function []=action_filter_elec(varargin)
fig = [];
if ishandle(varargin{1})
    flt = get(varargin{1}, 'String');
    fig = get(varargin{1}, 'Parent');
else
    flt = varargin{1};
end
if nargin>1
    fig =varargin{2};
end
s=getappdata(fig,mfilename);
hui = s.hui;


%update_elec_disp



function []=action_replot_elec(varargin)
fig = [];
elec_selection = NaN;
if ishandle(varargin{1})
    fig = get(varargin{1}, 'Parent');
else
    elec_selection = varargin{1};
end
if nargin>1
    fig =varargin{2};
end
s=getappdata(fig,mfilename);
h=s.h;
ha = s.ha;
hui = s.hui;

if isnan(elec_selection)
    elec_selection = get(hui.electrodelist, 'Value');
end

F= s.F; 
F = subarray(F,elec_selection,1);
axes(ha(1))
h{1} = plot(squeeze(rootmeansquare(F)));
set(h{1}, 'ButtonDownFcn', 'explorer(''hide'', gcbo)')
s.h=h;
setappdata(fig,mfilename,s);

