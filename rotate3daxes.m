function rotate3daxes(arg,arg2)
%rotate3daxes Interactively rotate the view of a 3-D plot.
%   rotate3daxes ON turns on mouse-based 3-D rotation.
%   rotate3daxes OFF turns if off.
%   rotate3daxes by itself toggles the state.
%
%   rotate3daxes(FIG,...) works on the figure FIG.
%   rotate3daxes(AXIS,...) works on the axis AXIS.
%       In this latter case, ONLY this axis will be rotated.
%
%   See also ZOOM.

%   rotate3daxes on enables  text feedback
%   rotate3daxes ON disables text feedback.

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
                rotaMotionFcn
            case 'down'
                rotaButtonDownFcn
            case 'up'
                rotaButtonUpFcn
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
rotaObj = findobj(allchild(fig),'Tag','rotaObj');

%KND : Add Button Rotate3DAxes in figure's toolbar 
h=findall(fig,'Tag','figToolRotate3DAxes');
if isempty(h)  
    %disp('Creating Rotate3DAxes button');
    h=findall(fig,'Tag','figToolRotate3D');
    h=copyobj(h, get(h, 'Parent'));
    set(h, 'Tag','figToolRotate3DAxes');
    set(h, 'ClickedCallback', 'rotate3daxes(gca), putdowntext(''rotate3daxes'',gcbo)');
    c=get(h, 'CData');
    c(6:12,6:12,:)=1;
    c(11,6:12,:)=0;
    c(6:12,7,:)=0;
    set(h, 'CData', c);
end

if(strcmp(state,'toggle'))
    if(~isempty(rotaObj))
        setState(target,'off');
    else
        setState(target,'on');
    end
    return;
elseif(strcmp(lower(state),'on'))
    if(isempty(rotaObj))
        plotedit(fig,'locktoolbarvisibility');
        rotaObj = makeRotaObj(fig);
        if isempty(axis)
            set(findall(fig,'Tag','figToolRotate3D'),'State','on');
            set(findall(fig,'Tag','figToolRotate3DAxes'),'State','off');
        else
            set(findall(fig,'Tag','figToolRotate3D'),'State','off');
            set(findall(fig,'Tag','figToolRotate3DAxes'),'State','on');
        end
    end
    
    rdata = get(rotaObj,'UserData');
    rdata.destAxis = axis;
    
    % Handle toggle of text feedback. ON means no feedback on means feedback.
    if(strcmp(state,'on'))
        rdata.textState = 1;
    else
        rdata.textState = 0;
    end
    set(rotaObj,'UserData',rdata);
    % set this so we can know if Rotate3d is on
    % for now there is only one on state
    % and this app data will not exist if it is off
    setappdata(fig,'Rotate3dOnState','on');
    scribefiglisten(fig,'on');
elseif(strcmp(lower(state),'off'))
    scribefiglisten(fig,'off');
    set(findall(fig,'Tag','figToolRotate3D'),'State','off');
    set(findall(fig,'Tag','figToolRotate3DAxes'),'State','off');
    if(~isempty(rotaObj))
        destroyRotaObj(rotaObj);
    end
    % get rid of on state appdata
    % if it exists.
    %     if isappdata(fig,'Rotate3dOnState')
    %         rmappdata(fig,'Rotate3dOnState');
    %     end
    
    scribefiglisten(fig,'off');
    state = getappdata(fig,'Rotate3dFigureState');
    if ~isempty(state)
        % since we didn't set the pointer,
        % make sure it does not get reset
        ptr = get(fig,'pointer');
        % restore figure and non-uicontrol children
        % don't restore uicontrols because they were restored
        % already when rotate3d was turned on
        uirestore(state,'nouicontrols');
        set(fig,'pointer',ptr)
        if isappdata(fig,'Rotate3dFigureState')
            rmappdata(fig,'Rotate3dFigureState');
        end
    end
    if isappdata(fig,'Rotate3dOnState')
        rmappdata(fig,'Rotate3dOnState');
    end
end

%---------------------------
% Button down callback
function rotaButtonDownFcn
rotaObj = findobj(allchild(gcbf),'Tag','rotaObj');
if(isempty(rotaObj))
    return;
else
    rdata = get(rotaObj,'UserData');
    
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
    
    % store the state on the zlabel:  that way if the user
    % plots over this axis, this state will be cleared and
    % we get to start over.
    viewData = getappdata(get(ax,'ZLabel'),'ROTATEAxesView');
    if isempty(viewData)
        setappdata(get(ax,'ZLabel'),'ROTATEAxesView', get(ax, 'View'));
    end
    
    selection_type = get(gcbf,'SelectionType');
    if strcmp(selection_type,'open')
        % this assumes that we will be getting a button up
        % callback after the open button down
        new_azel = getappdata(get(ax,'ZLabel'),'ROTATEAxesView');
        if(rdata.textState)
            set(rdata.textBoxText,'String',...
                sprintf('Az: %4.0f El: %4.0f',new_azel));
        end
        set(rotaObj, 'View', new_azel);
        return
    end
    
    rdata.oldFigureUnits = get(gcbf,'Units');
    set(gcbf,'Units','pixels');
    rdata.oldPt = get(gcbf,'CurrentPoint');
    rdata.oldAzEl = get(rdata.targetAxis,'View');
    
    % Map azel from -180 to 180.
    rdata.oldAzEl = rem(rem(rdata.oldAzEl+360,360)+180,360)-180; 
    if abs(rdata.oldAzEl(2))>90
        % Switch az to other side.
        rdata.oldAzEl(1) = rem(rem(rdata.oldAzEl(1)+180,360)+180,360)-180;
        % Update el
        rdata.oldAzEl(2) = sign(rdata.oldAzEl(2))*(180-abs(rdata.oldAzEl(2)));
    end
    
    set(rotaObj,'UserData',rdata);
    setOutlineObjToFitAxes(rotaObj);
    copyAxisProps(rdata.targetAxis, rotaObj);
    
    rdata = get(rotaObj,'UserData');
    if(rdata.oldAzEl(2) < 0)
        rdata.CrossPos = 1;
        set(rdata.outlineObj,'ZData',rdata.scaledData(4,:));
    else
        rdata.CrossPos = 0;
        set(rdata.outlineObj,'ZData',rdata.scaledData(3,:));
    end
    set(rotaObj,'UserData',rdata);
    
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
    set(gcbf,'WindowButtonMotionFcn','rotate3daxes(''motion'')');
end

%-------------------------------
% Button up callback
function rotaButtonUpFcn
rotaObj = findobj(allchild(gcbf),'Tag','rotaObj');
if isempty(rotaObj) | ...
        ~strcmp(get(gcbf,'WindowButtonMotionFcn'),'rotate3daxes(''motion'')')
    return;
else
    set(gcbf,'WindowButtonMotionFcn','');
    rdata = get(rotaObj,'UserData');
    set([rdata.outlineObj rdata.textBoxText],'Visible','off');
    rdata.oldAzEl = get(rotaObj,'View');
    set(rdata.targetAxis,'View',rdata.oldAzEl);
    set(gcbf,'Units',rdata.oldFigureUnits);
    set(rotaObj,'UserData',rdata)
end

%-----------------------------
% Mouse motion callback
function rotaMotionFcn
rotaObj = findobj(allchild(gcbf),'Tag','rotaObj');
rdata = get(rotaObj,'UserData');
new_pt = get(gcbf,'CurrentPoint');
old_pt = rdata.oldPt;
dx = new_pt(1) - old_pt(1);
dy = new_pt(2) - old_pt(2);
new_azel = mappingFunction(rdata, dx, dy);
set(rotaObj,'View',new_azel);
if(new_azel(2) < 0 & rdata.crossPos == 0)
    set(rdata.outlineObj,'ZData',rdata.scaledData(4,:));
    rdata.crossPos = 1;
    set(rotaObj,'UserData',rdata);
end
if(new_azel(2) > 0 & rdata.crossPos == 1) 
    set(rdata.outlineObj,'ZData',rdata.scaledData(3,:));
    rdata.crossPos = 0;
    set(rotaObj,'UserData',rdata);
end
if(rdata.textState)
    set(rdata.textBoxText,'String',sprintf('Az: %4.0f El: %4.0f',new_azel));
end

%----------------------------
% Map a dx dy to an azimuth and elevation
function azel = mappingFunction(rdata, dx, dy)
delta_az = round(rdata.GAIN*(-dx));
delta_el = round(rdata.GAIN*(-dy));
azel(1) = rdata.oldAzEl(1) + delta_az;
azel(2) = min(max(rdata.oldAzEl(2) + 2*delta_el,-90),90);
if abs(azel(2))>90
    % Switch az to other side.
    azel(1) = rem(rem(azel(1)+180,360)+180,360)-180; % Map new az from -180 to 180.
    % Update el
    azel(2) = sign(azel(2))*(180-abs(azel(2)));
end

%-----------------------------
% Scale data to fit target axes limits
function setOutlineObjToFitAxes(rotaObj)
rdata = get(rotaObj,'UserData');
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
set(rotaObj,'UserData',rdata);

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
function rotaObj = makeRotaObj(fig)

% save the previous state of the figure window
% rdata.uistate = uiclearmode(fig,'rotate3d',fig,'off');

rdata.targetAxis = []; % Axis that is being rotated (target axis)
rdata.destAxis = []; % the axis the caller specified (may be [])
rdata.GAIN    = 0.4;    % Motion gain
rdata.oldPt   = [];  % Point where the button down happened
rdata.oldAzEl = [];
curax = get(fig,'currentaxes');
rotaObj = axes('Parent',fig,'Visible','off','HandleVisibility','off','Drawmode','fast');
nondataobj = [];
setappdata(rotaObj,'NonDataObject',nondataobj);
% Data points for the outline box.
rdata.outlineData = [0 0 1 0;0 1 1 0;1 1 1 0;1 1 0 1;0 0 0 1;0 0 1 0; ...
        1 0 1 0;1 0 0 1;0 0 0 1;0 1 0 1;1 1 0 1;1 0 0 1;0 1 0 1;0 1 1 0; ...
        NaN NaN NaN NaN;1 1 1 0;1 0 1 0]'; 
rdata.outlineObj = line(rdata.outlineData(1,:),rdata.outlineData(2,:),rdata.outlineData(3,:), ...
    'Parent',rotaObj,'Erasemode','xor','Visible','off','HandleVisibility','off', ...
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
    state = uiclearmode(fig,'docontext','rotate3daxes',fig,'off');
    % restore button down functions for uicontrol children of the figure
    uirestore(state,'uicontrols');
    setappdata(fig,'Rotate3dFigureState',state);
end


set(fig,'WindowButtonDownFcn','rotate3daxes(''down'')');
set(fig,'WindowButtonUpFcn'  ,'rotate3daxes(''up'')');
set(fig,'WindowButtonMotionFcn','');
set(fig,'ButtonDownFcn','');

set(rotaObj,'Tag','rotaObj','UserData',rdata);
set(fig,'currentaxes',curax)

%----------------------------------
% Deactivate rotate object
function destroyRotaObj(rotaObj)
rdata = get(rotaObj,'UserData');

% uirestore(rdata.uistate);

delete(rdata.textBoxText);
delete(rotaObj);
