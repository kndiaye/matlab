function  [varargout]=plotdata(action,varargin);
% plotdata - plots multiple data typically [ Channels x Time x Trials ]
%
%   Example
%       >> plotdata(F)
%       >> plotdata('plot',F,Options)
%   See also:

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2004
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% ----------------------------- Script History ---------------------------------
% KND  2004-12-15 Creation
% KND  2005-12-15 Now links between many plotdata axes
% ----------------------------- Script History ---------------------------------
if nargin<1
    error('No data!')
elseif nargin==1 || isnumeric(action)
    varargin=[{action} varargin ];
    action='plot';
end

try
    varargout={eval(sprintf('action_%s(varargin{:});',action))};
catch
    eval(sprintf('action_%s(varargin{:});',action)); 
end


function [ha]=action_plot(data, varargin)
% -------------------------------------------------------------------------
% Check OPTIONS and default values when optional arguments are not
% specified
Def_OPTIONS = struct(...
    'TimeDim',imax(size(data)),...
    'Fields', {{'Channel', 'Trial' , 'Condition', 'Field4', 'Field5'}} ,...
    'Time', [] ,...
    'TimeWindow', [], ...
    'Values', [], ...
    'Interactive', 1, ...
    'LinkedAxes', [] ... % Link to other plots
    );
if nargin < 2
    OPTIONS = Def_OPTIONS;
else
    if length(varargin)>1
        OPTIONS = cell2struct(varargin(2:2:end),varargin(1:2:end),2);% struct(varargin{:});
    else
        OPTIONS = varargin{1};
    end
    % Check field names of passed OPTIONS and fill missing ones with default values
    DefFieldNames = fieldnames(Def_OPTIONS);
    for k = 1:length(DefFieldNames)
        if ~isfield(OPTIONS,DefFieldNames{k})
            OPTIONS = setfield(OPTIONS,DefFieldNames{k},getfield(Def_OPTIONS,DefFieldNames{k}));
        end
    end
    clear DefFieldNames
end
clear Def_OPTIONS
% -------------------------------------------------------------------------

z=permute(data, [OPTIONS.TimeDim 1:(OPTIONS.TimeDim-1) (OPTIONS.TimeDim+1):ndims(data)]);
if isempty(OPTIONS.Time)
    Time=1:size(z,1);
else
    Time=OPTIONS.Time;
end
nf=ndims(data)-1;
if length(OPTIONS.Fields) < nf
    OPTIONS.Fields(end+1:nf)={[]};
end
for i=1:nf
    if isempty( OPTIONS.Fields{i} )
        OPTIONS.Fields{i}=sprintf('Field %d',i);
    end
end
cla
if isempty(OPTIONS.TimeWindow)
    hp=plot(Time,z(:,:));
else
    hold on
    for i=1:size(z(:,:),2);
        hp(i)=plot(Time(1:OPTIONS.TimeWindow(i)), z(1:OPTIONS.TimeWindow(i),i), 'Color',subarray(get(gca, 'ColorOrder'), mod(i-1,size(get(gca, 'ColorOrder'),1))+1));
    end
    hold off
end
ha=get(hp(1), 'Parent');
sz=[size(z)];
x=OPTIONS;
x.Axes=ha;
x.DataSize=sz;
% x.Data=data;
x.Time=OPTIONS.Time;
sz(1)=[];
sz=[sz 1];
hp=reshape(hp,sz);
x.Traces=hp;
x.Selected=[];
setappdata(ha,mfilename,x)
for i=1:length(x.LinkedAxes)
    y=getappdata(x.LinkedAxes(i),mfilename);
    y.LinkedAxes=[y.LinkedAxes x.Axes];
    setappdata(y.Axes, mfilename, y);
end
if OPTIONS.Interactive
    set(hp, 'ButtonDownFcn', sprintf('%s(''click_trace'', gcbo)', mfilename));
    title('Click on a trace')
    h=uicontextmenu;

    uimenu('Label', 'Unselect all' ,   'Parent', h, 'Callback', sprintf('%s(''select_rmv'',overobj(''axes''))', mfilename));   
    uimenu('Label', 'Unselect visible ones' ,   'Parent', h, 'Callback', sprintf('%s(''select_rmv'',overobj(''axes''), ''Visible'', ''on'')', mfilename));   
    uimenu('Label', 'Hide selected traces' ,   'Parent', h, 'Callback', sprintf('%s(''hide_add'',overobj(''axes''))', mfilename));
    % 'set(getappdata(get(gcbo, ''UserData''), ''SelectedHandle''), ''Visible'', ''off'')');
    uimenu('Label', 'Un-hide last selected trace', 'Parent', h, 'Callback', sprintf('%s(''hide_rmv'',overobj(''axes''),1)', mfilename));
    % 'set(getappdata(get(gcbo, ''UserData''), ''SelectedHandle''), ''Visible'', ''on'')');
    uimenu('Label', 'Un-hide all traces', 'Parent', h, 'Callback', sprintf('%s(''hide_rmv'',overobj(''axes''))', mfilename));
    %'set(getappdata(get(gcbo, ''UserData''), ''Traces''), ''Visible'', ''on'')');
    uimenu('Label', 'List hidden traces', 'parent', h, 'Callback', sprintf('%s(''hide_list'',gca)', mfilename));

    %
    % uimenu('Label', 'Display single channel traces', 'Parent', h, 'Separator', 'on', 'Callback', [ ...
    %     'figure(''Name'', sprintf(''Channel #%d'', subarray(getappdata(get(gcbo, ''UserData''), ''Selected''), 1)));'...
    %     'plotdata(permute(cell2mat(get(subarray(getappdata(get(gcbo, ''UserData''), ''Traces''),'...
    %     'subarray(getappdata(get(gcbo, ''UserData''), ''Selected''), 1), 1),''YData'')),[3 2 1]));'...
    % ]);
    if prod(sz)>1
        for i=1:length(sz)
            h2=uimenu('Label', sprintf('Display single (%s) traces', OPTIONS.Fields{i}), 'Parent', h, 'Callback', [ ...
                'figure(''Name'', [ get(gcbf, ''Name'')  '', '' sprintf(''' sprintf('%s', OPTIONS.Fields{i}) ' #%d'', subarray(getappdata(get(gcbo, ''UserData''), ''Selected''), ' sprintf('%d',i) '))]);' ...
                'plotdata(reshape(shiftdim(cell2mat(x2cell(get(subarray(getappdata(get(gcbo, ''UserData''), ''Traces''),'...
                'subarray(getappdata(get(gcbo, ''UserData''), ''Selected''), ' sprintf('%d',i) '), ' sprintf('%d',i) '),''YData''))),1),'...
                '[subarray(getappdata(get(gcbo, ''UserData''),''DataSize''),' sprintf('%d',i+1) ', -2) 1])' ...
                ', ''TimeDim'',1, ''Time'', getappdata(get(gcbo, ''UserData''),''Time''), ' ...
                ' ''Fields'', {subarray(getappdata(get(gcbo, ''UserData''),''Fields''),' sprintf('%d',i) ', -2)} );'...
                ]);
            if i==1
                set(h2, 'separator', 'on')
            end

        end

        uimenu('separator', 'on', 'Label', 'Select one trace', 'Parent', h, 'Callback', 'set(getappdata(get(gcbo, ''UserData''), ''Traces''), ''Visible'', ''on'')');

    end
    set(get(h, 'Children'),'UserData', ha);
    set(hp, 'uicontextmenu', h);
    set(ha, 'uicontextmenu', h);

end

function sel=handles2ind(x,ho)
if ~isstruct(x)
    x=getappdata(x, mfilename);
end
sel=ind2sub2(size(x.Traces), idxmember(ho,x.Traces));

function b=ind2logical(traces,sel)
b=logical(zeros(size(traces)));
sel=num2cell(sel);
for i=1:size(sel,1)
    b(sel{i,:})=1;
end
return

function []=action_click_trace(ho)
ha=get(ho(1), 'Parent');
hf=get(ha, 'Parent');
if ismember(get(hf, 'SelectionType'), {'normal', 'extend'})
    action_select_toggle(ha,handles2ind(ha,ho));
end

function action_select_toggle(x, sel)
% Toggle selected/not-selected style
if ~isstruct(x)
    x=getappdata(x, mfilename);
end
for i=1:size(sel,1)
    if ismember(sel,x.Selected, 'rows')
        action_select_rmv(x, sel(i,:))
    else
        action_select_add(x, sel(i,:))
    end
end


function action_select_add(x, sel,link)
% Put back non-selected style
if nargin<2
    error('No selection')
end
if ~isstruct(x)
    x=getappdata(x, mfilename);
end
x.Selected=[x.Selected;sel];
set(x.Traces(ind2logical(x.Traces,sel)), 'LineWidth', 2);
setappdata(x.Axes, mfilename, x);
set(get(x.Axes,'Title'), 'String', [ 'Selection: [ ' sprintf('%d ', sel) ']']);
if nargin<3
    link=[];
end
if all(link)>0
    link=[link x.Axes];
    ToBeLinked=setdiff(x.LinkedAxes,link);    
    for i=1:length(ToBeLinked)
        action_select_add(ToBeLinked(i),sel,link)
    end
end
return

function action_select_rmv(x, sel,link)
% Put back to non-selected style
if ~isstruct(x)
    x=getappdata(x, mfilename);
end
if nargin<2
    % If unspecified act on the previously selected traces
    sel=x.Selected;
end
if nargin>1
    if ischar(sel)
        sel=findobj(x.Traces(ind2logical(x.Traces,x.Selected)), sel, link);
        sel=handles2ind(x, sel);
        link=[];
    end
end
x.Selected=x.Selected(~ismember(x.Selected, sel, 'rows'),:);
set(x.Traces(ind2logical(x.Traces,sel)), 'LineWidth', .5);
setappdata(x.Axes, mfilename, x);
if nargin<3 
    link=[];
end
if all(link)>0
    link=[link x.Axes];
    ToBeLinked=setdiff(x.LinkedAxes,link);    
    for i=1:length(ToBeLinked)
        action_select_rmv(ToBeLinked(i), sel,link)
    end
end
return

function action_hide_toggle(x, sel)
% Toggle selected/not-selected style
if ~isstruct(x)
    x=getappdata(x, mfilename);
end
for i=1:size(sel,1)
    if ismember(sel,x.Selected, 'rows')
        action_hide_rmv(x, sel(i,:))
    else
        action_hide_add(x, sel(i,:))
    end
end


function action_hide_add(x, sel)
% Hide selection
if ~isstruct(x)
    x=getappdata(x, mfilename);
end
if nargin<2
    sel=x.Selected;
elseif isscalar(sel) 
    if sel<=0
        error('wrong input')
    end
    sel=x.Selected(end:-1:(end-abs(sel)+1));
end
set(x.Traces(ind2logical(x.Traces,sel)), 'Visible', 'off');
return

function action_hide_rmv(x, sel)
% Put back non-selected style
if ~isstruct(x)
    x=getappdata(x, mfilename);
end
if nargin<2
    % If unspecified act on the previously selected traces
    sel=x.Selected;
elseif isscalar(sel) 
    if sel<=0
        error('wrong input')
    end    
    if isequal(get(x.Traces(ind2logical(x.Traces,x.Selected(end,:))), 'Visible'), 'on')
    % If we are being selecting a trace, we unselect it and go one step
    % further in the selected list.
        action_select_rmv(x,x.Selected(end,:))
        x=getappdata(x.Axes, mfilename);
    end
    sel=x.Selected(end:-1:(end-abs(sel)+1),:);
end
set(x.Traces(ind2logical(x.Traces,sel)), 'Visible', 'on');
return

function action_hide_list(x)
% List (in command window) the hidden traces
if ~isstruct(x)
    x=getappdata(x, mfilename);
end
disp(handles2ind(x ,findobj(x.Traces, 'Visible','off')))

%       [ '[ cell2mat(x2cell(argouts('...
%         ' ''ind2sub( size(getappdata(gca, ''''Traces'''')),nonzeros(idxmember(findobj(gca, ''''Visible'''', ''''off'''') , getappdata(gca,''''Traces''''))))'' ,'...
%         ' ndims(getappdata(gca,''Traces''))))) ]' ]);
