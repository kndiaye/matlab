function  [varargout]=plotnd(action,varargin)
% plotnd - plots multidimensional data typically [ Channels x Time x Trials ]
%
%
%OPTIONS:
%	'XDim': abscissa dimension. Default: imax(size(data)),...
%   'DimensionNames', {{'Channel', 'Trial' , 'Condition', 'Field4', 'Field5'}}
%   'X':
%   'XLim'
%   'Values'
%   'Interactive', 1
%   'LinkedAxes': Plotting axes that should be linked
%
%   Example
%       >> plotnd(F)
%       >> plotnd('plot',F,Options)
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
% KND  2007-04-03 Renamed plotnd (because 'plotdata' is an eeglab function)
% KND  2009-09-09 Added zoom ability
% ----------------------------- Script History ---------------------------------
if nargin<1
    error('No data!')

elseif all(ishandle(action(:))) && (nargin==2)
    if isstruct(varargin{1}) && isfield(varargin{1},'VerticalScrollAmount')
        hf=action;
        action = 'wheelzoom';
        varargin=[ {hf} varargin(:) ];
    end
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
    'DimensionNames', {{'Channel','Time','Trial','Condition', 'Field4', 'Field5'}} ,...
    'X', [] ,...
    'XDim', [] ,...
    'XLim', [], ...
    'Values', [], ...
    'Interactive', 1, ...
    'LinkedAxes', [], ... % Link to other plots
    'ColorDim', NaN , ...
    'LineStyleDim', NaN ...
    );
if nargin < 2
    OPTIONS = Def_OPTIONS;
else
    if length(varargin)>1
        OPTIONS = cell2struct(varargin(2:2:end),varargin(1:2:end),2);% struct(varargin{:});
    elseif isnumeric(varargin{1})
        OPTIONS.X=varargin{1};
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

if ~isfield(OPTIONS, 'XDim') || isempty(OPTIONS.XDim)
    if isfield(OPTIONS, 'X') && ~isempty(OPTIONS.X)
        OPTIONS.XDim=find(size(data) == numel(OPTIONS.X));
        if numel(OPTIONS.XDim)>1
            warning('Multiple dimensions match the size of X... I take the 1st one');
        end
    else
        OPTIONS.XDim=imax(size(data));
    end
end

%% Reshape data & update dimension names
nf=ndims(data);
sz0 = size(data);
permdim = [OPTIONS.XDim setdiff(1:nf,OPTIONS.XDim)];
ipermdim(permdim) = 1:numel(permdim);
z = permute(data,permdim);
sz=[size(z) 1];
if isempty(OPTIONS.X)
    X=1:size(z,1);
else
    X=OPTIONS.X;
end
if length(OPTIONS.DimensionNames) < nf
    OPTIONS.DimensionNames(end+1:nf)=regexprep(cellstr(num2str([length(OPTIONS.DimensionNames)+1:nf]')), '(.*)', 'dim_$1');
end
for i=1:nf
    if isempty( OPTIONS.DimensionNames{i} )
        OPTIONS.DimensionNames{i}=sprintf('Dim #%d',i);
        if i==OPTIONS.XDim
            OPTIONS.DimensionNames{i}=[ OPTIONS.DimensionNames{i} ' (X-axis)'];
        end
    end
end
%% Plot options
cla
sz=[size(z)];
if numel(sz)<3
sz=[sz 1];
end
ncurves = prod(sz(2:end));
if isnan(OPTIONS.ColorDim)
    try
        OPTIONS.ColorDim = subarray(setdiff(find(sz0>1),OPTIONS.XDim),1);
    catch
        OPTIONS.ColorDim = [];
    end
end
if isnan(OPTIONS.LineStyleDim)
    try
    OPTIONS.LineStyleDim = subarray(setdiff(find(sz0>1),OPTIONS.XDim),2);    
    catch
         OPTIONS.LineStyleDim = [];
    end 
end
if ~isfield(OPTIONS, 'ColorOrder')
    co = get(gca, 'ColorOrder');
    d=ipermdim(OPTIONS.ColorDim);
    if size(co,1)>=sz(d)
        % Enough colors in the ColorOrder
        OPTIONS.ColorOrder = co(1:sz(d),:);
    else
        OPTIONS.ColorOrder=co;
        OPTIONS.ColorOrder(end+[1:ncurves-length(co)],:) = rand(ncurves-length(co),3);
    end
end
if ~isfield(OPTIONS, 'LineStyleOrder')
    lso = get(gca, 'LineStyleOrder');
    if ischar(lso)
        lso=strread(lso, '%s', 'delimiter', '|');
    end
    OPTIONS.LineStyleOrder = lso;
    d=ipermdim(OPTIONS.LineStyleDim);
    if length(lso)<sz(d)
        %Ideally also have LineWidth as an option for plot property...
        OPTIONS.LineStyleOrder = { '-' , ':' , '--', '-.' };
    end

end
set(gca, 'LineStyleOrder', OPTIONS.LineStyleOrder);
set(gca, 'ColorOrder', OPTIONS.ColorOrder);
%% Do plot
hold on
if ~isempty(OPTIONS.XLim)
    X = X(1:OPTIONS.XLim(i));
    z = subarray(z,1:OPTIONS.XLim(i),1);
end
% Warning: MATLAB cycles through the line styles only after using all
% colors defined by the ColorOrder property. This behaviour may not match
% what the user may have asked for.
hp=plot(X,z(:,:));%,'Color', 'b', 'LineStyle', '-');
hp=reshape(hp,sz(2:end));

%% Apply ColorOrder & LineStyleOrder
% Note for later use of 'd': The first dim is squeezed in the handles array
% hp.
% Apply Color
d=ipermdim(OPTIONS.ColorDim);
n=size(OPTIONS.ColorOrder,1);
if isempty(d)
    set(hp,'Color', OPTIONS.ColorOrder(1,:))
else
    for i=1:n
        set(subarray(hp, i:n:sz(d),(d-1)), 'Color', OPTIONS.ColorOrder(i,:))
    end
end
% Apply LineStyle
if ~isnan(OPTIONS.LineStyleDim)
    % lengthen diemsionality of data to match OPTIONS requirements
    sz((end+1):OPTIONS.LineStyleDim) = 1;
    ipermdim((end+1):OPTIONS.LineStyleDim) = (numel(ipermdim)+1):OPTIONS.LineStyleDim;
    
    d=ipermdim(OPTIONS.LineStyleDim);
    n=numel(OPTIONS.LineStyleOrder);
    if isempty(d)
        set(hp, 'LineStyle', OPTIONS.LineStyleOrder{1})
    else
        for i=1:n
            set(subarray(hp, i:n:sz(d),(d-1)), 'LineStyle', OPTIONS.LineStyleOrder{i})
        end
    end
end

hold off
ha=get(hp(1), 'Parent');
set(ha,'tag',mfilename);
x=OPTIONS;
x.Axes=ha;
x.DataSize=sz(2:end);
% x.Data=data;
x.Traces=hp;
x.Selected=[];
x.X=OPTIONS.X;
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
    %     'plotnd(permute(cell2mat(get(subarray(getappdata(get(gcbo, ''UserData''), ''Traces''),'...
    %     'subarray(getappdata(get(gcbo, ''UserData''), ''Selected''), 1), 1),''YData'')),[3 2 1]));'...
    % ]);
    if prod(sz)>1
        for i=1:length(sz)
            h2=uimenu('Label', sprintf('Display single (%s) traces', OPTIONS.DimensionNames{i}), 'Parent', h, 'Callback', [ ...
                'figure(''Name'', [ get(gcbf, ''Name'')  '', '' sprintf(''' sprintf('%s', OPTIONS.DimensionNames{i}) ...
                ' #%d'', subarray(getappdata(get(gcbo, ''UserData''), ''Selected''), ' sprintf('%d',i) '))]);' ...
                [ 'plotnd(reshape(shiftdim(cell2mat(x2cell(get(subarray(getappdata(get(gcbo, ''UserData''), ''Traces''),'] ...
                'subarray(getappdata(get(gcbo, ''UserData''), ''Selected''), ' sprintf('%d',i) '), ' sprintf('%d',i) '),''YData''))),1),'...
                '[subarray(getappdata(get(gcbo, ''UserData''),''DataSize''),' sprintf('%d',i+1) ', -2) 1])' ...
                ', ''XDim'',1, ''X'', getappdata(get(gcbo, ''UserData''),''X''), ' ...
                ' ''DimensionNames'', {subarray(getappdata(get(gcbo, ''UserData''),''DimensionNames''),' sprintf('%d',i) ', -2)} );'...
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

    % Zoom with Mouse Wheel
    
    if str2num(getfield(ver('Matlab'), 'Version'))>=7.4
        % I didn't know how to pass extra argument to a callback
        % (along with the hObject and event that I also need) so... 
        %       set(get(ha,'parent'), 'WindowScrollWheelFcn',str2func(mfilename));
        % NOW I know:
        set(get(ha,'parent'), 'WindowScrollWheelFcn',sprintf('@(src,event)%s(''wheelzoom'',src,event)', mfilename));
    end

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


function action_hide_add(x, sel, varargin)
% Hide selection
if ~isstruct(x)
    x=getappdata(x, mfilename);
end
if nargin<2
    sel=NaN;
end

if isnan(sel)
    sel=x.Selected;
elseif isscalar(sel)
    if sel<=0
        error('wrong input')
    end
    sel=x.Selected(end:-1:(end-abs(sel)+1));
end
idx = ind2logical(x.Traces,sel);
if nargin>2
    switch(varargin{1})
        case 'across_channels',
            idx(:,any(idx,1),:) = 1;
    end
end
set(x.Traces(idx), 'Visible', 'off');
return

function action_hide_rmv(x, sel)
% Put back non-selected style
if ~isstruct(x)
    if isempty(x)
        x=gca;
    end
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
return
%       [ '[ cell2mat(x2cell(argouts('...
%         ' ''ind2sub( size(getappdata(gca, ''''Traces'''')),nonzeros(idxmember(findobj(gca, ''''Visible'''', ''''off'''') , getappdata(gca,''''Traces''''))))'' ,'...
%         ' ndims(getappdata(gca,''Traces''))))) ]' ]);


function action_wheelzoom(hf,event)
% Mouse wheel button zoom
if isempty(event)
    return;
elseif (event.VerticalScrollCount < 0)
    % ZOOM IN
    zoom_factor  = 1 - event.VerticalScrollCount ./ 5;
elseif (event.VerticalScrollCount > 0)
    % ZOOM OUT
    zoom_factor  = 1./(1 + event.VerticalScrollCount ./ 5);
end
hAxes = get(gcf, 'CurrentAxes');
zoomPoint =  get(hAxes, 'CurrentPoint');
zoom_axes(zoom_factor, hAxes, zoomPoint(1,1:2));

function action_zoom(hAxes,zoom_factor,zoomPoint)
% Calls zoom_axes.m
zoom_axes(zoom_factor,hAxes,zoomPoint);