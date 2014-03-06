function varargout = panel_scouts(varargin)
% PANEL_SCOUTS: Create a panel to add/remove/edit scouts attached to a given 3DViz figure.
% 
% USAGE:  bstPanelNew = panel_scouts('CreatePanel')
%                       panel_scouts('UpdatePanel')
%                       panel_scouts('UpdateScoutsList', sScouts)
%                       panel_scouts('UpdateScoutProperties')
%                       panel_scouts('CurrentFigureChanged_Callback')
%                       panel_scouts('SetCurrentSurface', newSurfaceFile)
%             sScouts = panel_scouts('GetScouts', iScouts)
%  [sScouts, iScouts] = panel_scouts('GetScouts')
%  [sScouts, iScouts] = panel_scouts('GetCurrentScouts')
%  [sScouts, iScouts] = panel_scouts('GetScoutsWithSurface', SurfaceFile)
%  [sScouts, iScouts] = panel_scouts('GetScoutsWithFigure', hFig)
%  [sScouts, iScouts] = panel_scouts('GetSelectedScouts')
%    [sScout, iScout] = panel_scouts('CreateNewScout', SurfaceFile, newVertices, newSeed)
%                       panel_scouts('SetSelectedScouts', iSelScouts)
%                       panel_scouts('SetSelectionState', isSelected)
%                       panel_scouts('SelectCorticalSpot', hFig)
%                       panel_scouts('StartNewScoutSurface')
%                       panel_scouts('StartNewScoutMri')
%                       panel_scouts('StartNewScoutMax')
%                       panel_scouts('EditExistingScoutSurface')
%                       panel_scouts('EditExistingScoutMri')
%                       panel_scouts('EditScoutLabel')
%                       panel_scouts('EditScoutsSize', action)
%                       panel_scouts('EditScoutsColor', newColor)
%                       panel_scouts('ScoutEditorInMri', )
%                       panel_scouts('PlotAllScouts')
%                       panel_scouts('PlotScout', iScout)
%                       panel_scouts('RemoveScoutsFromFigure', hFig)
%                       panel_scouts('RemoveScouts', iScouts) : remove a list of scouts
%                       panel_scouts('RemoveScouts', )        : remove the scouts selected in the JList 
%                       panel_scouts('RemoveUnusedScouts')
%                       panel_scouts('JoinScouts')
%                       panel_scouts('UpdateScoutsVertices', SurfaceFile)
%                       panel_scouts('SaveScouts')
%                       panel_scouts('LoadScouts')
%                       panel_scouts('ForwardModelForScout')
%                       panel_scouts('ViewInMriViewer')
%          ColorTable = panel_scouts('GetScoutsColorTable')
%       ScoutsOptions = panel_scouts('GetScoutDisplayType') 

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
    panelName = 'Scout';
    % Java initializations
    import java.awt.*;
    import javax.swing.*;
    import org.brainstorm.icon.IconLoader;
    import java.awt.event.KeyEvent;

    % CONSTANTS 
    DEFAULT_HEIGHT    = 20;
    HFILLED_WIDTH     = 40;
    BUTTON_SIZE_WIDTH  = 26;
    BUTTON_SIZE1_WIDTH = 22;
    TOOLBUTTON_SIZE    = Dimension(28,24);
    CHECKBOX_MARGIN    = Insets(3,10,3,10);
    jFontText = java.awt.Font('Dialog', java.awt.Font.PLAIN, 11);
    % The the better JList height
    JLIST_MAX_HEIGHT = 180;

    % Create tools panel
    jPanelNew = JPanel(BorderLayout());

    % ===== Create toolbar/menubar =====
    % Create menubar
    jMenuBar = JMenuBar();
        % === TOOLBAR ===
        % Toolbar embedded in the menubar, to display correctly the first icons (non-menus)
        jToolbarScouts = JToolBar('Edit scouts');
        jToolbarScouts.setBorderPainted(0);
        jToolbarScouts.setFloatable(0);
        jToolbarScouts.setRollover(1);
            % Button "Add scout"
            jButtonAddScout = JToggleButton(IconLoader.ICON_SCOUT_NEW);
            jButtonAddScout.setPreferredSize(TOOLBUTTON_SIZE);
            jButtonAddScout.setMaximumSize(TOOLBUTTON_SIZE);
            jButtonAddScout.setFocusable(0);
            jButtonAddScout.setToolTipText('<HTML><B>Select point</B>:<BR><BLOCKQUOTE> - If a scout selected in the list: point is added to the scout<BR> - Else, a new scout is created.</BLOCKQUOTE></HTML>')
            set(jButtonAddScout, 'ActionPerformedCallback', @(h,ev)bst_safeCall(@SetSelectionState, ev.getSource.isSelected()));
            jToolbarScouts.add(jButtonAddScout);
            % Button "Display scouts"
            jButtonDisplayScout = JButton(IconLoader.ICON_TS_DISPLAY);
            jButtonDisplayScout.setPreferredSize(TOOLBUTTON_SIZE);
            jButtonDisplayScout.setMaximumSize(TOOLBUTTON_SIZE);
            jButtonDisplayScout.setFocusable(0);
            set(jButtonDisplayScout, 'ActionPerformedCallback', @(h,ev)bst_safeCall(@DisplayScouts));
            jButtonDisplayScout.setToolTipText('<HTML><B>Display scouts time series</B>&nbsp;&nbsp;&nbsp;&nbsp;[ENTER]</HTML>');
            jToolbarScouts.add(jButtonDisplayScout);
        jMenuBar.add(jToolbarScouts);
        
        % === MENU NEW ===
        jMenuNew = JMenu('New');
        jMenuNew.setIcon(IconLoader.ICON_MENU);
            % Menu "New scout (design on surface)"
            jButtonNewScoutSurface = JMenuItem('Define in 3D view', IconLoader.ICON_SCOUT_NEW);
            set(jButtonNewScoutSurface, 'ActionPerformedCallback', @(h,ev)bst_safeCall(@StartNewScoutSurface));
            jMenuNew.add(jButtonNewScoutSurface);
            % Menu "New scout (design on MRI)"
            jButtonNewScoutMri = JMenuItem('Define in MRI slices', IconLoader.ICON_EDIT_SCOUT_IN_MRI);
            set(jButtonNewScoutMri, 'ActionPerformedCallback', @(h,ev)bst_safeCall(@StartNewScoutMri));
            jMenuNew.add(jButtonNewScoutMri);
            % Menu "New scout (SurfaceTiling)"
            jButtonSurfaceTiling = JMenuItem('Surface tiling', IconLoader.ICON_EDIT_SCOUT_IN_MRI);
            set(jButtonSurfaceTiling, 'ActionPerformedCallback', @(h,ev)bst_safeCall(@SurfaceTiling));
            jMenuNew.add(jButtonSurfaceTiling);
            % Separator
            jMenuNew.addSeparator();
            % Menu "Find vertex with maximal value"
            jButtonNewScoutMax = JMenuItem('Find maximal value', IconLoader.ICON_FIND_MAX);
            set(jButtonNewScoutMax, 'ActionPerformedCallback', @(h,ev)bst_safeCall(@StartNewScoutMax));
            jMenuNew.add(jButtonNewScoutMax);
        jMenuBar.add(jMenuNew);

        % === MENU EDIT ===
        jMenuEdit = JMenu('Edit');
        jMenuEdit.setIcon(IconLoader.ICON_MENU);
            % Button "Rename scout"
            jButtonRenameScout = JMenuItem('Rename', IconLoader.ICON_EDIT);
            set(jButtonRenameScout, 'ActionPerformedCallback', @(h,ev)bst_safeCall(@EditScoutLabel));
            jMenuEdit.add(jButtonRenameScout);
            % Button "Edit scout color"
            jButtonScoutColor = JMenuItem('Set color', IconLoader.ICON_COLOR_SELECTION);
            set(jButtonScoutColor, 'ActionPerformedCallback', @(h,ev)bst_safeCall(@EditScoutsColor));
            jMenuEdit.add(jButtonScoutColor);
            % Button "Remove scout"
            jButtonRemoveScout = JMenuItem('Remove', IconLoader.ICON_DELETE);
            set(jButtonRemoveScout, 'ActionPerformedCallback', @(h,ev)bst_safeCall(@RemoveScouts));
            jMenuEdit.add(jButtonRemoveScout);
            % Button "Join scouts"
            jButtonJoinScouts = JMenuItem('Merge', IconLoader.ICON_FUSION);
            set(jButtonJoinScouts, 'ActionPerformedCallback', @(h,ev)bst_safeCall(@JoinScouts));
            jMenuEdit.add(jButtonJoinScouts);
            % Button "Deselect all scouts"
            jButtonDeselect = JMenuItem('Deselect all', IconLoader.ICON_RELOAD);
            set(jButtonDeselect, 'ActionPerformedCallback', @(h,ev)bst_safeCall(@SetSelectedScouts, 0));
            jMenuEdit.add(jButtonDeselect);
            % Separator
            jMenuEdit.addSeparator();
            % Button "Add vertices"
            jButtonAddVertices = JMenuItem('Add vertices', IconLoader.ICON_SCOUT_NEW);
            set(jButtonAddVertices, 'ActionPerformedCallback', @(h,ev)bst_safeCall(@EditExistingScoutSurface));
            jMenuEdit.add(jButtonAddVertices);
            % Menu "Edit in MRI"
            jButtonEditInMri = JMenuItem('Edit in MRI', IconLoader.ICON_EDIT_SCOUT_IN_MRI);
            set(jButtonEditInMri, 'ActionPerformedCallback', @(h,ev)bst_safeCall(@EditExistingScoutMri));
            jMenuEdit.add(jButtonEditInMri);
            % Separator
            jMenuEdit.addSeparator();
            % Menu "Expand with correlation"
            jButtonCorrelation = JMenuItem('Expand (correlation)', IconLoader.ICON_RESIZE);
            jButtonCorrelation.setToolTipText('Expand scout based on correlation with other sources.');
            set(jButtonCorrelation, 'ActionPerformedCallback', @(h,ev)bst_safeCall(@ExpandWithCorrelation));
            jMenuEdit.add(jButtonCorrelation);
            % Menu "Find vertex with maximal value"
            jButtonSelectMaximum = JMenuItem('Find maximal value', IconLoader.ICON_FIND_MAX);
            set(jButtonSelectMaximum, 'ActionPerformedCallback', @(h,ev)bst_safeCall(@EditExistingScoutMax));
            jMenuEdit.add(jButtonSelectMaximum);
            % Separator
            jMenuEdit.addSeparator();
            % Menu "Remove scout vertices from surface"
            jButtonRemoveScout = JMenuItem('Remove vertices', IconLoader.ICON_DELETE);
            set(jButtonRemoveScout, 'ActionPerformedCallback', @(h,ev)bst_safeCall(@RemoveScoutFromSurface));
            jMenuEdit.add(jButtonRemoveScout);
            % Separator
            jMenuEdit.addSeparator();
            % Menu "Forward model"
            jButtonForwardModel = JMenuItem('Simulation', IconLoader.ICON_SCOUT_FORWARDMODEL);
            jButtonForwardModel.setToolTipText(['<HTML><B>Simulation: Forward model of selected scouts</B>:<BR>' ...
                                                '<BLOCKQUOTE>Simulate the scalp data that would be recorded if<BR>' ...
                                                'only the selected cortex region was activated.<BR><BR>' ...
                                                'If no scout is selected: simulate recordings produced<BR>' ... 
                                                'by the activity of the whole cortex.</BLOCKQUOTE></HTML>']);
            set(jButtonForwardModel, 'ActionPerformedCallback', @(h,ev)bst_safeCall(@ForwardModelForScout));
            jMenuEdit.add(jButtonForwardModel);
        jMenuBar.add(jMenuEdit);
        
        % === MENU VIEW ===
        jMenuView = JMenu('View');
        jMenuView.setIcon(IconLoader.ICON_MENU);
            % === FUNCTIONAL DISPLAY ===
            % Menu "View time series"
            jButtonDisplayScout = JMenuItem('View time series', IconLoader.ICON_TS_DISPLAY);
            set(jButtonDisplayScout, 'ActionPerformedCallback', @(h,ev)bst_safeCall(@DisplayScouts));
            jMenuView.add(jButtonDisplayScout);
            % === ANTOMICAL DISPLAY ===
            % Separator
            jMenuView.addSeparator();
            % Menu "View scout on cortex"
            jButtonViewOnCortex = JMenuItem('View on cortex', IconLoader.ICON_CORTEX);
            set(jButtonViewOnCortex, 'ActionPerformedCallback', @(h,ev)bst_safeCall(@ViewOnCortex));
            jMenuView.add(jButtonViewOnCortex);
            % Menu "View in MRI"
            jButtonViewInMriViewer = JMenuItem('View in MRIViewer', IconLoader.ICON_VIEW_SCOUT_IN_MRI);
            set(jButtonViewInMriViewer, 'ActionPerformedCallback', @(h,ev)bst_safeCall(@ViewInMriViewer));
            jMenuView.add(jButtonViewInMriViewer);
            % Menu "Center 3D MRI on scout"
            jButtonCenterMri = JMenuItem('Center MRI on scout', IconLoader.ICON_VIEW_SCOUT_IN_MRI);
            set(jButtonCenterMri, 'ActionPerformedCallback', @(h,ev)bst_safeCall(@CenterMriOnScout));
            jMenuView.add(jButtonCenterMri);
            
            % === DISPLAY OPTIONS ===
            % Separator
            jMenuView.addSeparator();
            % Menu "Scouts displayed in 3D"
            jMenuSelAll = JMenu('3D display options...');
            jMenuSelAll.setIcon(IconLoader.ICON_PROPERTIES);
                % Display ALL/SELECTED scouts
                jButtonGroup = ButtonGroup();
                jRadioScoutViewSelected = JRadioButtonMenuItem('Show selected scouts');
                jRadioScoutViewAll      = JRadioButtonMenuItem('Show all scouts', 1);
                set(jRadioScoutViewSelected, 'ActionPerformedCallback', @(h,ev)UpdateScoutsDisplay());
                set(jRadioScoutViewAll,      'ActionPerformedCallback', @(h,ev)UpdateScoutsDisplay());
                jRadioScoutViewSelected.setMargin(CHECKBOX_MARGIN);
                jRadioScoutViewAll.setMargin(CHECKBOX_MARGIN);
                jButtonGroup.add(jRadioScoutViewSelected);
                jButtonGroup.add(jRadioScoutViewAll);
                jMenuSelAll.add(jRadioScoutViewSelected);
                jMenuSelAll.add(jRadioScoutViewAll);
                % Separator
                jMenuSelAll.addSeparator();
                % SHOW/HIDE SCOUTS PATCHES OVER MRI SLICES
                jCheckViewPatchesInMri = JCheckBoxMenuItem('Show scout patch (in MRI/3D figures)', 0);
                set(jCheckViewPatchesInMri, 'ActionPerformedCallback', @(h,ev)UpdateScoutsDisplay());
                jCheckViewPatchesInMri.setMargin(CHECKBOX_MARGIN);
                jMenuSelAll.add(jCheckViewPatchesInMri);
                % LIMIT MRI SCOURCES TO SCOUTS
                jCheckLimitMriSources = JCheckBoxMenuItem('Limit MRI sources to scouts', 1);
                set(jCheckLimitMriSources, 'ActionPerformedCallback', @(h,ev)LimitMriSourcesToScouts());
                jCheckLimitMriSources.setMargin(CHECKBOX_MARGIN);
                jMenuSelAll.add(jCheckLimitMriSources);

            jMenuView.add(jMenuSelAll);
            % Menu "Time series options"
            jMenuTsOptions = JMenu('Time series options...');
            jMenuTsOptions.setIcon(IconLoader.ICON_PROPERTIES);
                % OPTIONS : Sources values (Relative / Absolute)
                jButtonGroupValues = ButtonGroup();
                jRadioValuesRelative = JRadioButtonMenuItem('Relative values', 0);
                jRadioValuesAbsolute = JRadioButtonMenuItem('Absolute values', 1);
                jRadioValuesRelative.setMargin(CHECKBOX_MARGIN);
                jRadioValuesAbsolute.setMargin(CHECKBOX_MARGIN);
                jButtonGroupValues.add(jRadioValuesRelative);
                jButtonGroupValues.add(jRadioValuesAbsolute);
                jMenuTsOptions.add(jRadioValuesRelative);
                jMenuTsOptions.add(jRadioValuesAbsolute);
                % Separator
                jMenuTsOptions.addSeparator();
                % OPTIONS : Sources type (Mean, max, all)
                jButtonGroupType = ButtonGroup();
                jRadioTypeMean = JRadioButtonMenuItem('Sources: Mean', 1);
                jRadioTypeMax  = JRadioButtonMenuItem('Sources: Max',  0);
                jRadioTypePower= JRadioButtonMenuItem('Sources: Power',  0);
                jRadioTypeAll  = JRadioButtonMenuItem('Sources: All',  0);
                jRadioTypeMean.setMargin(CHECKBOX_MARGIN);
                jRadioTypeMax.setMargin( CHECKBOX_MARGIN);
                jRadioTypePower.setMargin( CHECKBOX_MARGIN);
                jRadioTypeAll.setMargin( CHECKBOX_MARGIN);
                jButtonGroupType.add(jRadioTypeMean);
                jButtonGroupType.add(jRadioTypeMax);
                jButtonGroupType.add(jRadioTypePower);
                jButtonGroupType.add(jRadioTypeAll);
                set(jRadioTypeMean, 'ActionPerformedCallback', @SourcesTypeChanged_Callback);
                set(jRadioTypeMax,  'ActionPerformedCallback', @SourcesTypeChanged_Callback);
                set(jRadioTypePower,'ActionPerformedCallback', @SourcesTypeChanged_Callback);
                set(jRadioTypeAll,  'ActionPerformedCallback', @SourcesTypeChanged_Callback);
                jMenuTsOptions.add(jRadioTypeMean);
                jMenuTsOptions.add(jRadioTypeMax);
                jMenuTsOptions.add(jRadioTypePower);
                jMenuTsOptions.add(jRadioTypeAll);
            jMenuView.add(jMenuTsOptions);
        jMenuBar.add(jMenuView);
    jPanelNew.add(jMenuBar, BorderLayout.NORTH);
    
    
    % ===== PANEL MAIN =====
    jPanelMain = JPanel();
    jPanelMain.setLayout(BoxLayout(jPanelMain, BoxLayout.Y_AXIS));
    jPanelMain.setBorder(BorderFactory.createEmptyBorder(7,7,7,7));
%     jPanelMain.setPreferredSize(Dimension());
        % ===== FIRST PART =====
        jPanelFirstPart = JPanel(BorderLayout());
        jPanelFirstPart.setPreferredSize(Dimension(100,JLIST_MAX_HEIGHT));
        jPanelFirstPart.setMaximumSize(Dimension(500,JLIST_MAX_HEIGHT));
            % Vertical Toolbar
            jToolbarScouts2 = JToolBar('Edit scouts');
            jToolbarScouts2.setBorderPainted(0);
            jToolbarScouts2.setFloatable(0);
            jToolbarScouts2.setRollover(1);
            jToolbarScouts2.setOrientation(jToolbarScouts2.VERTICAL);
                % Button "Load scouts file"
                jButtonLoadScouts = JButton(IconLoader.ICON_FOLDER_OPEN);
                jButtonLoadScouts.setPreferredSize(TOOLBUTTON_SIZE);
                jButtonLoadScouts.setFocusable(0);
                jButtonLoadScouts.setToolTipText('Load scouts file');
                set(jButtonLoadScouts, 'ActionPerformedCallback', @(h,ev)bst_safeCall(@LoadScouts));
                jToolbarScouts2.add(jButtonLoadScouts);
                % Button "Save scouts file"
                jButtonSaveScouts = JButton(IconLoader.ICON_SAVE);
                jButtonSaveScouts.setPreferredSize(TOOLBUTTON_SIZE);
                jButtonSaveScouts.setFocusable(0);
                jButtonSaveScouts.setToolTipText('Save scouts file');
                set(jButtonSaveScouts, 'ActionPerformedCallback', @(h,ev)bst_safeCall(@SaveScouts));
                jToolbarScouts2.add(jButtonSaveScouts);
            jPanelFirstPart.add(jToolbarScouts2, BorderLayout.EAST);
            
            % ===== Scouts list =====
             jPanelScoutsList = JPanel(BorderLayout);
                jPanelScoutsList.setBorder(BorderFactory.createTitledBorder('Available scouts'));
                jListScouts = JList();
                set(jListScouts, 'ValueChangedCallback', @ScoutsListValueChanged_Callback, ...
                                 'KeyTypedCallback',     @ScoutsListKeyTyped_Callback, ...
                                 'MouseClickedCallback', @ScoutsListClick_Callback);
                jPanelScrollList = JScrollPane();
                jPanelScrollList.getLayout.getViewport.setView(jListScouts);
                jPanelScrollList.setBorder([]);
                jPanelScoutsList.add(jPanelScrollList);
            jPanelFirstPart.add(jPanelScoutsList, BorderLayout.CENTER);
        jPanelMain.add(jPanelFirstPart);

        % ===== Scouts options panel =====
        jPanelScoutOptions = getRiverPanel([0,3], [0,5,10,3], 'Scout size');           
            % OPTIONS : Scout size
%             jPanelScoutOptions.add('br', JLabel('Size: '));

            % OPTIONS : Scout growth
            jButtonSizeShrink  = JButton('<<');
            jButtonSizeShrink1 = JButton('<');
            jButtonSizeGrow1   = JButton('>');
            jButtonSizeGrow    = JButton('>>');
            jButtonSizeGrow.setPreferredSize(   Dimension(BUTTON_SIZE_WIDTH,  DEFAULT_HEIGHT));
            jButtonSizeGrow1.setPreferredSize(  Dimension(BUTTON_SIZE1_WIDTH, DEFAULT_HEIGHT));
            jButtonSizeShrink.setPreferredSize( Dimension(BUTTON_SIZE_WIDTH,  DEFAULT_HEIGHT));
            jButtonSizeShrink1.setPreferredSize(Dimension(BUTTON_SIZE1_WIDTH, DEFAULT_HEIGHT));
            jButtonSizeGrow.setFont(jFontText);
            jButtonSizeGrow1.setFont(jFontText);
            jButtonSizeShrink.setFont(jFontText);
            jButtonSizeShrink1.setFont(jFontText);
            jButtonSizeGrow.setMargin(   Insets(0,0,0,0));
            jButtonSizeGrow1.setMargin(  Insets(0,0,0,0));
            jButtonSizeShrink.setMargin( Insets(0,0,0,0));
            jButtonSizeShrink1.setMargin(Insets(0,0,0,0));
            jButtonSizeGrow.setFocusPainted(0);
            jButtonSizeGrow1.setFocusPainted(0);
            jButtonSizeShrink.setFocusPainted(0);
            jButtonSizeShrink1.setFocusPainted(0);
            jButtonSizeGrow.setToolTipText(   'Increase scout size');
            jButtonSizeGrow1.setToolTipText(  'Increase scout size (only one vertex)');
            jButtonSizeShrink.setToolTipText( 'Decrease scout size');
            jButtonSizeShrink1.setToolTipText('Decrease scout size (only one vertex)');
            set(jButtonSizeGrow,   'ActionPerformedCallback', @(h,ev)EditScoutsSize('Grow'));
            set(jButtonSizeGrow1,  'ActionPerformedCallback', @(h,ev)EditScoutsSize('Grow1'));
            set(jButtonSizeShrink, 'ActionPerformedCallback', @(h,ev)EditScoutsSize('Shrink'));
            set(jButtonSizeShrink1,'ActionPerformedCallback', @(h,ev)EditScoutsSize('Shrink1'));
            jPanelScoutOptions.add(jButtonSizeShrink);
            jPanelScoutOptions.add(jButtonSizeShrink1);
            jPanelScoutOptions.add(jButtonSizeGrow1);
            jPanelScoutOptions.add(jButtonSizeGrow);

            % Separator
            jPanelScoutOptions.add(JLabel('  '));
            
            % OPTIONS : Constrained to data
            jToggleConstrained = JToggleButton('Constrained');
            jToggleConstrained.setPreferredSize(Dimension(HFILLED_WIDTH, DEFAULT_HEIGHT));
            jToggleConstrained.setFont(jFontText);
            jToggleConstrained.setMargin(Insets(0,0,0,0));
            jToggleConstrained.setFocusPainted(0);
            jToggleConstrained.setToolTipText('Constrain patch growth to vertices with data above threshold.');
            jPanelScoutOptions.add('tab hfill', jToggleConstrained);

            % OPTIONS : Scout size in vertices/area
            jPanelScoutOptions.add('br', JLabel('Number of vertices:'));
            jLabelScoutSize = JLabel('');
%             jLabelScoutSize.setPreferredSize(Dimension(HFILLED_WIDTH, DEFAULT_HEIGHT));
            jPanelScoutOptions.add('tab hfill', jLabelScoutSize);
            
                       
        panelPrefSize = jPanelScoutOptions.getPreferredSize();
        jPanelScoutOptions.setMaximumSize(Dimension(32000, panelPrefSize.getHeight()));
        jPanelMain.add(jPanelScoutOptions);

        % ===== Display options panel =====
        jPanelDisplayOptions = getRiverPanel([0,1], [2,4,4,0], 'Display options');
            % OPTIONS : Overlay scouts/conditions
            jPanelDisplayOptions.add(JLabel('Overlay:'));
            jCheckOverlayScouts     = JCheckBox('Scouts',     0);
            jCheckOverlayConditions = JCheckBox('Conditions', 0);
            jCheckOverlayScouts.setMargin(Insets(0,0,0,0));
            jCheckOverlayConditions.setMargin(Insets(0,0,0,0));
            set(jCheckOverlayScouts,     'ActionPerformedCallback', @OverlayTypeChanged_Callback);
            set(jCheckOverlayConditions, 'ActionPerformedCallback', @OverlayTypeChanged_Callback);
            jPanelDisplayOptions.add('tab', jCheckOverlayScouts);
            jPanelDisplayOptions.add(jCheckOverlayConditions);
        panelPrefSize = jPanelDisplayOptions.getPreferredSize();
        jPanelDisplayOptions.setMaximumSize(Dimension(32000, panelPrefSize.getHeight()));
        jPanelMain.add(jPanelDisplayOptions);

        jPanelMain.add(Box.createVerticalGlue());
        jPanelMain.setPreferredSize(Dimension(200,280));
        jScrollMain = JScrollPane(jPanelMain);       
        jScrollMain.setBorder([]);
    jPanelNew.add(jScrollMain);
    
    % Create the BstPanel object that is returned by the function
    % => constructor BstPanel(jHandle, panelName, sControls)
    bstPanelNew = BstPanel(panelName, ...
                           jPanelNew, ...
                           struct('jPanelScoutsList',      jPanelScoutsList, ...
                                  'jToolbarScouts',        jToolbarScouts, ...
                                  'jButtonAddScout',       jButtonAddScout, ...
                                  'jPanelScoutOptions',    jPanelScoutOptions, ...
                                  'jLabelScoutSize',       jLabelScoutSize, ...
                                  'jPanelDisplayOptions',  jPanelDisplayOptions, ...
                                  'jRadioScoutViewSelected', jRadioScoutViewSelected, ...
                                  'jRadioScoutViewAll',      jRadioScoutViewAll, ...
                                  'jCheckViewPatchesInMri',  jCheckViewPatchesInMri, ...
                                  'jCheckLimitMriSources',   jCheckLimitMriSources, ...
                                  'jToggleConstrained',      jToggleConstrained, ...
                                  'jRadioTypeMean',          jRadioTypeMean, ...
                                  'jRadioTypeMax',           jRadioTypeMax, ...
                                  'jRadioTypePower',         jRadioTypePower, ...
                                  'jRadioTypeAll',           jRadioTypeAll, ...
                                  'jRadioValuesRelative',     jRadioValuesRelative, ...
                                  'jRadioValuesAbsolute',     jRadioValuesAbsolute, ...
                                  'jCheckOverlayScouts',      jCheckOverlayScouts, ...
                                  'jCheckOverlayConditions',  jCheckOverlayConditions, ...
                                  'jListScouts',                jListScouts));
                              
    
%% ===== INTERNAL CALLBACKS =====
    % Sources type changed
    function SourcesTypeChanged_Callback(varargin)
        % If 'ALL' sources type: disable overlays options
        if jRadioTypeAll.isSelected()
            jCheckOverlayScouts.setEnabled(0);
            jCheckOverlayConditions.setEnabled(0);
            jCheckOverlayScouts.setSelected(0);
            jCheckOverlayConditions.setSelected(0);
        else
            jCheckOverlayScouts.setEnabled(1);
            jCheckOverlayConditions.setEnabled(1);
        end
    end

    % Overlay type changed
    function OverlayTypeChanged_Callback(varargin)
        % If an overlay is activated : disable 'ALL' sources type
        if jCheckOverlayScouts.isSelected() || jCheckOverlayConditions.isSelected()
            jRadioTypeAll.setEnabled(0);
            if jRadioTypeAll.isSelected()
                jRadioTypeMean.setSelected(1);
            end
        else
            jRadioTypeAll.setEnabled(1);
        end
    end
                     
    function LimitMriSourcesToScouts()
%         global GlobalData;
        % Update selected scouts
        UpdateScoutsDisplay();
%         % Get all other figures
%         hAllFig = [];
%         for i = 1:length(GlobalData.Scouts)
%             hAllFig = [hAllFig, [GlobalData.Scouts(i).Handles.hFig]];
%         end
%         % Update all other figures
%         panel_surface('UpdateOverlayCubes', unique(hAllFig));
        
    end
end
                   
            

%% =================================================================================
%  === CONTROLS CALLBACKS  =========================================================
%  =================================================================================
%% ===== VIEW ONLY SELECTED SCOUTS ? =====
function status = isViewOnlySelectedScouts()
    % Get "Scouts" panel controls
    ctrl = bst_getContext('PanelControls', 'Scout');
    status = ctrl.jRadioScoutViewSelected.isSelected();
end

%% ===== LIST SELECTION CHANGED CALLBACK =====
function ScoutsListValueChanged_Callback(h, ev)
    if ~ev.getValueIsAdjusting()
        % Update panel "Scouts" fields
        UpdateScoutProperties();
        % Display/hide scouts
        if isViewOnlySelectedScouts()
            UpdateScoutsDisplay();
        end
    end
end

%% ===== LIST KEY TYPED CALLBACK =====
function ScoutsListKeyTyped_Callback(h, ev)
    switch(uint8(ev.getKeyChar()))
        % DELETE
        case ev.VK_DELETE
            RemoveScouts();
        case ev.VK_ENTER
            gui_viewResultsScouts();
        case uint8('+')
            EditScoutsSize('Grow1');
        case uint8('-')
            EditScoutsSize('Shrink1');
        case ev.VK_ESCAPE
            SetSelectedScouts(0);
    end
end

%% ===== LIST CLICK CALLBACK =====
function ScoutsListClick_Callback(h, ev)
    % If DOUBLE CLICK
    if (ev.getClickCount() == 2)
        % Rename selection
        EditScoutLabel();
    end
end


%% =================================================================================
%  === EXTERNAL PANEL CALLBACKS  ===================================================
%  =================================================================================
%% ===== UPDATE CALLBACK =====
function UpdatePanel()
    % Get "Scouts" panel controls
    ctrl = bst_getContext('PanelControls', 'Scout');
    % Get current scouts
    sScouts = GetCurrentScouts();
    % If a surface is available for current figure
    if ~isempty(sScouts)
        % Enable all panels
        gui_setEnabledControls([ctrl.jPanelScoutsList, ...
                                ctrl.jPanelDisplayOptions, ctrl.jPanelScoutOptions], 1);
    % Else : no figure associated with the panel : disable all controls
    else
        gui_setEnabledControls([ctrl.jPanelScoutsList, ...
                                ctrl.jPanelDisplayOptions, ctrl.jPanelScoutOptions], 0);
        % Release "Add scouts" button
        ctrl.jButtonAddScout.setSelected(0);
    end
    % Update scouts JList
    UpdateScoutsList(sScouts);
end


%% ===== UPDATE SCOUTS LIST =====
function UpdateScoutsList(sScouts)
    % If scouts list was not defined : get it
    if (nargin < 1)
        sScouts = GetCurrentScouts();
    end
    % Get "Scouts" panel controls
    ctrl = bst_getContext('PanelControls', 'Scout');
    % Create a new empty list
    listModel = awtcreate('javax.swing.DefaultListModel');
    % Add an item in list for each scout found for target figure
    for iScout = 1:length(sScouts)
        awtinvoke(listModel, 'addElement(Ljava.lang.Object;)', sScouts(iScout).Label);
    end
    % Update list model
    awtinvoke(ctrl.jListScouts, 'setModel(Ljavax.swing.ListModel;)', listModel);
    % Reset Scout comments
    awtinvoke(ctrl.jLabelScoutSize, 'setText(Ljava.lang.String;)', '');
end



%% ===== UPDATE SCOUT PROPERTIES DISPLAY =====
function UpdateScoutProperties()
    % Get "Scouts" panel controls
    ctrl = bst_getContext('PanelControls', 'Scout');
    % Get selected scouts
    sScouts = GetSelectedScouts();
    % Add all the selected scouts to compute : area, nbVertices
%     scoutArea = 0;
    nbVertices = 0;
    for i = 1:length(sScouts)
        % NbVertices
        nbVertices = nbVertices + length(sScouts(i).Vertices);
        % Area
%         if ~isempty(sScouts(i).Area) 
%             scoutArea = scoutArea + sScouts(i).Area;
%         end
    end
    % Format results (NbVertices / Area)
    if (nbVertices == 0)
        strSize = '';
    else
%     elseif (scoutArea == 0)
        strSize = sprintf(' [ %d ]', nbVertices);
%     else
%         strSize = sprintf('%d  (%0.2f cm2)', nbVertices, scoutArea);
    end
    % Update panel
    ctrl.jLabelScoutSize.setText(strSize);
end


%% ===== CURRENT FIGURE CHANGED =====
function CurrentFigureChanged_Callback(oldFig, hFig)
    global GlobalData;
    % === NO NEW FIGURE ===
    % If no figure is available
    if isempty(hFig) || ~ishandle(hFig)
        % Reset current surface
        GlobalData.CurrentScoutsSurface = '';
        return
    end
    % Get cortex surface for new figure
    [iNewSurf, TessInfo] = panel_surface('GetSurfaceCortex', hFig);
    % If no cortex defined, try to find a MRI surface
    if isempty(iNewSurf)
        [sMri, TessInfo, iNewSurf] = panel_surface('GetSurfaceMri', hFig);
    end

    % === COMPARE OLD AND NEW FIG ===
    if ~isempty(oldFig) && ishandle(oldFig) && (oldFig ~= hFig)
        % Get surfaces for old figure
        [iOldSurf, oldTessInfo] = panel_surface('GetSurfaceCortex', oldFig);
        % If no cortex defined, try to find a MRI surface
        if isempty(iOldSurf)
            [sMri, TessInfo, iOldSurf] = panel_surface('GetSurfaceMri', oldFig);
        end
        % If cortical surface did not change: ignore callback
        if ~isempty(iOldSurf) && ~isempty(iNewSurf) && io_compareFileNames(oldTessInfo(iOldSurf).SurfaceFile, TessInfo(iNewSurf).SurfaceFile);
            return
        end
    end

    % === UPDATE CURRENT SURFACE ===
    newSurfaceFile = '';
    % If no cortex surface is found in target figure
    if ~isempty(iNewSurf)
        % If anatomy surface : use correspondant cortex surface instead
        if strcmpi(TessInfo(iNewSurf).Name, 'Anatomy')
            sSurfCortex = bst_getContext('SurfaceFileByType', TessInfo(iNewSurf).SurfaceFile, 'Cortex');
            if ~isempty(sSurfCortex)
                newSurfaceFile = sSurfCortex.FileName;
            end
        else
            newSurfaceFile = TessInfo(iNewSurf).SurfaceFile;
        end
    end       
    % Update current surface
    SetCurrentSurface(newSurfaceFile);

    % === UPDATE SELECTED SCOUTS ===
    % Get current scouts (for new figure)
    [sScouts, iScouts] = GetCurrentScouts();
    % If 3D figure: scouts have graphic handles
    FigureId = getappdata(hFig, 'FigureId');
    switch(FigureId.Type)
        case 'MriViewer'
            iVisibleScouts = iScouts;
        case '3DViz'
            % Process each scout, to get if it is displayed in this figure
            iVisibleScouts = [];
            for i = 1:length(iScouts)
                % Get handles corresponding to this figure
                allhandles = [sScouts(i).Handles];
                iFigHandles = find([allhandles.hFig] == hFig);
                % If scout is displayed in this figure, and is VISIBLE in this figure: add it to the visible list
                if ~isempty(iFigHandles) && strcmpi(get(sScouts(i).Handles(iFigHandles).hScout, 'Visible'), 'on')
                    iVisibleScouts = [iVisibleScouts, iScouts(i)];
                end
            end
        otherwise
            iVisibleScouts = [];
    end
    % Select visible scouts
    SetSelectedScouts(iVisibleScouts);
end


%% ===== FOCUS CHANGED ======
function FocusChangedCallback(isFocused) %#ok<DEFNU>
    if ~isFocused
        SetSelectionState(0);
    end
end


%% ===== SET CURRENT SURFACE =====
function SetCurrentSurface(newSurfaceFile)
    global GlobalData;
    % Get previously selected surface
    oldSurfaceFile = GlobalData.CurrentScoutsSurface;
    % If SurfaceFile did not change did not change : return
    if strcmpi(newSurfaceFile, oldSurfaceFile)
        return;
    end
    % Update current surface file
    GlobalData.CurrentScoutsSurface = newSurfaceFile;
    % Update panel display
    UpdatePanel();
end

%% ===== UPDATE CURRENT SURFACE =====
function UpdateCurrentSurface() %#ok<DEFNU>
    curFig = gui_figuresManager('GetCurrentFigure', '3D');
    CurrentFigureChanged_Callback(curFig, curFig);
end


%% ===== GET ALL SCOUTS =====
function [sScouts, iScouts] = GetScouts(iScouts)
    global GlobalData;
    if (nargin < 1)
        sScouts = GlobalData.Scouts;
        iScouts = 1:length(sScouts);
    else
        sScouts = GlobalData.Scouts(iScouts);
    end
end


%% ===== GET CURRENT SCOUTS =====
function [sScouts, iScouts] = GetCurrentScouts()
    global GlobalData;
    sScouts = [];
    iScouts = [];
    % If no surface is defined : do nothing
    if isempty(GlobalData.CurrentScoutsSurface)
        return
    end
    % If surface is defined : return scouts associated to this surface
    [sScouts, iScouts] = GetScoutsWithSurface(GlobalData.CurrentScoutsSurface);
end


%% ===== GET SCOUTS WITH SURFACE=====
function [sScouts, iScouts] = GetScoutsWithSurface(SurfaceFile)
    global GlobalData;
    sScouts = [];
    % If surface is defined : return scouts associated to this surface
    iScouts = find(io_compareFileNames({GlobalData.Scouts.SurfaceFile}, SurfaceFile));
    if isempty(iScouts)
        return
    end
    sScouts = GlobalData.Scouts(iScouts);
end


%% ===== GET SCOUTS WITH FIGURE =====
function [sScouts, iScouts] = GetScoutsWithFigure(hFig)
    global GlobalData;
    sScouts = [];
    iScouts = [];
    if isempty(hFig)
        return
    end
    % If figure is defined : return scouts associated to this figure
    for i = 1:length(GlobalData.Scouts)
        if ismember(hFig, [GlobalData.Scouts(i).Handles.hFig])
            iScouts = [iScouts, i];
        end
    end
    sScouts = GlobalData.Scouts(iScouts);
end


%% ===== GET SELECTED SCOUTS =====
% NB: Returned indices are indices in GlobalData.Scouts array
function [sSelScouts, iSelScouts] = GetSelectedScouts()
    sSelScouts = [];
    iSelScouts = [];
    % Get current scouts
    [sScouts, iScouts] = GetCurrentScouts();
    if isempty(sScouts)
        return
    end
    % Get "Scouts" panel controls
    jListScouts = bst_getContext('PanelElement', 'Scout', 'jListScouts');
    % Get JList selected indices
    iSelScouts = uint16(jListScouts.getSelectedIndices())' + 1;
    if isempty(iScouts)
        return
    end
    sSelScouts = sScouts(iSelScouts);
    iSelScouts = iScouts(iSelScouts);
end


%% ===== SET SELECTED SCOUTS =====
% WARNING: Input indices are references in the GlobalData.Scouts array, not in the JList
function SetSelectedScouts(iSelScouts)
    % === GET SCOUT INDICES ===
    % No selection
    if isempty(iSelScouts) || (any(iSelScouts == 0))
        iSelItem = -1;
    % Find the selected scouts in the JList
    else
        [sScouts,iScouts] = GetCurrentScouts();
        iSelItem = [];
        for i=1:length(iSelScouts)
            iSelItem = [iSelItem, find(iSelScouts(i) == iScouts)];
        end
        if isempty(iSelItem)
            iSelItem = -1;
        else
            iSelItem = iSelItem - 1;
        end
    end
    % === CHECK FOR MODIFICATIONS ===
    % Get 3DViz figure information
    jListScouts = bst_getContext('PanelElement', 'Scout', 'jListScouts');
    if isempty(jListScouts)
        return
    end
    % Get previous selection
    iPrevItems = jListScouts.getSelectedIndices();
    % If selection did not change: exit
    if isequal(iPrevItems, iSelItem) || (isempty(iPrevItems) && isequal(iSelItem, -1))
        return
    end
    % === UPDATE SELECTION ===
    % Temporality disables JList selection callback
    jListCallback_bak = get(jListScouts, 'ValueChangedCallback');
    set(jListScouts, 'ValueChangedCallback', []);
    % Select items in JList
    jListScouts.setSelectedIndices(iSelItem);
    % Restore JList callback
    set(jListScouts, 'ValueChangedCallback', jListCallback_bak);
    % Update panel "Scouts" fields
    UpdateScoutProperties();
    % Display/hide scouts
    if isViewOnlySelectedScouts()
        UpdateScoutsDisplay();
    end
end



%% ===== GET SCOUT DISPLAY TYPE =====
% ScoutsOptions:
%    |- function          : {'Mean','Max','Power','All'} ?
%    |- overlayScouts     : {0, 1}
%    |- overlayConditions : {0, 1}
%    |- isAbsolute        : {0, 1}
function ScoutsOptions = GetScoutDisplayType() %#ok<DEFNU>
    % Get "Scouts" panel controls
    ctrl = bst_getContext('PanelControls', 'Scout');
    % Sources time series : MEAN, MAX, ALL
    if ctrl.jRadioTypeMean.isSelected()
        ScoutsOptions.function = 'Mean';
    elseif ctrl.jRadioTypeMax.isSelected()
        ScoutsOptions.function = 'Max';
    elseif ctrl.jRadioTypePower.isSelected()
        ScoutsOptions.function = 'Power';
    elseif ctrl.jRadioTypeAll.isSelected()
        ScoutsOptions.function = 'All';
    end
    % Overlay
    ScoutsOptions.overlayScouts     = ctrl.jCheckOverlayScouts.isSelected();
    ScoutsOptions.overlayConditions = ctrl.jCheckOverlayConditions.isSelected();
    % Display absolute values ?
    ScoutsOptions.isAbsolute = ctrl.jRadioValuesAbsolute.isSelected();
end


%% ===== CREATE NEW SCOUT =====
function [sScout, iScout] = CreateNewScout(SurfaceFile, newVertices, newSeed)
    global GlobalData;
    % == NEW SCOUT ==
    % New scout structure
    sScout  = db_getDataTemplate('Scout');
    iScout = length(GlobalData.Scouts) + 1;
    % Store current scout coordinates
    sScout.SurfaceFile = SurfaceFile;
    sScout.Vertices    = newVertices;
    sScout.Seed        = newSeed;

    % == SCOUT LABEL ==
    % Get other scouts with same surface file
    sOtherScouts = GetScoutsWithSurface(SurfaceFile);
    % Define scouts labels (Label=index)
    iDisplayIndice = length(sOtherScouts) + 1;
    scoutLabel = int2str(iDisplayIndice);
    % Check that the scout name does not exist yet (else, add a ')
    if ~isempty(sOtherScouts)
        while ismember(scoutLabel, {sOtherScouts.Label})
            scoutLabel = [scoutLabel, ''''];
        end
    end
    sScout.Label = scoutLabel;

    % == SCOUT COLOR ==
    ColorTable = GetScoutsColorTable();
    iColor = mod(iDisplayIndice-1, length(ColorTable)) + 1;
    sScout.Color = ColorTable(iColor,:);
    % == Register new scout ==
    GlobalData.Scouts(iScout) = sScout;
end


%% ===== GET SCOUTS COLOR TABLE =====
function ColorTable = GetScoutsColorTable()
    ColorTable = [0    1    0   ;
                  1    0    0   ; 
                  .4   .4   1   ;
                  1    .694 .392;
                  0    1    1   ;
                  1    0    1   ;
                  .4   0    0  ; 
                  0    .5   0];
end


%% ===== VIEW SCOUT =====
function DisplayScouts(varargin)
    % Stop scout editing
    SetSelectionState(0);
    % Get selected scouts
    [sSelScouts, iSelScouts] = GetSelectedScouts();
    % Warning message if no scout selected
    if isempty(sSelScouts)
        java_dialog('warning', 'No scout selected.', 'Display time series');
        return;
    end
    % Display scouts
    gui_viewResultsScouts();
end


%% ===============================================================================
%  ====== POINTS SELECTION =======================================================
%  ===============================================================================
%% ===== SCOUT SELECTION : start/stop =====
% Manual selection of a cortical spot : start(1), or stop(0)
function SetSelectionState(isSelected)
    % Get "Scouts" panel controls
    ctrl = bst_getContext('PanelControls', 'Scout');
    if isempty(ctrl)
        return
    end
    % Get list of figures where it is possible to select a scout
    hFigures = gui_figuresManager('GetFiguresForScouts');
    % No figure available
    if isempty(hFigures)
        if isSelected
            java_dialog('warning', 'No 3D figure with sources available.', 'Select a cortical spot');
        end
        % Release toolbar "AddScout" button 
        ctrl.jButtonAddScout.setSelected(0);
        return
    end
    % Start scout selection
    if isSelected
        % Push toolbar "AddScout" button 
        ctrl.jButtonAddScout.setSelected(1);        
        % Unselect all the scouts in JList
        SetSelectedScouts([]);
        % Set 3DViz figures in 'SelectingCorticalSpot' mode
        for hFig = hFigures
            setappdata(hFig, 'isSelectingCorticalSpot', 1);
            set(hFig, 'Pointer', 'cross');
        end
    % Stop scout selection
    else
        % Release toolbar "AddScout" button 
        ctrl.jButtonAddScout.setSelected(0);
        % Exit 3DViz figures from SelectingCorticalSpot mode
        for hFig = hFigures
            set(hFig, 'Pointer', 'arrow');
            setappdata(hFig, 'isSelectingCorticalSpot', 0);      
        end
    end
end



%% ===== SCOUT SELECTION : Selection performed =====
% Usage : SelectCorticalSpot(hFig) : Scout location = user click in figure hFIg
% If only one scout is selected: add the selected point to the selected scout
% Else: Create a new scout
function SelectCorticalSpot(hFig) %#ok<DEFNU>
    global GlobalData;
    % Get cortex and anatomy surface handle
    [iCortex, TessInfo] = panel_surface('GetSurfaceCortex', hFig);
    [sMri, TessInfo, iAnatomy] = panel_surface('GetSurfaceMri', hFig);


    % === POINT SELECTION ON CORTEX ===
    if ~isempty(iCortex)
        hSurface = TessInfo(iCortex).hPatch;
        % Get mouse 3D selection
        [pout vout vi] = select3d(hSurface);
    % === POINT SELECTION ON MRI ===
    elseif ~isempty(iAnatomy) && ~isempty(TessInfo.DataSource.FileName)
        % Get vertices
        sSubject = bst_getContext('MriFile', sMri.FileName);
        % If there is no cortex for this subject: exit
        if isempty(sSubject.iCortex)
            return
        end
        CortexFile = sSubject.Surface(sSubject.iCortex).FileName;
        sSurfCortex = bst_dataSetsManager('LoadSurface', CortexFile);
       
        % Select a point in the MRI slices
        [TessInfo, iTess, pout, vout, vi] = panel_coordinates('ClickPointInSurface', hFig, 'Anatomy');
        % Find the closest cortical point from this MRI coordinates
        dist = (sSurfCortex.Vertices(:,1) - pout(1)) .^ 2 + ...
               (sSurfCortex.Vertices(:,2) - pout(2)) .^ 2 + ...
               (sSurfCortex.Vertices(:,3) - pout(3)) .^ 2;
        [minDist, iMinDist] = min(dist);
        % If selected point is too far away from cortical surface : return
        if (sqrt(minDist) > 0.01)
            return
        end
        % Select the closest point
        vout = sSurfCortex.Vertices(iMinDist, :)';
        vi   = iMinDist;
    else
        return;
    end
    % Check that a point was selected
    if isempty(vout)
        return
    end   
        
    % === CREATING SCOUT OR ADDING POINTS ===
    % Get selected scouts
    [sSelScouts, iSelScouts] = GetSelectedScouts();
    % If there is more that one selected scout: select only the first one
    if (length(iSelScouts) > 1)
        SetSelectedScouts(iSelScouts(1));
        sSelScouts = sSelScouts(1);
        iSelScouts = iSelScouts(1);
    end
    isNewScout = (length(sSelScouts) ~= 1);
    
    % ==== CHECK UNICITY OF VERTICES ====
    % Get current scouts
    sScouts = GetCurrentScouts();
    if ~isempty(sScouts)
        % Check unicity
        scoutsVertices = [sScouts.Vertices];
        % If vertex was already set as a scout : return
        if ismember(vi, scoutsVertices)
            return 
        end
    end
       
    % ==== NEW SCOUT ====
    if isNewScout
        % Create new scout
        [sScout, iScout] = CreateNewScout(GlobalData.CurrentScoutsSurface, vi, vi);
    % ==== ADD POINT TO SELECTED SCOUT ====
    else
        % Use selected scout
        iScout = iSelScouts;
        % Add clicked vertex
        GlobalData.Scouts(iScout).Vertices = [GlobalData.Scouts(iScout).Vertices, vi];
    end
    
    % === UPDATE INTERFACE ===
    % Display scout patch
    PlotScout(iScout);
    % Update "Scouts" panel
    UpdatePanel();
    % Select last scout in list
    SetSelectedScouts(iScout);
    % Deselect "AddScout" button
    % (Only if creating new scout. If adding points to existing scouts, keep adding points)
    if isNewScout
        SetSelectionState(0);
    end
    % OverlayCube for 3D MRI display is not updated => Need to update it
    UpdateScoutsDisplay();
end


%% ===============================================================================
%  ====== SCOUTS CREATION/EDITION ================================================
%  ===============================================================================
%% ===== START NEW SCOUT / SURFACE =====
function StartNewScoutSurface()
    % Start edition of a new scout
    SetSelectionState(1);
end

%% ===== START NEW SCOUT / MRI =====
function StartNewScoutMri()
    % Open MRI scout editor (for creation)
    ScoutEditorInMri(-1);
end

%% ===== START NEW SCOUT / MAX =====
function StartNewScoutMax()
    SelectMaximumValue();
end

%% ===== SURFACE TILING =====
function SurfaceTiling()
    nClust = 30; %Number of surface tiles (clusters); % CBB: Prompt user
    VERBOSE = 1; % Turn on/off verbose of tiling process

    % Get cortex and anatomy surface handle
    [iSurf, TessInfo] = panel_surface('GetSurfaceCortexOrAnatomy'); %CBB: works with only one 3D figure being displayed
    infoProtocole = bst_getContext('ProtocolInfo');
    load(fullfile(infoProtocole.SUBJECTS,TessInfo.SurfaceFile),'VertConn');
    [CLASS, NumClass, nbre_zone] = cortex_cluster(VertConn,nClust,1:size(VertConn,1),1,VERBOSE);

    global GlobalData; 
    GlobalData = rmfield(GlobalData,'Scouts');
    for iNewScout=1:nbre_zone
        GlobalData.Scouts(iNewScout) = db_getDataTemplate('Scout');
        GlobalData.Scouts(iNewScout).Vertices = find(CLASS{1}==iNewScout);
        GlobalData.Scouts(iNewScout).Seed     = GlobalData.Scouts(iNewScout).Vertices(1);
        GlobalData.Scouts(iNewScout).SurfaceFile = TessInfo.SurfaceFile;
        GlobalData.Scouts(iNewScout).Label    = num2str(iNewScout);
        GlobalData.Scouts(iNewScout).Color = rand(1,3);
        PlotScout(iNewScout)
    end
    
    UpdateScoutsDisplay();
end


%% ===== EDIT EXISTING SCOUT / SURFACE =====
function EditExistingScoutSurface()
    % Get selected scouts
    [sSelScouts, iSelScouts] = GetSelectedScouts();
    % Warning message if no scout selected
    if isempty(sSelScouts)
        java_dialog('warning', 'No scout selected.', 'Edit existing scout');
        return;
    end
    % Start edition of a scout (will deselect the scout)
    SetSelectionState(1);
    % Select again the first selected scout
    SetSelectedScouts(iSelScouts(1));
end

%% ===== EDIT EXISTING SCOUT / MRI =====
function EditExistingScoutMri()
    % Get selected scouts
    [sScout, iScout] = GetSelectedScouts();
    % Warning message if no scout selected
    if isempty(sScout)
        java_dialog('warning', 'No scout selected.', 'Edit existing scout');
        return;
    % If more than one scout selected: keep only the first one
    elseif (length(sScout) > 1)
        sScout = sScout(1);
        iScout = iScout(1);
        SetSelectedScouts(iScout);
    end
    % Open MRI scout editor (for edition)
    ScoutEditorInMri(iScout);
end

%% ===== EDIT EXISTING SCOUT / MAX =====
function EditExistingScoutMax()
    % Get selected scouts
    [sScouts, iScouts] = GetSelectedScouts();
    % Warning message if no scout selected
    if isempty(sScouts)
        java_dialog('warning', 'No scout selected.', 'Find maximum value');
        return;
    end
    % Process all the selected scouts
    for i = 1:length(iScouts)
        SelectMaximumValue(iScouts(i));
    end
end


%% ===============================================================================
%  ====== SCOUTS OPERATIONS ======================================================
%  ===============================================================================
%% ===== PLOT ALL SCOUTS FOR CURRENT FIGURE =====
function PlotAllScouts() %#ok<DEFNU>
    [tmp__, iScouts] = GetCurrentScouts();
    for i=iScouts
        PlotScout(i);
    end
    UpdateScoutsDisplay();
end


%% ===== DISPLAY SCOUT =====
% Find all the figures where these scouts should be displayed, and plot them.
function PlotScout(iScout)
    global GlobalData;
    sScout = GlobalData.Scouts(iScout);
    % Get cortex file
    SurfaceFiles{1} = sScout.SurfaceFile;
    % Get anatomy file
    [sSubject, iSubject] = bst_getContext('SurfaceFile', SurfaceFiles{1});
    if ~isempty(sSubject) && ~isempty(sSubject.iAnatomy)
        SurfaceFiles{2} = sSubject.Anatomy(sSubject.iAnatomy).FileName;
    end
    % Get all the figures concerned with Scout cortex and MRI surface
    [hFigures, iFigures, iDataSets, iSurfaces] = gui_figuresManager('GetFigureWithSurface', SurfaceFiles);
    if isempty(hFigures)
        return
    end
    % Get Surface definition
    TessInfo = getappdata(hFigures(1), 'Surface');
    iSurface = iSurfaces(1);
    sSurface = TessInfo(iSurface);
    % Get Faces and Vertices list of target surface
    if strcmpi(sSurface.Name, 'Anatomy')
        sDbCortex   = bst_getContext('SurfaceFileByType', iSubject, 'Cortex');
        sSurfCortex = bst_dataSetsManager('LoadSurface', sDbCortex.FileName);
        Faces       = sSurfCortex.Faces;
        Vertices    = sSurfCortex.Vertices;
    else
        Faces    = get(sSurface.hPatch, 'Faces');
        Vertices = get(sSurface.hPatch, 'Vertices');
    end
        
    % Process all figures
    for hFig = hFigures
        % Get indice of the target figure in the sScout.Handles array
        iHnd = find([sScout.Handles.hFig] == hFig);
        % If figure is not referenced yet : add it
        if isempty(iHnd)
            iHnd = length(sScout.Handles) + 1;
            sScout.Handles(iHnd).hFig = hFig;
        end
        % Get axes handles 
        hAxes = findobj(hFig, 'tag', 'Axes3D');

        % === SCOUT 3D MARKER ===
        % Force scout location to be XYZ because scouts may be dispatched on a smoothed surface, 
        % i.e. with surface vertices being away from true locations
        MarkerLocation = double(Vertices(sScout.Seed, :));
        % Plot scout marker (if it does not exist yet)
        if isempty(sScout.Handles(iHnd).hScout) || ~ishandle(sScout.Handles(iHnd).hScout)
            sScout.Handles(iHnd).hScout = line(MarkerLocation(1), MarkerLocation(2), MarkerLocation(3), ...
                                'Marker',          'o', ...
                                'MarkerFaceColor', sScout.Color, ...
                                'MarkerEdgeColor', sScout.Color, ...
                                'MarkerSize',      5, ...
                                'Tag',             'ScoutMarker', ...
                                'Parent',          hAxes);
        % If scout marker already exist, just update its position
        else
            set(sScout.Handles(iHnd).hScout, 'XData', MarkerLocation(1), ...
                                             'YData', MarkerLocation(2), ...
                                             'ZData', MarkerLocation(3));
        end
        % Plot scout label (if it does not exist yet)
        if isempty(sScout.Handles(iHnd).hLabel) || ~ishandle(sScout.Handles(iHnd).hLabel)
            try
                sScout.Handles(iHnd).hLabel = text(1.1*MarkerLocation(1), 1.1*MarkerLocation(2), 1.1*MarkerLocation(3), ...
                                         sScout.Label, ...
                                         'Fontname',   'helvetica', ...
                                         'FontUnits',  'Point', ...
                                         'FontSize',   10, ...
                                         'FontWeight', 'normal', ...
                                         'Color',      [.9 1 .9], ...
                                         'HorizontalAlignment', 'center', ...
                                         'Tag',        'ScoutLabel', ...
                                         'Parent',     hAxes, ...
                                         'Interpreter','none');
            catch
                warning('Brainstorm:GraphicsError', 'Unknown error: could not display scout label.');
            end
        % If label is already displayed: just update its position
        else
            set(sScout.Handles(iHnd).hLabel, 'Position', 1.1 .* MarkerLocation);
        end
    
        % ===== SCOUT PATCH =====
        % === BUILD FACES/VERTICES ===
        % If there are more than one vertex available for the scout
        if (length(sScout.Vertices) > 1)
            % Get patch vertices
            patchVertices = Vertices(sScout.Vertices, :) * 1.00001;
            % Create a look-up table for the vertices indices
            vertTable = zeros(size(Vertices, 1), 1);
            vertTable(sScout.Vertices) = 1:length(sScout.Vertices);
            % Replace the vertices indices in the Faces list
            patchFaces = reshape(interp1(vertTable, Faces(:), 'nearest'), [], 3);
            iPatchFaces = (sum(patchFaces>0, 2) == 3);
            
            patchFaces = patchFaces(iPatchFaces, :);
%             % Compute scout area
%             sScout.Area = sum(sSurface.TriArea(iPatchFaces));
            sScout.Area = 0;
        else
            patchFaces = [];
            patchVertices = [];
            sScout.Area = 0;
        end
        
        % === DRAW VERTICES MARKERS === 
        if ~isempty(patchVertices)
            % Plot scout vertices (if graphic object does not exist yet)
            if isempty(sScout.Handles(iHnd).hVertices) || ~ishandle(sScout.Handles(iHnd).hVertices)
                sScout.Handles(iHnd).hVertices = line(patchVertices(:,1), patchVertices(:,2), patchVertices(:,3), ...
                                    'Marker',          '.', ...
                                    'MarkerFaceColor', sScout.Color, ...
                                    'MarkerEdgeColor', sScout.Color, ...
                                    'MarkerSize',      5, ...
                                    'LineStyle',       'none', ...
                                    'Tag',             'ScoutMarker', ...
                                    'Parent',          hAxes);
            else
                set(sScout.Handles(iHnd).hVertices, 'XData', patchVertices(:,1), ...
                                                    'YData', patchVertices(:,2), ...
                                                    'ZData', patchVertices(:,3));
            end
        else
            delete(sScout.Handles(iHnd).hVertices);
            sScout.Handles(iHnd).hVertices = [];
        end
        
        % === DRAW PATCH ===
        % If a patch is available (enough faces and vertices)
        if ~isempty(patchFaces) && ~isempty(patchVertices)
            % If patch does not exist yet : create it
            if isempty(sScout.Handles(iHnd).hPatch) || ~ishandle(sScout.Handles(iHnd).hPatch)
                sScout.Handles(iHnd).hPatch = patch('Faces',           patchFaces, ...
                                                    'Vertices',        patchVertices, ...
                                                    'FaceVertexCData', sScout.Color, ...
                                                    'FaceColor',       sScout.Color, ...
                                                    'EdgeColor',       sScout.Color,...
                                                    'FaceAlpha',       .3, ...
                                                    'BackFaceLighting','lit', ...
                                                    'Tag',             'ScoutPatch', ...
                                                    'Parent',          hAxes) ; 
            % Else : only update vertices and faces
            else
                set(sScout.Handles(iHnd).hPatch, 'Faces', patchFaces, 'Vertices', patchVertices);
            end
        % Else : Remove previous scout patch, if it existed
        elseif ishandle(sScout.Handles(iHnd).hPatch)
            delete(sScout.Handles(iHnd).hPatch);
            sScout.Handles(iHnd).hPatch = [];
        end
        
        % === ALSO UPDATE 3D MRI SLICES ===
%         gui_figure3DViz('UpdateOverlayCube', hFig, iSurface);
    end
    % Update scout defintion
    GlobalData.Scouts(iScout) = sScout;
end


%% ===== REMOVE SCOUTS FROM FIGURE =====
function RemoveScoutsFromFigure(hFig) %#ok<DEFNU>
    global GlobalData;
    % If removing scouts from a given figure
    for iScout = 1:length(GlobalData.Scouts)
        iHandles = 1;
        while (iHandles <= length(GlobalData.Scouts(iScout).Handles))
            if (GlobalData.Scouts(iScout).Handles(iHandles).hFig == hFig)
                GlobalData.Scouts(iScout).Handles(iHandles) = [];
            else
                iHandles = iHandles + 1;
            end
        end
    end
end

%% ===== REMOVE SCOUTS =====
% Usage : RemoveScouts(iScouts) : remove a list of scouts
%         RemoveScouts()        : remove the scouts selected in the JList 
function RemoveScouts(varargin)
    global GlobalData;
    % Stop scout edition
    SetSelectionState(0);
    % If scouts list is not defined
    if (nargin == 0)
        % Get selected scouts
        [sScouts, iScouts] = GetSelectedScouts();
        % Check whether a scout is selected
        if isempty(sScouts)
%             java_dialog('warning', 'No scout selected.', 'Remove scout');
            return
        end
    elseif (nargin == 1)
        iScouts = varargin{1};
        sScouts = GlobalData.Scouts(iScouts);
    else
        error('Invalid call to RemoveScouts.');
    end
    hAllFig = [];
    % Delete graphical objects
    for i = 1:length(sScouts)
        hAllFig = [hAllFig, [sScouts(i).Handles.hFig]];
        % Delete graphical scout markers
        hMarkers = [sScouts(i).Handles.hScout];
        delete(hMarkers(ishandle(hMarkers)));
        % Delete graphical scout labels
        hLabels = [sScouts(i).Handles.hLabel];
        delete(hLabels(ishandle(hLabels)));
        % Delete graphical scout patches
        hPatches = [sScouts(i).Handles.hPatch];
        delete(hPatches(ishandle(hPatches)));
        % Delete graphical scout vertices
        hVertices = [sScouts(i).Handles.hVertices];
        delete(hVertices(ishandle(hVertices)));
    end
    
    % Remove scouts definitions from global data structure
    GlobalData.Scouts(iScouts) = [];
    % Update "Scouts Manager" panel
    UpdateScoutsList();
    % Update MRI display in all figures
    panel_surface('UpdateOverlayCubes', unique(hAllFig));
end


%% ===== REMOVE SCOUTS VERTICES FROM SURFACE =====
function RemoveScoutFromSurface()
    % === GET VERTICES TO REMOVE ===
    % Get selected scouts
    [sScouts, iScouts] = GetSelectedScouts();
    % Check whether a scout is selected
    if isempty(sScouts)
        java_dialog('warning', 'No scout selected.', 'Remove scout');
        return
    end
    % Ask for user confirmation
    isConfirmed = java_dialog('confirm', ['Warning: This operation is going to alter permanently the surface.', 10 ...
                                          'If you have some results based on this surface, they will be unusable.' 10 10 ...
                                          'Remove vertices ?'], 'Remove scout vertices');
    if ~isConfirmed
        return
    end
    % Join scouts to get vertices to remove
    iRemoveVert = [sScouts.Vertices];
    % Get cortex file
    SurfaceFile = sScouts(1).SurfaceFile;
    
    % === DELETE ALL SCOUTS ===
    % Get all available scouts for this surface
    [sCurScouts, iCurScouts] = GetCurrentScouts();
    % Remove scouts
    RemoveScouts(iCurScouts);

    % === REMOVE VERTICES FROM SURFACE FILE ===
    % Get full surface file path
    ProtocolInfo = bst_getContext('ProtocolInfo');
    SurfaceFileFull = fullfile(ProtocolInfo.SUBJECTS, SurfaceFile);
    % Load surface file
    SurfaceMat = in_tess_bst(SurfaceFileFull);
    % Remove vertices
    [Vertices, Faces] = tess_removeVertices(SurfaceMat.Vertices, SurfaceMat.Faces, iRemoveVert);
    % Build new surface
    newSurfaceMat.Comment  = SurfaceMat.Comment;
    newSurfaceMat.Vertices = Vertices;
    newSurfaceMat.Faces    = Faces;
    % Save file back
    save(SurfaceFileFull, '-struct', 'newSurfaceMat');
    % Unload surface file
    bst_dataSetsManager('UnloadSurface', SurfaceFile);
    
    % === REMOVE VERTICES FROM FIGURES ===
    % Get all the figures concerned with Scout cortex and MRI surface
    [hFigures, iFigures, iDataSets, iSurfaces] = gui_figuresManager('GetFigureWithSurface', SurfaceFile);
    if isempty(hFigures)
        return
    end
    % Process all the figures
    for i = 1:length(hFigures)
        % Get surface definition
        TessInfo = getappdata(hFigures(i), 'Surface');
        surfaceFile = TessInfo(iSurfaces(i)).SurfaceFile;
        % Unload surface and load it again
        panel_surface('RemoveSurface', hFigures(i), iSurfaces(i));
        panel_surface('AddSurface', hFigures(i), surfaceFile);
    end
end

%% ===== REMOVE UNSUSED SCOUTS =====
function RemoveUnusedScouts() %#ok<DEFNU>
    global GlobalData;
    % Get list of all the subjects currently usefull
    UsefulSubjects = unique({GlobalData.DataSet.SubjectFile});
    % For each subject get the list list of useful surfaces
    UsefulSurfaces = {};
    for i = 1:length(UsefulSubjects)
        sSubject = bst_getContext('Subject', UsefulSubjects{i});
        if ~isempty(sSubject)
            UsefulSurfaces = cat(2, UsefulSurfaces, {sSubject.Surface.FileName});
        end
    end
    UsefulSurfaces = unique(UsefulSurfaces);
    
    % For each scout, check if associated cortex file is in the UsefulSurfaces array
    iScoutsToRemove = [];
    for iScout = 1:length(GlobalData.Scouts)
        if ~any(io_compareFileNames(GlobalData.Scouts(iScout).SurfaceFile, UsefulSurfaces))
            iScoutsToRemove(end + 1) = iScout;
        end
    end
    % Remove useless scouts 
    if ~isempty(iScoutsToRemove)
        RemoveScouts(iScoutsToRemove);
    end
end


%% ===== JOIN SCOUTS =====
% Join the scouts selected in the JList 
function JoinScouts()
    global GlobalData;
    % Stop scout edition
    SetSelectionState(0);
    % Get selected scouts
    [sScouts, iScouts] = GetSelectedScouts();
    % Need TWO scouts
    if (length(sScouts) < 2)
        java_dialog('warning', 'You need to select at least two scouts.', 'Join selected scouts');
        return;
    end

    % === Remove old scouts ===
    RemoveScouts(iScouts);
    % === Join scouts ===
    % Create new scout
    newScout = db_getDataTemplate('Scout');
    % Copy unmodified fields
    newScout.SurfaceFile = sScouts(1).SurfaceFile;
    newScout.Seed = sScouts(1).Seed;
    % Vertices : concatenation
    newScout.Vertices = unique([sScouts.Vertices]);
    % Label : "Label1 & Label2 & ..."
    newScout.Label = sScouts(1).Label;
    for i = 2:length(sScouts)
        newScout.Label = [newScout.Label ' & ' sScouts(i).Label];
    end

    % Add new scout to global structure
    iNewScout = length(GlobalData.Scouts) + 1;
    GlobalData.Scouts(iNewScout) = newScout;   
    % Display new scout
    PlotScout(iNewScout);
    % Update "Scouts Manager" panel
    UpdateScoutsList();   
    % Select last scout in list (new scout)
    SetSelectedScouts(iNewScout);
end


%% ===== EDIT SCOUT LABEL =====
% Rename one and only one selected scout
function EditScoutLabel()
    global GlobalData;
    % Stop scout edition
    SetSelectionState(0);
    % Get selected scouts
    [sScout, iScout] = GetSelectedScouts();
    % Warning message if no scout selected
    if isempty(sScout)
        java_dialog('warning', 'No scout selected.', 'Rename selected scout');
        return;
    % If more than one scout selected: keep only the first one
    elseif (length(sScout) > 1)
        iScout = iScout(1);
        sScout = sScout(1);
        SetSelectedScouts(iScout);
    end
    % Ask user for a new Scout Label
    newLabel = java_dialog('input', sprintf('Please enter a new label for scout "%s":', sScout.Label), ...
                             'Rename selected scout', [], sScout.Label);
    if isempty(newLabel) || strcmpi(newLabel, sScout.Label)
        return
    end
    % Update Scout definition
    GlobalData.Scouts(iScout).Label = newLabel;
    % Update graphical objects
    set([sScout.Handles.hLabel], 'String', newLabel);
    % Update JList
    UpdateScoutsList();
    % Select back selected scout
    SetSelectedScouts(iScout);
end


%% ===== EDIT SCOUTS SIZE =====
function EditScoutsSize(action)
    global GlobalData mutexGrowScout;
    % Stop scouts edition
    SetSelectionState(0);
    % Get "Scouts" panel controls
    ctrl = bst_getContext('PanelControls', 'Scout');
    % Use a mutex to prevent the function from being executed more than once at the same time
    if isempty(mutexGrowScout) || (mutexGrowScout > 1)
        % Entrance accepted
        tic
        mutexGrowScout = 0;
    else
        % Entrance rejected (another call is not finished,and was call less than 1 seconds ago)
        mutexGrowScout = toc;
        disp('Call to EditScoutsSize ignored...');
        return
    end
    
    % Get selected scouts
    [sScouts, iSelScouts] = GetSelectedScouts();
    % Can grow only scouts that are DISPLAYED IN AT LEAST ONE FIGURE
    if isempty(sScouts) || isempty(sScouts(1).Handles)
        return
    end
    % Get all current scouts
    [sScouts, iAllScouts] = GetCurrentScouts();
    % Get figure
    hFig = sScouts(1).Handles(1).hFig;
    % Get cortex and anatomy surface handle
    [iSurf, TessInfo] = panel_surface('GetSurfaceCortexOrAnatomy', hFig);

    % Process all the selected scouts
    for iScout = iSelScouts
        % Get cortex vertices
        sDbCortex   = bst_getContext('SurfaceFileByType', TessInfo(iSurf).SurfaceFile, 'Cortex');
        sSurfCortex = bst_dataSetsManager('LoadSurface', sDbCortex.FileName);
        % Get cortex patch vertices
        if strcmpi(TessInfo(iSurf).Name, 'Anatomy')
            patchVertices = sSurfCortex.Vertices;
        else
            patchVertices = get(TessInfo(iSurf).hPatch, 'Vertices');
        end
        % Get vertices of the scout (indices)
        vi = GlobalData.Scouts(iScout).Vertices;
        % Get coordinates of the seed
        seedXYZ = patchVertices(GlobalData.Scouts(iScout).Seed, :);
        % If constrained growth
        isContrained = ctrl.jToggleConstrained.isSelected();
        % Get vertices with values below the data threshold
        iUnderThresh = [];
        if isContrained
            if ~isempty( TessInfo(iSurf).Data )
                % iUnderThresh = find(abs(TessInfo(iSurf).Data) <= TessInfo(iSurf).DataThreshold * max(abs(TessInfo(iSurf).Data)));
                iUnderThresh = find(abs(TessInfo(iSurf).Data) <= TessInfo(iSurf).DataIntThreshold * max(abs(TessInfo(iSurf).DataMinMax)));
                % knd: to do: include DataExtThreshold
                %cluster_threshold
                iUnderThresh = [iUnderThresh ; ];
                
            end
        end
        
        % Now grow/shrink a patch around the selected probe by adding/removing a ring neighbors
        switch (action)
            case 'Grow'
                viNew = patch_swell(vi, sSurfCortex.VertConn);
                % Remove vertices under the threshold
                viNew = setdiff(viNew, iUnderThresh);
                if ~isempty(viNew)
                    % Get vertices of the scout (coordinates)
                    vXYZ = patchVertices(viNew, :);
                    % Compute the distance from each point to the seed
                    distFromSeed = sqrt((vXYZ(:,1)-seedXYZ(1)).^2 + (vXYZ(:,2)-seedXYZ(2)).^2 + (vXYZ(:,3)-seedXYZ(3)).^2);
                    % === LIMIT GROWTH WITH A SPHERE ===
                    % Radius of the sphere = mean(dist(v, seed)) + 1.5*std
                    sphereRadius = mean(distFromSeed) + 1.5 * std(distFromSeed);
                    % Keep only vertices in a sphere around the Scout seed
                    vi = union(vi, viNew(distFromSeed <= sphereRadius));
                end
            case 'Grow1'
                % Get closest neighbours
                viNew = setdiff(patch_swell(vi, sSurfCortex.VertConn), vi);
                % Remove vertices under the threshold
                viNew = setdiff(viNew, iUnderThresh);
                if ~isempty(viNew)
                    % Get new vertices of the scout (coordinates)
                    vXYZ = patchVertices(viNew, :);
                    % Compute the distance from each point to the seed
                    distFromSeed = sqrt((vXYZ(:,1)-seedXYZ(1)).^2 + (vXYZ(:,2)-seedXYZ(2)).^2 + (vXYZ(:,3)-seedXYZ(3)).^2);
                    % === ADD ONLY THE CLOSEST VERTEX ===
                    % Get the minimum distance
                    [minVal, iMin] = min(distFromSeed);
                    iMin = iMin(1);
                    % Add this vertex to scout vertices
                    vi = union(vi, viNew(iMin));
                end
                
            case 'Shrink1'
                % Remove a layer of connected vertices
                Expanded = patch_swell(vi, sSurfCortex.VertConn);
                viToRemove = patch_swell(Expanded, sSurfCortex.VertConn);
                viToRemove = intersect(viToRemove, vi);
                % Get vertices of the scout (coordinates)
                vXYZ = patchVertices(viToRemove, :);
                % Compute the distance from each point to the seed
                distFromSeed = sqrt((vXYZ(:,1)-seedXYZ(1)).^2 + (vXYZ(:,2)-seedXYZ(2)).^2 + (vXYZ(:,3)-seedXYZ(3)).^2);
                % === REMOVE ONLY THE FAREST VERTEX ===
                % Get the maximum distance
                [maxVal, iMax] = max(distFromSeed);
                iMax = iMax(1);
                % Remove this vertex from the scout vertices
                vi = setdiff(vi, viToRemove(iMax));
                
            case 'Shrink'
                % Remove a layer of connected vertices
                Expanded = patch_swell(vi, sSurfCortex.VertConn);
                viToRemove = patch_swell(Expanded, sSurfCortex.VertConn);
                % Get vertices of the scout (coordinates)
                vXYZ = patchVertices(vi, :);
                % Compute the distance from each point to the seed
                distFromSeed = sqrt((vXYZ(:,1)-seedXYZ(1)).^2 + (vXYZ(:,2)-seedXYZ(2)).^2 + (vXYZ(:,3)-seedXYZ(3)).^2);
                % === DEFINE SHRINK WITH A SPHERE ===
                % Radius of the sphere = mean(dist(v, seed)) + 1.5*std
                sphereRadius = mean(distFromSeed);
                % Keep only vertices in a sphere around the Scout seed
                viOutsideSphere = vi(distFromSeed > sphereRadius);
                % Remove only vertices that are removed by the two methods
                viToRemove = intersect(viToRemove, viOutsideSphere);
                vi = setdiff(vi, viToRemove);
        end
        
        % Remove vertices that are already in other scouts
        iOtherScouts = setdiff(iAllScouts, iScout);
        vi = setdiff(vi, [GlobalData.Scouts(iOtherScouts).Vertices]);
        
        % Save new list of vertices
        GlobalData.Scouts(iScout).Vertices = vi;       
        % If all the vertices were removed, keep initial scout vertex
        if isempty(GlobalData.Scouts(iScout).Vertices)
            GlobalData.Scouts(iScout).Vertices = GlobalData.Scouts(iScout).Seed;
        end
        % Display scout patch
        PlotScout(iScout);
    end

	% Release mutex 
    mutexGrowScout = [];
    % Update panel "Scouts" fields
    UpdateScoutProperties();
    % Display/hide scouts and update MRI overlay mask
    UpdateScoutsDisplay();
end


%% ===== EDIT SCOUTS COLOR =====
function EditScoutsColor(newColor)
    global GlobalData;
    % Get selected scouts
    [sSelScouts, iSelScouts] = GetSelectedScouts();
    if isempty(iSelScouts)
        java_dialog('warning', 'No scout selected.', 'Edit scout color');
        return
    end
    % If color is not specified in argument : ask it to user
    if (nargin < 1)
        % Use previous scout color
        newColor = uisetcolor(sSelScouts(1).Color, 'Select scout color');
        % If no color was selected: exit
        if (length(newColor) ~= 3) || all(sSelScouts(1).Color == newColor)
            return
        end
    end
    % Update scouts color
    for i = 1:length(iSelScouts)
        GlobalData.Scouts(iSelScouts(i)).Color = newColor;
        % Update color for all graphical instances
            % Seed
            set([sSelScouts(i).Handles.hScout], 'MarkerFaceColor', newColor, ...
                                                   'MarkerEdgeColor', newColor);
            % Patch
            set([sSelScouts(i).Handles.hPatch], 'FaceVertexCData', newColor, ...
                                                'FaceColor',       newColor, ...
                                                'EdgeColor',       newColor);
            % Vertices
            set([sSelScouts(i).Handles.hVertices], 'MarkerFaceColor', newColor, ...
                                                   'MarkerEdgeColor', newColor);                      
    end
end

%% ===== REDRAW SCOUTS =====
% Update vertices of scouts for a given surface
function UpdateScoutsVertices(SurfaceFile) %#ok<DEFNU>
    global GlobalData;
    % Get scouts to update
    iScoutsToUpdate = find(io_compareFileNames({GlobalData.Scouts.SurfaceFile}, SurfaceFile) & ~cellfun(@isempty, {GlobalData.Scouts.Handles}));
    if isempty(iScoutsToUpdate) || isempty(GlobalData.Scouts(iScoutsToUpdate(1)).Handles)
        return;
    end
    % Get surface information in figure appdata
    TessInfo = getappdata(GlobalData.Scouts(iScoutsToUpdate(1)).Handles(1).hFig, 'Surface');
    iSurface = find(io_compareFileNames({TessInfo.SurfaceFile}, SurfaceFile));
    if isempty(iSurface)
        return;
    end
    % Get displayed vertices of surface
    Vertices = get(TessInfo(iSurface).hPatch, 'Vertices');

    % Update vertices of all scouts
    for iScout = iScoutsToUpdate
        sScout = GlobalData.Scouts(iScout);
        % Update vertices for all graphical instances
        for ihand = 1:length(sScout.Handles)
            % Scout seed
            set(sScout.Handles(ihand).hScout,    'XData', Vertices(sScout.Seed, 1), ...
                                                 'YData', Vertices(sScout.Seed, 2), ...
                                                 'ZData', Vertices(sScout.Seed, 3));
            % Scout vertices
            set(sScout.Handles(ihand).hVertices, 'XData', Vertices(sScout.Vertices, 1), ...
                                                 'YData', Vertices(sScout.Vertices, 2), ...
                                                 'ZData', Vertices(sScout.Vertices, 3));
            % Scout label
            set(sScout.Handles(ihand).hLabel, 'Position', 1.1 * Vertices(sScout.Seed, :));
            % Scout patch
            set(sScout.Handles(ihand).hPatch, 'Vertices', Vertices(sScout.Vertices, :));
        end
    end
end


%% ===== UPDATE SCOUTS DISPLAY =====
% Display/hide scouts.
function UpdateScoutsDisplay()
    % Get current scouts
    [sScouts, iScouts] = GetCurrentScouts();
    % Get "Scouts" panel controls
    ctrl = bst_getContext('PanelControls', 'Scout');
    % View mode : VIEW SELECTED SCOUTS
    if isViewOnlySelectedScouts()
        % Get selected scouts
        [sSelScouts, iSelScouts] = GetSelectedScouts();
        % Get JList selected indices
        iVisibleScouts = [];
        for i = 1:length(iSelScouts)
            iVisibleScouts = [iVisibleScouts, find(iScouts == iSelScouts(i))];
        end
%         iVisibleScouts = iSelScouts;
%         iHiddenScouts = setdiff(1:length(iScouts), iVisibleScouts);
    % View mode : VIEW ALL SCOUTS
    else
        % All scouts are visible
        iVisibleScouts = 1:length(iScouts);
%         iHiddenScouts  = [];
    end
    hAllFig = [];
    % Check if 
    isDisplayIfOnlyAnatomy = ctrl.jCheckViewPatchesInMri.isSelected();
    % Loop on all scouts
    for i = 1:length(iScouts)
        % Is this scout supposed to be visible
        isVisibleGlobal = ismember(i, iVisibleScouts);
        % Process each figure in which this scout is accessible
        for iFig = 1:length(sScouts(i).Handles)
            hFig = sScouts(i).Handles(iFig).hFig;
            isVisibleLocal = isVisibleGlobal;
            % === IS SCOUT VISIBLE ? ===
            % If scout is visible according to selection, but should be hidden if there is only an anatomy surface
            if isVisibleGlobal && ~isDisplayIfOnlyAnatomy
                % Find cortex and anatomy surfaces
                iCortex  = panel_surface('GetSurfaceCortex', hFig);
                iAnatomy = panel_surface('GetSurfaceMri', hFig);
                % If only anatomy is accessible : hide scout
                if isempty(iCortex) && ~isempty(iAnatomy)
                    isVisibleLocal = 0;
                end
            end
            % === SET THE VISIBILITIES ===
            hGlobal = [sScouts(i).Handles(iFig).hScout, sScouts(i).Handles(iFig).hLabel];
            hLocal  = [sScouts(i).Handles(iFig).hPatch, sScouts(i).Handles(iFig).hVertices];
            % Set the visibility of all the scout elements
            if ~isempty(hGlobal)
                if isVisibleGlobal
                    set(hGlobal, 'Visible', 'on');
                else
                    set(hGlobal, 'Visible', 'off');
                end
            end
            if ~isempty(hLocal)
                if isVisibleLocal
                    set(hLocal, 'Visible', 'on');
                else
                    set(hLocal, 'Visible', 'off');
                end
            end
            % Add figure to the list of updated figures
            hAllFig = [hAllFig, hFig];
        end
    end
 
    % Add the list of the MriViewer figures
    hFigMriViewer = gui_figuresManager('GetFiguresByType', 'MriViewer');
    % List of all the figures that have proper scouts drawn in them
    hAllFig = unique([hFigMriViewer, hAllFig]);
    % Update overlay mask (for 3D MRI slices) for each figure
    panel_surface('UpdateOverlayCubes', hAllFig);
end



%% ===== SAVE SCOUT =====
function SaveScouts()
    global GlobalData;
    % Stop scout edition
    SetSelectionState(0);
    % Get protocol description
    ProtocolInfo = bst_getContext('ProtocolInfo');
    % Get selected scouts
    sScouts = GetSelectedScouts();
    if isempty(sScouts)
        return
    end
    % Build a default file name
    ScoutFile = fullfile(ProtocolInfo.SUBJECTS, fileparts(GlobalData.CurrentScoutsSurface), ...
                         ['scout', sprintf('_%s', sScouts.Label), '.mat']);
    % Get filename where to store the filename
    ScoutFile = java_fileSelector( 'save', 'Save selected scouts', ScoutFile, ... 
                                   'single', 'files', ...
                                   {{'_scout'}, 'Brainstorm cortical scouts (*scout*.mat)', 'BST'}, 1);
    if isempty(ScoutFile)
        return;
    end
    % Make sure that filename contains the 'scout' tag
    if isempty(strfind(ScoutFile, '_scout')) && isempty(strfind(ScoutFile, 'scout_'))
        [filePath, fileBase, fileExt] = fileparts(ScoutFile);
        ScoutFile = fullfile(filePath, ['scout_' fileBase fileExt]);
    end
    
    % Load tesselation vertices (just to get nb vertices)
    SurfaceFile = strrep(sScouts(1).SurfaceFile, ProtocolInfo.SUBJECTS, '');
    sSurf = bst_dataSetsManager('LoadSurface', SurfaceFile);
    % Prepare saved structure
    ScoutMat.Tesselation    = io_win2unix(SurfaceFile);
    ScoutMat.TessNbVertices = length(sSurf.Vertices);
    for i=1:length(sScouts)
        ScoutMat.Scout(i).Vertices = sScouts(i).Vertices;
        ScoutMat.Scout(i).Seed     = sScouts(i).Seed;
        ScoutMat.Scout(i).Label    = sScouts(i).Label;
        ScoutMat.Scout(i).Color    = sScouts(i).Color;
    end
    % Save file
    save(ScoutFile, '-struct', 'ScoutMat');
end


%% ===== LOAD SCOUT =====
function LoadScouts()
    global GlobalData;
    % === SELECT FILE TO LOAD ===
    % Stop scout edition
    SetSelectionState(0);
    % Get protocol description
    ProtocolInfo = bst_getContext('ProtocolInfo');
    % Build default scouts directory
    if ~isempty(GlobalData.CurrentScoutsSurface)
        scoutsSubDir = fileparts(GlobalData.CurrentScoutsSurface);
    else
        % Get current subject directory
        sSubject = bst_getContext('Subject');
        % If no current subject (no recordings were loaded yet)
        curFig = gui_figuresManager('GetCurrentFigure', '3D');
        if isempty(sSubject) && ~isempty(curFig)
            % Get subject of current figure 
            SubjectFile = getappdata(curFig, 'SubjectFile');
            if ~isempty(SubjectFile)
                sSubject = bst_getContext('Subject', SubjectFile);
            end
        end
        if isempty(sSubject)
            return;
        end
        scoutsSubDir = fileparts(sSubject.FileName);
    end
    scoutsDir = fullfile(ProtocolInfo.SUBJECTS, scoutsSubDir);
    % Ask user which are the files to be loaded
    ScoutFiles = java_fileSelector( 'open', 'Import scouts', scoutsDir, ... 
                                    'multiple', 'files', ...
                                    {{'_scout'},      'Cortical scouts (*scout*.mat)', 'BST'}, 1);
    if isempty(ScoutFiles)
        return
    end
    
    % ==== CREATE AND DISPLAY ====
    iNewScoutsList = [];
    bst_progressBar('start', 'Load scouts', 'Load scout file');
    % Load all files selected by user
    for iFile = 1:length(ScoutFiles)
        % Try to load scout file
        ScoutMat = load(ScoutFiles{iFile});
        
        % === INTEGRATION WITH CURRENT DATA ===
        % Find an existing figure with the same number of vertices
        [hFig,iFig,iDS,iSurf] = gui_figuresManager('GetFigureWithSurfaceNbVert', ScoutMat.TessNbVertices);
        % If no figure found: import scouts ignoring figures and currently loaded data
        if isempty(hFig)
            iFound = [];
        elseif (length(hFig) == 1)
            iFound = 1;
        % If there are more than one figure
        elseif (length(hFig) > 1)
            % Get current figure
            hCurFig = gui_figuresManager('GetCurrentFigure', '3D');
            % Find current figure in valid candidates for loaded scout
            iFound = find(hFig == hCurFig, 1);
            % If current figure is found: use it, else use first figure in the list
            if isempty(iFound)
                iFound = 1;
            end            
            hFig  = hFig(iFound);
            iSurf = iSurf(iFound);
        end
        % Replace scout tess field with the surface we've just found
        if ~isempty(iFound)
            TessInfo = getappdata(hFig, 'Surface');
            if strcmpi(TessInfo(iSurf).Name, 'Anatomy')
                sSurfCortex = bst_getContext('SurfaceFileByType', TessInfo(iSurf).SurfaceFile, 'Cortex');
                ScoutMat.Tesselation = sSurfCortex.FileName;
            else
                ScoutMat.Tesselation = TessInfo(iSurf).SurfaceFile;
            end
        end
        
        % === AUTO-CORRECT TESSELATION FIELD ===
        % If Figure not found && Tesselation pointed by the Scout does not exist
        if isempty(iFound) && ~exist(fullfile(ProtocolInfo.SUBJECTS, ScoutMat.Tesselation), 'file')
            CorrectedTess = '';
            bst_progressBar('start', 'Load scouts', 'Finding a valid cortex surface...');
            % If NbVertices is not defined: cannot find file
            if isfield(ScoutMat, 'TessNbVertices') && ~isempty(ScoutMat.TessNbVertices)
                % Look for a tesselation file with the same number of vertices in the scout directory
                dirTess = fileparts(ScoutFiles{iFile});
                listTessFiles = dir(fullfile(dirTess, '*tess*.mat'));
                % Load each tess file and check the number of vertices
                for iTess = 1:length(listTessFiles)
                    TessMat = in_tess_bst(fullfile(dirTess, listTessFiles(iTess).name));
                    % If number of vertices is correct: keep this tess file
                    if (length(TessMat.Vertices) == ScoutMat.TessNbVertices)
                        CorrectedTess = fullfile(fileparts(ScoutFiles{iFile}), listTessFiles(iTess).name);
                        break
                    end
                end
            end
            % If a replacing surface was found: save it
            if ~isempty(CorrectedTess)
                ScoutMat.Tesselation = strrep(CorrectedTess, ProtocolInfo.SUBJECTS, '');
                save(ScoutFiles{iFile}, '-struct', 'ScoutMat');
            % Else, no replacing surface was found: error
            else
                error(['This scout file need surface file "' ScoutMat.Tesselation '",' 10 ...
                       'which cannot be found in anatomy directory.' 10 10 ...
                       'Please check the Tesselation field of the scout file.']);
            end
        end
        
        % === CREATE ALL SCOUT PATCHES ===
        bst_progressBar('start', 'Load scouts', 'Create scouts patches...');
        try
            % Each scout file may contain many scouts definitions
            for i = 1:length(ScoutMat.Scout)
                if ~isempty(ScoutMat.Scout(i).Seed)
                    % Create new scout
                    iNewScout = length(GlobalData.Scouts) + 1;
                    iNewScoutsList = [iNewScoutsList, iNewScout];
                    GlobalData.Scouts(iNewScout) = db_getDataTemplate('Scout');
                    % Copy needed fields
                    GlobalData.Scouts(iNewScout).SurfaceFile = ScoutMat.Tesselation;
                    GlobalData.Scouts(iNewScout).Vertices = ScoutMat.Scout(i).Vertices;
                    GlobalData.Scouts(iNewScout).Seed     = ScoutMat.Scout(i).Seed;
                    GlobalData.Scouts(iNewScout).Label    = ScoutMat.Scout(i).Label;
                    if isfield(ScoutMat.Scout(i), 'Color')
                        GlobalData.Scouts(iNewScout).Color = ScoutMat.Scout(i).Color;
                    else
                        GlobalData.Scouts(iNewScout).Color = [0 1 0];
                    end
                    % Display scout
                    PlotScout(iNewScout);
                end
            end
            % Update display (call only useful for 3D MRI slices)
            UpdateScoutsDisplay();
        catch
            warning('Brainstorm:BadScoutFile', 'Unable to load scout file : "%s".', ScoutFiles{iFile});
        end
    end
    
    % ===== CHECK CURRENT SURFACE =====
    % If current scouts surface is not defined, use the first scout surface
    if isempty(GlobalData.CurrentScoutsSurface)
        GlobalData.CurrentScoutsSurface = GlobalData.Scouts(iNewScoutsList(1)).SurfaceFile;
    end
    
    % ===== UPDATE PANEL =====
    % Update "Scouts" panel
    if (length(iNewScoutsList) > 10)
        % Many scouts: select and display only the first one
        ctrl = bst_getContext('PanelControls', 'Scout');
        ctrl.jRadioScoutViewSelected.setSelected(1);
        UpdatePanel();
        SetSelectedScouts(iNewScoutsList(1));
    elseif ~isempty(iNewScoutsList)
        % Only few scouts : select and display all 
        UpdatePanel();
        SetSelectedScouts(iNewScoutsList);
    end
    bst_progressBar('stop');
end


%% ===== FORWARD MODEL FOR SCOUTS =====
% Simulate the surface data that could be recorded if only the selected scouts were activated
function ForwardModelForScout()
    global GlobalData;
    ProtocolInfo = bst_getContext('ProtocolInfo');
    % Stop scout edition
    SetSelectionState(0);
    % ===== GET ALL ACCESSIBLE DATA =====
    % Get selected figure
    hFig = gui_figuresManager('GetCurrentFigure', '3D');
    if isempty(hFig) || ~ishandle(hFig) || isempty(getappdata(hFig, 'ResultsFile'))
        return
    end
    % Get ResultsFile and Surface
    ResultsFile = getappdata(hFig, 'ResultsFile');
    
    % Get selected scouts
    sScouts = GetSelectedScouts();
    % Some scouts were found : get their vertices
    if ~isempty(sScouts) && ~isempty(sScouts(1).Handles)
        % Get all source vertices to perform simulation
        iVertices = unique([sScouts.Vertices]);
    % No scouts: use all vertices to do simulation
    else
        iVertices = [];
    end
    
    % ===== LOAD GAIN MATRIX =====
    % Get study
    [sStudy, iStudy, iResult] = bst_getContext('ResultsFile', ResultsFile);
    % Get headmodel
    sHeadModel = bst_getContext('HeadModelForStudy', iStudy);
    if isempty(sHeadModel)
        error('No headmodel available for this study.');
    end
    % Load HeadModel file
    HeadModelMat = load(fullfile(ProtocolInfo.STUDIES, sHeadModel.FileName), 'Gain');
    if isempty(HeadModelMat)
        error('Invalid headmodel.');
    end
    % Get gain file
    if ischar(HeadModelMat.Gain{1})
        % Read gain matrix
        gainfile = fullfile(ProtocolInfo.STUDIES, fileparts(sHeadModel.FileName), HeadModelMat.Gain{1});
        G = read_gain(gainfile);
    elseif isnumeric(HeadModelMat.Gain{1})
        G = HeadModelMat.Gain{1};
    end
    % If no vertices selected yet: use all
    if isempty(iVertices)
        iVertices = 1:size(G, 2);
    end
    % Keep only the vertices we want to project on surface
    G = G(:,iVertices);
    
    % ===== GET RESULTS MATRIX =====
    % Load results matrix
    [iDS, iResult] = bst_dataSetsManager('LoadResultsFileFull', ResultsFile);
    if isempty(iDS)
        return
    end
    % Progress bar
    bst_progressBar('start', 'Simulation', 'Simulation of surface recordings...');
    % Get sources matrix
    ResultsValues = bst_dataSetsManager('GetResultsValues', iDS, iResult, iVertices, 'UserTimeWindow');
    % Get ChannelFlag
    ChannelFlag = GlobalData.DataSet(iDS).Results(iResult).ChannelFlag;
    % Build time vector
    timeWnd = round(10000 * GlobalData.DataSet(iDS).Measures.Time) / 10000;
    smpRate = round(10000 * GlobalData.DataSet(iDS).Measures.SamplingRate) / 10000;
    TimeVector = timeWnd(1) : smpRate : timeWnd(2);
    
    % ===== BUILD SIMULATED DATA FILE =====
    % Get a string to represent time
    c = clock;
    strTime = sprintf('%02.0f%02.0f%02.0f_%02.0f%02.0f', c(1)-2000, c(2:5));
    % Get a string to represent scouts
    strScouts = '';
    if ~isempty(sScouts)
        if (length(sScouts) > 1)
            strScouts = '(';
        end
        for i=1:length(sScouts)
            strScouts = [strScouts, sScouts(i).Label, ','];
        end
        if (length(sScouts) > 1)
            strScouts(end) = ')';
        else
            strScouts(end) = [];
        end
        strScouts = [strScouts, '@'];
    end
    
    % Build data file
    DataMat = struct('Comment',     ['Simulation: ' strScouts sStudy.Result(iResult).Comment ' (' strTime ')'], ...
                     'Time',        TimeVector, ...
                     'F',           G * ResultsValues, ...
                     'ChannelFlag', ChannelFlag);

    % Output file
    newDataFile = fullfile(ProtocolInfo.STUDIES, fileparts(ResultsFile), ...
                           ['data_simulation_', strTime, '.mat']);
    newDataFile = io_makeUniqueFilename(newDataFile);
    % Save file
    save(newDataFile, '-struct', 'DataMat');
    % Hide progress bar 
    bst_progressBar('stop');
    
    % ===== UPDATE DATABASE =====
    % Build data structure
    sData = db_getDataTemplate('Data');
    sData.FileName = strrep(newDataFile, ProtocolInfo.STUDIES, '');
    sData.Comment  = DataMat.Comment;
    % Add it to study
    sStudy.Data(end + 1) = sData;
    bst_setContext('Study', iStudy, sStudy);
    % Update display
    tree_updateNode('Study', iStudy);
    % Select node
    tree_selectStudyNode(iStudy);
end


%% ===== VIEW SCOUT IN MRI =====
function ViewInMriViewer()
    % Stop scout edition
    SetSelectionState(0);
    % Get protocol description
    ProtocolInfo = bst_getContext('ProtocolInfo');
    % Get selected scouts
    [sScouts, iScouts] = GetSelectedScouts();
    if isempty(sScouts)
        java_dialog('warning', 'No scout selected.', 'View scout in MRI.');
        return
    elseif (length(sScouts) > 1)
        % More than one scout selected: select only the first one
        sScouts = sScouts(1);
        iScouts = iScouts(1);
        SetSelectedScouts(iScouts(1));
    end
    % Get the subject associated with the first selected scout
    sSubject = bst_getContext('SurfaceFile', sScouts.SurfaceFile);
    % Get the anatomy file for this subject
    if isempty(sSubject) || isempty(sSubject.iAnatomy)
        error('No MRI defined for this subject');
    end
    MriFile = fullfile(ProtocolInfo.SUBJECTS, sSubject.Anatomy(sSubject.iAnatomy).FileName);
    % Build full surface path
    SurfaceFile = fullfile(ProtocolInfo.SUBJECTS, sScouts.SurfaceFile);
    
    % Configure view to display only the scouts in MRI
    ctrl = bst_getContext('PanelControls', 'Scout');
    ctrl.jCheckLimitMriSources.setSelected(1);
        
    % Progress bar
    bst_progressBar('Start', 'MRI Viewer', 'Opening MRI Viewer...');
    % Display subject's anatomy in MRI Viewer
    hFig = gui_viewMri(MriFile, SurfaceFile, 'ReadOnly');
    % Close progress bar
    bst_progressBar('Stop');
    % Center view on first scout
    CenterMriOnScout();
end


%% ===== VIEW SCOUT ON CORTEX =====
function ViewOnCortex()
    % === Get selected scout ===
    [sScouts, iScouts] = GetSelectedScouts();
    if isempty(sScouts)
        java_dialog('warning', 'No scout selected.', 'View scout on cortex.');
        return
    elseif (length(sScouts) > 1)
        % More than one scout selected: select only the first one
        sScouts = sScouts(1);
        iScouts = iScouts(1);
        SetSelectedScouts(iScouts(1));
    end
    % === Display associated surface ===
    gui_viewSurfaceFile(sScouts.SurfaceFile);
end


%% ===== EDIT SCOUT IN MRI =====
function iScout = ScoutEditorInMri(iScout)
    global GlobalData;
    % Stop scout edition
    SetSelectionState(0);
    % === GET SCOUT ===
    % Create new scout or edit existing one
    isNewScout = isempty(iScout) || (iScout <= 0);
    % Get existing scout
    if ~isNewScout
        sScout = GetScouts(iScout);
        if isempty(sScout)
            isNewScout = 1;
        end
    end

    % === GET FIGURE AND SURFACE ===
    % If a scout already exists: use its surface
    if ~isNewScout
        % Get surface for this scout
        SurfaceFile = sScout.SurfaceFile;
        % Get subject for this surface
        [sSubject, iSubject] = bst_getContext('SurfaceFile', SurfaceFile);
    % Else use current figure/surface
    else
        % Get current 3d figure
        [hFig,iFig,iDS] = gui_figuresManager('GetCurrentFigure', '3D');
        % Get cortical surface
        [iSurf, TessInfo] = panel_surface('GetSurfaceCortexOrAnatomy');
        if isempty(iSurf)
            % Display warning message
            java_dialog('warning', 'No cortex surface available.', 'Edit scout in MRI');
            return
        end
        % Build surface filename
        if strcmpi(TessInfo(iSurf).Name, 'Anatomy')
            % If anatomy surface : use correspondant cortex surface instead
            sSurfCortex = bst_getContext('SurfaceFileByType', TessInfo(iSurf).SurfaceFile, 'Cortex');
            SurfaceFile = sSurfCortex.FileName;
        else
            SurfaceFile = TessInfo(iSurf).SurfaceFile;
        end
        % Get subject for this figure
        [sSubject, iSubject] = bst_getContext('Subject', GlobalData.DataSet(iDS).SubjectFile);
    end

    % === LOAD MRI AND SURFACE ===
    % Get the anatomy file for this subject
    if isempty(sSubject) || isempty(sSubject.iAnatomy)
        error('No MRI defined for this subject');
    end
    % Progress bar
    bst_progressBar('start', 'Edit mask', 'Initialization...');
    % Load Mri
    sMri = bst_dataSetsManager('LoadMri', iSubject);
    % Load Vertices from Surface
    [sSurf, iSurf] = bst_dataSetsManager('LoadSurface', SurfaceFile);
    % Get interpolation matrix MRI<->Surface
    tess2mri_interp = bst_dataSetsManager('GetTess2MriInterp', iSurf);
    % Compute the position of the vertices in MRI coordinates
    mriVertices = scs2mri(sMri, sSurf.Vertices' * 1000) ./ repmat(sMri.Voxsize', 1, length(sSurf.Vertices));

    % === BUILD INITIAL MASK ===
    % If scout already exist, generate a mask for it
    if ~isNewScout
        % Get vertices to display
        iVertices = sScout.Vertices;
        % Display only specified vertices
        [iMri,iVert] = find(tess2mri_interp(:,iVertices));
        Values = round(sum(tess2mri_interp(:,iVertices),2) * 255);
        Indices = unique(iMri);
        Values = full(Values(Indices));
        
        % Apply a threshold to the values
        iUnderThreshold = (Values < 0.5 * 255);
        Values(iUnderThreshold) = [];
        Indices(iUnderThreshold) = [];
        
        % Create mask volume (same size than the MRI)
        initMask = zeros(size(sMri.Cube), 'uint8');
        % Set values in the cube
        initMask(Indices) = Values;
    else
        % No scout: empty initial mask
        initMask = [];
    end
 
    % === INITIAL POSITION ===
    % If scout already exist,
    if ~isNewScout
        % Orientation: Display in axial slices
        initPosition(1) = 3;
        % Position: mean of the scout vertices
        initPosition(2) = round(mean(mriVertices(initPosition(1), sScout.Vertices)));
    else
        % No scout: Default display
        initPosition = [];
    end
       
    % === COLORMAP ===
    % Get colormap
    sColormap = bst_colormaps('GetColormap', 'Anatomy');
    
    % === EDIT MASK ===
    % Open mask editor
    newMask = mri_editMask(sMri.Cube, sMri.Voxsize, initMask, initPosition, sColormap.Name);
    if isempty(newMask)
        return
    end
    % Dilatation of the mask
    newMask = vol_dilate(newMask, 6);
    % Mask was modified: find the vertices inside the new mask
    rVertices = round(mriVertices);
    iVerticesInMri = sub2ind(size(sMri.Cube), rVertices(1,:), rVertices(2,:), rVertices(3,:));
    % Find the vertices inside the mask
    iVerticesInMask = find(newMask(iVerticesInMri));
    % If no vertices : cannot define a scout
    if isempty(iVerticesInMask)
        error(['The mask you designed does not contain any surface vertices.' 10 'It cannot be used to create a scout']);
    end
    
    % === OUTPUT SCOUT ===
    % Create new scout
    if isNewScout
        [sScout, iScout] = CreateNewScout(SurfaceFile, iVerticesInMask, iVerticesInMask(1));
    % Update vertices
    else
        sScout.Vertices = iVerticesInMask;
        % If seed is not anymore inside the scout : use the first vertex available
        if ~ismember(sScout.Seed, sScout.Vertices)
            sScout.Seed = sScout.Vertices(1);
        end
    end
    % Save updated scout
    GlobalData.Scouts(iScout) = sScout;
    % Update scout display
    PlotScout(iScout);
    % Update display or Scouts properties
    UpdatePanel();
    % Stop scout edition
    SetSelectionState(0);
    % Select new scout
    SetSelectedScouts(iScout);
    % Close progress bar
    bst_progressBar('Stop');
end


%% ===== CENTER MRI ON SCOUT =====
function CenterMriOnScout()
    % === GET SELECTED SCOUT ===
    % Get selected scouts
    [sScout, iScout] = GetSelectedScouts();
    if isempty(sScout)
        java_dialog('warning', 'No scout selected.', 'Center MRI on scout');
        return
    elseif (length(sScout) > 1)
        % More than one scout selected: select only the first one
        sScout = sScout(1);
        iScout = iScout(1);
        SetSelectedScouts(iScout);
    end
    % === GET FIGURE ===
    % Get current 3D figure
    hFig = gui_figuresManager('GetCurrentFigure', '3D');
    if isempty(hFig)
        java_dialog('warning', 'No 3D figure.', 'Center MRI on scout');
        return
    end
    % Get figure type
    FigureId = getappdata(hFig, 'FigureId');
    % Get anatomy surface
    [sMri, TessInfo, iAnatomy] = panel_surface('GetSurfaceMri', hFig);   
    if isempty(iAnatomy)
        java_dialog('warning', 'No MRI displayed in current figure.', 'Center MRI on scout');
        return
    end
    % === CENTER MRI VIEW ===
    % Get MRI structure
    sMri = bst_dataSetsManager('GetMri', TessInfo(iAnatomy).SurfaceFile);
    % Get cortex surface
    sDbCortex   = bst_getContext('SurfaceFileByType', TessInfo(iAnatomy).SurfaceFile, 'Cortex');
    sSurfCortex = bst_dataSetsManager('LoadSurface', sDbCortex.FileName);
    % Get new slices coordinates
    newPosScs = sSurfCortex.Vertices(sScout.Seed,:);
    newPosMri = scs2mri(sMri, newPosScs' * 1000)' ./ sMri.Voxsize;
    % If figure is a MRIViewer
    switch (FigureId.Type)
        case 'MriViewer'
            gui_figureMriViewer('SetLocation', 'mri', hFig, [], newPosMri);
        case '3DViz'
            TessInfo(iAnatomy).CutsPosition = round(newPosMri);
            gui_figure3DViz('UpdateMriDisplay', hFig, [1 2 3], TessInfo, iAnatomy);
    end
end


%% ===== EXPAND WITH CORRELATION =====
function ExpandWithCorrelation()
    global GlobalData;
    % Stop scout edition
    SetSelectionState(0);
    % ===== GET ALL NEEDED INFO =====
    % Get selected scouts
    [sScout, iScout] = GetSelectedScouts();
    if isempty(sScout)
        java_dialog('warning', 'No scout selected.', 'Expand scout using correlation');
        return
    elseif (length(sScout) > 1)
        % More than one scout selected: select only the first one
        sScout = sScout(1);
        iScout = iScout(1);
        SetSelectedScouts(iScout);
    end

    % Get selected figure
    hFig = gui_figuresManager('GetCurrentFigure', '3D');
    if isempty(hFig)
        return
    end
    % Get results file
    ResultsFile = getappdata(hFig, 'ResultsFile');
    if isempty(ResultsFile)
        bst_error('No sources displayed in this figure.', 'Expand with correlation', 0);
        return
    end
    
    % ===== THRESHOLD =====
    % For selected scout, find sources that are strongly correlated
    Threshold = 0.95;
    % Ask confirmation of the thresolh level to the user
    res = java_dialog('input', 'Thresold value for correlation', 'Sources correlation', [], num2str(Threshold));
    if isempty(res)
        return;
    end
    Threshold = str2num(res);
    if isempty(Threshold)
        return;
    end
    
    % ===== LOAD RESULTS =====
    % Progress bar
    bst_progressBar('start', 'Sources correlation', 'Loading results...');
    % Load results file 
    [iDS, iResult] = bst_dataSetsManager('LoadResultsFileFull', ResultsFile);
    % If no DataSet is accessible : error
    if isempty(iDS)
        warning(['Cannot load file : "', ResultsFile, '"']);
        return
    end
    % Get results values over the current time window
    ResultsValues = bst_dataSetsManager('GetResultsValues', iDS, iResult, [], 'UserTimeWindow');

    % ===== CORRELATION BETWEEN SOURCES =====
    % Progress bar
    nbSources = size(ResultsValues,1);
    blockSize = round(nbSources / 100);
    bst_progressBar('start', 'Sources correlation', 'Computing correlation...', 0, 100);
    % Remove all vertices from initial scout
    corrVertices = zeros(1,nbSources);
    corrVertices(sScout.Seed) = 1;
    % Process each vertex
    for iVert = 1:nbSources
        if (mod(iVert, blockSize) == 0)
            bst_progressBar('inc', 1);
        end
        if (iVert == sScout.Seed)
            continue
        end
        corr = corrcoef(ResultsValues([sScout.Seed iVert],:)');
        if (abs(corr(2,1)) > Threshold)
            corrVertices(iVert) = 1;
        end
    end
    % Final list of scouts
    sScout.Vertices = find(corrVertices);
            
    % ===== DISPLAY =====
    % Update scout
    GlobalData.Scouts(iScout) = sScout;       
    % Display scout patch
    PlotScout(iScout);
    % Update panel "Scouts" fields
    UpdateScoutProperties();
    % Display/hide scouts and update MRI overlay mask
    UpdateScoutsDisplay();
    % Hide progress bar
    bst_progressBar('stop');    

end


%% ===== SELECT MAXIMUM VALUE =====
% Usage:  SelectMaximumValue(iScout) : Keep only the maximum value in the selected scout
%         SelectMaximumValue()       : Create new scout with the vertex with maximum value at current time
function SelectMaximumValue(iScout)
    global GlobalData;
    % Parse input
    if (nargin < 1)
        isNewScout = 1;
    else
        isNewScout = 0;
        sScout = GetScouts(iScout);
    end
    % Stop scouts edition
    SetSelectionState(0);
    % Get current cortical surface  
    [iSurf, TessInfo] = panel_surface('GetSurfaceCortexOrAnatomy');
    % If no cortex surface available
    if isempty(iSurf) || isempty(TessInfo(iSurf).Data) || isempty(TessInfo(iSurf).DataSource.FileName)
        java_dialog('warning', 'No 3D figure with sources avaialable.', 'Find maximum value');
        return;
    end
    
    % Get the vertices with maximal value, at the present time ONLY
    if isNewScout
        % Get surface file to which the scout will be attached
        if strcmpi(TessInfo(iSurf).Name, 'Anatomy')
            % If anatomy surface : use correspondant cortex surface instead
            sSurfCortex = bst_getContext('SurfaceFileByType', TessInfo(iSurf).SurfaceFile, 'Cortex');
            SurfaceFile = sSurfCortex.FileName;
        else
            SurfaceFile = TessInfo(iSurf).SurfaceFile;
        end
        % If creating scout: look for max in the whole surface
        [valMax, iVertMax] = max(abs(TessInfo(iSurf).Data));
        % Create a new scout with the maximum (Keep only the FIRST maximal vertex)
        [sScout, iScout] = CreateNewScout(SurfaceFile, iVertMax(1), iVertMax(1));
    else
        % If editing scout: look for max only in the scout's vertices
        [valMax, iVertMax] = max(abs(TessInfo(iSurf).Data(sScout.Vertices)));
        iVertMax = sScout.Vertices(iVertMax);
        % Update scout (Keep only the FIRST maximal vertex)
        sScout.Vertices = iVertMax(1);
        sScout.Seed     = iVertMax(1);
        GlobalData.Scouts(iScout) = sScout;
    end
    
    % Display scout patch
    PlotScout(iScout);
    % Update "Scouts" panel
    if isNewScout
        UpdatePanel();
        % Select new scout
        SetSelectedScouts(iScout);
    else
        % Update panel "Scouts" fields
        UpdateScoutProperties();
        % Display/hide scouts and update MRI overlay mask
        UpdateScoutsDisplay();
    end
end








