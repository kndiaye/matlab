function varargout = panel_surface(varargin)
% PANEL_SURFACE: Panel to load and plot surfaces.
% 
% USAGE:  bstPanel = panel_surface('CreatePanel')
%                    panel_surface('UpdatePanel')
%                    panel_surface('CurrentFigureChanged_Callback')
%       nbSurfaces = panel_surface('CreateSurfaceList',      %          %         iSurface = panel_surface('AddSurface',             hFig, surfaceFile)
%                    panel_surface('UpdateSurfaceProperties')
%         iSurface = panel_surface('AddSurface',             hFig, surfaceFile)
%                    panel_surface('RemoveSurface',          hFig, iSurface)
%                    panel_surface('SetSurfaceTransparency', hFig, iSurf, alpha)
%                    panel_surface('SetSurfaceColor',        hFig, iSurf, newColor)
%                    panel_surface('ApplyDefaultDisplay')
%           [isOk] = panel_surface('SetSurfaceData',        hFig, iTess, dataType, dataFile, isStat, isZscore)

%           [isOk] = panel_surface('UpdateSurfaceData',     hFig, iSurfaces)
%  [iCortex,TessInfo,hFig] = panel_surface('GetSurfaceCortex')
%          iCortex = panel_surface('GetSurfaceCortex',      hFig)
%                    panel_surface('UpdateOverlayCube',     hFig, iTess)

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

% No parameters 
if (nargin == 0)
% Else : execute appropriate local function
elseif ischar(varargin{1}) 
    if (nargout)
        [varargout{1:nargout}] = bst_safeCall(str2func(varargin{1}), varargin{2:end});
    else
        bst_safeCall(str2func(varargin{1}), varargin{2:end});
    end
end
end


%% ===== CREATE PANEL =====
function bstPanelNew = CreatePanel() %#ok<DEFNU>
    panelName = 'Surface';
    % Java initializations
    import java.awt.*;
    import javax.swing.*;
    import org.brainstorm.icon.IconLoader;
   
    % Constants
    LABEL_WIDTH    = 30;
    BUTTON_WIDTH   = 40;
    SLIDER_WIDTH   = 20;
    DEFAULT_HEIGHT = 22;
    TB_HEIGHT      = 28;
    jFontText = java.awt.Font('Dialog', java.awt.Font.PLAIN, 10);
    % Create panel
    jPanelNew = JPanel(BorderLayout());
    jPanelNew.setBorder([]);

    % ====================================================================
    % ==== TOOLBAR : SURFACES LIST =======================================
    % Create Toolbar
    jToolbarSurfaces = JToolBar('Edit scouts');
    jToolbarSurfaces.setBorderPainted(0);
    jToolbarSurfaces.setFloatable(0);
    jToolbarSurfaces.setRollover(1);
    jToolbarSurfaces.setPreferredSize(Dimension(100, TB_HEIGHT));
        % Add title "Surfaces"
        jLabelSurfacesTitle = JLabel('    Surfaces:');
        jLabelSurfacesTitle.setFont(jFontText);
        jToolbarSurfaces.add(jLabelSurfacesTitle);
        % Separation panel
        jToolbarSurfaces.add(JPanel());
        % Add separator
        jToolbarSurfaces.addSeparator(Dimension(10, TB_HEIGHT));
        % Create "Add" button
        jButtonAddSurface = JButton(IconLoader.ICON_SURFACE_ADD);
        jButtonAddSurface.setMaximumSize(Dimension(26, 26));
        jButtonAddSurface.setPreferredSize(Dimension(26, 26));
        jButtonAddSurface.setToolTipText('Add a surface');
        jButtonAddSurface.setFocusPainted(0);
        set(jButtonAddSurface, 'ActionPerformedCallback', @ButtonAddSurfaceCallback);
        jToolbarSurfaces.add(jButtonAddSurface);
        % Create "Remove" button
        jButtonRemoveSurface = JButton(IconLoader.ICON_SURFACE_REMOVE);
        jButtonRemoveSurface.setMaximumSize(Dimension(26, 26));
        jButtonRemoveSurface.setPreferredSize(Dimension(26, 26));
        jButtonRemoveSurface.setToolTipText('Remove surface from figure');
        jButtonRemoveSurface.setFocusPainted(0);
        set(jButtonRemoveSurface, 'ActionPerformedCallback', @ButtonRemoveSurfaceCallback);
        jToolbarSurfaces.add(jButtonRemoveSurface);
    jPanelNew.add(jToolbarSurfaces, BorderLayout.NORTH);

    % ====================================================================
    % ==== OPTIONS PANEL ==================================================
    % Create OPTIONS scrollpane
    jPanelOptions = getRiverPanel([3,5]);
        % ===== Create panel : surface configuration =====
        jPanelSurfaceOptions = getRiverPanel([1,1], [1,1,1,1], 'Surface options');              
            % Alpha title 
            jLabelTranspTitle = JLabel('Transp.:');
            jLabelTranspTitle.setFont(jFontText);
            jPanelSurfaceOptions.add('br', jLabelTranspTitle);
            % Alpha slider
            jSliderSurfAlpha = JSlider(0, 100, 0);
            jSliderSurfAlpha.setPreferredSize(Dimension(SLIDER_WIDTH, DEFAULT_HEIGHT));
            set(jSliderSurfAlpha, 'MouseReleasedCallback', @(h,ev)SliderCallback(h, ev, 'SurfAlpha'), ...
                                  'KeyPressedCallback',    @(h,ev)SliderCallback(h, ev, 'SurfAlpha'));
            jPanelSurfaceOptions.add('tab hfill', jSliderSurfAlpha);
            % Alpha label
            jLabelSurfAlpha = JLabel('     ', JLabel.RIGHT);
            jLabelSurfAlpha.setFont(jFontText);
            jLabelSurfAlpha.setPreferredSize(Dimension(LABEL_WIDTH, DEFAULT_HEIGHT));
            jLabelSurfAlpha.setToolTipText('Set surface transparency');
            jPanelSurfaceOptions.add(jLabelSurfAlpha);
            % Color button
            jButtonSurfColor = JButton('Color');
            jButtonSurfColor.setFont(jFontText);
            jButtonSurfColor.setPreferredSize(Dimension(BUTTON_WIDTH, DEFAULT_HEIGHT));
            jButtonSurfColor.setMargin(Insets(0,0,0,0));
            jButtonSurfColor.setToolTipText('Set surface color');
            jButtonSurfColor.setFocusPainted(0);
            set(jButtonSurfColor, 'ActionPerformedCallback', @ButtonSurfColorCallback);
            jPanelSurfaceOptions.add(jButtonSurfColor);

            % Curvature title and slider
            jLabelCurvTitle = JLabel('Curvature:');
            jLabelCurvTitle.setFont(jFontText);
            jPanelSurfaceOptions.add('br', jLabelCurvTitle);
            % Curvature : [-0.20, 0.20] with step=0.01   => Integer:[-20,20]
            jSliderSurfCurvature = JSlider(-20, 20, 0);
            jSliderSurfCurvature.setPreferredSize(Dimension(SLIDER_WIDTH,DEFAULT_HEIGHT));
            set(jSliderSurfCurvature, 'MouseReleasedCallback', @(h,ev)SliderCallback(h, ev, 'SurfCurvature'), ...
                                      'KeyPressedCallback',    @(h,ev)SliderCallback(h, ev, 'SurfCurvature'));
            jPanelSurfaceOptions.add('tab hfill', jSliderSurfCurvature);
            % Curvature label
            jLabelSurfCurvature = JLabel('     ', JLabel.RIGHT);
            jLabelSurfCurvature.setFont(jFontText);
            jLabelSurfCurvature.setPreferredSize(Dimension(LABEL_WIDTH,DEFAULT_HEIGHT));
            jPanelSurfaceOptions.add(jLabelSurfCurvature);
            % Curvature 'View' button
            jButtonSurfCurvature = JToggleButton('Show');
            jButtonSurfCurvature.setFont(jFontText);
            jButtonSurfCurvature.setPreferredSize(Dimension(BUTTON_WIDTH,DEFAULT_HEIGHT));
            jButtonSurfCurvature.setMargin(Insets(0,0,0,0));
            jButtonSurfCurvature.setToolTipText('Show/hide surface curvature');
            jButtonSurfCurvature.setFocusPainted(0);
            set(jButtonSurfCurvature, 'ActionPerformedCallback', @ButtonShowCurvatureCallback);
            jPanelSurfaceOptions.add(jButtonSurfCurvature);

            % Smooth title
            jLabelSmoothTitle = JLabel('Smooth:');
            jLabelSmoothTitle.setFont(jFontText);
            jPanelSurfaceOptions.add('br', jLabelSmoothTitle);
            % Smooth slider 
            jSliderSurfSmoothValue = JSlider(0, 100, 0);
            jSliderSurfSmoothValue.setPreferredSize(Dimension(SLIDER_WIDTH, DEFAULT_HEIGHT));
            jSliderSurfSmoothValue.setToolTipText('Smooth surface');
            set(jSliderSurfSmoothValue, 'MouseReleasedCallback', @(h,ev)SliderCallback(h, ev, 'SurfSmoothValue'), ...
                                        'KeyPressedCallback',    @(h,ev)SliderCallback(h, ev, 'SurfSmoothValue'));
            jPanelSurfaceOptions.add('tab hfill', jSliderSurfSmoothValue);
            % Smooth ALPHA label
            jLabelSurfSmoothValue = JLabel('     ', JLabel.RIGHT);
            jLabelSurfSmoothValue.setFont(jFontText);
            jLabelSurfSmoothValue.setPreferredSize(Dimension(LABEL_WIDTH, DEFAULT_HEIGHT));
            jPanelSurfaceOptions.add(jLabelSurfSmoothValue);

            % Edge button
            jButtonSurfEdge = JToggleButton('Edge');
            jButtonSurfEdge.setFont(jFontText);
            jButtonSurfEdge.setPreferredSize(Dimension(BUTTON_WIDTH,DEFAULT_HEIGHT));
            jButtonSurfEdge.setMargin(Insets(0,0,0,0));
            jButtonSurfEdge.setToolTipText('Show/hide surface triangles');
            jButtonSurfEdge.setFocusPainted(0);
            set(jButtonSurfEdge, 'ActionPerformedCallback', @ButtonShowEdgesCallback);
            jPanelSurfaceOptions.add(jButtonSurfEdge);
        jPanelOptions.add('br hfill', jPanelSurfaceOptions);
    
        % ===== Create panel : data description =====
        jPanelDataOptions = getRiverPanel([1,1], [1,8,1,10], 'Data options');
            % ======================
            % Threshold label
            jLabelIntThreshTitle = JLabel('Int. Thresh.:');
            jLabelIntThreshTitle.setFont(jFontText);
            jPanelDataOptions.add(jLabelIntThreshTitle);
            % Threshold slider
            jSliderDataIntThresh = JSlider(0, 100, 50);
            jSliderDataIntThresh.setPreferredSize(Dimension(SLIDER_WIDTH, DEFAULT_HEIGHT));
            set(jSliderDataIntThresh, 'MouseReleasedCallback', @(h,ev)SliderCallback(h, ev, 'DataIntThreshold'), ...
                                      'KeyPressedCallback',    @(h,ev)SliderCallback(h, ev, 'DataIntThreshold'));
            jPanelDataOptions.add('tab hfill', jSliderDataIntThresh);
            % Threshold label
            jLabelDataIntThresh = JLabel('     ', JLabel.RIGHT);
            jLabelDataIntThresh.setFont(jFontText);
            jLabelDataIntThresh.setPreferredSize(Dimension(LABEL_WIDTH, DEFAULT_HEIGHT));
            jPanelDataOptions.add(jLabelDataIntThresh);

            % ======================        
            % Cluster size (extent) threshold
            jLabelExtThreshTitle = JLabel('Extent Thr.:');
            jLabelExtThreshTitle.setFont(jFontText);
            jPanelDataOptions.add('br', jLabelExtThreshTitle);
            % Threshold slider
            jSliderDataExtThresh = JSlider(0, 100, 50);
            jSliderDataExtThresh.setPreferredSize(Dimension(SLIDER_WIDTH, DEFAULT_HEIGHT));
            set(jSliderDataExtThresh, 'MouseReleasedCallback', @(h,ev)SliderCallback(h, ev, 'DataExtThreshold'), ...
                                      'KeyPressedCallback',    @(h,ev)SliderCallback(h, ev, 'DataExtThreshold'));
            jPanelDataOptions.add('tab hfill', jSliderDataExtThresh);
            % Threshold label
            jLabelDataExtThresh = JLabel('     ', JLabel.RIGHT);
            jLabelDataExtThresh.setFont(jFontText);
            jLabelDataExtThresh.setPreferredSize(Dimension(LABEL_WIDTH, DEFAULT_HEIGHT));
            jPanelDataOptions.add(jLabelDataExtThresh);
            
            % ======================
            % Alpha title and slider
            jLabelAlphaTitle = JLabel('Transp.:');
            jLabelAlphaTitle.setFont(jFontText);
            jPanelDataOptions.add('br', jLabelAlphaTitle);
            jSliderDataAlpha = JSlider(0, 100, 0);
            jSliderDataAlpha.setPreferredSize(Dimension(SLIDER_WIDTH, DEFAULT_HEIGHT));
            set(jSliderDataAlpha, 'MouseReleasedCallback', @(h,ev)SliderCallback(h, ev, 'DataAlpha'), ...
                                  'KeyPressedCallback',    @(h,ev)SliderCallback(h, ev, 'DataAlpha'));
            jPanelDataOptions.add('tab hfill', jSliderDataAlpha);
            % Data alpha label
            jLabelDataAlpha = JLabel('     ', JLabel.RIGHT);
            jLabelDataAlpha.setFont(jFontText);
            jLabelDataAlpha.setPreferredSize(Dimension(LABEL_WIDTH, DEFAULT_HEIGHT));
            jPanelDataOptions.add(jLabelDataAlpha);
            
        jPanelOptions.add('br hfill', jPanelDataOptions);
        
        % ===== Create panel : surface resect =====
        jPanelSurfaceResect = getRiverPanel([0,4], [1,8,8,0], 'Resect [X,Y,Z]');
            % === RESECT SLIDERS ===
            % Sub panel
            panelResect = JPanel();
            panelResect.setLayout(BoxLayout(panelResect, BoxLayout.LINE_AXIS));
                % Resect X : Slider 
                jSliderResectX = JSlider(-100, 100, 0);
                jSliderResectX.setPreferredSize(Dimension(SLIDER_WIDTH, DEFAULT_HEIGHT));
                set(jSliderResectX, 'MouseReleasedCallback', @(h,ev)SliderCallback(h, ev, 'ResectX'), ...
                                    'KeyPressedCallback',    @(h,ev)SliderCallback(h, ev, 'ResectX'));
                panelResect.add('hfill', jSliderResectX);   
                % Resect Y : Title and Slider 
                jSliderResectY = JSlider(-100, 100, 0);
                jSliderResectY.setPreferredSize(Dimension(SLIDER_WIDTH, DEFAULT_HEIGHT));
                set(jSliderResectY, 'MouseReleasedCallback', @(h,ev)SliderCallback(h, ev, 'ResectY'), ...
                                    'KeyPressedCallback',    @(h,ev)SliderCallback(h, ev, 'ResectY'));
                panelResect.add('hfill', jSliderResectY);     
                % Resect Z : Title and Slider 
                jSliderResectZ = JSlider(-100, 100, 0);
                jSliderResectZ.setPreferredSize(Dimension(SLIDER_WIDTH, DEFAULT_HEIGHT));
                set(jSliderResectZ, 'MouseReleasedCallback', @(h,ev)SliderCallback(h, ev, 'ResectZ'), ...
                                    'KeyPressedCallback',    @(h,ev)SliderCallback(h, ev, 'ResectZ'));
                panelResect.add('hfill', jSliderResectZ);   
            jPanelSurfaceResect.add('hfill', panelResect);
            
            % === HEMISPHERES SELECTION ===
            % Title
            jPanelSurfaceResect.add('br', JLabel('  '));
            % Left Hemisphere
            jToggleResectLeft  = JToggleButton('Left');
            jToggleResectLeft.setFont(jFontText);
            jToggleResectLeft.setMargin(Insets(0,0,0,0));
            jToggleResectLeft.setPreferredSize(Dimension(50, 20));
            jToggleResectLeft.setFocusPainted(0);
            set(jToggleResectLeft, 'MouseReleasedCallback', @ButtonResectLeftToggle_Callback);
            jPanelSurfaceResect.add(jToggleResectLeft);
            
            % Right Hemisphere
            jToggleResectRight = JToggleButton('Right');
            jToggleResectRight.setFont(jFontText);
            jToggleResectRight.setMargin(Insets(0,0,0,0));
            jToggleResectRight.setPreferredSize(Dimension(50, 20));
            jToggleResectRight.setFocusPainted(0);
            set(jToggleResectRight, 'MouseReleasedCallback', @ButtonResectRightToggle_Callback);
            jPanelSurfaceResect.add(jToggleResectRight);
            
            % Separator
            jPanelSurfaceResect.add('hfill', JLabel(' '));
            
            % Reset button
            jButtonResectReset = JButton('Reset');
            jButtonResectReset.setFont(jFontText);
            jButtonResectReset.setMargin(Insets(0,0,0,0));
            jButtonResectReset.setPreferredSize(Dimension(50, 20));
            jButtonResectReset.setFocusPainted(0);
            set(jButtonResectReset, 'ActionPerformedCallback', @ButtonResectResetCallback);
            jPanelSurfaceResect.add(jButtonResectReset);
            % Separator from the border
            jPanelSurfaceResect.add(JLabel('  '));
            
        jPanelOptions.add('br hfill', jPanelSurfaceResect);
 
        % NbVertices Title
        jLabelNbVertTitle = JLabel('    Vertices : ');
        jLabelNbVertTitle.setFont(jFontText);
        jPanelOptions.add('br', jLabelNbVertTitle);
        % NbVertices
        jLabelNbVertices = JLabel('0');
        jLabelNbVertices.setFont(jFontText);
        jPanelOptions.add(jLabelNbVertices);
        % NbFaces Title
        jLabelNbFacesTitle = JLabel('    Faces : ');
        jLabelNbFacesTitle.setFont(jFontText);
        jPanelOptions.add(jLabelNbFacesTitle);
        % NbFaces
        jLabelNbFaces = JLabel('0');
        jLabelNbFaces.setFont(jFontText);
        jPanelOptions.add(jLabelNbFaces);
        
    jScrollPaneOptions = JScrollPane(jPanelOptions);
    jScrollPaneOptions.setBorder([]);
    jPanelNew.add(jScrollPaneOptions, BorderLayout.CENTER);
    
    % Create the BstPanel object that is returned by the function
    % => constructor BstPanel(jHandle, panelName, sControls)
    bstPanelNew = BstPanel(panelName, ...
                           jPanelNew, ...
                           struct('jToolbarSurfaces',       jToolbarSurfaces, ...
                                  'jPanelOptions',          jPanelOptions, ...
                                  'jPanelSurfaceOptions',   jPanelSurfaceOptions, ...
                                  'jPanelSurfaceResect',    jPanelSurfaceResect, ...
                                  'jPanelDataOptions',      jPanelDataOptions, ...                             
                                  'jLabelNbVertices',       jLabelNbVertices, ...
                                  'jLabelNbFaces',          jLabelNbFaces, ...
                                  'jSliderSurfAlpha',       jSliderSurfAlpha, ...
                                  'jLabelSurfAlpha',        jLabelSurfAlpha, ...
                                  'jButtonSurfColor',       jButtonSurfColor, ...
                                  'jLabelSurfSmoothValue',  jLabelSurfSmoothValue, ...
                                  'jSliderSurfSmoothValue', jSliderSurfSmoothValue, ...
                                  'jSliderSurfCurvature',   jSliderSurfCurvature, ...
                                  'jLabelSurfCurvature',    jLabelSurfCurvature, ...
                                  'jButtonSurfCurvature',   jButtonSurfCurvature, ...
                                  'jButtonSurfEdge',        jButtonSurfEdge, ...
                                  'jSliderResectX',         jSliderResectX, ...
                                  'jSliderResectY',         jSliderResectY, ...
                                  'jSliderResectZ',         jSliderResectZ, ...
                                  'jToggleResectLeft',       jToggleResectLeft, ...
                                  'jToggleResectRight',      jToggleResectRight, ...
                                  'jSliderDataAlpha',       jSliderDataAlpha, ...
                                  'jLabelDataAlpha',        jLabelDataAlpha, ...
                                  'jSliderDataExtThresh',      jSliderDataExtThresh, ...
                                  'jLabelDataExtThresh',       jLabelDataExtThresh, ...
                                  'jSliderDataIntThresh',      jSliderDataIntThresh, ...
                                  'jLabelDataIntThresh',       jLabelDataIntThresh));



    %% ===== RESET RESECT CALLBACK =====
    function ButtonResectResetCallback(varargin)
        import java.awt.event.MouseEvent;
        % Reset initial resect sliders positions
        jSliderResectX.setValue(0);
        jSliderResectY.setValue(0);
        jSliderResectZ.setValue(0);
        SliderCallback([], MouseEvent(jSliderResectX, 0, 0, 0, 0, 0, 1, 0), 'ResectX');
        SliderCallback([], MouseEvent(jSliderResectY, 0, 0, 0, 0, 0, 1, 0), 'ResectY');
        SliderCallback([], MouseEvent(jSliderResectZ, 0, 0, 0, 0, 0, 1, 0), 'ResectZ');
    end

    %% ===== RESECT LEFT TOGGLE CALLBACK =====
    function ButtonResectLeftToggle_Callback(varargin)
        if jToggleResectLeft.isSelected()
            jToggleResectRight.setSelected(0);
            SelectHemispheres('left');
        else
            SelectHemispheres('none');
        end
    end

    %% ===== RESECT RIGHT TOGGLE CALLBACK =====
    function ButtonResectRightToggle_Callback(varargin)
        if jToggleResectRight.isSelected()
            jToggleResectLeft.setSelected(0);
            SelectHemispheres('right');
        else
            SelectHemispheres('none');
        end
    end
end


%% =================================================================================
%  === CONTROLS CALLBACKS  =========================================================
%  =================================================================================
%% ===== SLIDERS CALLBACKS =====
function SliderCallback(hObject, event, target)
    % Get panel controls
    ctrl = bst_getContext('PanelControls', 'Surface');
    % Get slider pointer
    jSlider = event.getSource();
    % If slider is not enabled : do nothing
    if ~jSlider.isEnabled()
        return
    end

    % Get handle to current 3DViz figure
    hFig = gui_figuresManager('GetCurrentFigure', '3D');
    if isempty(hFig)
        return
    end
    % Get current surface index (in the current figure)
    iSurface = getappdata(hFig, 'iSurface');
    % If surface data is not accessible
    if isempty(hFig) || isempty(iSurface)
        return;
    end
    % Get figure AppData (figure's surfaces configuration)
    TessInfo = getappdata(hFig, 'Surface');
    if (iSurface > length(TessInfo))
        return;
    end
    % Is selected surface a MRI/slices surface
    isAnatomy = strcmpi(TessInfo(iSurface).Name, 'Anatomy');
    
    % Get slider value and update surface value
    switch (target)
        case 'SurfAlpha'
            % Update value in Surface array
            TessInfo(iSurface).SurfAlpha = jSlider.getValue() / 100;
            % Display value in the label associated with the slider
            ctrl.jLabelSurfAlpha.setText(sprintf('%d%%', round(TessInfo(iSurface).SurfAlpha * 100)));
            % Update current surface
            setappdata(hFig, 'Surface', TessInfo);
            % For MRI: redraw all slices
            if isAnatomy
                figure_callback(hFig, 'UpdateMriDisplay', hFig, [], TessInfo, iSurface);
            % Else: Update color display on the surface
            else
                figure_callback(hFig, 'UpdateSurfaceAlpha', hFig, iSurface);
            end
    
        case 'SurfSmoothValue'
            TessInfo(iSurface).SurfSmoothValue = jSlider.getValue() / 100;
            ctrl.jLabelSurfSmoothValue.setText(sprintf('%d%%', round(TessInfo(iSurface).SurfSmoothValue * 100)));
            % Update current surface
            setappdata(hFig, 'Surface', TessInfo);
            % For MRI display : Smooth slider changes threshold
            if isAnatomy
                figure_callback(hFig, 'UpdateMriDisplay', hFig, [], TessInfo, iSurface);
            % Else: Update color display on the surface
            else
                % Smooth surface
                figure_callback(hFig, 'UpdateSurfaceAlpha', hFig, iSurface);
                % Update scouts displayed on this surfce
                panel_scouts('UpdateScoutsVertices', TessInfo(iSurface).SurfaceFile);
                % Set the new value as the default value
                DefaultSurfaceDisplay = bst_getContext('DefaultSurfaceDisplay');
                DefaultSurfaceDisplay.SurfSmoothValue = TessInfo(iSurface).SurfSmoothValue;
                bst_setContext('DefaultSurfaceDisplay', DefaultSurfaceDisplay);
            end

        case 'SurfCurvature'
            % Update value in Surface array
            % Correspondance : [-80,80] <=> [-0.80, 0.80] 
            TessInfo(iSurface).SurfCurvatureThreshold = jSlider.getValue() / 100;
            ctrl.jLabelSurfCurvature.setText(sprintf('%d%%', round(100 * TessInfo(iSurface).SurfCurvatureThreshold)));
            % Update current surface
            setappdata(hFig, 'Surface', TessInfo);
            % Update surface display (ONLY if Curvature is currently displayed)
            if TessInfo(iSurface).SurfShowCurvature
                figure_callback(hFig, 'UpdateSurfaceColor', hFig, iSurface);
            end

        case 'DataAlpha'
            % Update value in Surface array
            TessInfo(iSurface).DataAlpha = jSlider.getValue() / 100;
            ctrl.jLabelDataAlpha.setText(sprintf('%d%%', round(TessInfo(iSurface).DataAlpha * 100)));
            % Update current surface
            setappdata(hFig, 'Surface', TessInfo);
            % Update color display on the surface
            figure_callback(hFig, 'UpdateSurfaceColor', hFig, iSurface);

        case 'DataIntThreshold'
            % Update value in Surface array
            TessInfo(iSurface).DataIntThreshold = jSlider.getValue() / 100;
            ctrl.jLabelDataIntThresh.setText(sprintf('%d%%', round(TessInfo(iSurface).DataIntThreshold * 100)));
            % Update current surface
            setappdata(hFig, 'Surface', TessInfo);
            % Update color display on the surface
            figure_callback(hFig, 'UpdateSurfaceColor', hFig, iSurface);
            % Set the new value as the default value (NOT FOR MRI)
            if ~isAnatomy
                DefaultSurfaceDisplay = bst_getContext('DefaultSurfaceDisplay');
                DefaultSurfaceDisplay.DataIntThreshold = TessInfo(iSurface).DataIntThreshold;
                bst_setContext('DefaultSurfaceDisplay', DefaultSurfaceDisplay); 
            end
            
        case 'DataExtThreshold'
            % Threshold based on cluster size
            % I use a very gross exponential scale
            % Update value in Surface array            
            %TessInfo(iSurface).DataExtThreshold = round(exp(jSlider.getValue()/15))-1;
            TessInfo(iSurface).DataExtThreshold = round(jSlider.getValue())-1;
            ctrl.jLabelDataExtThresh.setText(sprintf('%d', TessInfo(iSurface).DataExtThreshold));
            % Update current surface
            setappdata(hFig, 'Surface', TessInfo);
            % Update color display on the surface
            figure_callback(hFig, 'UpdateSurfaceColor', hFig, iSurface);
            % Set the new value as the default value (NOT FOR MRI)
            if ~isAnatomy
                DefaultSurfaceDisplay = bst_getContext('DefaultSurfaceDisplay');
                DefaultSurfaceDisplay.DataExtThreshold = TessInfo(iSurface).DataExtThreshold;
                bst_setContext('DefaultSurfaceDisplay', DefaultSurfaceDisplay); 
            end
            
        case {'ResectX', 'ResectY', 'ResectZ'}
            % Get target axis
            dim = find(strcmpi(target, {'ResectX', 'ResectY', 'ResectZ'}));
            % JSliderResect values : [-100,100]
            if isAnatomy
                % Get MRI size
                sMri = bst_dataSetsManager('GetMri', TessInfo(iSurface).SurfaceFile);
                cubeSize = size(sMri.Cube);
                % Change slice position
                newPos = round((jSlider.getValue()+100) / 200 * cubeSize(dim));
                newPos = saturate(newPos, [1, cubeSize(dim)]);
                TessInfo(iSurface).CutsPosition(dim) = newPos;
                % Update MRI display
                figure_callback(hFig, 'UpdateMriDisplay', hFig, dim, TessInfo, iSurface);
            else
                ResectSurface(hFig, iSurface, dim, jSlider.getValue() / 100);
            end

        otherwise
            error('Unknow slider');
    end
end



%% ===== BUTTON SURFACE COLOR CALLBACK =====
function ButtonSurfColorCallback(hObject, event)
    % Get handle to current 3DViz figure
    hFig = gui_figuresManager('GetCurrentFigure', '3D');
    if isempty(hFig)
        return
    end
    % Get figure AppData (figure's surfaces configuration)
    TessInfo = getappdata(hFig, 'Surface');
    % Get current surface index (in the current figure)
    iSurface = getappdata(hFig, 'iSurface');
    % Ignore MRI slices
    if strcmpi(TessInfo(iSurface).Name, 'Anatomy')
        return
    end
    % Ask user to select a color
    newColor2 = uisetcolor(TessInfo(iSurface).AnatomyColor(2,:), 'Select surface color');
    if (length(newColor2) ~= 3)
        return
    end
    % Change surface color
    SetSurfaceColor(hFig, iSurface, newColor2);
end
             


%% ===== BUTTON SURFACE "SHOW CURVATURE" CALLBACK =====
function ButtonShowCurvatureCallback(hObject, event)
    % Get handle to current 3DViz figure
    hFig = gui_figuresManager('GetCurrentFigure', '3D');
    if isempty(hFig)
        return
    end
    % Get current surface index (in the current figure)
    iSurface = getappdata(hFig, 'iSurface');
    % Get handle to "View" button
    jButtonSurfCurvature = event.getSource();
    % Show/hide curvature in figure display
    SetShowCurvature(hFig, iSurface, jButtonSurfCurvature.isSelected());
    % Set the new value as the default value
    DefaultSurfaceDisplay = bst_getContext('DefaultSurfaceDisplay');
    DefaultSurfaceDisplay.SurfShowCurvature = jButtonSurfCurvature.isSelected();
    bst_setContext('DefaultSurfaceDisplay', DefaultSurfaceDisplay);
end

%% ===== SET SHOW CURVATURE =====
% Usage : SetShowCurvature(hFig, iSurfaces, status)
% Parameters : 
%     - hFig : handle to a 3DViz figure
%     - iSurfaces : can be a single indice or an array of indices
%     - status    : 1=display, 0=hide
function SetShowCurvature(hFig, iSurfaces, status)
    % Get surfaces list 
    TessInfo = getappdata(hFig, 'Surface');
    gui_makeuswait('start')
    % Process all surfaces
    for iSurf = iSurfaces
        % Shet status : show/hide
        TessInfo(iSurf).SurfShowCurvature = status;
    end
    % Update figure's AppData (surfaces configuration)
    setappdata(hFig, 'Surface', TessInfo);
    % Update surface display
    figure_callback(hFig, 'UpdateSurfaceColor', hFig, iSurf);
    gui_makeuswait('stop');
end


%% ===== SHOW SURFACE EDGES =====
function ButtonShowEdgesCallback(varargin)
    % Get handle to current 3DViz figure
    hFig = gui_figuresManager('GetCurrentFigure', '3D');
    if isempty(hFig)
        return
    end
    % Get current surface (in the current figure)
    TessInfo = getappdata(hFig, 'Surface');
    iSurf    = getappdata(hFig, 'iSurface');
    % Set edges display on/off
    TessInfo(iSurf).SurfShowEdges = ~TessInfo(iSurf).SurfShowEdges;
    setappdata(hFig, 'Surface', TessInfo);
    % Update display
    figure_callback(hFig, 'UpdateSurfaceColor', hFig, iSurf);
end


%% ===== HEMISPHERE SELECTION RADIO CALLBACKS =====
function SelectHemispheres(name)
    % Get handle to current 3DViz figure
    hFig = gui_figuresManager('GetCurrentFigure', '3D');
    if isempty(hFig)
        return
    end
    % Get surface properties
    TessInfo = getappdata(hFig, 'Surface');
    iSurf    = getappdata(hFig, 'iSurface');
    % Ignore MRI
    if strcmpi(TessInfo(iSurf).Name, 'Anatomy')
        return;
    end
    % Update surface Resect field
    TessInfo(iSurf).Resect = name;
    setappdata(hFig, 'Surface', TessInfo);
    
    % Reset all the resect sliders
    ctrl = bst_getContext('PanelControls', 'Surface');
    ctrl.jSliderResectX.setValue(0);
    ctrl.jSliderResectY.setValue(0);
    ctrl.jSliderResectZ.setValue(0);
    
    % Display progress bar
    bst_progressBar('start', 'Select hemisphere', 'Selecting hemisphere...');
    % Update surface display
    figure_callback(hFig, 'UpdateSurfaceAlpha', hFig, iSurf);
    % Display progress bar
    bst_progressBar('stop');
end


%% ===== RESECT SURFACE =====
function ResectSurface(hFig, iSurf, resectDim, resectValue)
    % Get surfaces description
    TessInfo = getappdata(hFig, 'Surface');
    % If previously using "Select hemispheres"
    if ischar(TessInfo(iSurf).Resect)
        % Reset "Resect" field
        TessInfo(iSurf).Resect = [0 0 0];
    end
    % Update value in Surface array
    TessInfo(iSurf).Resect(resectDim) = resectValue;
    % Update surface
    setappdata(hFig, 'Surface', TessInfo);
    % Hide trimmed part of the surface
    figure_callback(hFig, 'UpdateSurfaceAlpha', hFig, iSurf);
    
    % Deselect both Left and Right buttons
    ctrl = bst_getContext('PanelControls', 'Surface');
    ctrl.jToggleResectLeft.setSelected(0);
    ctrl.jToggleResectRight.setSelected(0);
end


%% ===== ADD SURFACE CALLBACK =====
function ButtonAddSurfaceCallback(varargin)
    % Get target figure handle
    hFig = gui_figuresManager('GetCurrentFigure', '3D');
    if isempty(hFig)
        return
    end
    % Get Current subject
    SubjectFile = getappdata(hFig, 'SubjectFile');
    if isempty(SubjectFile)
        return
    end
    sSubject = bst_getContext('Subject', SubjectFile);
    if isempty(sSubject)
        return
    end

    % List of available surfaces types
    typesList = {};
    if ~isempty(sSubject.iScalp)
        typesList{end+1} = 'Scalp';
    end
    if ~isempty(sSubject.iOuterSkull)
        typesList{end+1} = 'OuterSkull';
    end
    if ~isempty(sSubject.iInnerSkull)
        typesList{end+1} = 'InnerSkull';
    end
    if ~isempty(sSubject.iCortex)
        typesList{end+1} = 'Cortex';
    end
    if ~isempty(sSubject.iAnatomy)
        typesList{end+1} = 'Anatomy';
    end
    if isempty(typesList)
        return
    end
    % Ask user which kind of surface he wants to add to the figure 3DViz
    surfaceType = java_dialog('question', 'What kind of surface would you like to display ?', 'Add surface', [], typesList, typesList{1});

    % Switch between surfaces types
    switch (surfaceType)
        case 'Anatomy'
            SurfaceFile = sSubject.Anatomy(sSubject.iAnatomy(1)).FileName;
        case 'Cortex'
            SurfaceFile = sSubject.Surface(sSubject.iCortex(1)).FileName;
        case 'Scalp'
            SurfaceFile = sSubject.Surface(sSubject.iScalp(1)).FileName;
        case 'InnerSkull'
            SurfaceFile = sSubject.Surface(sSubject.iInnerSkull(1)).FileName;
        case 'OuterSkull'
            SurfaceFile = sSubject.Surface(sSubject.iSurfaceFile(1)).FileName;
        otherwise
            return;
    end
    % Add surface to the figure
    AddSurface(hFig, SurfaceFile); 
    % 3D MRI: Update Colormap
    if strcmpi(surfaceType, 'Anatomy')
        % Get figure
        [hFig,iFig,iDS] = gui_figuresManager('GetFigure', hFig);
        % Update colormap
        gui_figure3DViz('ColormapChangedCallback', iDS, iFig);
    end
end


%% ===== REMOVE SURFACE CALLBACK =====
function ButtonRemoveSurfaceCallback(varargin)
    % Get target figure handle
    hFig = gui_figuresManager('GetCurrentFigure', '3D');
    if isempty(hFig)
        return
    end
    % Get current surface index
    iSurface = getappdata(hFig, 'iSurface');
    if isempty(iSurface)
        return
    end
    % Remove surface
    RemoveSurface(hFig, iSurface);
    % Update "Surfaces" panel
    UpdatePanel();
end


%% ===== SURFACE BUTTON CLICKED CALLBACK =====
function ButtonSurfaceClickedCallback(hObject, event, varargin)
    % Get current 3DViz figure
    hFig = gui_figuresManager('GetCurrentFigure', '3D');
    if isempty(hFig)
        return
    end
    % Get index of the surface associated to this button
    iSurface = str2num(event.getSource.getName());
    % Store current surface index 
    setappdata(hFig, 'iSurface', iSurface);
    % Update scouts surface
    panel_scouts('UpdateCurrentSurface');
    % Update surface properties
    UpdateSurfaceProperties();
end



%% =================================================================================
%  === EXTERNAL CALLBACKS  =========================================================
%  =================================================================================
%% ===== UPDATE PANEL =====
function UpdatePanel(varargin)
    % Get JComboBox pointer
    panelSurfacesCtrl = bst_getContext('PanelControls', 'Surface');
    if isempty(panelSurfacesCtrl)
        return
    end
    % If no current 3D figure defined
    hFig = gui_figuresManager('GetCurrentFigure', '3D');
    if isempty(hFig)
        % Remove surface buttons
        CreateSurfaceList(panelSurfacesCtrl.jToolbarSurfaces, 0);
        % Disable all panel controls
        gui_setEnabledControls([panelSurfacesCtrl.jToolbarSurfaces, panelSurfacesCtrl.jPanelOptions], 0); 
    else
        % Enable Surfaces selection panel
        gui_setEnabledControls(panelSurfacesCtrl.jToolbarSurfaces, 1);
        % Update surfaces list
        nbSurfaces = CreateSurfaceList(panelSurfacesCtrl.jToolbarSurfaces, hFig);
        % If no surface is available
        if (nbSurfaces <= 0)
            % Disable "Display" and "Options" panel
            gui_setEnabledControls(panelSurfacesCtrl.jPanelOptions, 0);
            % Else : one or more surfaces are available
        else
            % Enable "Display" and "Options" panel
            gui_setEnabledControls(panelSurfacesCtrl.jPanelOptions, 1);
            % Update surface properties
            UpdateSurfaceProperties();
        end
    end
end


%% ===== DISPATCH FIGURE CALLBACKS =====
function figure_callback(hFig, CallbackName, varargin)
    % Get figure type
    FigureId = getappdata(hFig, 'FigureId');
    % Different figure types
    switch (FigureId.Type)
        case 'MriViewer'
            gui_figureMriViewer(CallbackName, varargin{:});
        case '3DViz'
            gui_figure3DViz(CallbackName, varargin{:});
    end
end


%% ===== CURRENT FIGURE CHANGED =====
function CurrentFigureChanged_Callback() %#ok<DEFNU>
    UpdatePanel();
end


%% ===== CREATE SURFACES LIST =====
function nbSurfaces = CreateSurfaceList(jToolbarSurfaces, hFig)
    % Java initializations
    import java.awt.*;
    import javax.swing.*;
    import org.brainstorm.icon.IconLoader;

    nbSurfaces = 0;
    % Remove all toolbar surface buttons
    for iComp = 1:jToolbarSurfaces.getComponentCount()-5
        jToolbarSurfaces.remove(1);
    end
    % If no figure is specified : return
    if isempty(hFig) || ~ishandle(hFig) || (hFig == 0)
        return;
    end
    % Create a button group for Surfaces and "Add" button
    jButtonGroup = ButtonGroup();
    
    % If a figure is defined 
    if ishandle(hFig)
        % Get selected surface index
        iSurface = getappdata(hFig, 'iSurface');
        % Loop on all the available surfaces for this figure
        TessInfo = getappdata(hFig, 'Surface');
        for iSurf = 1:length(TessInfo)
            % Select only one button
            isSelected = (iSurf == iSurface);
            % Get button icon (depends on surface name)
            switch lower(TessInfo(iSurf).Name)
                case 'cortex'
                    iconButton = IconLoader.ICON_SURFACE_CORTEX;
                case 'scalp'
                    iconButton = IconLoader.ICON_SURFACE_SCALP;
                case 'innerskull'
                    iconButton = IconLoader.ICON_SURFACE_INNERSKULL;
                case 'outerskull'
                    iconButton = IconLoader.ICON_SURFACE_OUTERSKULL;
                case 'other'
                    iconButton = IconLoader.ICON_SURFACE;
                case 'anatomy'
                    iconButton = IconLoader.ICON_ANATOMY;
            end
            % Create surface button 
            jButtonSurf = JToggleButton(iconButton, isSelected);
            jButtonSurf.setMaximumSize(Dimension(24,24));
            jButtonSurf.setPreferredSize(Dimension(24,24));
            % Store the surface index as the button Name
            jButtonSurf.setName(sprintf('%d', iSurf));
            % Attach a click callback
            set(jButtonSurf, 'ActionPerformedCallback', @ButtonSurfaceClickedCallback);
            % Add button to button group
            jButtonGroup.add(jButtonSurf);
            % Add button to toolbar, at the end of the surfaces list
            iButton = jToolbarSurfaces.getComponentCount() - 4;
            jToolbarSurfaces.add(jButtonSurf, iButton);
        end
        % Return number of surfaces added
        nbSurfaces = length(TessInfo);
    else
        % No surface available for current figure
        nbSurfaces = 0;
    end
   
    % Update graphical composition of panel
    jToolbarSurfaces.updateUI();
end


%% ===== UPDATE SURFACE PROPERTIES =====
function UpdateSurfaceProperties()
% disp('=== panel_surface > UpdateSurfaceProperties ===');
    import org.brainstorm.list.BstListItem;
    % Get current figure handle
    hFig = gui_figuresManager('GetCurrentFigure', '3D');
    if isempty(hFig)
        return
    end
    % Get panel controls
    panelControls = bst_getContext('PanelControls', 'Surface');
    if isempty(panelControls)
        return
    end
    % Get selected surface properties
    TessInfo = getappdata(hFig, 'Surface');
    if isempty(TessInfo)
        return;
    end
    % Get selected surface index
    iSurface = getappdata(hFig, 'iSurface');
    % If surface is sliced MRI
    isAnatomy = strcmpi(TessInfo(iSurface).Name, 'Anatomy');

    % ==== Surface properties ====
    % Number of vertices
    panelControls.jLabelNbVertices.setText(sprintf('%d', TessInfo(iSurface).nVertices));
    % Number of faces
    panelControls.jLabelNbFaces.setText(sprintf('%d', TessInfo(iSurface).nFaces));
    % Surface alpha
    panelControls.jSliderSurfAlpha.setValue(100 * TessInfo(iSurface).SurfAlpha);
    panelControls.jLabelSurfAlpha.setText(sprintf('%d%%', round(100 * TessInfo(iSurface).SurfAlpha)));
    % Surface color
    surfColor = TessInfo(iSurface).AnatomyColor(2, :);
    panelControls.jButtonSurfColor.setBackground(java.awt.Color(surfColor(1),surfColor(2),surfColor(3)));
    % Surface smoothing ALPHA
    panelControls.jSliderSurfSmoothValue.setValue(100 * TessInfo(iSurface).SurfSmoothValue);
    panelControls.jLabelSurfSmoothValue.setText(sprintf('%d%%', round(100 * TessInfo(iSurface).SurfSmoothValue)));
    % Correspondance : [-0.80, 0.80] <=> [-80,80]
    panelControls.jSliderSurfCurvature.setValue(round(100 * TessInfo(iSurface).SurfCurvatureThreshold));
    panelControls.jLabelSurfCurvature.setText(sprintf('%d%%', round(100 * TessInfo(iSurface).SurfCurvatureThreshold)));
    % Show surface curvature button
    panelControls.jButtonSurfCurvature.setSelected(TessInfo(iSurface).SurfShowCurvature);
    % Show surface edges button
    panelControls.jButtonSurfEdge.setSelected(TessInfo(iSurface).SurfShowEdges);
    
    % ==== Resect properties ====
    % Ignore for MRI slices
    if isAnatomy
        sMri = bst_dataSetsManager('GetMri', TessInfo(iSurface).SurfaceFile);
        ResectXYZ = double(TessInfo(iSurface).CutsPosition) ./ size(sMri.Cube) * 200 - 100;
        radioSelected = 'none';
    elseif ischar(TessInfo(iSurface).Resect)
        ResectXYZ = [0,0,0];
        radioSelected = TessInfo(iSurface).Resect;
    else
        ResectXYZ = 100 * TessInfo(iSurface).Resect;
        radioSelected = 'none';
    end
    % X, Y, Z
    panelControls.jSliderResectX.setValue(ResectXYZ(1));
    panelControls.jSliderResectY.setValue(ResectXYZ(2));
    panelControls.jSliderResectZ.setValue(ResectXYZ(3));
    
    % Select one radio button
    switch (radioSelected)
        case 'left'
            panelControls.jToggleResectLeft.setSelected(1);
            panelControls.jToggleResectRight.setSelected(0);
        case 'right'
            panelControls.jToggleResectRight.setSelected(1);
            panelControls.jToggleResectLeft.setSelected(0);
        case 'none'
            panelControls.jToggleResectLeft.setSelected(0);
            panelControls.jToggleResectRight.setSelected(0);
    end
    
    % ==== Data properties ====
    % Data alpha
    panelControls.jSliderDataAlpha.setValue(100 * TessInfo(iSurface).DataAlpha);
    panelControls.jLabelDataAlpha.setText(sprintf('%d%%', round(100 * TessInfo(iSurface).DataAlpha)));
    % Data intensity threshold
    panelControls.jSliderDataIntThresh.setValue(100 * TessInfo(iSurface).DataIntThreshold);
    panelControls.jLabelDataIntThresh.setText(sprintf('%d%%', round(100 * TessInfo(iSurface).DataIntThreshold)));
    % Cluster extent threshold
    panelControls.jSliderDataExtThresh.setValue(TessInfo(iSurface).DataExtThreshold);
    panelControls.jLabelDataExtThresh.setText(sprintf('%d', TessInfo(iSurface).DataExtThreshold));
    
end


%% ===== ADD A SURFACE =====
% Add a surface to a given 3DViz figure
% USAGE : iTess = panel_surface('AddSurface', hFig, surfaceFile)
% OUTPUT: Indice of the surface in the figure's surface array
function iTess = AddSurface(hFig, surfaceFile)
    % ===== CHECK EXISTENCE =====
    % Check whether filename is an absolute or relative path
    if exist(surfaceFile, 'file')
        ProtocolInfo = bst_getContext('ProtocolInfo');
        surfaceFile  = strrep(surfaceFile, ProtocolInfo.SUBJECTS, '');
    end
    % Get figure appdata (surfaces configuration)
    TessInfo = getappdata(hFig, 'Surface');
    % Check that this surface is not already displayed in 3DViz figure
    iTess = find(io_compareFileNames({TessInfo.SurfaceFile}, surfaceFile));
    if ~isempty(iTess)
        warning('Brainstorm:SurfaceAlreadyDisplayed', 'This surface is already displayed. Ignoring...');
        return
    end
    % Get figure type
    FigureId = getappdata(hFig, 'FigureId');
    % Progress bar
    isNewProgressBar = ~bst_progressBar('isVisible');
    bst_progressBar('start', 'Add surface', 'Updating display...');
    
    % ===== BUILD STRUCTURE =====
    % Add a new surface at the end of the figure's surfaces list
    iTess = length(TessInfo) + 1;
    TessInfo(iTess) = db_getDataTemplate('TessInfo');                       
    % Set the surface properties
    TessInfo(iTess).SurfaceFile = surfaceFile;
    TessInfo(iTess).DataSource.Type     = '';
    TessInfo(iTess).DataSource.FileName = '';

    % ===== PLOT OBJECT =====
    % Get file type (tessalation or MRI)
    [fileFormat, fileType] = io_getFileType(surfaceFile);
    % === TESSELATION ===
    if ismember('tess', fileType)
        % === LOAD SURFACE ===
        % Load surface file
        sSurface = bst_dataSetsManager('LoadSurface', surfaceFile);
        % Get some properties
        TessInfo(iTess).Name      = sSurface.Name;
        TessInfo(iTess).nVertices = size(sSurface.Vertices, 1);
        TessInfo(iTess).nFaces    = size(sSurface.Faces, 1);

        % === PLOT SURFACE ===
        switch (FigureId.Type)
            case 'MriViewer'
                % Nothing to do: surface will be displayed as an overlay slice in gui_figureMriViewer.m
            case {'3DViz', 'Topography'}
                % Create and display surface patch
                [hFig, TessInfo(iTess).hPatch] = gui_figure3DViz('PlotSurface', hFig, ...
                                         sSurface.Faces, ...
                                         sSurface.Vertices, ...
                                         TessInfo(iTess).AnatomyColor(2,:), ...
                                         TessInfo(iTess).SurfAlpha);
        end
        % Update figure's surfaces list and current surface pointer
        setappdata(hFig, 'Surface',  TessInfo);
        setappdata(hFig, 'iSurface', iTess);
        % Show curvature if needed 
        if TessInfo(iTess).SurfShowCurvature
            SetShowCurvature(hFig, iTess, 1);
        end
        
    % === MRI ===
    elseif ismember('subjectimage', fileType)
        % === LOAD MRI ===
        sMri = bst_dataSetsManager('LoadMri', surfaceFile);
        TessInfo(iTess).Name = 'Anatomy';
        % Initial position of the cuts : middle in each direction
        TessInfo(iTess).CutsPosition = round(size(sMri.Cube) / 2);
        TessInfo(iTess).SurfSmoothValue = .3;
        % Update figure's surfaces list and current surface pointer
        setappdata(hFig, 'Surface',  TessInfo);
        setappdata(hFig, 'iSurface', iTess);

        % === PLOT MRI ===
        switch (FigureId.Type)
            case 'MriViewer'
                % Configure MRIViewer
                gui_figureMriViewer('SetupMri', hFig);
            case '3DViz'
                % Camera basic orientation: TOP
                gui_figure3DViz('SetStandardView', hFig, 'top');
        end
        % Plot MRI
        PlotMri(hFig);
    end
    % Automatically set transparencies (to view different layers at the same time)
    SetAutoTransparency(hFig);
    drawnow;
    % Close progress bar
    if isNewProgressBar
        bst_progressBar('stop');
    end
    % Update panel
    UpdatePanel();
end
   


%% ===== SET DATA SOURCE FOR A SURFACE =====
%Associate a data/results matrix to a surface.
% Usage : SetSurfaceData(hFig, iTess, dataType, dataFile, isStat, isZscore)
% Parameters : 
%     - hFig : handle to a 3DViz figure
%     - iTess     : indice of the surface to update (in hFig appdata)
%     - dataType  : type of data to overlay on the surface {'Source', 'Data', ...}
%     - dataFile  : filename of the data to display over the surface
%     - isStat    : 1, if results is a statistical result; 0, else
%     - isZscore  : 1, if results is a result of z-score normalization; 0, else
function isOk = SetSurfaceData(hFig, iTess, dataType, dataFile, isStat, isZscore) %#ok<DEFNU>
    % Get figure index in DataSet figures list
    [tmp__, iFig, iDS] = gui_figuresManager('GetFigure', hFig);
    if isempty(iDS)
        error('No DataSet acessible for this 3D figure');
    end
    % Get surfaces list for this figure
    TessInfo = getappdata(hFig, 'Surface');
    
    % === GET DATA THRESHOLD ===
    % Cortex
    if strcmpi(TessInfo(iTess).Name, 'Cortex')
        % Get defaults for surface display
        DefaultSurfaceDisplay = bst_getContext('DefaultSurfaceDisplay');
        % Data threshold
        try
            dataIntThreshold = DefaultSurfaceDisplay.DataIntThreshold;
        catch
            DefaultSurfaceDisplay
            dataIntThreshold = 1;
        end
        try
        dataExtThreshold = DefaultSurfaceDisplay.DataExtThreshold;
          catch
            DefaultSurfaceDisplay
            dataExtThreshold = 0;
        end
    % Anatomy or Statistics : 0%
    elseif strcmpi(TessInfo(iTess).Name, 'Anatomy') || isStat
        dataIntThreshold = 0;
        dataExtThreshold = 0;
    % Else: normal data on scalp
    else
        dataIntThreshold = 0.5;
        dataExtThreshold = 0;
    end
    
    % === PREPARE SURFACE ===
    TessInfo(iTess).DataSource.Type     = dataType;
    TessInfo(iTess).DataSource.FileName = dataFile;
    TessInfo(iTess).DataSource.isStat   = isStat;
    TessInfo(iTess).DataSource.isZscore = isZscore;
    TessInfo(iTess).DataIntThreshold       = dataIntThreshold;
    TessInfo(iTess).DataExtThreshold       = dataExtThreshold;
    % Type of data displayed on the surface: sources/recordings/nothing
    switch (dataType)
        case 'Data'
            setappdata(hFig, 'DataFile', dataFile);
        case 'Source'
            setappdata(hFig, 'ResultsFile', dataFile);
        case 'Surface'
            % Nothing to do...
        otherwise
            TessInfo(iTess).Data = [];
            TessInfo(iTess).DataWmat = [];
    end
    % Update figure appdata
    setappdata(hFig, 'Surface', TessInfo); 
    % Plot surface
    isOk = UpdateSurfaceData(hFig, iTess);
    % Update  panel
    UpdatePanel();
end



%% ===== UPDATE SURFACE DATA =====
% Update the 'Data' field for given surfaces :
%    - Load data/results matrix (F, ImageGridAmp, ...) if it is not loaded yet
%    - Store global minimum/maximum of data
%    - Interpolate data matrix over the target surface (interp_mail) if number of vertices does not match
%    - And update color display (ColormapChangedCallback)
%
% Usage:  UpdateSurfaceData(hFig, iSurfaces)
%         UpdateSurfaceData(hFig)
function isOk = UpdateSurfaceData(hFig, iSurfaces)
% disp('=== panel_surface > UpdateSurfaceData ===');
    global GlobalData;
    isOk = 1;
    % Get surfaces list 
    TessInfo = getappdata(hFig, 'Surface');
    % If the aim is to update all the surfaces 
    if (nargin < 2) || isempty(iSurfaces)
        iSurfaces = 1:length(TessInfo);
    end
        
    % Get figure index (in DataSet structure)
    [tmp__, iFig, iDS] = gui_figuresManager('GetFigure', hFig);
    % Find the DataSet indice that corresponds to the current figure
    if isempty(iDS)
        error('No DataSet acessible for this 3D figure');
    end
    
    % For each surface
    for iTess = iSurfaces
        % If surface patch object doesn't exist => error
        if isempty(TessInfo(iTess).hPatch)
            error('Patch is not displayed');
        end
        
        % ===== GET SURFACE DATA =====
        % Switch between different data types to display on the surface
        switch (TessInfo(iTess).DataSource.Type)
            case 'Data'
                % Get TimeVector and current time indice
                [TimeVector, CurrentTimeIndex] = bst_dataSetsManager('GetTimeVector', iDS);
                % If 'F' matrix is not loaded for this file
                if isempty(GlobalData.DataSet(iDS).Measures.F)
                    % Load recording matrix
                    bst_dataSetsManager('LoadRecordingsMatrix', iDS);
                end
                
                % If surface is displayed : update it
                if ~isempty(TessInfo(iTess).hPatch) && ishandle(TessInfo(iTess).hPatch)
                    % Get vertices of surface
                    Vertices = get(TessInfo(iTess).hPatch, 'Vertices');
                    % Warn user if tessellation is huge
                    if size(Vertices,1) > 20000
                        if ~java_dialog('confirm', {sprintf('Tessellation has %d vertices; computation time for rendering might be excessive.',size(Vertices,1)),'Do you still want to proceed ?'},'Long computation expected')
                            % Stop computation
                            isOk = 0;
                            return
                        end
                    end

                    % Get selected channels indices and location
                    [SelectedChannels, PChanLocs] = gui_figure3DViz('GetSelectedChannels', iDS, iFig);
%                     % Get Selected channels
%                     SelectedChannels = good_channel(GlobalData.DataSet(iDS).Channel, ...
%                                            GlobalData.DataSet(iDS).Measures.ChannelFlag, ...
%                                            GlobalData.DataSet(iDS).Figure(iFig).Id.Modality);
                                       
                    % Interpolate data on scalp surface (only if Matrix is not computed yet, or channels changed)
                    % => TRICK : it is difficult to test if the sensors locations or the surface vertices changed
                    %            => Just the the number of channels and vertices (should be ok...)
                    if isempty(TessInfo(iTess).DataWmat) || ...
                            (size(TessInfo(iTess).DataWmat,2) ~= length(SelectedChannels)) || ...
                            (size(TessInfo(iTess).DataWmat,1) ~= length(Vertices))
                        interType = [GlobalData.DataSet(iDS).Figure(iFig).Id.Modality, 'ToScalp'];
                        TessInfo(iTess).DataWmat = interp_mail(Vertices, PChanLocs, interType);
                    end
                    % Set data for current time frame
                    TessInfo(iTess).Data = single(TessInfo(iTess).DataWmat * ...
                                                  double(GlobalData.DataSet(iDS).Measures.F(SelectedChannels, CurrentTimeIndex)));
                    % Store minimum and maximum of displayed data
                    TessInfo(iTess).DataMinMax = [min(min(TessInfo(iTess).Data)), ...
                                                  max(max(TessInfo(iTess).Data))];
                end
                % Update "Static" status for this figure
                setappdata(hFig, 'isStatic', GlobalData.DataSet(iDS).Measures.isStatic);

            case 'Source'
                % === LOAD RESULTS VALUES ===
                % Get results index
                iResult = bst_dataSetsManager('GetResultInDataSet', iDS, TessInfo(iTess).DataSource.FileName);
                % If Results file is not found in GlobalData structure
                if isempty(iResult)
                    % Load Results file
                    [iDS, iResult] = bst_dataSetsManager('LoadResultsFile', ...
                                             TessInfo(iTess).DataSource.FileName, ...
                                             GlobalData.DataSet(iDS).DataFile, ...
                                             '', ...
                                             GlobalData.DataSet(iDS).StudyFile, ...
                                             GlobalData.DataSet(iDS).SubjectFile);
                    if isempty(iResult)
                        return
                    end
                end
                % If 'ImageGridAmp' matrix is not loaded for this file
                if isempty(GlobalData.DataSet(iDS).Results(iResult).ImageGridAmp) && ...
                   isempty(GlobalData.DataSet(iDS).Results(iResult).ImagingKernel)
                    % Load recording matrix
                    bst_dataSetsManager('LoadResultsMatrix', iDS, iResult);
                end
                
                % === GET CURRENT VALUES ===
                % Get results values
                TessInfo(iTess).Data = bst_dataSetsManager('GetResultsValues', iDS, iResult, [], 'CurrentTimeIndex');
                % If min/max values for this file were not computed yet
                if isempty(TessInfo(iTess).DataMinMax)
                    TessInfo(iTess).DataMinMax = bst_dataSetsManager('GetResultsMaximum', iDS, iResult);
                end
                % Reset Overlay cube
                TessInfo(iTess).OverlayCube = [];

                % Check the consistency between the number of results points (number of sources)
                % and the number of vertices of the target surface patch
                % IGNORE TEST FOR MRI
                if (length(TessInfo(iTess).Data) ~= TessInfo(iTess).nVertices) && ~strcmpi(TessInfo(iTess).Name, 'Anatomy')
                    bst_error(sprintf(['Number of sources (%d) is smaller than number of vertices (%d).\n\n' ...
                              'Please compute the sources again.'], size(TessInfo(iTess).Data, 1), TessInfo(iTess).nVertices), 'Data mismatch', 0);
                    isOk = 0;
                    return;
                end
                % Update "Static" status for this figure
                setappdata(hFig, 'isStatic', GlobalData.DataSet(iDS).Results(iResult).isStatic);

            case 'Surface'
                % Get loaded surface
                SurfaceFile = TessInfo(iTess).DataSource.FileName;
                sSurf = bst_dataSetsManager('LoadSurface', SurfaceFile);
                % Build uniform data vector
                TessInfo(iTess).Data = ones(length(sSurf.Vertices),1);
                TessInfo(iTess).DataMinMax = [1 1];
                setappdata(hFig, 'isStatic', 1);
                
            otherwise
                % Nothing to do
        end
        % Error if all data values are null
        if (max(abs(TessInfo(iTess).DataMinMax)) == 0)
%             bst_error('All values are null. Please check your input file.', 'Surface error');
            warning('All values are null. Please check your input file.');
        end
    end
    % Update surface definition
    setappdata(hFig, 'Surface', TessInfo);
    % Update colormap
    UpdateSurfaceColormap(hFig, iSurfaces);
end



%% ===== UPDATE SURFACE COLORMAP =====
function UpdateSurfaceColormap(hFig, iSurfaces)
% disp('=== panel_surface > UpdateSurfaceColormap ===');
    global GlobalData;
    % Get surfaces list 
    TessInfo = getappdata(hFig, 'Surface');
    if isempty(TessInfo)
        return
    end
    % If the aim is to update all the surfaces 
    if (nargin < 2) || isempty(iSurfaces)
        iSurfaces = 1:length(TessInfo);
    end
    
    % Get default colormap to use for this figure
    [listTypes, defaultColormapType] = gui_figuresManager('GetDisplayedDataTypes', hFig);
    % Get figure axes
    hAxes = [findobj(hFig, 'Tag', 'Axes3D'), findobj(hFig, 'Tag', 'axc'), findobj(hFig, 'Tag', 'axa'), findobj(hFig, 'Tag', 'axs')];
    hasData = 0;
    hasSource = 0;
    
    % Get figure index (in DataSet structure)
    [tmp__, iFig, iDS] = gui_figuresManager('GetFigure', hFig);
    % Find the DataSet indice that corresponds to the current figure
    if isempty(iDS)
        error('No DataSet acessible for this 3D figure');
    end
    
    % For each surface
    for iTess = iSurfaces
        % ===== COLORMAPPING =====
        % Get recordings and source colormap
        if isempty(TessInfo(iTess).DataSource.Type) || strcmpi(TessInfo(iTess).DataSource.Type, 'Surface')
            sColormap = bst_colormaps('GetColormap', 'Anatomy');
        elseif TessInfo(iTess).DataSource.isStat || TessInfo(iTess).DataSource.isZscore
            sColormap = bst_colormaps('GetColormap', 'Stat');
        else
            sColormap = bst_colormaps('GetColormap', TessInfo(iTess).DataSource.Type);
        end
        % === Colormap : Normalized or Absolute ?
        % Normalized : Color bounds (CLim) are set to a local extrema (at this time frame)
        if sColormap.isNormalized
            absMaxVal = max(abs(TessInfo(iTess).Data(:)));
        % Fixed : Color bounds are fixed, defined statically by the user (sColormap.MaxValue)
        elseif ~isempty(sColormap.MaxValue)
            absMaxVal = sColormap.MaxValue;
        % Absolute : Color bounds (CLim) are set to the global extrema (over all the time frames)
        else
            absMaxVal = max(abs(TessInfo(iTess).DataMinMax));
        end
            
        % === Data values : Absolute | Normal ? ===
        if sColormap.isAbsoluteValues
            % Display absolute values of data
            TessInfo(iTess).Data = abs(TessInfo(iTess).Data);
            TessInfo(iTess).DataLimitValue = [0, absMaxVal];
        else
            % Display normal data (positive and negative values)
            TessInfo(iTess).DataLimitValue = [-absMaxVal, absMaxVal];
        end
        % If current colormap is the default colormap for this figure (for colorbar)
        if (strcmpi(defaultColormapType, 'Stat') && (TessInfo(iTess).DataSource.isStat || TessInfo(iTess).DataSource.isZscore)) || ...
                strcmpi(defaultColormapType, TessInfo(iTess).DataSource.Type)
            if all(~isnan(TessInfo(iTess).DataLimitValue)) && (TessInfo(iTess).DataLimitValue(1) < TessInfo(iTess).DataLimitValue(2))
                set(hAxes, 'CLim', TessInfo(iTess).DataLimitValue);
            else
                %warning('Brainstorm:AxesError', 'Error using set: Bad value for axes property: CLim: Values must be increasing and non-NaN.');
                set(hAxes, 'CLim', [0 1e-30]);
            end
        end
                            
        % ===== DISPLAY ON MRI =====
        if strcmpi(TessInfo(iTess).Name, 'Anatomy') && ~isempty(TessInfo(iTess).DataSource.Type) && ...
                (isempty(TessInfo(iTess).OverlayCube) )...|| ~strcmpi(TessInfo(iTess).DataSource.Type, 'Surface'))
            % Progress bar
            isProgressBar = bst_progressBar('isVisible');
            bst_progressBar('start', 'Display MRI', 'Updating values...');
            % ===== Update surface display =====  
            % Update figure's appdata (surface list)
            setappdata(hFig, 'Surface', TessInfo);
            % Update OverlayCube
            UpdateOverlayCube(hFig, iTess);
            % Hide progress bar
            if ~isProgressBar
                bst_progressBar('stop');
            end
            % Put focus back on previous figure
            curFig = gui_figuresManager('GetCurrentFigure', '3D');
            if ~isempty(curFig)
                figure(curFig);
            end
        else
            % Update figure's appdata (surface list)
            setappdata(hFig, 'Surface', TessInfo);
            % Update surface color
            figure_callback(hFig, 'UpdateSurfaceColor', hFig, iTess);
        end
        
        % ===== Colorbar ticks and labels =====
        if strcmpi(TessInfo(iTess).DataSource.Type, 'Data')
            hasData = 1;
        elseif strcmpi(TessInfo(iTess).DataSource.Type, 'Source')
            hasSource = 1;
        end
    end
    
    % ===== Colorbar ticks and labels =====
    % Set figure colormap
    set(hFig, 'Colormap', sColormap.CMap);
    % Create/Delete colorbar
    bst_colormaps('SetColorbarVisible', hFig, sColormap.DisplayColorbar);
    % Display only one colorbar (preferentially the results colorbar)
    if GlobalData.DataSet(iDS).isStat % || GlobalData.DataSet(iDS).isZscore (NOT FOR THE COLORMAP, ONLY FOR THE UNITS)
        bst_colormaps('ConfigureColorbar', hFig, 'stat');
    elseif hasSource
        bst_colormaps('ConfigureColorbar', hFig, 'Results');
    elseif hasData
        bst_colormaps('ConfigureColorbar', hFig, GlobalData.DataSet(iDS).Figure(iFig).Id.Modality);
    end
end

    
%% ===== GET SURFACE: ANATOMY =====
function [sMri,TessInfo,iTess,iMri] = GetSurfaceMri(hFig)
	% Get list of surfaces for the figure
    TessInfo = getappdata(hFig, 'Surface');
    % Find "Anatomy"
    iTess = find(strcmpi({TessInfo.Name}, 'Anatomy'));
    if isempty(iTess)
        sMri = [];
        return
    elseif (length(iTess) > 1)
        iTess = iTess(1);
    end
    % Get Mri filename
    MriFile = TessInfo(iTess).SurfaceFile;
    % Get loaded MRI
    [sMri,iMri] = bst_dataSetsManager('GetMri', MriFile);
end


%% ===== GET SURFACE: CORTEX =====
% Usage:  [iCortex, TessInfo, hFig] = GetSurfaceCortex()
%               [iCortex, TessInfo] = GetSurfaceCortex(hFig)
function [iCortex, TessInfo, hFig] = GetSurfaceCortex(hFig)
    % If target figure is not defined: use the current 3D figure
    if ((nargin < 1) || isempty(hFig))
        % Get current 3d figure
        hFig = gui_figuresManager('GetCurrentFigure', '3D');
        % No current 3D figure: error
        if isempty(hFig)
            iCortex = [];
            TessInfo = [];
            return
        end
    end
    % Get surfaces list
    TessInfo = getappdata(hFig, 'Surface');
    % Find 'Cortex' surfaces
    iCortex = find(strcmpi({TessInfo.Name}, 'Cortex'));
    % No cortex
    if isempty(iCortex)
        iCortex = [];
        return;
    % More than one
    elseif (length(iCortex) > 1)
        % Try to get the one that is selected in "surfaces" panel
        iSurf = getappdata(hFig, 'iSurface');
        % Selected surface does not help
        if isempty(iSurf) || ~ismember(iSurf, iCortex)
            % Use first cortex surface available
            iCortex = iCortex(1);
            return
        % Use selected surface
        else
            iCortex = iSurf;
        end
    end
end


%% ===== GET CORTEX OR ANATOMY SURFACE =====
% Usage:  [iSurf, TessInfo, hFig] = GetSurfaceCortexOrAnatomy()
%               [iSurf, TessInfo] = GetSurfaceCortexOrAnatomy(hFig)
function [iSurf, TessInfo, hFig] = GetSurfaceCortexOrAnatomy(hFig) %#ok<DEFNU>
    % If target figure is not defined: use the current 3D figure
    if ((nargin < 1) || isempty(hFig))
        % Get current 3d figure
        hFig = gui_figuresManager('GetCurrentFigure', '3D');
        % No current 3D figure: error
        if isempty(hFig)
            iSurf = [];
            TessInfo = [];
            return
        end
    end
    % Get surfaces
    iCortex = GetSurfaceCortex(hFig);
    [sMri, TessInfo, iAnatomy] = GetSurfaceMri(hFig);
    % Get target surface
    if ~isempty(iCortex)
        iSurf = iCortex;
    elseif ~isempty(iAnatomy)
        iSurf = iAnatomy;
    else
        iSurf = [];
    end
end


%% ===== REMOVE A SURFACE =====
function RemoveSurface(hFig, iSurface)
    % Get figure appdata (surfaces configuration)
    TessInfo = getappdata(hFig, 'Surface');
    if (iSurface < 0) || (iSurface > length(TessInfo))
        return;
    end
    % Remove associated patch
    iRemPatch = ishandle(TessInfo(iSurface).hPatch);
    delete(TessInfo(iSurface).hPatch(iRemPatch));

    % Remove surface from the figure's surfaces list
    TessInfo(iSurface) = [];
    % Update figure's surfaces list
    setappdata(hFig, 'Surface', TessInfo);
    % Set another figure as current figure
    if isempty(TessInfo)
        setappdata(hFig, 'iSurface', []);
    elseif (iSurface <= length(TessInfo))
        setappdata(hFig, 'iSurface', iSurface);
    else
        setappdata(hFig, 'iSurface', iSurface - 1);
    end
    
%     % Get figure description
%     [hFig, iFig, iDS] = gui_figuresManager('GetFigure', hFig);
%     % Update colormaps
%     figure_callback(hFig, 'ColormapChangedCallback', iDS, iFig);
end
       


%% ===== PLOT MRI =====
% Usage:  hs = panel_surface('PlotMri', hFig, posXYZ) : Set the position of cuts and plot MRI
%         hs = panel_surface('PlotMri', hFig)         : Plot MRI for current positions
function hs = PlotMri(hFig, posXYZ)
    global GlobalData;
    % Get MRI
    [sMri,TessInfo,iTess,iMri] = GetSurfaceMri(hFig);
    % Set positions or use default
    if (nargin < 2) || isempty(posXYZ)
        posXYZ = TessInfo(iTess).CutsPosition;
        iDimPlot = ~isnan(posXYZ);
    else
        iDimPlot = ~isnan(posXYZ);
        TessInfo(iTess).CutsPosition(iDimPlot) = posXYZ(iDimPlot);
    end
    % Get initial threshold value
    threshold = TessInfo(iTess).SurfSmoothValue * 2 * double(sMri.Histogram.bgLevel);
    % Get colormaps
    switch (TessInfo(iTess).DataSource.Type)
        case 'Source'
            if TessInfo(iTess).DataSource.isStat || TessInfo(iTess).DataSource.isZscore
                sColormapData = bst_colormaps('GetColormap', 'Stat');
            else 
                sColormapData = bst_colormaps('GetColormap', 'Source');
            end
        case 'Surface'
            sColormapData = bst_colormaps('GetColormap', 'Overlay');
        otherwise
            sColormapData = bst_colormaps('GetColormap', 'Source');
    end
    sColormapMri = bst_colormaps('GetColormap', 'Anatomy');
    % Define OPTIONS structure
    OPTIONS.sMri             = sMri;
    OPTIONS.iMri             = iMri;
    OPTIONS.cutsCoords       = posXYZ;                         % [x,y,z] location of the cuts in the volume
    OPTIONS.MriThreshold     = threshold;                      % MRI threshold (if value<threshold : background)
    OPTIONS.MriAlpha         = TessInfo(iTess).SurfAlpha;      % MRI alpha value (ie. opacity)
    OPTIONS.MriColormap      = sColormapMri.CMap;              % MRI Colormap     
    OPTIONS.OverlayCube      = TessInfo(iTess).OverlayCube;    % Overlay values
    OPTIONS.OverlayIntThreshold = TessInfo(iTess).DataIntThreshold;  % Overlay intensity threshold
    OPTIONS.OverlayExtThreshold = TessInfo(iTess).DataExtThreshold;  % Overlay extent threshold
    OPTIONS.OverlayAlpha     = TessInfo(iTess).DataAlpha;      % Overlay transparency
    OPTIONS.OverlayColormap  = sColormapData.CMap;             % Overlay colormap
    OPTIONS.OverlayBounds    = TessInfo(iTess).DataLimitValue; % Overlay colormap amplitude, [minValue,maxValue]
    OPTIONS.isMipAnatomy     = GlobalData.MIP.isMipAnatomy;
    OPTIONS.isMipFunctional  = GlobalData.MIP.isMipFunctional;
    OPTIONS.MipAnatomy       = TessInfo(iTess).MipAnatomy;
    OPTIONS.MipFunctional    = TessInfo(iTess).MipFunctional;
    % Plot cuts
    [hs, OutputOptions] = mri_drawCuts(hFig, OPTIONS);         
    TessInfo(iTess).hPatch(iDimPlot) = hs(iDimPlot);
    % Save maximum in each direction in TessInfo structure
    if OPTIONS.isMipAnatomy
        iUpdateSlice = ~cellfun(@isempty, OutputOptions.MipAnatomy);
        TessInfo(iTess).MipAnatomy(iUpdateSlice) = OutputOptions.MipAnatomy(iUpdateSlice);
    end
    if OPTIONS.isMipFunctional
        iUpdateSlice = ~cellfun(@isempty, OutputOptions.MipFunctional);
        TessInfo(iTess).MipFunctional(iUpdateSlice) = OutputOptions.MipFunctional(iUpdateSlice);
    end
    % Save TessInfo
    setappdata(hFig, 'Surface', TessInfo);
end


%% ===== UPDATE OVERLAY MASKS =====
function UpdateOverlayCubes(hFig) %#ok<DEFNU>
    for i = 1:length(hFig)
        [sMri, TessInfo, iTess] = GetSurfaceMri(hFig(i));
        if ~isempty(iTess) && ~isempty(TessInfo(iTess).Data)
            UpdateOverlayCube(hFig(i), iTess);
        end
    end
end


%% ===== UPDATE OVERLAY MASK =====
% Usage:  UpdateOverlayCube(hFig, iTess)
function UpdateOverlayCube(hFig, iTess)
% disp('=== panel_surface > UpdateOverlayCube ===');
    % Get MRI
    TessInfo = getappdata(hFig, 'Surface');
    sMri = bst_dataSetsManager('GetMri', TessInfo(iTess).SurfaceFile);
    if isempty(sMri) || isempty(sMri.Cube) || isempty(TessInfo(iTess).Data)
       return 
    end
    % Process depend on overlay data file
    switch (TessInfo(iTess).DataSource.Type)
       case 'Data'
           % Get scalp surface
           error('Not supported yet');
        case 'Source'
            % Get cortex surface
            sSubject = bst_getContext('MriFile', sMri.FileName);
            SurfaceFile = sSubject.Surface(sSubject.iCortex).FileName;
        case 'Surface'
            % Get surface specified in DataSource.FileName
            SurfaceFile = TessInfo(iTess).DataSource.FileName;
    end    
    % Get transformation MRI<->Surface
    [sSurf, iSurf] = bst_dataSetsManager('LoadSurface', SurfaceFile);
    tess2mri_interp = bst_dataSetsManager('GetTess2MriInterp', iSurf);
    % If no interpolation tess<->mri accessible : exit
    if isempty(tess2mri_interp)
       return 
    end
    % === GET SCOUTS ===
    % Get "Scouts" panel controls
    ctrl = bst_getContext('PanelControls', 'Scout');
    % View mode : VIEW SELECTED SCOUTS
    if ctrl.jRadioScoutViewSelected.isSelected()
        % Get selected scouts
        [sSelScouts, iSelScouts] = panel_scouts('GetSelectedScouts');
    % View mode : VIEW ALL SCOUTS
    elseif ctrl.jRadioScoutViewAll.isSelected()
        % Get all available scouts
        [sSelScouts, iSelScouts] = panel_scouts('GetScouts');
    end
    % Display only scouts that are related to this figure
    FigureId = getappdata(hFig, 'FigureId');
    switch (FigureId.Type)
        case 'MriViewer'
            % Take all the scouts
        case '3DViz'
            [sScoutsFig, iScoutsFig] = panel_scouts('GetScoutsWithFigure', hFig);
            iSelScouts = intersect(iSelScouts, iScoutsFig);
            sSelScouts = panel_scouts('GetScouts', iSelScouts);
    end
    % Progress bar
    isProgressBar = bst_progressBar('isVisible');
    bst_progressBar('start', 'Display MRI', 'Updating values...');

    % === UPDATE MASK ===
    mriSize = size(sMri.Cube);
    % If no selected scouts
    if isempty(sSelScouts) || ~ctrl.jCheckLimitMriSources.isSelected()
        % Build interpolated cube
        TessInfo(iTess).OverlayCube = tess_projectDataInMri(...
                                        tess2mri_interp, ...
                                        mriSize, ...
                                        TessInfo(iTess).Data);
    else
        % Get all the vertices concerned by the interpolation
        iVertices = [sSelScouts.Vertices];
        % Build interpolated cube
        TessInfo(iTess).OverlayCube = tess_projectDataInMri(...
                                        tess2mri_interp(:,iVertices), ...
                                        mriSize, ...
                                        TessInfo(iTess).Data(iVertices));
    end
    % Reset MIP functional fields
    TessInfo(iTess).MipFunctional = cell(3,1);
    % === UPDATE DISPLAY ===
    % Get surface description
    setappdata(hFig, 'Surface', TessInfo);
    % Redraw surface vertices color
    figure_callback(hFig, 'UpdateSurfaceColor', hFig, iTess);
    % Hide progress bar
    if ~isProgressBar
        bst_progressBar('stop');
    end
end


%% ===== SET SURFACE TRANSPARENCY =====
function SetSurfaceTransparency(hFig, iSurf, alpha)
    % Update surface transparency
    TessInfo = getappdata(hFig, 'Surface');
    TessInfo(iSurf).SurfAlpha = alpha;
    setappdata(hFig, 'Surface', TessInfo);
    % Update panel controls
    UpdateSurfaceProperties();
    % Update surface display
    figure_callback(hFig, 'UpdateSurfaceColor', hFig, iSurf);
    figure_callback(hFig, 'UpdateSurfaceAlpha', hFig, iSurf);
end



%% ===== SET THRESHOLD =====
function SetDataThreshold(hFig, iSurf, value)
    % Update surface transparency
    TessInfo = getappdata(hFig, 'Surface');
    TessInfo(iSurf).DataIntThreshold = value;
    setappdata(hFig, 'Surface', TessInfo);
    % Update panel controls
    UpdateSurfaceProperties();
    % Update color display on the surface
    figure_callback(hFig, 'UpdateSurfaceColor', hFig, iSurf);
end
%% ===== SET AUTO TRANSPARENCY =====
function SetAutoTransparency(hFig)
    % Get surfaces definitions
    TessInfo = getappdata(hFig, 'Surface');
    % Look for different surfaces types
    iCortex = find(ismember({TessInfo.Name}, {'Cortex', 'Anatomy'}));
    iOther  = find(ismember({TessInfo.Name}, {'Scalp', 'InnerSkull', 'OuterSkull'}));
    % Set other surfaces transparency if cortex at the same time
    if ~isempty(iCortex) && ~isempty(iOther)
        for i = 1:length(iOther)
            SetSurfaceTransparency(hFig, iOther(i), 0.7);
        end
    end
end
    

%% ===== SET SURFACE COLOR =====
function SetSurfaceColor(hFig, iSurf, newColor2)
    % Compute the color used to display curvature (newColor1)
    newColor1 = .6 .* newColor2;

    % Get description of surfaces
    TessInfo = getappdata(hFig, 'Surface');
    % Update surface description (figure's appdata)
    TessInfo(iSurf).AnatomyColor(1,:) = newColor1;
    TessInfo(iSurf).AnatomyColor(2,:) = newColor2;
    % Update Surface appdata structure
    setappdata(hFig, 'Surface', TessInfo);
    
    % Get panel controls
    ctrl = bst_getContext('PanelControls', 'Surface');
    % Change button color
    ctrl.jButtonSurfColor.setBackground(java.awt.Color(newColor2(1), newColor2(2), newColor2(3)));
    % Update panel controls
    UpdateSurfaceProperties();
    
    % Update color display on the surface
    figure_callback(hFig, 'UpdateSurfaceColor', hFig, iSurf);
end

%% ===== APPLY DEFAULT DISPLAY TO SURFACE =====
function ApplyDefaultDisplay() %#ok<DEFNU>
    % Get panel controls
    ctrl = bst_getContext('PanelControls', 'Surface');
    % Get defaults for surface display
    DefaultSurfaceDisplay = bst_getContext('DefaultSurfaceDisplay');
    % Surface smooth
    if (ctrl.jSliderSurfSmoothValue.getValue() ~= DefaultSurfaceDisplay.SurfSmoothValue * 100)
        ctrl.jSliderSurfSmoothValue.setValue(DefaultSurfaceDisplay.SurfSmoothValue * 100);
        event = java.awt.event.MouseEvent(ctrl.jSliderSurfSmoothValue, 0, 0, 0, 0, 0, 1, 0, 0);
        SliderCallback([], event, 'SurfSmoothValue');
    end
    % Surface edges
    if DefaultSurfaceDisplay.SurfShowCurvature && ~ctrl.jButtonSurfCurvature.isSelected()
        ctrl.jButtonSurfCurvature.doClick();
    end
end

