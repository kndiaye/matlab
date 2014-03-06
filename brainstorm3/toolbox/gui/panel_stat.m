function varargout = panel_stat(varargin)
% PANEL_STAT: Creation and management of samples sets.
%
% USAGE:  bstPanelNew = panel_statConditions('CreatePanel')
%                       panel_statConditions('ResetPanel')

% @=============================================================================
% This software is part of The Brainstorm Toolbox
% http://neuroimage.usc.edu/brainstorm
% 
% Copyright (c)2010 Brainstorm by the University of Southern California
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

fprintf('Karim''s version!!!');

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
function bstPanelNew = CreatePanel()
    panelName = 'Statistics';
    % Java initializations
    import java.awt.*;
    import javax.swing.*;
    import org.brainstorm.icon.IconLoader;
    import org.brainstorm.tree.*;
    import org.brainstorm.dnd.*;

    % CONSTANTS
    TB_BUTTON = 23;
    jFontText = java.awt.Font('Dialog', java.awt.Font.PLAIN, 10);
    % Create topmost panel (BORDER LAYOUT)
    jPanelNew = JPanel(BorderLayout());
    % === TOOLBAR ===
    % Toolbar itself
    jToolbarStat = JToolBar('Statistics', JToolBar.VERTICAL);
    jToolbarStat.setBorderPainted(0);
    jToolbarStat.setFloatable(0);
    jToolbarStat.setRollover(1);
        jButtonGroupType = ButtonGroup();
        % Button "Recordings"
        jButtonRecordings = JToggleButton(IconLoader.ICON_DATA_LIST, 1);
        jButtonRecordings.setPreferredSize(Dimension(TB_BUTTON,TB_BUTTON));
        jButtonRecordings.setToolTipText('Process recordings');
        jButtonRecordings.setFocusable(0);
        set(jButtonRecordings, 'ActionPerformedCallback', @DataType_Callback);
        jButtonGroupType.add(jButtonRecordings);
        jToolbarStat.add(jButtonRecordings);
        % Button "Sources"
        jButtonSources = JToggleButton(IconLoader.ICON_RESULTS_LIST);
        jButtonSources.setPreferredSize(Dimension(TB_BUTTON, TB_BUTTON));
        jButtonSources.setToolTipText('Process sources');
        jButtonSources.setFocusable(0);
        set(jButtonSources, 'ActionPerformedCallback', @DataType_Callback);
        jButtonGroupType.add(jButtonSources);
        jToolbarStat.add(jButtonSources);
        jToolbarStat.addSeparator();

        % Button "RUN"
        jButtonRun = JButton(IconLoader.ICON_RUN);
        jButtonRun.setPreferredSize(Dimension(TB_BUTTON, TB_BUTTON));
        jButtonRun.setToolTipText('Start test');
        jButtonRun.setFocusable(0);
        set(jButtonRun, 'ActionPerformedCallback', @(h,ev)bst_safeCall(@ButtonRun_Callback));
        jToolbarStat.add(jButtonRun);
    jPanelNew.add(jToolbarStat, BorderLayout.WEST);
    
    % === PANEL "A/B" ===
    jPanelAB = JPanel(); 
    jPanelAB.setLayout(BoxLayout(jPanelAB, BoxLayout.LINE_AXIS));
        % === CONDITION A ===
        jPanelA = JPanel(BorderLayout());
        jPanelA.setBorder(BorderFactory.createTitledBorder('Samples A'));
            % Tree of Condition A
            jTreeFilesA = BstTree();
            jTreeFilesA.setEditable(0);
            % Keyboard callback
            set(jTreeFilesA, 'MouseClickedCallback', @(h,ev)gui_stat_common('TreeClicked_Callback', h, ev), ...
                             'KeyPressedCallback', @(h,ev)gui_stat_common('TreeKeyboard_Callback', h, ev), ...
                             'FocusLostCallback',  @(h,ev)jTreeFilesA.getSelectionModel.setSelectionPath([]));
            % Configure selection model
            jTreeSelModel = jTreeFilesA.getSelectionModel();
            jTreeSelModel.setSelectionMode(jTreeSelModel.DISCONTIGUOUS_TREE_SELECTION);
            % Enable drag'n'drop
            jTreeFilesA.setDragEnabled(1);
            transfHandler = TreeDropTransferHandler();
            jTreeFilesA.setTransferHandler(transfHandler);
            set(jTreeFilesA.getModel(), 'TreeStructureChangedCallback', @(h,ev)gui_stat_common('UpdateItemProperties', jTreeFilesA, 'SampleFilesAA'));
            % Scroll panel
            jScrollListFilesA = JScrollPane(jTreeFilesA);
            jPanelA.add(jScrollListFilesA, BorderLayout.CENTER);
        jPanelAB.add(jPanelA);
        
        % === CONDITION B ===
        jPanelB = JPanel(BorderLayout());
        jPanelB.setBorder(BorderFactory.createTitledBorder('Samples B'));
            % Tree of Condition B
            jTreeFilesB = BstTree();
            jTreeFilesB.setEditable(0);
            % Keyboard callback
            set(jTreeFilesB, 'MouseClickedCallback', @(h,ev)gui_stat_common('TreeClicked_Callback', h, ev), ...
                             'KeyPressedCallback',   @(h,ev)gui_stat_common('TreeKeyboard_Callback', h, ev), ...
                             'FocusLostCallback',    @(h,ev)jTreeFilesB.getSelectionModel.setSelectionPath([]));
            % Configure selection model
            jTreeSelModel = jTreeFilesB.getSelectionModel();
            jTreeSelModel.setSelectionMode(jTreeSelModel.DISCONTIGUOUS_TREE_SELECTION);
            % Enable drag'n'drop
            jTreeFilesB.setDragEnabled(1);
            transfHandler = TreeDropTransferHandler();
            jTreeFilesB.setTransferHandler(transfHandler);
            set(jTreeFilesB.getModel(), 'TreeStructureChangedCallback', @(h,ev)gui_stat_common('UpdateItemProperties', jTreeFilesB, 'SampleFilesAB'));
            % Scroll panel
            jScrollListFilesB = JScrollPane(jTreeFilesB);
            jPanelB.add(jScrollListFilesB, BorderLayout.CENTER);
        jPanelAB.add(jPanelB);
    jPanelNew.add(jPanelAB, BorderLayout.CENTER);
    
    % Create the BstPanel object that is returned by the function
    % => constructor BstPanel(jHandle, panelName, sControls)
    bstPanelNew = BstPanel(panelName, ...
                           jPanelNew, ...
                           struct('jPanelTop',         jPanelNew, ...
                                  'jButtonRecordings', jButtonRecordings, ...
                                  'jButtonSources',    jButtonSources, ...
                                  'jPanelAB',          jPanelAB, ...
                                  'jTreeFilesA',       jTreeFilesA, ...
                                  'jTreeFilesB',       jTreeFilesB));
                   

%% =========================================================================
%  ===== LOCAL CALLBACKS ===================================================
%  =========================================================================
%% ===== CHANGE DATA TYPE =====
    function DataType_Callback(hObject, ev)
        bst_progressBar('start', 'Updating samples list', 'Updating samples list...');
        % Update items counts in all trees
        gui_stat_common('UpdateItemProperties', jTreeFilesA, 'SampleFilesAA', 1);
        gui_stat_common('UpdateItemProperties', jTreeFilesB, 'SampleFilesAB', 1);
        bst_progressBar('stop');
    end
end

%% =========================================================================
%  ===== PROCESSING FUNCTIONS ==============================================
%  =========================================================================
%% ===== RESET PANEL =====
function ResetPanel(varargin) %#ok<DEFNU>
    % Get panel controls
    ctrl = bst_getContext('PanelControls', 'Statistics');
    % Remove all nodes from all the trees
    awtinvoke(ctrl.jTreeFilesA.getModel.getRoot(), 'removeAllChildren()');
    awtinvoke(ctrl.jTreeFilesB.getModel.getRoot(), 'removeAllChildren()');
    % Update all trees
    awtinvoke(ctrl.jTreeFilesA, 'refresh()');
    awtinvoke(ctrl.jTreeFilesB, 'refresh()');
end


%% ===== RUN STATS =====
function ButtonRun_Callback(varargin)
%     bst_progressBar('start', 'Initialization', 'Initialization...');
    global GlobalData;
    % ===== CHECK INPUTS =====
    % Get conditions
    Conditions = gui_stat_common('GetConditions', 'Statistics');
    if isempty(Conditions)
        return
    end

    % Check samples number
    if isempty(Conditions.SamplesA) %|| isempty(Conditions.SamplesB)
        bst_error('Empty samples list.', 'Statistics', 0);
        return
    end
    SampleFiles = cat(2, GlobalData.Stat.SampleFilesAA, GlobalData.Stat.SampleFilesAB);
    % Check if nothing changed
    if ~gui_stat_common('CheckConditions', 'Statistics')
        % Empty all samples lists
        ResetPanel();
        % Display error message
        bst_error(['Database contents changed.' 10 ...
                   'Please select again the files you want to process.'], 'Statistics', 0);
        return
    end
    % Check if samples mix zscore and initial values
    iZscore   = find(~cellfun(@(c)isempty(strfind(c,'_zscore')), SampleFiles));
    iTimeMean = find(~cellfun(@(c)isempty(strfind(c,'_timemean')), SampleFiles));
    iTimeMean = setdiff(iTimeMean, iZscore);
    iNormal   = setdiff(1:length(SampleFiles), [iZscore, iTimeMean]);
    
    % If mixed input file types: warning
    if (~isempty(iZscore) && ~isempty(iTimeMean)) || (~isempty(iZscore) && ~isempty(iNormal)) || (~isempty(iTimeMean) && ~isempty(iNormal))
        bst_progressBar('hide');
        % Build list of available file tags
        fileTags = {'normal'};
        if ~isempty(iZscore)
            fileTags{end + 1} = 'zscore';
        end
        if ~isempty(iTimeMean)
            fileTags{end + 1} = 'timemean';
        end
        fileTags{end + 1} = 'all';
        % Ask user to choose between file tags
        res = java_dialog('question', ['You mixed file types that cannot be processed together.' 10 ...
                                       'Please chose one in the list:' 10 10], ...
                                      'Statistics', [], fileTags, 'normal');
        % Record user selection, or exit if canceled
        if isempty(res)
            bst_progressBar('stop');
            return;
        elseif strcmpi(res, 'all')
            GlobalData.Stat.FilterFileTag = '';
        else
            GlobalData.Stat.FilterFileTag = ['_' res];
        end
        
        bst_progressBar('show');
    else
        GlobalData.Stat.FilterFileTag = '';
    end
    
    % ===== RUN TEST =====
    % Get samples
    Conditions = gui_stat_common('GetConditions', 'Statistics', GlobalData.Stat.FilterFileTag);
    % Display options panel
    bstPanel = panel_statRun('CreatePanel', Conditions);
    gui_showPanel(bstPanel, 'JavaWindow', 'Statistics', [], 'modal');
    
    bst_progressBar('stop');
end


%% ===== GET ROOT NODE =====
function [nodeRoot, jTree] = GetRootNode(TreeName) %#ok<DEFNU>
    nodeRoot = [];
    % Get panel controls
    ctrl = bst_getContext('PanelControls', 'Statistics');
    if isempty(ctrl)
        return
    end
    % Get input tree
    switch (TreeName)
        case 'StatA'
            jTree = ctrl.jTreeFilesA;
        case 'StatB'
            jTree = ctrl.jTreeFilesB;
    end
    % Get root node
    treeModel = awtinvoke(jTree, 'getModel()');
    nodeRoot = awtinvoke(treeModel, 'getRoot()');
end


%% ===== SET SOURCES/RECORDINGS =====
% Usage:  SetFileType('results')
%         SetFileType('data')
function SetFileType(datatype) %#ok<DEFNU>
    % Get panel controls
    ctrl = bst_getContext('PanelControls', 'Statistics');
    % Select corect button
    switch lower(datatype)
        case 'results'
            ctrl.jButtonSources.setSelected(1);
        case 'data'
            ctrl.jButtonRecordings.setSelected(1);
    end
end









  