function scrollaxes(arg,arg2)
%scrollaxes Interactively scrollte the view of a 3-D plot.
%   scrollaxes ON turns on mouse-based scroll
%   scrollaxes OFF turns if off.
%   scrollaxes by itself toggles the state.
%
%   scrollaxes(FIG,...) works on the figure FIG.
%   scrollaxes(AXIS,...) works on the axis AXIS.
%       In this latter case, ONLY this axis will be scrollted.
%
%   See also ZOOM.

%   scrollaxes on enables  text feedback
%   scrollaxes ON disables text feedback.

%   Revised by Rick Paxson 10-25-96
%   Clay M. Thompson 5-3-94
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.46 $  $Date: 2002/06/14 18:45:51 $
%   KND : 2005-07-06 : Rotate ONLY pre-specified axis, if any.

if(nargin == 0)
    setState(gcf,'toggle');
elseif nargin==1
    if ishandle(arg)
        setState(arg,'toggle')
    else
        switch(lower(arg)) % how much performance hit here
            case 'motion'
                scrollMotionFcn
            case 'down'
                scrollButtonDownFcn
            case 'up'
                scrollButtonUpFcn
            case 'on'
                setState(gcf,arg);
            case 'off'
                setState(gcf,arg);
            otherwise
                error('Unknown action string.');
        end
    end
elseif nargin==2
    if ~ishandle(arg), error('Unknown figure.'); end
    switch(lower(arg2)) % how much performance hit here
        case 'on'
            setState(arg,arg2)
        case 'off'
            setState(arg,arg2);
        otherwise
            error('Unknown action string.');
    end
end

%--------------------------------
% Set activation state. Options on, ON, off
function setState(target,state)

% if the target is an axis, restrict to that
if strcmp(get(target,'Type'),'axes')
    axis = target;
    fig = get(axis,'Parent');
else   % otherwise, allow any axis in this figure
    axis = [];
    fig = target;
end
scrollObj = findobj(allchild(fig),'Tag','scrollObj');

% %KND : Add Button Rotate3DAxes in figure's toolbar 
% h=findall(fig,'Tag','figToolRotate3DAxes');
% if isempty(h)  
%     %disp('Creating Rotate3DAxes button');
%     h=findall(fig,'Tag','figToolRotate3D');
%     h=copyobj(h, get(h, 'Parent'));
%     set(h, 'Tag','figToolRotate3DAxes');
%     set(h, 'ClickedCallback', 'scrollaxes(gca), putdowntext(''scrollaxes'',gcbo)');
%     c=get(h, 'CData');
%     c(6:12,6:12,:)=1;
%     c(11,6:12,:)=0;
%     c(6:12,7,:)=0;
%     set(h, 'CData', c);
% end

if(strcmp(state,'toggle'))
    if(~isempty(scrollObj))
        setState(target,'off');
    else
        setState(target,'on');
    end
    return;
elseif(strcmp(lower(state),'on'))
    if(isempty(scrollObj))
        plotedit(fig,'locktoolbarvisibility');
        scrollObj = makeRotaObj(fig);
        if isempty(axis)
%             set(findall(fig,'Tag','figToolRotate3D'),'State','on');
            set(findall(fig,'Tag','figToolScrollAxes'),'State','off');
        else
%             set(findall(fig,'Tag','figToolRotate3D'),'State','off');
            set(findall(fig,'Tag','figToolScrollAxes'),'State','on');
        end
    end
    
    rdata = getappdata(scrollObj,'ScrollData');
    rdata.destAxis = axis;
    
    
    % Handle toggle of text feedback. ON means no feedback on means feedback.
    if(strcmp(state,'on'))
        rdata.textState = 1;
    else
        rdata.textState = 0;
    end
    setappdata(scrollObj,'ScrollData',rdata);
    % set this so we can know if Rotate3d is on
    % for now there is only one on state
    % and this app data will not exist if it is off
    setappdata(fig,'ScrollAxesOnState','on');
    scribefiglisten(fig,'on');
elseif(strcmp(lower(state),'off'))
    scribefiglisten(fig,'off');
%     set(findall(fig,'Tag','figToolScroll'),'State','off');
%     set(findall(fig,'Tag','figToolRotate3DAxes'),'State','off');
    if(~isempty(scrollObj))
        destroyRotaObj(scrollObj);
    end
    % get rid of on state appdata
    % if it exists.
    %     if isappdata(fig,'Rotate3dOnState')
    %         rmappdata(fig,'Rotate3dOnState');
    %     end
    
    scribefiglisten(fig,'off');
    state = getappdata(fig,'ScrollAxesFigureState');
    if ~isempty(state)
        % since we didn't set the pointer,
        % make sure it does not get reset
        ptr = get(fig,'pointer');
        % restore figure and non-uicontrol children
        % don't restore uicontrols because they were restored
        % already when scroll was turned on
        uirestore(state,'nouicontrols');
        set(fig,'pointer',ptr)
        if isappdata(fig,'ScrollAxesFigureState')
            rmappdata(fig,'ScrollAxesFigureState');
        end
    end
    if isappdata(fig,'ScrollAxesOnState')
        rmappdata(fig,'ScrollAxesOnState');
    end
end

%---------------------------
% Button down callback
function scrollButtonDownFcn
scrollObj = findobj(allchild(gcbf),'Tag','scrollObj');
if(isempty(scrollObj))
    return;
else
    rdata = getappdata(scrollObj,'ScrollData');
    
    %KND: Rotate ONLY the axes which were 
    if ~isempty(rdata.destAxis) & ~isequal(gca, rdata.destAxis)
        return
    end
    
    % Activate axis that is clicked in
    allAxes = findobj(datachildren(gcbf),'flat','type','axes');
    axes_found = 0;
    funits = get(gcbf,'units');
    set(gcbf,'units','pixels');
    for i=1:length(allAxes),
        ax=allAxes(i);
        cp = get(gcbf,'CurrentPoint');
        aunits = get(ax,'units');
        set(ax,'units','pixels')
        pos = get(ax,'position');
        set(ax,'units',aunits)
        if cp(1) >= pos(1) & cp(1) <= pos(1)+pos(3) & ...
                cp(2) >= pos(2) & cp(2) <= pos(2)+pos(4)
            axes_found = 1;
            set(gcbf,'currentaxes',ax);
            break
        end % if
    end % for
    set(gcbf,'units',funits)
    if axes_found==0, return, end
    
    if (not(isempty(rdata.destAxis)) & rdata.destAxis ~= ax) 
        return
    end       
    
    rdata.targetAxis = ax;
    rdata.XLim = get(ax,'XLim');
    
    % store the state on the zlabel:  that way if the user
    % plots over this axis, this state will be cleared and
    % we get to start over.
%     viewData = getappdata(get(ax,'ZLabel'),'ROTATEAxesView');
%     if isempty(viewData)
%         setappdata(get(ax,'ZLabel'),'ROTATEAxesView', get(ax, 'View'));
%     end
    
    selection_type = get(gcbf,'SelectionType');
    if strcmp(selection_type,'open')
        % this assumes that we will be getting a button up
        % callback after the open button down
        lims = getappdata(get(ax,'ZLabel'),'ROTATEAxesView');
        if(rdata.textState)
            set(rdata.textBoxText,'String',...
                sprintf('X: %4.0f %4.0f',lims));
        end
        set(scrollObj, 'XLim', lims);
        return
    end
    
    rdata.oldFigureUnits = get(gcbf,'Units');
    set(gcbf,'Units','pixels');
    rdata.oldPt = get(gcbf,'CurrentPoint');
    rdata.oldLims = [ get(rdata.targetAxis,'XLim') ; get(rdata.targetAxis,'YLim')];

    setappdata(scrollObj,'ScrollData',rdata);
    setOutlineObjToFitAxes(scrollObj);
    copyAxisProps(rdata.targetAxis, scrollObj);
    
    rdata = getappdata(scrollObj,'ScrollData');
    setappdata(scrollObj,'ScrollData',rdata);
    
    if(rdata.textState)
        fig_color = get(gcbf,'Color');
        % if the figure color is 'none', setting the uicontrol 
        % backgroundcolor to white and the foreground accordingly.
        if strcmp(fig_color, 'none')
            fig_color = [1 1 1];
        end
        c = sum([.3 .6 .1].*fig_color);
        set(rdata.textBoxText,'BackgroundColor',fig_color);
        if(c > .5)
            set(rdata.textBoxText,'ForegroundColor',[0 0 0]);
        else
            set(rdata.textBoxText,'ForegroundColor',[1 1 1]);
        end
        set(rdata.textBoxText,'Visible','on');
    end
    set(rdata.outlineObj,'Visible','on');
    set(gcbf,'WindowButtonMotionFcn','scrollaxes(''motion'')');
end

%-------------------------------
% Button up callback
function scrollButtonUpFcn
scrollObj = findobj(allchild(gcbf),'Tag','scrollObj');
if isempty(scrollObj) | ...
        ~strcmp(get(gcbf,'WindowButtonMotionFcn'),'scrollaxes(''motion'')')
    return;
else
    set(gcbf,'WindowButtonMotionFcn','');
    rdata = getappdata(scrollObj,'ScrollData');
    set([rdata.outlineObj rdata.textBoxText],'Visible','off');
    rdata.XLim = get(scrollObj,'XLim');
    set(rdata.targetAxis,'XLim',rdata.XLim);
%     set(gcbf,'Units',rdata.oldFigureUnits);
    setappdata(scrollObj,'ScrollData',rdata)
end

%-----------------------------
% Mouse motion callback
function scrollMotionFcn
scrollObj = findobj(allchild(gcbf),'Tag','scrollObj');
rdata = getappdata(scrollObj,'ScrollData');
switch get(get(rdata.targetAxis, 'Parent'), 'selectiontype') 
    case {'extend'}    
        new_pt = get(gcbf,'CurrentPoint');
        old_pt = rdata.oldPt;
        dx = new_pt(1) - old_pt(1);
        dy = new_pt(2) - old_pt(2);
        lims = mappingFunction(rdata, dx, dy);
        set(scrollObj,'XLim',lims);
    
    otherwise
        return       
        plims=get(rdata.targetAxis,'XLim');
        axis(rdata.targetAxis, 'normal');
        axis(rdata.targetAxis, 'tight');
        lims=get(rdata.targetAxis,'XLim');
        set(rdata.targetAxis,'XLim',plims);
        set(scrollObj,'XLim',lims);
         
end

% if(new_azel(2) < 0 & rdata.crossPos == 0)
%     set(rdata.outlineObj,'ZData',rdata.scaledData(4,:));
%     rdata.crossPos = 1;
%     setappdata(scrollObj,'ScrollData',rdata);
% end
% if(new_azel(2) > 0 & rdata.crossPos == 1) 
%     set(rdata.outlineObj,'ZData',rdata.scaledData(3,:));
%     rdata.crossPos = 0;
%     setappdata(scrollObj,'ScrollData',rdata);
% end
setappdata(scrollObj,'ScrollData',rdata);
if(rdata.textState)
    set(rdata.textBoxText,'String',sprintf('X: %4.0f %4.0f',lims));
end

%----------------------------
% Map a dx dy to a zoomed window on data
function lims = mappingFunction(rdata, dx, dy)
lims = rdata.XLim;
ctr = (lims(1)+lims(2))/2;
width = (lims(2)-lims(1))/2;
lims = ctr+[-width width]*exp(dy/rdata.GAIN(2));
lims= lims + width*rdata.GAIN(1)*(-dx);

%-----------------------------
% Scale data to fit target axes limits
function setOutlineObjToFitAxes(scrollObj)
rdata = getappdata(scrollObj,'ScrollData');
ax = rdata.targetAxis;
x_extent = get(ax,'XLim');
y_extent = get(ax,'YLim');
z_extent = get(ax,'ZLim');
X = rdata.outlineData;
X(1,:) = X(1,:)*diff(x_extent) + x_extent(1);
X(2,:) = X(2,:)*diff(y_extent) + y_extent(1);
X(3,:) = X(3,:)*diff(z_extent) + z_extent(1);
X(4,:) = X(4,:)*diff(z_extent) + z_extent(1);
set(rdata.outlineObj,'XData',X(1,:),'YData',X(2,:),'ZData',X(3,:));
rdata.scaledData = X;
setappdata(scrollObj,'ScrollData',rdata);

%-------------------------------
% Copy properties from one axes to another.
function copyAxisProps(original, dest)
props = {
    'DataAspectRatio'
    'DataAspectRatioMode'
    'CameraViewAngle'
    'CameraViewAngleMode'
    'XLim'
    'YLim'
    'ZLim'
    'PlotBoxAspectRatio'
    'PlotBoxAspectRatioMode'
    'Units'
    'Position'
    'View'
    'Projection'
};
values = get(original,props);
set(dest,props,values);

%-------------------------------------------
% Constructor for the Rotate object.
function scrollObj = makeRotaObj(fig)

% save the previous state of the figure window
% rdata.uistate = uiclearmode(fig,'scroll',fig,'off');

rdata.targetAxis = []; % Axis that is being scrollted (target axis)
rdata.destAxis = []; % the axis the caller specified (may be [])
rdata.GAIN    = [ 1e-2 40 ] ;    % Motion gain
rdata.oldPt   = [];  % Point where the button down happened
rdata.oldLims = [];
curax = get(fig,'currentaxes');
scrollObj = axes('Parent',fig,'Visible','off','HandleVisibility','off','Drawmode','fast');
nondataobj = [];
setappdata(scrollObj,'NonDataObject',nondataobj);
% Data points for the outline box.
rdata.outlineData = [0 0 1 0;0 1 1 0;1 1 1 0;1 1 0 1;0 0 0 1;0 0 1 0; ...
        1 0 1 0;1 0 0 1;0 0 0 1;0 1 0 1;1 1 0 1;1 0 0 1;0 1 0 1;0 1 1 0; ...
        NaN NaN NaN NaN;1 1 1 0;1 0 1 0]'; 
rdata.outlineObj = line(rdata.outlineData(1,:),rdata.outlineData(2,:),rdata.outlineData(3,:), ...
    'Parent',scrollObj,'Erasemode','xor','Visible','off','HandleVisibility','off', ...
    'Clipping','off');

% Make text box.
fig_color = get(fig, 'Color');

% if the figure color is 'none', setting the uicontrol 
% backgroundcolor to white and the foreground accordingly.
if strcmp(fig_color, 'none')
    fig_color = [1 1 1];
end
rdata.textBoxText = uicontrol('parent',fig,'Units','Pixels','Position',[2 2 130 20],'Visible','off', ...
    'Style','text','BackgroundColor', fig_color,'HandleVisibility','off');

rdata.textState = [];
rdata.oldFigureUnits = '';
rdata.crossPos = 0;  % where do we put the X at zmin or zmax? 0 means zmin 1 means zmax
rdata.scaledData = rdata.outlineData;


state = getappdata(fig,'Rotate3dFigureState');
if isempty(state)
    % turn off all other interactive modes
    state = uiclearmode(fig,'docontext','scrollaxes',fig,'off');
    % restore button down functions for uicontrol children of the figure
    uirestore(state,'uicontrols');
    setappdata(fig,'Rotate3dFigureState',state);
end


set(fig,'WindowButtonDownFcn','scrollaxes(''down'')');
set(fig,'WindowButtonUpFcn'  ,'scrollaxes(''up'')');
set(fig,'WindowButtonMotionFcn','');
set(fig,'ButtonDownFcn','');

set(scrollObj,'Tag','scrollObj');
setappdata(scrollObj,'ScrollData',rdata);
set(fig,'currentaxes',curax)

%----------------------------------
% Deactivate scrollte object
function destroyRotaObj(scrollObj)
rdata = getappdata(scrollObj,'ScrollData');

% uirestore(rdata.uistate);

delete(rdata.textBoxText);
delete(scrollObj);
