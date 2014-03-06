function varargout = gui_figure3DViz( varargin )
% GUI_FIGURE3DVIZ: Creation and callbacks for 3D visualization figures.
%
% USAGE: 
%        [hFig] = gui_figure3DViz()                        : Create default figure
%        [hFig] = gui_figure3DViz(FigureId, figureName)    : Create named figure
%        [hFig] = gui_figure3DViz(FigureId)                : Create unnamed figure
%                 gui_figure3DViz('CurrentTimeChangedCallback', iDS, iFig)
%                 gui_figure3DViz('ColormapChangedCallback',    iDS, iFig, ColormapType)    
%                 gui_figure3DViz('FigureClickCallback',        hFig, event)  
%                 gui_figure3DViz('FigureMouseMoveCallback',    hFig, event)  
%                 gui_figure3DViz('FigureMouseUpCallback',      hFig, event)  
%                 gui_figure3DViz('FigureMouseWheelCallback',   hFig, event)  
%                 gui_figure3DViz('FigureKeyPressedCallback',   hFig, keyEvent)   
%                 gui_figure3DViz('ResetView',                  hFig)
%                 gui_figure3DViz('SetStandardView',            hFig, viewNames)
%                 gui_figure3DViz('DisplayFigurePopup',         hFig)
% [Chan,ChanLoc]= gui_figure3DViz('GetSelectedChannels',        iDS, iFig)
%                 gui_figure3DViz('UpdateSelectedChannels',     iDS, iFig)
%                 gui_figure3DViz('UpdateSurfaceColor',    hFig, iTess)
%                 gui_figure3DViz('ViewSensors',           hFig, isMarkers, isLabels)
%                 gui_figure3DViz('ViewAxis',              hFig, isVisible)
%     [hFig,hs] = gui_figure3DViz('PlotSurface',           hFig, faces, verts, cdata, dataCMap, transparency)

% @=============================================================================
% This software is part of The Brainstorm Toolbox
% http://neuroimage.usc.edu/brainstorm
% 
% Copyright (c)2009 Brainstorm by the University of Southern California
% This software is distributed under the terms of the GNU General Public License
% as published by the Free Software Foundation. Further details on the GPL
% license can be found at http://www.gnu.org/copyleft/gpl.html.
% 
% FOR RESEARCH PURPOSES ONLY. THE SOFTWARE IS PROVIDED "AS IS," AND THE
% UNIVERSITY OF SOUTHERN CALIFORNIA AND ITS COLLABORATORS DO NOT MAKE ANY
% WARRANTY, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO WARRANTIES OF
% MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, NOR DO THEY ASSUME ANY
% LIABILITY OR RESPONSIBILITY FOR THE USE OF THIS SOFTWARE.
%
% For more information type "brainstorm licence" at command prompt.
% =============================================================================@
%
% Authors: Francois Tadel, 2008
% ----------------------------- Script History ---------------------------------
% FT  24-Jun-2008  Creation
% ------------------------------------------------------------------------------

%% ===== CALL TO A SUBFUNCTION =====
if (nargin >= 1) && ischar(varargin{1}) 
    if (nargout)
        [varargout{1:nargout}] = bst_safeCall(str2func(varargin{1}), varargin{2:end});
    else
        bst_safeCall(str2func(varargin{1}), varargin{2:end});
    end
    return
    
%% ===== CREATE FIGURE =====
% Create default figure
% CALL: [hFig] = gui_figure3DViz()
elseif (nargin == 0)
    % Create a new 3DViz figure
    FigureId = db_getDataTemplate('FigureId');
    FigureId.Type     = '3DViz';
    FigureId.SubType  = '';
    FigureId.Modality = '';
    [hFig, hAxes] = gui_figure3DViz(FigureId, '3D');
    % Set figure visible
    set(hFig, 'Visible', 'on');
    % Return values
    if (nargout >= 1)
        varargout{1} = hFig;
    end
    if (nargout >= 2)
        varargout{2} = hAxes;
    end
    
% CALL: [hFig] = gui_figure3DViz(FigureId, figureName) : Create named figure
%       [hFig] = gui_figure3DViz(FigureId)             : Create unnamed figure
elseif isstruct(varargin{1})
    % Get FigureId and figure Name
    FigureId   = varargin{1};
    if (nargin >= 2)
        figureName = varargin{2};
    else
        figureName = '3D';
    end
    % Get renderer name
    rendererName = 'opengl';

    % === CREATE FIGURE ===
    hFig = figure('Visible',       'off', ...
                  'NumberTitle',   'off', ...
                  'IntegerHandle', 'off', ...
                  'MenuBar',       'none', ...
                  'Toolbar',       'none', ...
                  'DockControls',  'on', ...
                  'Units',         'pixels', ...
                  'Color',         [0 0 0], ...
                  'Tag',           FigureId.Type, ...
                  'Name',          figureName, ...
                  'Renderer',      rendererName, ...
                  'CloseRequestFcn',       @(h,ev)gui_figuresManager('DeleteFigure',h,ev), ...
                  'KeyPressFcn',           @(h,ev)bst_safeCall(@FigureKeyPressedCallback,h,ev), ...
                  'WindowButtonDownFcn',   @FigureClickCallback, ...
                  'WindowButtonMotionFcn', @FigureMouseMoveCallback, ...
                  'WindowButtonUpFcn',     @FigureMouseUpCallback, ...
                  'ResizeFcn',             @(h,ev)bst_colormaps('ResizeCallbackForColorbar', h, ev), ...
                  'BusyAction',    'queue', ...
                  'Interruptible', 'off');   
    % Define Mouse wheel callback separately (not supported by old versions of Matlab)
    bstVersion = bst_getContext('Version');
    if bstVersion.MatlabVersion >= 7.4
        set(hFig, 'WindowScrollWheelFcn',  @FigureMouseWheelCallback);
    end
    
    % === CREATE AXES ===
    hAxes = axes('Parent',   hFig, ...
                 'Units',    'normalized', ...
                 'Position', [.05 .05 .9 .9], ...
                 'Tag',      'Axes3D', ...
                 'Visible',  'off', ...
                 'BusyAction',    'queue', ...
                 'Interruptible', 'off');
    axis vis3d
    axis equal 
    axis off
         
    % === APPDATA STRUCTURE ===
    setappdata(hFig, 'Surface',     repmat(db_getDataTemplate('TessInfo'), 0));
    setappdata(hFig, 'iSurface',    []);
    setappdata(hFig, 'StudyFile',   []);   
    setappdata(hFig, 'SubjectFile', []);      
    setappdata(hFig, 'DataFile',    []); 
    setappdata(hFig, 'ResultsFile', []);
    setappdata(hFig, 'isSelectingCorticalSpot', 0);
    setappdata(hFig, 'isSelectingCoordinates',  0);
    setappdata(hFig, 'hasMoved',    0);
    setappdata(hFig, 'isPlotEditToolbar',   0);
    setappdata(hFig, 'AllChannelsDisplayed', 0);
    setappdata(hFig, 'FigureId', FigureId);
    setappdata(hFig, 'isStatic', 0);

    % === LIGHTING ===
    hl = [];
    % Fixed lights
    hl(1) = camlight(  0,  40, 'infinite');
    hl(2) = camlight(180,  40, 'infinite');
    hl(3) = camlight(  0, -90, 'infinite');
    hl(4) = camlight( 90,   0, 'infinite');
    hl(5) = camlight(-90,   0, 'infinite');
    % Moving camlight
    hl(6) = light('Tag', 'FrontLight', 'Color', [1 1 1], 'Style', 'infinite', 'Parent', hAxes);
    camlight(hl(6), 'headlight');
    % Mute the intensity of the lights
    for i = 1:length(hl)
        set(hl(i), 'color', .4*[1 1 1]);
    end
    
    % Camera basic orientation
    SetStandardView(hFig, 'top');
    
    % Returned values
    if (nargout >= 1)
        varargout{1} = hFig;
    end
    if (nargout >= 2)
        varargout{2} = hAxes;
    end
end
end


%% =========================================================================================
%  ===== FIGURE CALLBACKS ==================================================================
%  =========================================================================================
function Compile() %#ok<DEFNU>
    % Nothing to do... just to force the compilation of the file
end

%% ===== CURRENT TIME CHANGED =====
function CurrentTimeChangedCallback(iDS, iFig) %#ok<DEFNU>
    global GlobalData;
    panel_surface('UpdateSurfaceData', GlobalData.DataSet(iDS).Figure(iFig).hFigure);
end
    
%% ===== COLORMAP CHANGED =====
% Usage:  ColormapChangedCallback(iDS, iFig, ColormapType) : Update display only if target colormap is used in figure
%         ColormapChangedCallback(iDS, iFig)               : Update display anyway
function ColormapChangedCallback(iDS, iFig, ColormapType) %#ok<DEFNU>
    global GlobalData;
    panel_surface('UpdateSurfaceColormap', GlobalData.DataSet(iDS).Figure(iFig).hFigure);
end


    
%% =========================================================================================
%  ===== KEYBOARD AND MOUSE CALLBACKS ======================================================
%  =========================================================================================
% Complete mouse and keyboard management over the main axes
% Supports : - Customized 3D-Rotation (LEFT click)
%            - Pan (SHIFT+LEFT click, OR MIDDLE click
%            - Zoom (CTRL+LEFT click, OR RIGHT click, OR WHEEL)
%            - Colorbar contrast/brightness
%            - Restore original view configuration (DOUBLE click)

%% ===== FIGURE CLICK CALLBACK =====
function FigureClickCallback(hFig, varargin)   
%disp('=== MouseDown ===');
    % Find axes
    hAxes = findobj(hFig, 'Tag', 'Axes3D');
    if isempty(hAxes)
        warning('Brainstorm:NoAxes', 'Axes could not be found');
        return;
    end
    % Get figure type
    FigureId = getappdata(hFig, 'FigureId');
    % Double click: reset view           
    if strcmpi(get(hFig, 'SelectionType'), 'open')
        ResetView(hFig);
    end
    % Check if MouseUp was executed before MouseDown
    if isappdata(hFig, 'clickAction') && strcmpi(getappdata(hFig,'clickAction'), 'MouseDownNotConsumed')
        % Should ignore this MouseDown event
        setappdata(hFig,'clickAction','MouseDownOk');
        return;
    end
   
    % Start an action (pan, zoom, rotate, contrast, luminosity)
    % Action depends on : 
    %    - the mouse button that was pressed (LEFT/RIGHT/MIDDLE), 
    %    - the keys that the user presses simultaneously (SHIFT/CTRL)
    clickAction = '';
    switch(get(hFig, 'SelectionType'))
        % Left click
        case 'normal'
            % 2DLayout: pan
            if strcmpi(FigureId.SubType, '2DLayout')
                clickAction = 'pan';
            % 2D: nothing
            elseif ismember(FigureId.SubType, {'2DDisc', '2DSensorCap'})
                % Nothing to do
            % Else (3D): rotate
            else
                clickAction = 'rotate';
            end
        % CTRL+Mouse, or Mouse right
        case 'alt'
            clickAction = 'popup';
        % SHIFT+Mouse, or Mouse middle
        case 'extend'
            clickAction = 'pan';
    end
    
    % Record action to perform when the mouse is moved
    setappdata(hFig, 'clickAction', clickAction);
    setappdata(hFig, 'clickSource', hFig);
    % Reset the motion flag
    setappdata(hFig, 'hasMoved', 0);
    % Record mouse location in the figure coordinates system
    setappdata(hFig, 'clickPositionFigure', get(hFig, 'CurrentPoint'));
    % Record mouse location in the axes coordinates system
    setappdata(hFig, 'clickPositionAxes', get(hAxes, 'CurrentPoint'));
%disp('=== MouseDown: END ===');
end

    
%% ===== FIGURE MOVE =====
function FigureMouseMoveCallback(hFig, varargin)  
    % Get axes handle
    hAxes = findobj(hFig, 'tag', 'Axes3D');
    % Get current mouse action
    clickAction = getappdata(hFig, 'clickAction');   
    clickSource = getappdata(hFig, 'clickSource');   
    % If no action is currently performed
    if isempty(clickAction)
        % Colorbar help message
%         ColorbarHelpMessage(hFig);
        return
    end
    % If MouseUp was executed before MouseDown
    if strcmpi(clickAction, 'MouseDownNotConsumed') || isempty(getappdata(hFig, 'clickPositionFigure'))
        % Ignore Move event
        return
    end
    % If source is not the same as the current figure: fire mouse up event
    if (clickSource ~= hFig)
        FigureMouseUpCallback(hFig);
        FigureMouseUpCallback(clickSource);
        return
    end

    % Set the motion flag
    setappdata(hFig, 'hasMoved', 1);
    % Get current mouse location in figure
    curptFigure = get(hFig, 'CurrentPoint');
    motionFigure = 0.3 * (curptFigure - getappdata(hFig, 'clickPositionFigure'));
    % Get current mouse location in axes
    curptAxes = get(hAxes, 'CurrentPoint');
    oldptAxes = getappdata(hFig, 'clickPositionAxes');
    if isempty(oldptAxes)
        return
    end
    motionAxes = curptAxes - oldptAxes;
    % Update click point location
    setappdata(hFig, 'clickPositionFigure', curptFigure);
    setappdata(hFig, 'clickPositionAxes',   curptAxes);
    % Get figure size
    figPos = get(hFig, 'Position');
       
    % Switch between different actions (Pan, Rotate, Zoom, Contrast)
    switch(clickAction)              
        case 'rotate'
            % Else : ROTATION
            % Rotation functions : 5 different areas in the figure window
            %     ,---------------------------.
            %     |             2             |
            % .75 |---------------------------| 
            %     |   3  |      5      |  4   |   
            %     |      |             |      | 
            % .25 |---------------------------| 
            %     |             1             |
            %     '---------------------------'
            %           .25           .75
            %
            % ----- AREA 1 -----
            if (curptFigure(2) < .25 * figPos(4))
                camroll(hAxes, motionFigure(1));
                camorbit(hAxes, 0,-motionFigure(2), 'camera');
            % ----- AREA 2 -----
            elseif (curptFigure(2) > .75 * figPos(4))
                camroll(hAxes, -motionFigure(1));
                camorbit(hAxes, 0,-motionFigure(2), 'camera');
            % ----- AREA 3 -----
            elseif (curptFigure(1) < .25 * figPos(3))
                camroll(hAxes, -motionFigure(2));
                camorbit(hAxes, -motionFigure(1),0, 'camera');
            % ----- AREA 4 -----
            elseif (curptFigure(1) > .75 * figPos(3))
                camroll(hAxes, motionFigure(2));
                camorbit(hAxes, -motionFigure(1),0, 'camera');
            % ----- AREA 5 -----
            else
                camorbit(hAxes, -motionFigure(1),-motionFigure(2), 'camera');
            end
            camlight(findobj(hAxes, 'Tag', 'FrontLight'), 'headlight');

        case 'pan'
            % Get camera textProperties
            pos    = get(hAxes, 'CameraPosition');
            up     = get(hAxes, 'CameraUpVector');
            target = get(hAxes, 'CameraTarget');
            % Calculate a normalised right vector
            right = cross(up, target - pos);
            up    = up ./ realsqrt(sum(up.^2));
            right = right ./ realsqrt(sum(right.^2));
            % Calculate new camera position and camera target
            panFactor = 0.001;
            pos    = pos    + panFactor .* (motionFigure(1).*right - motionFigure(2).*up);
            target = target + panFactor .* (motionFigure(1).*right - motionFigure(2).*up);
            set(hAxes, 'CameraPosition', pos, 'CameraTarget', target);

        case 'zoom'
            if (motionFigure(2) == 0)
                return;
            elseif (motionFigure(2) < 0)
                % ZOOM IN
                Factor = 1-motionFigure(2)./100;
            elseif (motionFigure(2) > 0)
                % ZOOM OUT
                Factor = 1./(1+motionFigure(2)./100);
            end
            zoom(hFig, Factor);
            
        case {'moveSlices', 'popup'}
            % Get MRI
            [sMri,TessInfo,iTess] = panel_surface('GetSurfaceMri', hFig);
            if isempty(iTess)
                return
            end
            
            % === DETECT ACTION ===
            % Is moving axis and direction are not detected yet : do it
            if (~isappdata(hFig, 'moveAxis') || ~isappdata(hFig, 'moveDirection'))
                % Guess which cut the user is trying to change
                % Sometimes some problem occurs, leading to values > 800
                % for a 1-pixel movement => ignoring
                if (max(motionAxes(1,:)) > 20)
                    return;
                end
                % Convert MRI-CS -> SCS
                motionAxes = motionAxes * sMri.SCS.R;
                % Get the maximum deplacement as the direction
                [value, moveAxis] = max(abs(motionAxes(1,:)));
                moveAxis = moveAxis(1);
                % Get the directions of the mouse deplacement that will
                % increase or decrease the value of the slice
                [value, moveDirection] = max(abs(motionFigure));                   
                moveDirection = sign(motionFigure(moveDirection(1))) .* ...
                                sign(motionAxes(1,moveAxis)) .* ...
                                moveDirection(1);
                % Save the detected movement direction and orientation
                setappdata(hFig, 'moveAxis',      moveAxis);
                setappdata(hFig, 'moveDirection', moveDirection);
                
            % === MOVE SLICE ===
            else                
                % Get saved information about current motion
                moveAxis      = getappdata(hFig, 'moveAxis');
                moveDirection = getappdata(hFig, 'moveDirection');
                % Get the motion value
                val = sign(moveDirection) .* motionFigure(abs(moveDirection));
                % Get the new position of the slice
                oldPos = TessInfo(iTess).CutsPosition(moveAxis);
                newPos = round(saturate(oldPos + val, [1 size(sMri.Cube, moveAxis)]));
                
                % Plot a patch that indicates the location of the cut
                PlotSquareCut(hFig, TessInfo(iTess), moveAxis, newPos);

                % Draw a new X-cut according to the mouse motion
                posXYZ = [NaN, NaN, NaN];
                posXYZ(moveAxis) = newPos;
                panel_surface('PlotMri', hFig, posXYZ);
            end
            
        case 'colorbar'
            % Delete legend
            % delete(findobj(hFig, 'Tag', 'ColorbarHelpMsg'));
            % Get colormap name           
            [AllColormapTypes, ColormapType] = gui_figuresManager('GetDisplayedDataTypes', hFig);
            % Changes contrast
            sColormap = bst_colormaps('ColormapChangeModifiers', ColormapType, [motionFigure(1), motionFigure(2)] ./ 100, 0);
            set(hFig, 'Colormap', sColormap.CMap);
    end
%disp('=== MouseMove: END ===');
end

                
%% ===== FIGURE MOUSE UP =====        
function FigureMouseUpCallback(hFig, varargin)
%disp('=== MouseUp ===');
    global GlobalData;
    % === 3DViz specific commands ===
    % Get application data (current user/mouse actions)
    clickAction = getappdata(hFig, 'clickAction');
    hasMoved    = getappdata(hFig, 'hasMoved');
    hAxes       = findobj(hFig, 'tag', 'Axes3D');
    isSelectingCorticalSpot = getappdata(hFig, 'isSelectingCorticalSpot');
    isSelectingCoordinates  = getappdata(hFig, 'isSelectingCoordinates');
    
    % Remove mouse appdata (to stop movements first)
    setappdata(hFig, 'hasMoved', 0);
    if isappdata(hFig, 'clickPositionFigure')
        rmappdata(hFig, 'clickPositionFigure');
    end
    if isappdata(hFig, 'clickPositionAxes')
        rmappdata(hFig, 'clickPositionAxes');
    end
    if isappdata(hFig, 'clickAction')
        rmappdata(hFig, 'clickAction');
    else
        setappdata(hFig, 'clickAction', 'MouseDownNotConsumed');
    end
    if isappdata(hFig, 'moveAxis')
        rmappdata(hFig, 'moveAxis');
    end
    if isappdata(hFig, 'moveDirection')
        rmappdata(hFig, 'moveDirection');
    end
    % Remove SquareCut objects
    PlotSquareCut(hFig);
    % Get figure description
    [hFig, iFig, iDS] = gui_figuresManager('GetFigure', hFig);
    if isempty(iDS)
        return
    end
    Figure = GlobalData.DataSet(iDS).Figure(iFig);
    % Update figure selection
    if strcmpi(Figure.Id.Type, '3DViz') || strcmpi(Figure.Id.SubType, '3DSensorCap')
        gui_figuresManager('SetCurrentFigure', hFig, '3D');
    else
        gui_figuresManager('SetCurrentFigure', hFig);
    end
    
    % ===== SIMPLE CLICK ===== 
    % If user did not move the mouse since the click
    if ~hasMoved
        % === POPUP ===
        if strcmpi(clickAction, 'popup')
            DisplayFigurePopup(hFig);
            
        % === SELECTING CORTICAL SCOUTS ===
        elseif isSelectingCorticalSpot
            panel_scouts('SelectCorticalSpot', hFig);
            
        % === SELECTING POINT (COORDINATES PANEL) ===
        elseif isSelectingCoordinates
            panel_coordinates('SelectPoint', hFig);
            
        % === SELECTING SENSORS ===
        else
            % Check if sensors are displayed in this figure
            hSensorsPatch = findobj(hAxes, 'Tag', 'SensorsPatch');
            if (length(hSensorsPatch) == 1)
                % Select the nearest sensor from the mouse
                [p, v, vi] = select3d(hSensorsPatch);
                % If sensor index is not valid
                if isempty(vi) || (vi > length(Figure.SelectedChannels)) || (vi <= 0)
                    return
                end
                % If clicked point is too far away (5mm) from the closest sensor
                % (Do not test Topography figures)
                if ~strcmpi(Figure.Id.Type, 'Topography')
                    if (norm(p - v) > 0.005)
                        return
                    end
                end
                % Is figure used only to display channels
                AllChannelsDisplayed = getappdata(hFig, 'AllChannelsDisplayed');
                % If not all the channels are displayed: need to convert the selected sensor indice
                if ~AllChannelsDisplayed
                    % Get channel indice (in Channel array)
                    iChannel = Figure.SelectedChannels(vi);
                else
                    AllModalityChannels = good_channel(GlobalData.DataSet(iDS).Channel, ...
                                                       [], Figure.Id.Modality);
                    iChannel = AllModalityChannels(vi);
                end
                % If channel is not selected
                if ~ismember(iChannel, GlobalData.DataSet(iDS).MouseSelectedChannels)
                    % If data is not supposed to have more than one channel selected
                    if isappdata(hFig, 'UniqueChannelSelection') && (getappdata(hFig, 'UniqueChannelSelection') == 1)
                        newList = iChannel;
                    else
                        newList = [GlobalData.DataSet(iDS).MouseSelectedChannels, iChannel];
                    end
                    % Add it to mouse-selected channels list
                    bst_dataSetsManager('SetMouseSelectedChannels', GlobalData.DataSet(iDS).ChannelFile, newList);   
                % Channel is already mouse-selected : unselect it
                else
                    % Remove it from mouse-selected channels list
                    bst_dataSetsManager('SetMouseSelectedChannels', GlobalData.DataSet(iDS).ChannelFile, ...
                        setdiff(GlobalData.DataSet(iDS).MouseSelectedChannels, iChannel));
                end
            end
        end
    % ===== MOUSE HAS MOVED ===== 
    else
        % COLORMAP HAS CHANGED
        if strcmpi(clickAction, 'colorbar')
            % Apply new colormap to all figures
            [AllColormapTypes, ColormapType] = gui_figuresManager('GetDisplayedDataTypes', hFig);
            bst_colormaps('FireColormapChanged', ColormapType);
        % SLICES WERE MOVED
        elseif strcmpi(clickAction, 'popup')
            % Update "Surfaces" panel
            panel_surface('UpdateSurfaceProperties');            
        end
    end
%disp('=== MouseUp: END ===');    
end


%% ===== FIGURE MOUSE WHEEL =====
function FigureMouseWheelCallback(hFig, event)  
    % ONLY FOR 3D AND 2DLayout
    if isempty(event)
        return;
    elseif (event.VerticalScrollCount < 0)
        % ZOOM IN
        Factor = 1 - event.VerticalScrollCount ./ 20;
    elseif (event.VerticalScrollCount > 0)
        % ZOOM OUT
        Factor = 1./(1 + event.VerticalScrollCount ./ 20);
    end
    zoom(Factor);
end


%% ===== KEYBOAD CALLBACK =====
function FigureKeyPressedCallback(hFig, keyEvent)   
    global GlobalData TimeSliderMutex;
    % Prevent multiple executions
    hAxes = findobj(hFig, 'Tag', 'Axes3D');
    set([hFig hAxes], 'BusyAction', 'cancel');
    % Get figure description
    [hFig, iFig, iDS] = gui_figuresManager('GetFigure', hFig);
    if isempty(hFig)
        return
    end
    FigureId = GlobalData.DataSet(iDS).Figure(iFig).Id;
    % ===== GET SELECTED CHANNELS =====
    isMenuSelectedChannels = 0;
    if ~isempty(iDS) 
        % Get channel selection
        MouseSelection = GlobalData.DataSet(iDS).MouseSelectedChannels;
        if ~isempty(MouseSelection) && ~isempty(FigureId.Modality) && (FigureId.Modality(1) ~= '$')
            isMenuSelectedChannels = 1;
        end
    end
    % Get if figure should contain all the modality sensors (display channel net)
    AllChannelsDisplayed = getappdata(hFig, 'AllChannelsDisplayed');
    % Check if it is a realignment figure
    isAlignFig = ~isempty(findobj(hFig, 'Tag', 'AlignToolbar'));
    % If figure is 2D
    is2D = ~strcmpi(FigureId.Type, '3DViz') && ~strcmpi(FigureId.SubType, '3DSensorCap');
        
    % ===== PROCESS BY CHARACTERS =====
    switch (keyEvent.Character)
        % === NUMBERS : VIEW SHORTCUTS ===
        case '1'
            if ~is2D
                SetStandardView(hFig, 'left');
            end
        case '2'
            if ~is2D
                SetStandardView(hFig, 'bottom');
            end
        case '3'
            if ~is2D
                SetStandardView(hFig, 'right');
            end
        case '4'
            if ~is2D
                SetStandardView(hFig, 'front');
            end
        case '5'
            if ~is2D
                SetStandardView(hFig, 'top');
            end
        case '6'
            if ~is2D
                SetStandardView(hFig, 'back');
            end
        case '7'
            if ~isAlignFig && ~is2D
                SetStandardView(hFig, {'left', 'right'});
            end
        case '8'
            if ~isAlignFig && ~is2D
                SetStandardView(hFig, {'bottom', 'top'});
            end
        case '9'
            if ~isAlignFig && ~is2D
                SetStandardView(hFig, {'front', 'back'});      
            end
        case '0'
            if ~isAlignFig && ~is2D
                SetStandardView(hFig, {'left', 'right', 'top'});
            end
        case '='
            if ~isAlignFig && ~is2D
                ApplyViewToAllFigures(hFig);
            end
        % === SCOUTS : GROW/SHRINK ===
        case '+'
            panel_scouts('EditScoutsSize', 'Grow1');
        case '-'
            panel_scouts('EditScoutsSize', 'Shrink1');
                                   
        otherwise
            % ===== PROCESS BY KEYS =====
            switch (keyEvent.Key)
                % === LEFT, RIGHT, PAGEUP, PAGEDOWN : Processed by TimeWindow  ===
                case {'leftarrow', 'rightarrow', 'pageup', 'pagedown'}
                    if isempty(TimeSliderMutex) || ~TimeSliderMutex
                        panel_timeWindow('SliderKeyCallback',hFig, keyEvent);
                    end
                % === DATABASE NAVIGATOR ===
                case {'f1', 'f2', 'f3', 'f4'}
                    if ~isAlignFig
                        gui_figuresManager('NavigatorKeyPress', hFig, keyEvent);
                    end
                % === DATA FILES : OTHER VIEWS ===
                % CTRL+A : View axis
                case 'a'
                    if ismember('control', keyEvent.Modifier)
                    	ViewAxis(hFig);
                    end 
                % CTRL+D : Dock figure
                case 'd'
                    if ismember('control', keyEvent.Modifier)
                        isDocked = strcmpi(get(hFig, 'WindowStyle'), 'docked');
                        gui_figuresManager('DockFigure', hFig, ~isDocked);
                    end
                % CTRL+R : Recordings time series
                case 'r'
                    if ismember('control', keyEvent.Modifier)
                    	gui_figuresManager('ViewTimeSeries', hFig);
                    end
                % CTRL+T : Default topography
                case 't'
                    if ismember('control', keyEvent.Modifier)
                        gui_figuresManager('ViewTopography', hFig); 
                    end
                % CTRL+S : Sources (first results file)
                case 's'
                    if ismember('control', keyEvent.Modifier)
                        gui_figuresManager('ViewResults', hFig); 
                    end
                % CTRL+I : Save as image
                case 'i'
                    if ismember('control', keyEvent.Modifier)
                        out_figure_image(hFig);
                    end
                % CTRL+E : Sensors and labels
                case 'e'
                    if ~isAlignFig && ismember('control', keyEvent.Modifier) && ~strcmpi(FigureId.Modality, 'Fsynth') && ~strcmpi(FigureId.Modality, 'Residuals')
                        hLabels = findobj(hFig, 'Tag', 'SensorsLabels');
                        isMarkers = ~isempty(findobj(hFig, 'Tag', 'SensorsPatch')) || ~isempty(findobj(hFig, 'Tag', 'SensorsMarkers'));
                        isLabels  = ~isempty(hLabels);
                        % All figures, except "2DLayout"
                        if ~strcmpi(FigureId.SubType, '2DLayout')
                            % Cycle between three modes : Nothing, Sensors, Sensors+labels
                            if isMarkers && isLabels
                                ViewSensors(hFig, 0, 0);
                            elseif isMarkers
                                ViewSensors(hFig, 1, 1);
                            else
                                ViewSensors(hFig, 1, 0);
                            end
                        % "2DLayout"
                        elseif isLabels
                            isLabelsVisible = strcmpi(get(hLabels(1), 'Visible'), 'on');
                            if isLabelsVisible
                                set(hLabels, 'Visible', 'off');
                            else
                                set(hLabels, 'Visible', 'on');
                            end
                        end
                    end
                    
                % === CHANNELS ===
                % RETURN: VIEW SELECTED CHANNELS
                case 'return'
                    if ~isAlignFig && isMenuSelectedChannels && ~AllChannelsDisplayed
                        gui_figureTimeSeries('DisplayDataSelectedChannels', iDS, MouseSelection, ...
                            FigureId.Modality, hFig);
                    end
                % DELETE: SET SELECTED CHANNELS AS BAD
                case 'delete'
                    if ~isAlignFig && isMenuSelectedChannels && ~AllChannelsDisplayed
                        ChannelFlagSelectionBad = GlobalData.DataSet(iDS).Measures.ChannelFlag;
                        ChannelFlagSelectionBad(MouseSelection) = -1;
                        panel_channelEditor('UpdateChannelFlag', GlobalData.DataSet(iDS).DataFile, ...
                                            0, ChannelFlagSelectionBad);
                        % Reset MouseSelectedChannels
                        bst_dataSetsManager('SetMouseSelectedChannels', GlobalData.DataSet(iDS).ChannelFile, []);
                    end
                % ESCAPE: RESET CHANNELS SELECTION
                case 'escape'
                    if ~isAlignFig && isMenuSelectedChannels && ~AllChannelsDisplayed
                        bst_dataSetsManager('SetMouseSelectedChannels', GlobalData.DataSet(iDS).ChannelFile, []);
                    end
            end
    end
    % Restore events
    if ~isempty(hFig) && ishandle(hFig) && ~isempty(hAxes) && ishandle(hAxes)
        set([hFig hAxes], 'BusyAction', 'queue');
    end
end


%% ===== RESET VIEW =====
% Restore initial camera position and orientation
function ResetView(hFig)
    zoom out
    % Get Axes handle
    hAxes = findobj(hFig, 'Tag', 'Axes3D');
    set(hFig, 'CurrentAxes', hAxes);
    % Camera basic orientation
    SetStandardView(hFig, 'top');
    % Try to find a light source. If found, align it with the camera
    camlight(findobj(hAxes, 'Tag', 'FrontLight'), 'headlight');
end


%% ===== SET STANDARD VIEW =====
function SetStandardView(hFig, viewNames)
    % Make sure that viewNames is a cell array
    if ischar(viewNames)
        viewNames = {viewNames};
    end
    % Get Axes handle
    hAxes = findobj(hFig, 'Tag', 'Axes3D');
    % Get the data types displayed in this figure
    listTypes = gui_figuresManager('GetDisplayedDataTypes', hFig);
    R = eye(3);
    % If MRI displayed in the figure, use the orientation of the slices, instead of the orientation of the axes
    if ismember('Anatomy', listTypes)
        % Get the mri surface
        TessInfo = getappdata(hFig, 'Surface');
        iTess = find(strcmpi({TessInfo.Name}, 'Anatomy'));
        if ~isempty(iTess)
            sMri = bst_dataSetsManager('GetMri', TessInfo(iTess).SurfaceFile);
            % Get the rotation to change orientation
            R = [0 1 0;-1 0 0; 0 0 1] * pinv(sMri.SCS.R);
        end
    end
    % Apply the first orientation to the target figure
    switch lower(viewNames{1})
        case 'left'
            newView = [0,1,0];
            newCamup = [0 0 1];
        case 'right'
            newView = [0,-1,0];
            newCamup = [0 0 1];
        case 'back'
            newView = [-1,0,0];
            newCamup = [0 0 1];
        case 'front'
            newView = [1,0,0];
            newCamup = [0 0 1];
        case 'bottom'
            newView = [0,0,-1];
            newCamup = [1 0 0];
        case 'top'
            newView = [0,0,1];
            newCamup = [1 0 0];
    end
    % Update camera position
    view(hAxes, newView * R);
    camup(hAxes, newCamup * R);
    
    % Update head light position
    camlight(findobj(hAxes, 'Tag', 'FrontLight'), 'headlight');
    
    % If there are other view to represent
    if (length(viewNames) > 1)
        hClones = gui_figuresManager('GetClones', hFig);
        % Process the other required views
        for i = 2:length(viewNames)
            if ~isempty(hClones)
                % Use an already cloned figure
                hNewFig = hClones(1);
                hClones(1) = [];
            else
                % Clone figure
                hNewFig = gui_figuresManager('CloneFigure', hFig);
            end
            % Set orientation
            SetStandardView(hNewFig, viewNames(i));
        end
        % If there are some cloned figures left : close them
        if ~isempty(hClones)
            close(hClones);
            % Update figures layout
            gui_layout();
        end
    end
end


%% ===== APPLY VIEW TO ALL FIGURES =====
function ApplyViewToAllFigures(hSrcFig)
    % Get Axes handle
    hSrcAxes = findobj(hSrcFig, 'Tag', 'Axes3D');
    % Get surface descriptions
    SrcTessInfo = getappdata(hSrcFig, 'Surface');
    % Get all figures
    hAllFig = gui_figuresManager('GetFiguresByType', '3DViz');
    hAllFig = setdiff(hAllFig, hSrcFig);
    % Process all figures
    for i = 1:length(hAllFig)
        % Get Axes handle
        hDestFig = hAllFig(i);
        hDestAxes = findobj(hDestFig, 'Tag', 'Axes3D');
        % === COPY CAMERA ===
        % Copy view angle
        [az,el] = view(hSrcAxes);
        view(hDestAxes, az, el);
        % Copy camup
        up = camup(hSrcAxes);
        camup(hDestAxes, up);
        % Update head light position
        camlight(findobj(hDestAxes, 'Tag', 'FrontLight'), 'headlight');
        
        % === COPY SURFACES PROPERTIES ===
        DestTessInfo = getappdata(hDestFig, 'Surface');
        % Process each surface of the figure
        for iTess = 1:length(DestTessInfo)
            % Find surface name in source figure
            iTessInSrc = find(strcmpi(DestTessInfo(iTess).Name, {SrcTessInfo.Name}));
            % If surface is also available in source figure
            if ~isempty(iTessInSrc)
                % Copy surf properties
                iTessInSrc = iTessInSrc(1);
                DestTessInfo(iTess).SurfAlpha              = SrcTessInfo(iTessInSrc).SurfAlpha;
                DestTessInfo(iTess).SurfShowCurvature      = SrcTessInfo(iTessInSrc).SurfShowCurvature;
                DestTessInfo(iTess).SurfCurvatureThreshold = SrcTessInfo(iTessInSrc).SurfCurvatureThreshold;
                DestTessInfo(iTess).SurfShowEdges          = SrcTessInfo(iTessInSrc).SurfShowEdges;
                DestTessInfo(iTess).AnatomyColor           = SrcTessInfo(iTessInSrc).AnatomyColor;
                DestTessInfo(iTess).SurfSmoothValue        = SrcTessInfo(iTessInSrc).SurfSmoothValue;
                DestTessInfo(iTess).DataAlpha              = SrcTessInfo(iTessInSrc).DataAlpha;
                DestTessInfo(iTess).DataIntThreshold          = SrcTessInfo(iTessInSrc).DataIntThreshold;
                DestTessInfo(iTess).DataExtThreshold          = SrcTessInfo(iTessInSrc).DataExtThreshold;
                DestTessInfo(iTess).CutsPosition           = SrcTessInfo(iTessInSrc).CutsPosition;
                DestTessInfo(iTess).Resect                 = SrcTessInfo(iTessInSrc).Resect;
                % Update surfaces structure
                setappdata(hDestFig, 'Surface', DestTessInfo);
                % Update display
                if strcmpi(DestTessInfo(iTess).Name, 'Anatomy')
                    UpdateMriDisplay(hDestFig, [], DestTessInfo, iTess);
                else
                    UpdateSurfaceAlpha(hDestFig, iTess);
                    UpdateSurfaceColor(hDestFig, iTess);
                end
                % Update scouts displayed on this surfce
                panel_scouts('UpdateScoutsVertices', DestTessInfo(iTess).SurfaceFile);
            end
        end
    end
end


%% ===== POPUP MENU =====
% Show a popup dialog about the target 3DViz figure
function DisplayFigurePopup(hFig)
    import javax.swing.*;
    import java.awt.*;
    import java.awt.event.KeyEvent;
    import org.brainstorm.icon.IconLoader;
    
    global GlobalData;
    % Get figure description
    [hFig, iFig, iDS] = gui_figuresManager('GetFigure', hFig);
    if isempty(iDS)
        return
    end
    % Get DataFile associated with this figure
    ProtocolInfo = bst_getContext('ProtocolInfo');
    DataFile = GlobalData.DataSet(iDS).DataFile;
    if ~isempty(ProtocolInfo)
        DataFileFull = fullfile(ProtocolInfo.STUDIES, DataFile);
    else
        % Protocol not defined => running without without full brainstorm GUI
        DataFileFull = [];
    end
    % Create popup menu
    jPopup = JPopupMenu();   
    
    % ==== DISPLAY OTHER FIGURES ====
    % Only for MEG and EEG time series
    Modality = GlobalData.DataSet(iDS).Figure(iFig).Id.Modality;  
    FigureType = GlobalData.DataSet(iDS).Figure(iFig).Id.Type;  
    if ~isempty(DataFile) && ~isempty(DataFileFull)
        % === View RECORDINGS ===
        jItem = JMenuItem([Modality ' Recordings'], IconLoader.ICON_TS_DISPLAY);
        jItem.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_R, KeyEvent.CTRL_MASK));
        set(jItem, 'ActionPerformedCallback', @(h,ev)gui_figuresManager('ViewTimeSeries',hFig));
        jPopup.add(jItem);
        % === View TOPOGRAPHY ===
        if ~strcmpi(FigureType, 'Topography')
            jItem = JMenuItem([Modality ' Topography'], IconLoader.ICON_TOPOGRAPHY);
            jItem.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_T, KeyEvent.CTRL_MASK));
            set(jItem, 'ActionPerformedCallback', @(h,ev)gui_figuresManager('ViewTopography',hFig));
            jPopup.add(jItem);
        end
        % === View SOURCES ===
        if isempty(getappdata(hFig, 'ResultsFile'))
            jItem = JMenuItem('View sources', IconLoader.ICON_RESULTS);
            jItem.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_S, KeyEvent.CTRL_MASK));
            set(jItem, 'ActionPerformedCallback', @(h,ev)gui_figuresManager('ViewResults',hFig));
            jPopup.add(jItem);
        end
        jPopup.addSeparator();
    end
    
    % ==== CHANNELS MENU =====
    if ~isempty(DataFile) && ~isempty(DataFileFull) && ~strcmpi(Modality, 'Fsynth') && ~strcmpi(Modality, 'Residuals')
        jMenuChannels = JMenu('Channels');
        jMenuChannels.setIcon(IconLoader.ICON_CHANNEL);
        % ==== Selected channels submenu ====
        isMarkers = ~isempty(GlobalData.DataSet(iDS).Figure(iFig).Handles.hSensorMarkers);
        MouseSelection = GlobalData.DataSet(iDS).MouseSelectedChannels;
        % Excludes figures without selection and display-only figures (modality name starts with '$')
        if ~isempty(DataFile) && ...
                isMarkers && ...
                ~isempty(MouseSelection) && ...
                ~isempty(Modality) && ...
                (Modality(1) ~= '$')
            % === VIEW TIME SERIES ===
            jItem = JMenuItem('View selected', IconLoader.ICON_TS_DISPLAY);
            jItem.setAccelerator(KeyStroke.getKeyStroke(int32(KeyEvent.VK_ENTER), 0)); % ENTER
            set(jItem, 'ActionPerformedCallback', @(h, ev)gui_figuresManager('ViewTimeSeries', hFig, MouseSelection));
            jMenuChannels.add(jItem);
            % === SET AS BAD CHANNELS ===
            ChannelFlagSelectionBad = GlobalData.DataSet(iDS).Measures.ChannelFlag;
            ChannelFlagSelectionBad(MouseSelection) = -1;
            jItem = JMenuItem('Mark selected as bad', IconLoader.ICON_BAD);
            jItem.setAccelerator(KeyStroke.getKeyStroke(int32(KeyEvent.VK_DELETE), 0)); % DEL
            set(jItem, 'ActionPerformedCallback', @(h, ev)panel_channelEditor('UpdateChannelFlag', ...
                        DataFile, 0, ChannelFlagSelectionBad));
            jMenuChannels.add(jItem);
            % === RESET SELECTION ===
            jItem = JMenuItem('Reset selection', IconLoader.ICON_SURFACE);
            jItem.setAccelerator(KeyStroke.getKeyStroke(int32(KeyEvent.VK_ESCAPE), 0)); % ESCAPE
            set(jItem, 'ActionPerformedCallback', @(h, ev)bst_dataSetsManager('SetMouseSelectedChannels', ...
                        GlobalData.DataSet(iDS).ChannelFile, []));
            jMenuChannels.add(jItem);
        end
        % Separator if previous items
        if (jMenuChannels.getItemCount() > 0)
            jMenuChannels.addSeparator();
        end
        
        % ==== CHANNEL FLAG =====
        if ~isempty(DataFile) && isMarkers
            % ==== MARK ALL CHANNELS AS GOOD ====
            ChannelFlagGood = ones(size(GlobalData.DataSet(iDS).Measures.ChannelFlag));
            jItem = JMenuItem('Mark all channels as good', IconLoader.ICON_GOOD);
            set(jItem, 'ActionPerformedCallback', ...
                @(h, ev)panel_channelEditor('UpdateChannelFlag', GlobalData.DataSet(iDS).DataFile, ...
                                            0, ChannelFlagGood));        
            jMenuChannels.add(jItem);
            % ==== EDIT CHANNEL FLAG ====
            jItem = JMenuItem('Edit good/bad channels...', IconLoader.ICON_GOODBAD);
            set(jItem, 'ActionPerformedCallback', @(h,ev)gui_editChannelFlag(DataFile));
            jMenuChannels.add(jItem);
        end
        % Separator if previous items
        if (jMenuChannels.getItemCount() > 0)
            jMenuChannels.addSeparator();
        end
        
        % ==== View Sensors ====
        % Not for 2DLayout
        if ~strcmpi(GlobalData.DataSet(iDS).Figure(iFig).Id.SubType, '2DLayout')
            % Menu "View sensors"
            jItem = JCheckBoxMenuItem('Display sensors', IconLoader.ICON_CHANNEL, isMarkers);
            jItem.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_E, KeyEvent.CTRL_MASK));
            set(jItem, 'ActionPerformedCallback', @(h,ev)ViewSensors(hFig, ~isMarkers, []));
            jMenuChannels.add(jItem);
            % Menu "View sensor labels"
            isLabels = ~isempty(GlobalData.DataSet(iDS).Figure(iFig).Handles.hSensorLabels);
            jItem = JCheckBoxMenuItem('Display labels', IconLoader.ICON_CHANNEL_LABEL, isLabels);
            set(jItem, 'ActionPerformedCallback', @(h,ev)ViewSensors(hFig, [], ~isLabels));
            jMenuChannels.add(jItem);
        else
            % Menu "View sensor labels"
            isLabels = ~isempty(GlobalData.DataSet(iDS).Figure(iFig).Handles.hSensorLabels);
            if isLabels
                isLabelsVisible = strcmpi(get(GlobalData.DataSet(iDS).Figure(iFig).Handles.hSensorLabels(1), 'Visible'), 'on');
                jItem = JCheckBoxMenuItem('Display labels', IconLoader.ICON_CHANNEL_LABEL, isLabelsVisible);
                jItem.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_E, KeyEvent.CTRL_MASK));
                if isLabelsVisible
                    targetVisible = 'off';
                else
                    targetVisible = 'on';
                end
                set(jItem, 'ActionPerformedCallback', @(h,ev)set(GlobalData.DataSet(iDS).Figure(iFig).Handles.hSensorLabels, 'Visible', targetVisible));
                jMenuChannels.add(jItem);
            end
        end
        jPopup.add(jMenuChannels);
    end
    

    % ==== Menu colormaps ====
    % Get list of displayed data types
    listTypes = gui_figuresManager('GetDisplayedDataTypes', hFig);
    % Menu "Recordings (EEG/MEG) colormap"
    if any(ismember({'data','eeg','meg'}, lower(listTypes))) && ~strcmpi(Modality, 'Residuals')
        ColormapType = bst_colormaps('GetColormapType', Modality);
        jMenuColormapsData = JMenu(['Colormap (' lower(ColormapType) ')']);
        jMenuColormapsData.setIcon(IconLoader.ICON_COLORMAP_RECORDINGS);
        set(jMenuColormapsData, 'MenuSelectedCallback', @(h,ev)bst_colormaps('CreateColormapMenu', ev.getSource(), ColormapType));
        jPopup.add(jMenuColormapsData);
    end
    % Menu "Sources colormap"
    if ismember('Source', listTypes) || strcmpi(Modality, 'Residuals')
        jMenuColormapsSource = JMenu('Colormap (sources)');
        jMenuColormapsSource.setIcon(IconLoader.ICON_COLORMAP_SOURCES);
        set(jMenuColormapsSource, 'MenuSelectedCallback', @(h,ev)bst_colormaps('CreateColormapMenu', ev.getSource(), 'Source'));
        jPopup.add(jMenuColormapsSource);
    end
    % Menu "Stat colormap"
    if ismember('Stat', listTypes)
        jMenuColormapsStat = JMenu('Colormap (stat)');
        jMenuColormapsStat.setIcon(IconLoader.ICON_COLORMAP_RECORDINGS);
        set(jMenuColormapsStat, 'MenuSelectedCallback', @(h,ev)bst_colormaps('CreateColormapMenu', ev.getSource(), 'Stat'));
        jPopup.add(jMenuColormapsStat);
    end
    % Menu "Anatomy colormap"
    if ismember('Anatomy', listTypes)
        jMenuColormapsSource = JMenu('Colormap (anatomy)');
        jMenuColormapsSource.setIcon(IconLoader.ICON_COLORMAP_ANATOMY);
        set(jMenuColormapsSource, 'MenuSelectedCallback', @(h,ev)bst_colormaps('CreateColormapMenu', ev.getSource(), 'Anatomy'));
        jPopup.add(jMenuColormapsSource);
    end
    
    % ==== Maximum Intensity Projection ====
    if ismember('Anatomy', listTypes)
        jMenuMIP = JMenu('Maximum Intensity Power');
        jMenuMIP.setIcon(IconLoader.ICON_RESULTS);
        % MIP: Anatomy
        jItem = JCheckBoxMenuItem('MIP: Anatomy', GlobalData.MIP.isMipAnatomy);
        set(jItem, 'ActionPerformedCallback', @(h,ev)MipAnatomy_Callback(hFig,ev));
        jMenuMIP.add(jItem);
        jPopup.add(jMenuMIP);
        % MIP: Functional
        if ismember('Source', listTypes)
            jItem = JCheckBoxMenuItem('MIP: Functional', GlobalData.MIP.isMipFunctional);
            set(jItem, 'ActionPerformedCallback', @(h,ev)MipFunctional_Callback(hFig,ev));
            jMenuMIP.add(jItem);
        end
        jPopup.add(jMenuMIP);
    end
    
    % ==== Navigation submenu ====
    if ~isempty(DataFile) && ~isempty(DataFileFull)
        jMenuNavigator = JMenu('Navigator');
        jMenuNavigator.setIcon(IconLoader.ICON_NEXT_SUBJECT);
            bst_navigator('CreateNavigatorMenu', jMenuNavigator);
        jPopup.add(jMenuNavigator);
        jPopup.addSeparator();
    end
    
    % ==== Menu SNAPSHOT ====
    jMenuSave = JMenu('Snapshot');
    jMenuSave.setIcon(IconLoader.ICON_SNAPSHOT);
        % Default output dir
        LastUsedDirs = bst_getContext('LastUsedDirs');
        DefaultOutputDir = LastUsedDirs.Export;
        % Is there a time window defined
        isTime = ~isempty(GlobalData) && ~isempty(GlobalData.MaxTimeWindow.Time) ...
                 && ~isempty(GlobalData.UserTimeWindow.CurrentTime) && ~isempty(GlobalData.UserTimeWindow.Time) ...
                 && ~isempty(DataFileFull);
        % === SAVE AS IMAGE ===
        jItem = JMenuItem('Save as image', IconLoader.ICON_SAVE);
        jItem.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_I, KeyEvent.CTRL_MASK));
        set(jItem, 'ActionPerformedCallback', @(h,ev)out_figure_image(hFig));
        jMenuSave.add(jItem);
        % === SAVE AS FIGURE ===
        jItem = JMenuItem('Save as Matlab figure', IconLoader.ICON_SAVE);
        set(jItem, 'ActionPerformedCallback', @(h,ev)out_figure_matlab(hFig));
        jMenuSave.add(jItem);
        % === MOVIES ===
        % WARNING: Windows ONLY (for the moment)
        % And NOT for 2DLayout figures
        if ispc && ~strcmpi(GlobalData.DataSet(iDS).Figure(iFig).Id.SubType, '2DLayout')
            % Separator
            jMenuSave.addSeparator();
            % === MOVIE (TIME) ===
            if isTime
                jItem = JMenuItem('Movie (time)', IconLoader.ICON_MOVIE);
                set(jItem, 'ActionPerformedCallback', @(h,ev)out_figure_movie(hFig, DefaultOutputDir, 'time'));
                jMenuSave.add(jItem);
            end
            % If not topography
            if ~strcmpi(FigureType, 'Topography')
                % === MOVIE (HORIZONTAL) ===
                jItem = JMenuItem('Movie (horizontal)', IconLoader.ICON_MOVIE);
                set(jItem, 'ActionPerformedCallback', @(h,ev)out_figure_movie(hFig, DefaultOutputDir, 'horizontal'));
                jMenuSave.add(jItem);
                % === MOVIE (VERTICAL) ===
                jItem = JMenuItem('Movie (vertical)', IconLoader.ICON_MOVIE);
                set(jItem, 'ActionPerformedCallback', @(h,ev)out_figure_movie(hFig, DefaultOutputDir, 'vertical'));
                jMenuSave.add(jItem);
            end
        end
        % === CONTACT SHEETS ===
        % If time, and if not 2DLayout
        if isTime && ~strcmpi(GlobalData.DataSet(iDS).Figure(iFig).Id.SubType, '2DLayout')
            % Separator
            jMenuSave.addSeparator();
            % === CONTACT SHEET (TIME) ===
            jItem = JMenuItem('Contact sheet (time)', IconLoader.ICON_CONTACTSHEET);
            set(jItem, 'ActionPerformedCallback', @(h,ev)out_figure_contactSheet(hFig, DefaultOutputDir));
            jMenuSave.add(jItem);
        end
        % === CONTACT SHEET / SLICES ===
        if ismember('Anatomy', listTypes)
            % === CONTACT SHEET (AXIAL) ===
            jItem = JMenuItem('Contact sheet (axial)', IconLoader.ICON_CONTACTSHEET);
            set(jItem, 'ActionPerformedCallback', @(h,ev)out_figure_mriSlices(hFig, 'z', DefaultOutputDir));
            jMenuSave.add(jItem);
            % === CONTACT SHEET (CORONAL) ===
            jItem = JMenuItem('Contact sheet (coronal)', IconLoader.ICON_CONTACTSHEET);
            set(jItem, 'ActionPerformedCallback', @(h,ev)out_figure_mriSlices(hFig, 'y', DefaultOutputDir));
            jMenuSave.add(jItem);
            % === CONTACT SHEET (SAGITTAL) ===
            jItem = JMenuItem('Contact sheet (sagittal)', IconLoader.ICON_CONTACTSHEET);
            set(jItem, 'ActionPerformedCallback', @(h,ev)out_figure_mriSlices(hFig, 'x', DefaultOutputDir));
            jMenuSave.add(jItem);
        end
    jPopup.add(jMenuSave);
    
    % ==== Menu "Figure" ====    
    jMenuFigure = JMenu('Figure');
    jMenuFigure.setIcon(IconLoader.ICON_LAYOUT_SHOWALL);
        % Show axes
        isAxis = ~isempty(findobj(hFig, 'Tag', 'AxisXYZ'));
        jItem = JCheckBoxMenuItem('View axis', IconLoader.ICON_AXES, isAxis);
        jItem.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_A, KeyEvent.CTRL_MASK)); 
        set(jItem, 'ActionPerformedCallback', @(h,ev)ViewAxis(hFig, ~isAxis));
        jMenuFigure.add(jItem);
        % Show Head points
        isHeadPoints = ~isempty(GlobalData.DataSet(iDS).HeadPoints) && ~isempty(GlobalData.DataSet(iDS).HeadPoints.Loc);
        if isHeadPoints
            % Are head points visible
            hHeadPointsMarkers = findobj(GlobalData.DataSet(iDS).Figure(iFig).hFigure, 'Tag', 'HeadPointsMarkers');
            isVisible = ~isempty(hHeadPointsMarkers) && strcmpi(get(hHeadPointsMarkers, 'Visible'), 'on');
            jItem = JCheckBoxMenuItem('View head points', IconLoader.ICON_CHANNEL, isVisible);
            set(jItem, 'ActionPerformedCallback', @(h,ev)ViewHeadPoints(hFig, ~isVisible));
            jMenuFigure.add(jItem);
        end
        jMenuFigure.addSeparator();
        % Change background color
        jItem = JMenuItem('Change background color', IconLoader.ICON_COLOR_SELECTION);
        set(jItem, 'ActionPerformedCallback', @(h,ev)ChangeBackgroundColor(hFig));
        jMenuFigure.add(jItem);
        jMenuFigure.addSeparator();
        % Show Matlab controls
        isMatlabCtrl = ~strcmpi(get(hFig, 'MenuBar'), 'none') && ~strcmpi(get(hFig, 'ToolBar'), 'none');
        jItem = JCheckBoxMenuItem('Matlab controls', IconLoader.ICON_MATLAB_CONTROLS, isMatlabCtrl);
        set(jItem, 'ActionPerformedCallback', @(h,ev)gui_figuresManager('ShowMatlabControls', hFig, ~isMatlabCtrl));
        jMenuFigure.add(jItem);
        % Show plot edit toolbar
        isPlotEditToolbar = getappdata(hFig, 'isPlotEditToolbar');
        jItem = JCheckBoxMenuItem('Plot edit toolbar', IconLoader.ICON_PLOTEDIT, isPlotEditToolbar);
        set(jItem, 'ActionPerformedCallback', @(h,ev)gui_figuresManager('TogglePlotEditToolbar', hFig));
        jMenuFigure.add(jItem);
        % Dock figure
        isDocked = strcmpi(get(hFig, 'WindowStyle'), 'docked');
        jItem = JCheckBoxMenuItem('Dock figure', IconLoader.ICON_DOCK, isDocked);
        jItem.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_D, KeyEvent.CTRL_MASK)); 
        set(jItem, 'ActionPerformedCallback', @(h,ev)gui_figuresManager('DockFigure', hFig, ~isDocked));
        jMenuFigure.add(jItem);
    jPopup.add(jMenuFigure);
    
    % ==== Menu "Views" ====    
    % Not for Topography
    if ~strcmpi(FigureType, 'Topography')
        jMenuView = JMenu('Views');
        jMenuView.setIcon(IconLoader.ICON_AXES);
        % Check if it is a realignment figure
        isAlignFigure = ~isempty(findobj(hFig, 'Tag', 'AlignToolbar'));
        % STANDARD VIEWS
        % Create items
        jItemViewLeft   = JMenuItem('Left');
        jItemViewBottom = JMenuItem('Bottom');
        jItemViewRight  = JMenuItem('Right');
        jItemViewFront  = JMenuItem('Front');
        jItemViewTop    = JMenuItem('Top');
        jItemViewBack   = JMenuItem('Back');
        % Callbacks
        set(jItemViewLeft,   'ActionPerformedCallback', @(h,ev)SetStandardView(hFig, {'left'}));
        set(jItemViewBottom, 'ActionPerformedCallback', @(h,ev)SetStandardView(hFig, {'bottom'}));
        set(jItemViewRight,  'ActionPerformedCallback', @(h,ev)SetStandardView(hFig, {'right'}));
        set(jItemViewFront,  'ActionPerformedCallback', @(h,ev)SetStandardView(hFig, {'front'}));
        set(jItemViewTop,    'ActionPerformedCallback', @(h,ev)SetStandardView(hFig, {'top'}));
        set(jItemViewBack,   'ActionPerformedCallback', @(h,ev)SetStandardView(hFig, {'back'}));
        % Keyboard shortcuts
        jItemViewLeft.setAccelerator(  KeyStroke.getKeyStroke('1')); 
        jItemViewBottom.setAccelerator(KeyStroke.getKeyStroke('2')); 
        jItemViewRight.setAccelerator( KeyStroke.getKeyStroke('3'));
        jItemViewFront.setAccelerator( KeyStroke.getKeyStroke('4'));
        jItemViewTop.setAccelerator(   KeyStroke.getKeyStroke('5'));
        jItemViewBack.setAccelerator(  KeyStroke.getKeyStroke('6'));
        % Add items to menu
        jMenuView.add(jItemViewLeft);
        jMenuView.add(jItemViewBottom);
        jMenuView.add(jItemViewRight);
        jMenuView.add(jItemViewFront);
        jMenuView.add(jItemViewTop);
        jMenuView.add(jItemViewBack);
        
        % MULTIPLE VIEWS
        if ~isAlignFigure
            % Create items
            jItemViewLR     = JMenuItem('[Left, Right]');
            jItemViewTB     = JMenuItem('[Top, Bottom]');
            jItemViewFB     = JMenuItem('[Front, Back]');
            jItemViewLTR    = JMenuItem('[Left, Top, Right]');
            % Callbacks
            set(jItemViewLR,     'ActionPerformedCallback', @(h,ev)SetStandardView(hFig, {'left', 'right'}));
            set(jItemViewTB,     'ActionPerformedCallback', @(h,ev)SetStandardView(hFig, {'top', 'bottom'}));
            set(jItemViewFB,     'ActionPerformedCallback', @(h,ev)SetStandardView(hFig, {'front','back'}));
            set(jItemViewLTR,    'ActionPerformedCallback', @(h,ev)SetStandardView(hFig, {'left', 'top', 'right'}));
            % Keyboard shortcuts
            jItemViewLR.setAccelerator(    KeyStroke.getKeyStroke('7'));
            jItemViewTB.setAccelerator(    KeyStroke.getKeyStroke('8'));
            jItemViewFB.setAccelerator(    KeyStroke.getKeyStroke('9'));
            jItemViewLTR.setAccelerator(   KeyStroke.getKeyStroke('0'));
            % Add items to menu
            jMenuView.add(jItemViewLR);
            jMenuView.add(jItemViewTB);
            jMenuView.add(jItemViewFB);
            jMenuView.add(jItemViewLTR);
            
            % SET SAME VIEW FOR ALL FIGURES
            jMenuView.addSeparator();
            jItem = JMenuItem('Apply this view to all figures');
            jItem.setAccelerator(KeyStroke.getKeyStroke('='));
            set(jItem, 'ActionPerformedCallback', @(h,ev)ApplyViewToAllFigures(hFig));
            jMenuView.add(jItem);
            
            % CLONE FIGURE
            jMenuView.addSeparator();
            jItem = JMenuItem('Clone figure');
            set(jItem, 'ActionPerformedCallback', @(h,ev)gui_figuresManager('CloneFigure', hFig));
            jMenuView.add(jItem);
        end
        jPopup.add(jMenuView);
    end
    
    % ==== Display menu ====
    gui_showPopup(jPopup);

end


%% ===== FIGURE CONFIGURATION FUNCTIONS =====
% CHECKBOX MIP ANATOMY
function MipAnatomy_Callback(hFig, ev)
    global GlobalData;
    GlobalData.MIP.isMipAnatomy = ev.getSource().isSelected();
    UpdateMriDisplay(hFig);
end
% CHECKBOX MIP FUNCTIONAL
function MipFunctional_Callback(hFig, ev)
    global GlobalData;
    GlobalData.MIP.isMipFunctional = ev.getSource().isSelected();
    UpdateMriDisplay(hFig);
end

% %% ===== COLORBAR HELP MESSAGE =====
% function ColorbarHelpMessage(hFig)
%     % Get colorbar
%     hColorbar = findobj(hFig, 'Tag', 'Colorbar');
%     % If a colorbar is found
%     if ~isempty(hColorbar) && strcmpi(get(hColorbar,'Visible'), 'on')
%         % Get mouse position and colorbar position
%         barPos = get(hColorbar, 'Position');
%         curptFigure = get(hFig, 'CurrentPoint');
%         % Get previous legend
%         hLabel = findobj(hFig, 'Tag', 'ColorbarHelpMsg');
%         % Check if mouse over the colorbar
%         if (curptFigure(1) >= barPos(1)) 
%             % Display the help text for colorbar (only if not displayed yet)
%             if isempty(hLabel)
%                 hLabel = uicontrol('Style', 'text', ...
%                     'String',              ['Click and move mouse to adjust colormap:' 10 'Horizontal: contrast, vertical:brightness'], ...
%                     'Units',               'Pixels', ...
%                     'Position',            [6 0 220 28], ...
%                     'HorizontalAlignment', 'left', ...
%                     'FontUnits',           'points', ...
%                     'FontSize',            7.5, ...
%                     'ForegroundColor',     [.3 1 .3], ...
%                     'BackgroundColor',     [0 0 0], ...
%                     'Tag',                 'ColorbarHelpMsg', ...
%                     'Parent',              hFig);
%             end
%         elseif ~isempty(hLabel)
%             delete(hLabel);
%         end
%     end
% end


%% ==============================================================================================
%  ====== SURFACES ==============================================================================
%  ==============================================================================================
%% ===== GET SELECTED CHANNELS INDICES AND LOCATION =====
function [SelectedChannels, PChanLocs, PChanOrient] = GetSelectedChannels(iDS, iFig)
    global GlobalData;
    PChanLocs = [];
    PChanOrient = [];
    Channel = GlobalData.DataSet(iDS).Channel;

    % Update selected channels
    UpdateSelectedChannels(iDS, iFig);
    % Get selected channels indices
    SelectedChannels = GlobalData.DataSet(iDS).Figure(iFig).SelectedChannels;
    % No channel available or locations not requested : return
    if isempty(SelectedChannels)
        return;
    end
    
    % === CHANNELS LOCATIONS ===
    % If modality and selected channels are defined
    if (nargout >= 2)
        % Get channel locations
        chanlocs = [Channel(SelectedChannels).Loc]';
        if isempty(chanlocs)
            return
        end
        % Keep only one kind of sensors locations
        nLocs = round(length(chanlocs) / length(SelectedChannels));
        chanlocs = chanlocs(1:nLocs:end,:);
        % Check intergrity of Channel structure
        if size(chanlocs,1) ~= length(SelectedChannels)
            bst_error('Channel locations do not match the number of channels in Channel structure.','Perverted Channel structure.');
            return
        end
        % Get selected channels locations
        PChanLocs = chanlocs;
    end
    
    % === CHANNELS ORIENTATIONS ===
    if (nargout >= 3)
        % Get channel locations
        chanorient = [Channel(SelectedChannels).Orient]';
        if isempty(chanorient)
            return
        end
        % Keep only one kind of sensors locations
        nOrient = round(length(chanorient) / length(SelectedChannels));
        chanorient = chanorient(1:nOrient:end,:);
        % Check intergrity of Channel structure
        if size(chanorient,1) ~= length(SelectedChannels)
            bst_error('Channel orientations do not match the number of channels in Channel structure.','Perverted Channel structure.');
            return
        end
        % Get selected channels locations
        PChanOrient = chanorient;
    end
end


%% ===== UPDATE SELECTED CHANNELS =====
function UpdateSelectedChannels(iDS, iFig)
    global GlobalData;
    Channel  = GlobalData.DataSet(iDS).Channel;
    hFig     = GlobalData.DataSet(iDS).Figure(iFig).hFigure;
    Modality = GlobalData.DataSet(iDS).Figure(iFig).Id.Modality;
    
    % If Modality of the window is not defined yet : select EEG or MEG
    if isempty(Modality)
        % Get the possible modalities for this figure
        %AvailableModalities = getChannelModalities(Channel, ones(length(Channel), 1));
        AvailableModalities = getChannelModalities(Channel);
        Modality = '';
        
        % If some modality is defined for this figure
        if ~isempty(AvailableModalities)
            % If both EEG and MEG are available for this figure 
            if all(ismember({'MEG', 'EEG'}, AvailableModalities))
                % Ask the user which one to display : MEG or EEG
                button = java_dialog('question', 'Please select a modality for this figure.', ...
                                       'Get available modalities', [], {'MEG', 'EEG'}, 'MEG');
                % If user did not answer : abort...
                if isempty(button)
                    return
                else
                    Modality = button;
                end
            % Else if only MEG is available : set figure modality to MEG
            elseif ismember('MEG', AvailableModalities)
                Modality = 'MEG';
            % Else if only EEG is available : set figure modality to EEG
            elseif ismember('EEG', AvailableModalities)
                Modality = 'EEG';
            end
        end     
        % If no modality is available : return
        if isempty(Modality)
            return;
        end
        % Else set this modality as the new window modality
        GlobalData.DataSet(iDS).Figure(iFig).Id.Modality = Modality;
        % Add '/modality' at the end of the figure title
        set(hFig, 'Name',  [get(hFig, 'Name'), '/', Modality]);
    end
    
    % CHANNEL FLAG
    ChannelFlag = GlobalData.DataSet(iDS).Measures.ChannelFlag;
    if isempty(ChannelFlag)
        ChannelFlag = ones(length(Channel), 1);
    end
    % SELECTED CHANNELS
    GlobalData.DataSet(iDS).Figure(iFig).SelectedChannels = good_channel(...
            Channel, ChannelFlag, Modality);

end

            

%% ===== PLOT SURFACE =====
% Convenient function to consistently plot surfaces.
% USAGE : [hFig,hs] = PlotSurface(hFig, faces, verts, cdata, dataCMap, transparency)
% Parameters :
%     - hFig         : figure handle to use
%     - faces        : the triangle listing (array)
%     - verts        : the corresponding vertices (array)
%     - surfaceColor : color data used to display the surface itself (CData for each vertex, or a unique color for all vertices)
%     - dataColormap : colormap used to display the data on the surface
%     - transparency : surface transparency ([0,1])
% Returns :
%     - hFig : figure handle used
%     - hs   : handle to the surface
function varargout = PlotSurface( hFig, faces, verts, surfaceColor, transparency) %#ok<DEFNU>
    % Check inputs
    if (nargin ~= 5)
        error('Invalid call to PlotSurface');
    end
    % If vertices are assumed transposed (if the assumption is wrong, will crash below anyway)
    if (size(verts,2) > 3)
        verts = verts';  
    end
    % If vertices are assumed transposed (if the assumption is wrong, will crash below anyway)
    if (size(faces,2) > 3)
        faces = faces';  
    end
    % Set figure as current
    set(0, 'CurrentFigure', hFig);

    % If cdata is a single RGB color
    if isequal(size(surfaceColor), [1,3])
        % Create patch
        hs = patch('Faces',            faces, ...
                   'Vertices',         verts,...
                   'FaceColor',        surfaceColor, ...
                   'FaceAlpha',        1 - transparency, ...
                   'AlphaDataMapping', 'none', ...
                   'EdgeColor',        'none', ...
                   'BackfaceLighting', 'lit');
    else
        surfaceColor = blend_anatomy_data(ones(size(verts,1),1), ... % Curvature
                                          surfaceColor, ...          % Current density
                                          NaN, ...                   % Limit value
                                          0, ...          % Current density transparency
                                          [], ...                    % Anatomy color
                                          []);                       % Data colormap
        % Create patch
        hs = patch('Faces',            faces, ...
                   'Vertices',         verts,...
                   'FaceVertexCData',  surfaceColor, ...
                   'FaceColor',        'interp', ...
                   'FaceAlpha',        'flat', ...
                   'AlphaDataMapping', 'none', ...
                   'EdgeColor',        'none', ...
                   'BackfaceLighting', 'lit');
    end
    
    % Configure patch material
    material([ 0.5 0.50 0.20 1.00 0.5 ])
    lighting phong
    
    % Set output variables
    if(nargout>0),
        varargout{1} = hFig;
        varargout{2} = hs;
    end
end


%% ===== PLOT SQUARE/CUT =====
% USAGE:  PlotSquareCut(hFig, TessInfo, dim, pos)
%         PlotSquareCut(hFig)  : Remove all square cuts displayed
function PlotSquareCut(hFig, TessInfo, dim, pos)
    % Get figure description and MRI
    [hFig, iFig, iDS] = gui_figuresManager('GetFigure', hFig);
    % Delete the previous patch
    delete(findobj(hFig, 'Tag', 'squareCut'));
    if (nargin < 4)
        return
    end
    hAxes  = findobj(hFig, 'tag', 'Axes3D');
    % Get maximum dimensions (MRI size)
    sMri = bst_dataSetsManager('GetMri', TessInfo.SurfaceFile);
    mriSize = size(sMri.Cube);
    voxSize = sMri.Voxsize;

    % Get locations of the slice
    nbPts = 50;
    baseVect = linspace(-.01, 1.01, nbPts);
    switch(dim)
        case 1
            X = ones(nbPts)         .* (pos + 2)  .* voxSize(1); 
            Y = meshgrid(baseVect)  .* mriSize(2) .* voxSize(2);   
            Z = meshgrid(baseVect)' .* mriSize(3) .* voxSize(3); 
            surfColor = [1 .5 .5];
        case 2
            X = meshgrid(baseVect)  .* mriSize(1) .* voxSize(1); 
            Y = ones(nbPts)         .* (pos + 2)  .* voxSize(2) + .1;    
            Z = meshgrid(baseVect)' .* mriSize(3) .* voxSize(3); 
            surfColor = [.5 1 .5];
        case 3
            X = meshgrid(baseVect)  .* mriSize(1) .* voxSize(1); 
            Y = meshgrid(baseVect)' .* mriSize(2) .* voxSize(2); 
            Z = ones(nbPts)         .* (pos + 2)  .* voxSize(3) + .1;        
            surfColor = [.5 .5 1];
    end

    % === Switch coordinates from MRI-CS to SCS ===
    % Apply Rotation/Translation
    XYZ = [reshape(X, 1, []);
           reshape(Y, 1, []); 
           reshape(Z, 1, [])];
    XYZ = mri2scs(sMri, XYZ);
    % Convert to milimeters
    XYZ = XYZ ./ 1000;

    % === PLOT SURFACE ===
    % Plot new surface  
    hCut = surface('XData',     reshape(XYZ(1,:),nbPts,nbPts), ...
                   'YData',     reshape(XYZ(2,:),nbPts,nbPts), ...
                   'ZData',     reshape(XYZ(3,:),nbPts,nbPts), ...
                   'CData',     ones(nbPts), ...
                   'FaceColor',        surfColor, ...
                   'FaceAlpha',        .3, ...
                   'EdgeColor',        'none', ...
                   'AmbientStrength',  .5, ...
                   'DiffuseStrength',  .9, ...
                   'SpecularStrength', .1, ...
                   'Tag',    'squareCut', ...
                   'Parent', hAxes);
end


%% ===== UPDATE MRI DISPLAY =====
% USAGE:  UpdateMriDisplay(hFig, dims, TessInfo, iTess)
%         UpdateMriDisplay(hFig, dims)
%         UpdateMriDisplay(hFig)
function UpdateMriDisplay(hFig, dims, TessInfo, iTess)
    % Parse inputs
    if (nargin < 4)
        [sMri,TessInfo,iTess] = panel_surface('GetSurfaceMri', hFig);
    end
    if (nargin < 2) || isempty(dims)
        dims = [1 2 3];
    end
    % Get the slices that need to be redrawn
    newPos = [NaN, NaN, NaN];
    newPos(dims) = TessInfo(iTess).CutsPosition(dims);
    % Redraw the three slices
    panel_surface('PlotMri', hFig, newPos);
end



%% ===== UPDATE SURFACE COLOR =====
% Compute color RGB values for each vertex of the surface, taking in account : 
%     - the surface color,
%     - the surface curvature and curvature threshold,
%     - the data matrix displayed over the surface (and the data threshold),
%     - the data colormap : RGB values, normalized?, absolute values?, limits
%     - the data transparency
% Parameters : 
%     - hFig : handle to a 3DViz figure
%     - iTess     : indice of the surface to update
function UpdateSurfaceColor(hFig, iTess)
    % Get surfaces list 
    TessInfo = getappdata(hFig, 'Surface');
    % Ignore empty surfaces and MRI slices
    if isempty(TessInfo(iTess).hPatch) || ~any(ishandle(TessInfo(iTess).hPatch))
        return 
    end
    % Get best colormap to display data
    if ~isempty(TessInfo(iTess).DataSource) && TessInfo(iTess).DataSource.isStat || TessInfo(iTess).DataSource.isZscore
        sColormap = bst_colormaps('GetColormap', 'Stat');
    else
        sColormap = bst_colormaps('GetColormap', TessInfo(iTess).DataSource.Type);
    end
    
    % === BUILD VALUES ===
    % If there is no data overlay
    if isempty(TessInfo(iTess).Data)
        tmp = [];
    else
        tmp = TessInfo(iTess).Data;
        % Apply data threshold
        % PERCENT OF LOCAL MAX 
        % tmp(abs(TessInfo(iTess).Data) < TessInfo(iTess).DataThreshold * max(abs(TessInfo(iTess).Data))) = 0; 
        % PERCENT OF GLOBAL MAX
        tmp(abs(TessInfo(iTess).Data) < TessInfo(iTess).DataIntThreshold * max(abs(TessInfo(iTess).DataLimitValue))) = 0; 
        % Cluster size using DataExtThreshold
        % knd: to do DataExtThreshold
        if TessInfo(iTess).DataExtThreshold > 0
            sSurf = bst_dataSetsManager('GetSurface', TessInfo(iTess).SurfaceFile);
            tmp = cluster_threshold(tmp,TessInfo(iTess).DataExtThreshold,sSurf.VertConn,1,0);
        end
        if sColormap.isAbsoluteValues
            tmp = abs(tmp);
        end
    end
    
    % === MRI ===
    if strcmpi(TessInfo(iTess).Name, 'Anatomy')
        % Update display
        UpdateMriDisplay(hFig, [], TessInfo, iTess);
        
    % === SURFACE ===
    else
        % SHOW CURVATURE
        if TessInfo(iTess).SurfShowCurvature
            % Get surface
            sSurf = bst_dataSetsManager('GetSurface', TessInfo(iTess).SurfaceFile);
            % Apply threshold to curvature mapping
            curvTmp = sSurf.Curvature;
            curvTmp( sSurf.Curvature >= TessInfo(iTess).SurfCurvatureThreshold) = .2;
            curvTmp( sSurf.Curvature <  TessInfo(iTess).SurfCurvatureThreshold) = -.2;                          
        % DO NOT SHOW CURVATURE
        else
            % Set Curvature = 1 for all the vertices
            curvTmp = ones(TessInfo(iTess).nVertices, 1);
        end

        % Compute RGB values
        FaceVertexCdata = blend_anatomy_data(curvTmp, ...                                   % Curvature
                                             tmp, ...                                       % Current density
                                             TessInfo(iTess).DataLimitValue, ...            % Limit value
                                             TessInfo(iTess).DataAlpha,...                  % Current density transparency
                                             TessInfo(iTess).AnatomyColor([1,end], :), ...  % Anatomy color
                                             sColormap.CMap);                               % Data colormap
        % Edge display : on/off
        if ~TessInfo(iTess).SurfShowEdges
            EdgeColor = 'none';
        else
            EdgeColor = [0 .8 0];
        end

        set(TessInfo(iTess).hPatch, 'FaceVertexCdata', FaceVertexCdata, ...
                                    'FaceColor',       'interp', ...
                                    'EdgeColor',       EdgeColor); 
    end
end


%% ===== SMOOTH SURFACE CALLBACK =====
function SmoothSurface(hFig, iTess, smoothValue)
    % Get surfaces list 
    TessInfo = getappdata(hFig, 'Surface');
    % Ignore MRI slices
    if strcmpi(TessInfo(iTess).Name, 'Anatomy')
        return
    end
    % Get surfaces vertices
    sSurf = bst_dataSetsManager('GetSurface', TessInfo(iTess).SurfaceFile);
    % If smoothValue is null: restore initial vertices
    if (smoothValue == 0)
        set(TessInfo(iTess).hPatch, 'Vertices', sSurf.Vertices);
        return
    end

    % ===== SMOOTH SURFACE =====
    gui_makeuswait('start');
    SurfSmoothIterations = 200 * smoothValue * length(sSurf.Vertices) / 100000;
    % Calculate smoothed vertices locations
    Vertices_sm = tess_smooth(sSurf.Vertices, ...
                              smoothValue, ...
                              SurfSmoothIterations, ...
                              sSurf.VertConn);
    % Apply smoothed locations
    set(TessInfo(iTess).hPatch, 'Vertices',  Vertices_sm);
    gui_makeuswait('stop');
end



%% ===== UPDATE SURFACE ALPHA =====
% Update Alpha values for the given surface.
% Fields that are used from TessInfo:
%    - SurfAlpha : Transparency of the surface patch
%    - Resect    : [x,y,z] doubles : Resect surfaces at these coordinates
%                  or string {'left', 'right', 'all'} : Display only selected part of the surface
function UpdateSurfaceAlpha(hFig, iTess)
    % Get surfaces list 
    TessInfo = getappdata(hFig, 'Surface');
    Surface = TessInfo(iTess);
       
    % Ignore empty surfaces and MRI slices
    if strcmpi(Surface.Name, 'Anatomy') || isempty(Surface.hPatch) || ~ishandle(Surface.hPatch)
        return 
    end
    % Apply current smoothing
    SmoothSurface(hFig, iTess, Surface.SurfSmoothValue);
    % Get surfaces vertices
    Vertices = get(Surface.hPatch, 'Vertices');
    nbVertices = length(Vertices);
    % Get vertex connectivity
    sSurf = bst_dataSetsManager('GetSurface', TessInfo(iTess).SurfaceFile);
    VertConn = sSurf.VertConn;
    % Create Alpha data
    FaceVertexAlphaData = ones(nbVertices,1) * (1-Surface.SurfAlpha);
    
    % ===== HEMISPHERE SELECTION (CHAR) =====
    if ischar(Surface.Resect)
        % Assumptions for this process :
        %    - (Y,Z) plane represents more or less the inter-hemispheric plane
        %    - Y<0 : Right hemisphere
        %    - Y>0 : Left hemisphere
        %    - The two hemispheres are not connected (as they are extracted by BrainVisa)
        % 
        % Get the start point
        START_PERCENT = .3;
        switch Surface.Resect
            case 'right'
                % Get maximal y value
                [yMax, iHideVert] = max(Vertices(:,2));
                % Get all the vertices that are at more than START_PERCENT of the maximum
                iNewVert = find(Vertices(:,2) > START_PERCENT * yMax)';
                iNewVert = setdiff(iNewVert, iHideVert);
            case 'left'
                % Get minimal y value
                [yMin, iHideVert] = min(Vertices(:,2));
                % Get all the vertices that are at more than 40% of the maximum
                iNewVert = find(Vertices(:,2) < START_PERCENT * yMin)';
                iNewVert = setdiff(iNewVert, iHideVert);
            case 'none'
                iHideVert = [];
        end

        % If not displaying the whole brain
        if ~isempty(iHideVert)
            % Grow region until getting all the hemisphere
            while ~isempty(iNewVert)
                iHideVert = union(iHideVert, iNewVert);
                iNewVert = patch_swell(iHideVert, VertConn);
            end
            % Check if we included all the brain (error...)
            if length(iHideVert) >= .8 * nbVertices
                %warning('The two hemispheres are connected. Cutting at y=0.');
                iHideVert = [];
                % The two hemispheres are connected => Cut at y=0
                if strcmpi(Surface.Resect, 'left')
                    %iHideVert = find(Vertices(:,2) < 0);
                    Surface.Resect = [0 -0.0000001 0];
                else
                    %iHideVert = find(Vertices(:,2) > 0);
                    Surface.Resect = [0 0.0000001 0];
                end
            end
        end
        % Update Alpha data
        FaceVertexAlphaData(iHideVert) = 0;
    end
        
    % ===== RESECT (DOUBLE) =====
    if isnumeric(Surface.Resect) && (length(Surface.Resect) == 3) && ~all(Surface.Resect == 0)
        iNoModif = [];
        % Get faces and vertices
        Vertices = get(Surface.hPatch, 'Vertices');
        Faces = get(Surface.hPatch, 'Faces');
        % Compute mean and max of the coordinates
        meanVertx = mean(Vertices, 1);
        maxVertx  = max(abs(Vertices), [], 1);
        % Limit values
        resectVal = Surface.Resect .* maxVertx + meanVertx;
        % Get vertices that are kept in all the cuts
        for iCoord = 1:3
            if Surface.Resect(iCoord) > 0
                iNoModif = union(iNoModif, find(Vertices(:,iCoord) < resectVal(iCoord)));
            elseif Surface.Resect(iCoord) < 0
                iNoModif = union(iNoModif, find(Vertices(:,iCoord) > resectVal(iCoord)));
            end
        end
        % Get all the faces that are partially visible
        ShowVert = zeros(nbVertices,1);
        ShowVert(iNoModif) = 1;
        facesStatus = sum(ShowVert(Faces), 2);
        iFacesVisible = find(facesStatus > 0);

        % Get the vertices of the faces that are partially visible
        iVerticesVisible = Faces(iFacesVisible,:);
        iVerticesVisible = unique(iVerticesVisible(:))';

        % Get vertices to project
        iVerticesToProject = [iVerticesVisible, patch_swell(iVerticesVisible, VertConn)];
        iVerticesToProject = setdiff(iVerticesToProject, iNoModif);
        % If there are some vertices to project
        if ~isempty(iVerticesToProject)
            % === FIRST PROJECTION ===
            % For the projected vertices: get the distance from each cut
            distToCut = abs(Vertices(iVerticesToProject, :) - repmat(resectVal, [length(iVerticesToProject), 1]));
            % Set the distance to the cuts that are not required to infinite
            distToCut(:,(Surface.Resect == 0)) = Inf;
            % Get the closest cut
            [minDist, closestCut] = min(distToCut, [], 2);

            % Project each vertex       
            Vertices(sub2ind(size(Vertices), iVerticesToProject, closestCut')) = resectVal(closestCut);

            % === SECOND PROJECTION ===            
            % In the faces that have visible and invisible vertices: project the invisible vertices
            % on the visible vertices
            %
            % Get the mixed faces (partially visible)
            ShowVert = zeros(nbVertices,1);
            ShowVert(iVerticesVisible) = 1;
            facesStatus = sum(ShowVert(Faces), 2);
            iFacesMixed = find((facesStatus > 0) & (facesStatus < 3));
            
            % Get the 
            projectList = logical(ShowVert(Faces(iFacesMixed,:)));
            for iFace = 1:length(iFacesMixed)
                iVertVis = Faces(iFacesMixed(iFace), projectList(iFace,:));
                iVertHid = Faces(iFacesMixed(iFace), ~projectList(iFace,:));
                % Project hidden vertices on first visible vertex
                Vertices(iVertHid, :) = repmat(Vertices(iVertVis(1), :), length(iVertHid), 1);
            end
            
            % Update patch
            set(Surface.hPatch, 'Vertices', Vertices);
        end
        % Hide some vertices
        FaceVertexAlphaData(setdiff(1:nbVertices, iVerticesVisible)) = 0;
    end
    % Update surface
    set(Surface.hPatch, 'FaceVertexAlphaData', FaceVertexAlphaData, ...
                        'FaceAlpha',           'interp');
end


%% ===== VIEW SENSORS =====
%Display sensors markers and labels in a 3DViz figure.
% Usage:   ViewSensors(hFig, isMarkers, isLabels)           : Display selected channels of figure hFig
%          ViewSensors(hFig, isMarkers, isLabels, Modality) : Display channels of target Modality in figure hFig
% Parameters :
%     - hFig      : target '3DViz' figure
%     - isMarkers : Sensors markers status : {0 (hide), 1 (show), [] (ignore)}
%     - isLabels  : Sensors labels status  : {0 (hide), 1 (show), [] (ignore)}
%     - Modality  : Sensor type to display ('EEG', 'MEG', ...)
function ViewSensors(hFig, isMarkers, isLabels, Modality)
    global GlobalData;
    % Parse inputs
    if (nargin < 4)
        Modality = '';
    end
    % Get figure description
    [hFig, iFig, iDS] = gui_figuresManager('GetFigure', hFig);
    if isempty(iDS)
        return
    end
    PlotHandles = GlobalData.DataSet(iDS).Figure(iFig).Handles;
    isTopography = strcmpi(get(hFig, 'Tag'), 'Topography');
    is2D = 0;
    
    % ===== MARKERS LOCATIONS =====
    % === TOPOGRAPHY ===
    if isTopography
        % Markers locations where stored in the Handles structure while creating topography patch
        if isempty(PlotHandles.MarkersLocs)
            return
        end
        % Get a location to display the Markers
        markersLocs = PlotHandles.MarkersLocs;
        % Flag=1 if 2D display
        is2D = ismember(GlobalData.DataSet(iDS).Figure(iFig).Id.SubType, {'2DDisc','2DSensorCap'});
        % Get selected channels
        SelectedChannels = GlobalData.DataSet(iDS).Figure(iFig).SelectedChannels;
        textLocs      = markersLocs;
        markersOrient = [];
    % === 3DVIZ ===
    % Display selected channels
    elseif isempty(Modality)
        % Get selected channel indices and locations
        [SelectedChannels, PChanLocs, PChanOrient] = GetSelectedChannels(iDS, iFig);
        if isempty(SelectedChannels)
            return
        end
        % Get locations to display the Markers
        markersLocs   = PChanLocs;
        markersOrient = PChanOrient;
        textLocs      = markersLocs;
    % Else : display sensors of the target modality
    else
        Channel = GlobalData.DataSet(iDS).Channel;
        % Find sensors of the target modality, select and display them
        % SelectedChannels = GetSelectedChannels(iDS, iFig);
        % SelectedChannels = find(strcmpi({Channel.Type}, Modality));
        SelectedChannels = good_channel(Channel, [], Modality);
        % If no channels for this modality
        if isempty(SelectedChannels)
            bst_error(['No "' Modality '" sensors in channel file: "' GlobalData.DataSet(iDS).ChannelFile '".'], 'View sensors', 0);
            return
        end
        % VectorView306 / CTF: keep all the coils defintions
        if ismember(Modality, {'Vectorview306', 'CTF'})
            markersLocs = cell2mat(cellfun(@(c)c(:,:), {Channel(SelectedChannels).Loc},    'UniformOutput', 0))';
            textLocs    = cell2mat(cellfun(@(c)c(:,1), {Channel(SelectedChannels).Loc},    'UniformOutput', 0))';
        % Else: only keep the first location
        else
            markersLocs = cell2mat(cellfun(@(c)c(:,1), {Channel(SelectedChannels).Loc}, 'UniformOutput', 0))';
            textLocs    = markersLocs;
        end
        % Markers orientations: only for MEG
        if ismember(Modality, {'MEG', 'MEG GRAD', 'MEG MAG', 'Vectorview306', 'CTF'})
            markersOrient = cell2mat(cellfun(@(c)c(:,1), {Channel(SelectedChannels).Orient}, 'UniformOutput', 0))';
        else
            markersOrient = [];
        end
    end
    % Make sure that electrodes locations are in double precision
    markersLocs = double(markersLocs);
    markersOrient = double(markersOrient);
    
    % ===== DISPLAY MARKERS OBJECTS =====
    % Put focus on target figure
%     figure(hFig);
    hAxes = findobj(hFig, 'Tag', 'Axes3D');
    % === SENSORS ===
    if ~isempty(isMarkers)
        % Delete sensor markers
        if ~isempty(PlotHandles.hSensorMarkers) && all(ishandle(PlotHandles.hSensorMarkers))
            delete(PlotHandles.hSensorMarkers);
            delete(PlotHandles.hSensorOrient);
            PlotHandles.hSensorMarkers = [];
            PlotHandles.hSensorOrient = [];
        end
        
        % Display sensors markers
        if isMarkers
            % Is display of a flat 2D topography map
            if is2D
                PlotHandles.hSensorMarkers = gui_plotSensors2D(hAxes, markersLocs);
            % If VectorView306   
            elseif strcmpi(Modality, 'Vectorview306')
                [PlotHandles.hSensorMarkers, PlotHandles.hSensorOrient] = ...
                    gui_plotSensorsVectorview306(hAxes, markersLocs, markersOrient);
                isLabels = 0;
                % Display head points
                ViewHeadPoints(hFig, 1);
            % If CTF   
            elseif strcmpi(Modality, 'CTF')
                [PlotHandles.hSensorMarkers, PlotHandles.hSensorOrient] = ...
                    gui_plotSensorsCTF(hAxes, markersLocs, markersOrient);
                isLabels = 0;
                % Display head points
                ViewHeadPoints(hFig, 1);
            % Define face and edge colors :
            % If more than one patch : transparent sensor cap
            elseif ~isempty(findobj(hAxes, 'type', 'patch')) || ~isempty(findobj(hAxes, 'type', 'surface'))
                [PlotHandles.hSensorMarkers, PlotHandles.hSensorOrient] = ...
                    gui_plotSensorsNet(hAxes, markersLocs, 0, markersOrient);
            % Else, sensor cap is the only patch => display its faces
            else
                [PlotHandles.hSensorMarkers, PlotHandles.hSensorOrient] = ...
                    gui_plotSensorsNet(hAxes, markersLocs, 1, markersOrient);
            end
        end
    end
    
    % === LABELS ===
    if ~isempty(isLabels)
        % Delete sensor labels
        if ~isempty(PlotHandles.hSensorLabels)
            delete(PlotHandles.hSensorLabels(ishandle(PlotHandles.hSensorLabels)));
            PlotHandles.hSensorLabels = [];
        end
        % Display sensor labels
        if isLabels
            sensorNames = {GlobalData.DataSet(iDS).Channel.Name}';
            if ~isempty(sensorNames)
                % Get the names of the seleected sensors
                sensorNames = sensorNames(SelectedChannels);
                PlotHandles.hSensorLabels = text(1.08*textLocs(:,1), 1.08*textLocs(:,2), 1.08*textLocs(:,3), ...
                                                 sensorNames, ...
                                                 'Parent',              hAxes, ...
                                                 'HorizontalAlignment', 'center', ...
                                                 'Fontsize',            10, ...
                                                 'FontUnits',           'points', ...
                                                 'FontWeight',          'normal', ...
                                                 'Tag',                 'SensorsLabels', ...
                                                 'Color',               [1,1,.2], ...
                                                 'Interpreter',         'none');
            end
        end
    end
    
    GlobalData.DataSet(iDS).Figure(iFig).Handles = PlotHandles;
    
    % ===== Update MouseSelectedChannels =====
    bst_dataSetsManager('UpdateSelectionForFigure', iDS);
end



%% ===== VIEW HEAD POINTS =====
function ViewHeadPoints(hFig, isVisible)
    global GlobalData;
    % Get figure description
    [hFig, iFig, iDS] = gui_figuresManager('GetFigure', hFig);
    if isempty(iDS)
        return
    end
    hAxes = findobj(hFig, 'Tag', 'Axes3D');
    % If no head points are available: exit
    if isempty(GlobalData.DataSet(iDS).HeadPoints) || ~isfield(GlobalData.DataSet(iDS).HeadPoints, 'Loc') || isempty(GlobalData.DataSet(iDS).HeadPoints.Loc)
        return
    end
    HeadPoints = GlobalData.DataSet(iDS).HeadPoints;
    % Else, get previous head points
    hHeadPointsMarkers = findobj(hFig, 'Tag', 'HeadPointsMarkers');
    hHeadPointsLabels  = findobj(hFig, 'Tag', 'HeadPointsLabels');
    % If head points graphic objects already exist: set the "Visible" property
    if ~isempty(hHeadPointsMarkers)
        if isVisible
            set(hHeadPointsMarkers, 'Visible', 'on');
            set(hHeadPointsLabels,  'Visible', 'on');
        else
            set(hHeadPointsMarkers, 'Visible', 'off');
            set(hHeadPointsLabels,  'Visible', 'off');
        end
    % If head points objects were not created yet: create them
    elseif isVisible
        % Get digitized points locations
        digLoc = double(HeadPoints.Loc)';
        % Display markers
        hDigMark = line(digLoc(:,1), digLoc(:,2), digLoc(:,3), ...
                'Parent',          hAxes, ...
                'LineWidth',       2, ...
                'LineStyle',       'none', ...
                'MarkerFaceColor', [.3 1 .3], ...
                'MarkerEdgeColor', [.4 .7 .4], ...
                'MarkerSize',      6, ...
                'Marker',          'o', ...
                'Tag',             'HeadPointsMarkers');
        % Prepare display names
        digNames = cell(size(HeadPoints.Label));
        for i = 1:length(HeadPoints.Label)
            switch upper(HeadPoints.Type{i})
                case 'CARDINAL'
                    digNames{i} = HeadPoints.Label{i};
%                 case 'EXTRA'
%                     if isnumeric(HeadPoints.Label{i})
%                         digNames{i} = num2str(HeadPoints.Label{i});
%                     else
%                         digNames{i} = HeadPoints.Label{i};
%                     end
                otherwise
                    if isnumeric(HeadPoints.Label{i})
                        digNames{i} = [HeadPoints.Type{i}, '-', num2str(HeadPoints.Label{i})];
                    else
                        digNames{i} = [HeadPoints.Type{i}, '-', HeadPoints.Label{i}];
                    end            
            end
        end
        % Only display the legends for points that are not "EXTRA" or "EEG"
        iNotExtra = find(~strcmpi(HeadPoints.Type, 'EXTRA') & ~strcmpi(HeadPoints.Type, 'EEG'));
        % Display labels
        if ~isempty(iNotExtra)
            hDigLabel = text(1.08*digLoc(iNotExtra,1), 1.08*digLoc(iNotExtra,2), 1.08*digLoc(iNotExtra,3), ...
                            digNames(iNotExtra)', ...
                            'Parent',              hAxes, ...
                            'HorizontalAlignment', 'center', ...
                            'Fontsize',            10, ...
                            'FontUnits',           'points', ...
                            'FontWeight',          'normal', ...
                            'Tag',                 'HeadPointsLabels', ...
                            'Color',               [1,1,.2], ...
                            'Interpreter',         'none');
        end
    end
end


%% ===== VIEW AXIS =====
function ViewAxis(hFig, isVisible)
    hAxes = findobj(hFig, 'Tag', 'Axes3D');
    if (nargin < 2)
        isVisible = isempty(findobj(hAxes, 'Tag', 'AxisXYZ'));
    end
    if isVisible
        line([0 0.15], [0 0], [0 0], 'Color', [1 0 0], 'Marker', '>', 'Parent', hAxes, 'Tag', 'AxisXYZ');
        line([0 0], [0 0.15], [0 0], 'Color', [0 1 0], 'Marker', '>', 'Parent', hAxes, 'Tag', 'AxisXYZ');
        line([0 0], [0 0], [0 0.15], 'Color', [0 0 1], 'Marker', '>', 'Parent', hAxes, 'Tag', 'AxisXYZ');
        text(0.151, 0, 0, 'X', 'Color', [1 0 0], 'Parent', hAxes, 'Tag', 'AxisXYZ');
        text(0, 0.151, 0, 'Y', 'Color', [0 1 0], 'Parent', hAxes, 'Tag', 'AxisXYZ');
        text(0, 0, 0.151, 'Z', 'Color', [0 0 1], 'Parent', hAxes, 'Tag', 'AxisXYZ');
    else
        hAxisXYZ = findobj(hAxes, 'Tag', 'AxisXYZ');
        if ~isempty(hAxisXYZ)
            delete(hAxisXYZ);
        end
    end
end


%% ===== CHANGE BACKGROUND COLOR =====
function ChangeBackgroundColor(hFig)
    % Use previous scout color
    newColor = uisetcolor([0 0 0], 'Select scout color');
    % If no color was selected: exit
    if (length(newColor) ~= 3) || all(newColor == [0 0 0])
        return
    end
    % Set background
    set(hFig, 'Color', newColor);
end


