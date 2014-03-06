function varargout = panel_statRun(varargin)
% PANEL_STATRUN: Selection and execution of the process to apply to the samples sets.
%
% USAGE:  bstPanelNew = panel_statRun('CreatePanel', panelName)
%                       panel_statRun('CallBatch')
%                       panel_statRun('UpdatePanel')
%             Comment = panel_statRun('FormatComment', ...)

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
function bstPanelNew = CreatePanel(Conditions) %#ok<DEFNU>
    panelName = 'panel_statRun';
    % Java initializations
    import java.awt.*;
    import javax.swing.*;
    % Constants
    HFILLED_WIDTH  = 10;
    DEFAULT_HEIGHT = 20;
    SPINNER_WIDTH  = 70;
    TEXT_WIDTH     = 53;
    JCOMBO_DM = java.awt.Dimension(10,25);
    jFontText = java.awt.Font('Dialog', java.awt.Font.PLAIN, 10);
    windowDim = [350, 0];
    isUpdateAvailable = 0;

    % Get some information about processes
    isData = strcmpi(Conditions.DataType, 'data');
    nbSamplesA = length(Conditions.SamplesA);
    nbSamplesB = length(Conditions.SamplesB);
    [sProcesses, sSimpleTests, sPermTests, sAnova] = GetProcessesList(Conditions.NbSamplesSets, nbSamplesA, nbSamplesB);
        
    % ===== GET TIME DEFINITION =====
    % Get first input file time ranges
    FileTimeVector = GetFileTimeVector(Conditions.SamplesA(1).iStudy, Conditions.SamplesA(1).iItem, isData);
    % Get default values for baseline
    if (FileTimeVector(1) < 0) && (FileTimeVector(end) > 0)
        BaselineBounds = [FileTimeVector(1), 0];
    else
%         BaselineBounds = [FileTimeVector(1), .8*FileTimeVector(1) + .2*FileTimeVector(end)];
        BaselineBounds = [FileTimeVector(1), FileTimeVector(end)];
    end

    % ===== CREATE PANEL =====
    jPanelNew = getRiverPanel([6,3], [5,5,0,10]);
    % === COMMENT ===
    jPanelNew.add(JLabel('Comment:'));
    jTextComment = JTextField('');
    jTextComment.setPreferredSize(Dimension(HFILLED_WIDTH, DEFAULT_HEIGHT));
    jPanelNew.add('hfill', jTextComment);

    % ===== PROCESSES PANEL =====
    jPanelOp = getRiverPanel([10,10], [0,20,5,20]);       
        % Statistics type
        jComboTestOp = JComboBox();
        jComboTestOp.setPreferredSize(JCOMBO_DM);    
        jComboTestOp.setMaximumRowCount(30);
        % set(jComboTestOp, 'ItemStateChangedCallback', @UpdatePanel);
        jPanelOp.add('hfill', jComboTestOp);
        % Fill the combo box
        FillProcessComboBox(jComboTestOp, sProcesses);

        % === DESCRIPTION ===
        jLabelDescriptionOp = JLabel('No process available.');
        jLabelDescriptionOp.setVerticalAlignment(JLabel.TOP);
        jPanelOp.add('br hfill', jLabelDescriptionOp);

        jTextFactors = [];
    % ===== TABBED PANEL =====
    % If no tests possible: create a flat titled panel
    if (Conditions.NbSamplesSets == 1)
        % Initialize unsed controls to "Null"
        jTabbedStat = [];
        jComboTestSimple = [];
        jComboTestPermut = [];
        jLabelDescriptionSimple = [];
        jLabelDescriptionPermut = [];
        jSpinnerNbPermut = [];
        % Add a title to the panel
        jPanelOp.setPreferredSize(Dimension(150,120));
        jPanelOp.setBorder(javax.swing.BorderFactory.createTitledBorder('Process selection'));
        jPanelNew.add('br hfill', jPanelOp);
        windowDim(2) = 470;
    % Else: Tabbed pane
    else
        jTabbedStat = JTabbedPane();
        % set(jTabbedStat, 'StateChangedCallback', @UpdatePanel);
            % PROCESSES PANEL
            jTabbedStat.addTab('Processes', jPanelOp);
            % ===== SIMPLE TESTS =====
            jPanelSimple = getRiverPanel([10,10], [0,20,5,20]);       
                % === TEST TYPE ===
                % Statistics type
                jComboTestSimple = JComboBox();
                jComboTestSimple.setPreferredSize(JCOMBO_DM); 
                % set(jComboTestSimple, 'ItemStateChangedCallback', @UpdatePanel);
                jPanelSimple.add('hfill', jComboTestSimple);
                % Fill the combo box
                FillProcessComboBox(jComboTestSimple, sSimpleTests);
                
                % === DESCRIPTION ===
                jLabelDescriptionSimple = JLabel('No test available.');
                jLabelDescriptionSimple.setVerticalAlignment(JLabel.TOP);
                jPanelSimple.add('br hfill', jLabelDescriptionSimple);
            jTabbedStat.addTab('Simple tests', jPanelSimple);

            % ===== PERMUTATION TESTS =====
            jPanelPermut = getRiverPanel([10,10], [0,20,5,20]);       
                % Statistics type
                jComboTestPermut = JComboBox();
                jComboTestPermut.setPreferredSize(JCOMBO_DM); 
                % set(jComboTestPermut, 'ItemStateChangedCallback', @UpdatePanel);
                jPanelPermut.add('hfill', jComboTestPermut);
                % Fill the combo box
                FillProcessComboBox(jComboTestPermut, sPermTests);
                
                % === NUMBER OF PERMUTATIONS ===
                jPanelPermut.add('br', JLabel('Number of permutations: '));
                spinmodel = SpinnerNumberModel(10000, 1, 50000, 100);
                jSpinnerNbPermut = JSpinner(spinmodel);  
                jSpinnerNbPermut.setPreferredSize(Dimension(SPINNER_WIDTH, DEFAULT_HEIGHT));
                jPanelPermut.add(jSpinnerNbPermut);
                
                % === DESCRIPTION ===
                jLabelDescriptionPermut = JLabel('No test available.');
                jLabelDescriptionPermut.setVerticalAlignment(JLabel.TOP);
                jPanelPermut.add('br hfill', jLabelDescriptionPermut);

            jTabbedStat.addTab('Permutations', jPanelPermut);

            
            % ===== ANOVA =====
            jPanelAnova = getRiverPanel([10,10], [0,20,5,20]);
            % Statistics type
            jComboAnova= JComboBox();
            jComboAnova.setPreferredSize(JCOMBO_DM);
            set(jComboAnova, 'ItemStateChangedCallback', @UpdatePanel);
            jPanelPermut.add('hfill', jComboAnova);
            % Fill the combo box
            FillProcessComboBox(jComboAnova, sAnova);

            % === FACTORS ===
            jPanelAnova.add('br', JLabel('Factors: '));
            % # of subjects:
            NS = numel(unique({Conditions.SamplesA.SubjectName}));
            
            [u,i,j] = unique([Conditions.SamplesA.iItem])
            if numel(u)>1
                Comments = bst_getContext('Study', [Conditions.SamplesA.iStudy]);
                Comments = [Comments.Data];
                
                cellfun2('getfield', cellfun2('fliplr', getfield2(bst_getContext('Study', [Conditions.SamplesA.iStudy]), 'Data')), 'Comment')'
                
                SelectedItem = listdlg('ListString', ...
                    [strvcat({Conditions.SamplesA(i).Condition}) repmat(' : ',length(u),1) strvcat({Conditions.SamplesA(i).Comment})],...
                    'SelectionMode','single', 'Name', 'Pick an inverse model');
                if isempty(SelectedItem)
                    return
                end
                Conditions.SamplesA  = Conditions.SamplesA(j == SelectedItem);
                assignin('base', 'sA', Conditions.SamplesA);
            end
            % Get samples
            %GlobalData.Stat.FilterFileTag = ['_timemean' ];
            %Conditions = gui_stat_common('GetConditions', 'Statistics', GlobalData.Stat.FilterFileTag);        
            
            tbl.h{1}='Condition';
            tbl.t = {Conditions.SamplesA.Condition};
            tbl.t = tbl.t(:)
            
            if NS > 1 
                tbl.t = tbl.t(1+[0:3]*NS)
            end
            %tbl.h{end+1}='Comment';
            %tbl.t(:,end+1) = {Conditions.SamplesA(1+[0:3]*15).Comment};
            tbl.h{end+1}='Factor 1';
            tbl.t(:,end+1)={ '1' ; '2' ;  '1' ; '2' };
            tbl.h{end+1}='Factor 2';
            tbl.t(:,end+1)={ '1' ; '1' ;  '2' ; '2' };            

            jTableFactors = JTable(tbl.t,tbl.h);
            jTableFactors.setPreferredSize(Dimension(4*SPINNER_WIDTH, 5*DEFAULT_HEIGHT));
            jPanelAnova.add('br', jTableFactors);
        
            % === DESCRIPTION ===
            jLabelDescriptionAnova = JLabel('No option available.');
            jLabelDescriptionAnova.setVerticalAlignment(JLabel.TOP);
            jPanelAnova.add('br hfill', jLabelDescriptionAnova);

            jTabbedStat.addTab('ANOVA', jPanelAnova);
            jTabbedStat.setEnabledAt(3, 1);

            % Statistical tests : min two samples in each condition
            if (nbSamplesA <= 1) || (nbSamplesB <= 1)
                % Disable "simple tests" and "permutations" tabs if not enough samples
                jTabbedStat.setEnabledAt(1, 0);
                jTabbedStat.setEnabledAt(2, 0);
            end
        jTabbedStat.setPreferredSize(Dimension(150,175));
        jPanelNew.add('br hfill', jTabbedStat);
        windowDim(2) = 350;
    end
    
    % === TIME WINDOWS ===
    jPanelTimeWindows = getRiverPanel([2,3], [0,18,10,0], 'Time windows');
        % === WINDOW A ===
        jLabelTimeA = JLabel('Time window: ');
        jPanelTimeWindows.add(jLabelTimeA);
        % Time window A : START
        jTextTimeStartA = JTextField('');
        jTextTimeStartA.setPreferredSize(Dimension(TEXT_WIDTH, DEFAULT_HEIGHT));
        jTextTimeStartA.setHorizontalAlignment(JTextField.RIGHT);
        jTextTimeStartA.setFont(jFontText); 
        jPanelTimeWindows.add('tab', jTextTimeStartA);
        jLabelSeparatorA = JLabel('-');
        jPanelTimeWindows.add(jLabelSeparatorA);
        % Time window A : STOP
        jTextTimeStopA = JTextField('');
        jTextTimeStopA.setPreferredSize(Dimension(TEXT_WIDTH, DEFAULT_HEIGHT));
        jTextTimeStopA.setHorizontalAlignment(JTextField.RIGHT);
        jTextTimeStopA.setFont(jFontText); 
        jPanelTimeWindows.add(jTextTimeStopA);

        % Set time controls callbacks
        TimeUnit = gui_validateText(jTextTimeStartA, [], [], FileTimeVector, [], jTextTimeStopA,  FileTimeVector(1), @UpdatePanel);
        TimeUnit = gui_validateText(jTextTimeStopA,  [], [], FileTimeVector, jTextTimeStartA, [], FileTimeVector(end), @UpdatePanel);
        % Display time unit
        jLabelTimeUnitA = JLabel(TimeUnit);
        jPanelTimeWindows.add(jLabelTimeUnitA);
        
        % === WINDOW B ===
        jLabelTimeB = JLabel('Baseline: ');
        jPanelTimeWindows.add('br', jLabelTimeB);
        % Time window B : START
        jTextTimeStartB = JTextField('');
        jTextTimeStartB.setPreferredSize(Dimension(TEXT_WIDTH, DEFAULT_HEIGHT));
        jTextTimeStartB.setHorizontalAlignment(JTextField.RIGHT);
        jTextTimeStartB.setFont(jFontText); 
        jPanelTimeWindows.add('tab', jTextTimeStartB);
        jLabelSeparatorB = JLabel('-');
        jPanelTimeWindows.add(jLabelSeparatorB);
        % Time window B : STOP
        jTextTimeStopB = JTextField('');
        jTextTimeStopB.setPreferredSize(Dimension(TEXT_WIDTH, DEFAULT_HEIGHT));
        jTextTimeStopB.setHorizontalAlignment(JTextField.RIGHT);
        jTextTimeStopB.setFont(jFontText); 
        jPanelTimeWindows.add(jTextTimeStopB);

        % Set time controls callbacks
        gui_validateText(jTextTimeStartB, [], [], FileTimeVector, [], jTextTimeStopB,  BaselineBounds(1), []);
        gui_validateText(jTextTimeStopB,  [], [], FileTimeVector, jTextTimeStartB, [], BaselineBounds(2), []);
        % Display time unit
        jLabelTimeUnitB = JLabel(TimeUnit);
        jPanelTimeWindows.add(jLabelTimeUnitB);
    jPanelNew.add('br hfill', jPanelTimeWindows);

    % ===== SOURCES PANEL =====
    jPanelSources = getRiverPanel([0,0], [0,0,0,0], 'Sources');
    jCheckAbsoluteValues = JCheckBox('Use absolute values of sources activations');
    jCheckAbsoluteValues.setMargin(Insets(0,10,0,0));
    set(jCheckAbsoluteValues, 'ActionPerformedCallback', @CheckAbsoluteValues_Callback);
    jPanelSources.add(jCheckAbsoluteValues);
    % Add panel only if processing sources (results)
    if ~isData
        jPanelNew.add('br hfill', jPanelSources);
        jCheckAbsoluteValues.setSelected(1);
        windowDim(2) = windowDim(2) + 70;
    else
        jCheckAbsoluteValues.setVisible(0);
        jCheckAbsoluteValues.setSelected(0);
    end
            
    % ===== CLUSTER PANEL CONFIG =====
    jCheckCluster = [];
    jCheckAvgCluster = [];
    jListCluster  = [];
    iScouts       = [];
    if (Conditions.NbSamplesSets == 1)
        errMsg = '';
        % === ELECTRODES CLUSTERS ===
        if isData
            clusterType = 'Cluster';
            % Get all available clusters for these results
            [sClusters, iClusters] = GetClusters(Conditions);
            % ERROR 1
            if isnumeric(sClusters) && (sClusters == -1)
                errMsg = 'No channel file available for at least one file.';
            % ERROR 2
            elseif isnumeric(sClusters) && (sClusters == -2)
                errMsg = 'No cluster available. Use "Cluster" tab to create one.';
            % SUCCESS: Get selected clusters
            else
                [tmp__, iSelect] = panel_clusters('GetSelectedClusters');
            end

        % === SCOUTS ===
        else
            clusterType = 'Scout';
            % Get selected scouts
            [sClusters,    iClusters]    = GetScouts(Conditions);
            [sSelClusters, iSelClusters] = panel_scouts('GetSelectedScouts');
            % ERROR 1
            if isnumeric(sClusters) && (sClusters == -1)
                errMsg = 'The sources files were not computed for the same cortical surface.';
            % ERROR 2
            elseif isnumeric(sClusters) && (sClusters == -2)
                errMsg = 'No scout available. Use "Scout" tab to create one.';
            % SUCCESS: Get selected scouts
            else
                iSelect = find(ismember(iClusters, iSelClusters));
            end
        end
        
        % Create panel
        jPanelCluster = getRiverPanel([0,0], [0,12,0,12], [clusterType 's']);
        % If error: just add show the error message
        if ~isempty(errMsg)
            windowDim(2) = windowDim(2) + 50;
            jPanelCluster.add(JLabel(['      ' errMsg]));
        % Else: clusters are available
        else
            windowDim(2) = windowDim(2) + 120;
            % Use only selected scouts/clusters
            jCheckCluster = JCheckBox(['Use only selected ' clusterType 's']);
            jPanelCluster.add(jCheckCluster);
            % Average cluster checkbox
            if (length(sClusters) > 1)
                jCheckAvgCluster = JCheckBox(['Merge selected ' clusterType 's'], 0);
                %jPanelCluster.setMargin(Insets(0,12,0,15));
                jPanelCluster.add(jCheckAvgCluster);
            end
            
            % === JLIST: CLUSTERS ===
            % Create list (display labels of all clusters)
            paddedLabels = cellfun(@(c)cat(2,' ',c,' '),{sClusters.Label}, 'UniformOutput', 0);
            jListCluster = JList(paddedLabels);
            jListCluster.setLayoutOrientation(jListCluster.HORIZONTAL_WRAP);
            jListCluster.setVisibleRowCount(-1);
            % Pre-select clusters that are selected in the GUI
            if ~isempty(iSelect)
                jListCluster.setSelectedIndices(iSelect - 1);
            end
            % Create scroll panel
            jScrollPanelCluster = JScrollPane(jListCluster);
            jPanelCluster.add('br hfill vfill', jScrollPanelCluster);            
        end
        jPanelNew.add('br vfill hfill', jPanelCluster);
    end
    
    % ===== OUTPUT PANEL =====
    if (Conditions.NbSamplesSets == 1)
        jPanelOutput = getRiverPanel([0,3], [0,10,10,10], 'Output');
        buttonGroupOutput = ButtonGroup();
        % OUTPUT: Brainstorm Database
        jRadioOutputDatabase = JRadioButton('Brainstorm database', 1);
        jRadioOutputDatabase.setToolTipText(['<HTML><B><U>Brainstorm database:<BR><BLOCKQUOTE>' ...
                                             'All the files that are generated are automatically added to database.<BR><BR>'...
                                             ' - <U>One output file</U>:<BR>' ...
                                             'Most of the processes produce only one file that is stored either,<BR>' ...
                                             'in the original condition or in an "Analysis" node.<BR><BR>' ...
                                             ' - <U>Multiple output files</U>:<BR>' ...
                                             'The processes that are marked "[sample by sample]" produce one file<BR>' ...
                                             'for each file A (or couple of files A/B) in the sample list.']);
        buttonGroupOutput.add(jRadioOutputDatabase);
        jPanelOutput.add(jRadioOutputDatabase);
        % Overwrite original files
        jPanelOutput.add('br', JLabel('        '));
        jCheckOverwriteFiles = JCheckBox('Overwrite initial files', 1);
        jPanelOutput.add(jCheckOverwriteFiles);
        % OUTPUT: Condition path (check)
        jPanelOutput.add('br', JLabel('        '));
        jCheckOutputCond = JCheckBox('Select output condition');
        jPanelOutput.add(jCheckOutputCond);
        % OUTPUT: Condition path (text)
        jTextOutputCond = JTextField('');
        jTextOutputCond.setMargin(Insets(0,0,0,20));
        jPanelOutput.add('hfill', jTextOutputCond);
        % OUTPUT: User file
        jRadioOutputFile   = JRadioButton('User defined file: All data is stored in one unique file');
        buttonGroupOutput.add(jRadioOutputFile);
        jPanelOutput.add('br', jRadioOutputFile);
        % OUTPUT: Matlab variable
        jRadioOutputMatlab = JRadioButton('Export to a Matlab variable');
        buttonGroupOutput.add(jRadioOutputMatlab);
        jPanelOutput.add('br', jRadioOutputMatlab);
        jPanelNew.add('br hfill', jPanelOutput);
        % Callbacks
        set(jRadioOutputDatabase, 'ActionPerformedCallback', @UpdateOutput);
        set(jRadioOutputFile,     'ActionPerformedCallback', @UpdateOutput);
        set(jRadioOutputMatlab,   'ActionPerformedCallback', @UpdateOutput);
        set(jCheckOverwriteFiles, 'ActionPerformedCallback', @UpdateOutput);
        set(jCheckOutputCond,     'ActionPerformedCallback', @UpdateOutput);
    else
        jRadioOutputDatabase = [];
        jRadioOutputFile = [];
        jRadioOutputMatlab = [];
        jCheckOverwriteFiles = [];
        jCheckOutputCond = [];
        jTextOutputCond = [];
    end
    
    % ===== VALIDATION BUTTONS =====
    % Help
    jButtonHelp = JButton('Help');
    jButtonHelp.setForeground(Color(.7, 0, 0));
    if (Conditions.NbSamplesSets == 1)
        set(jButtonHelp, 'ActionPerformedCallback', @(h,ev)bst_help('PanelStatRunProcess.html', 1));
    else
        set(jButtonHelp, 'ActionPerformedCallback', @(h,ev)bst_help('PanelStatRunStat.html', 1));
    end
    jPanelNew.add('br right', jButtonHelp);
    % Cancel
    jButtonCancel = JButton('Cancel');
    set(jButtonCancel, 'ActionPerformedCallback', @ButtonCancel_Callback);
    jPanelNew.add(jButtonCancel);
    % Run
    jButtonRun = JButton('Run');
    set(jButtonRun, 'ActionPerformedCallback', @(h,ev)bst_safeCall(@ButtonRun_Callback));
    jPanelNew.add(jButtonRun);
    
    % Set main panel size
    jPanelNew.setPreferredSize(Dimension(windowDim(1), windowDim(2)));

    % Create the BstPanel object that is returned by the function
    % => constructor BstPanel(jHandle, panelName, sControls)
    bstPanelNew = BstPanel(panelName, ...
                           jPanelNew, ...
                           struct('jListCluster', jListCluster));

     % Set UpdatePanel callbacks
     set(jComboTestOp,     'ItemStateChangedCallback', @ComboUpdatePanel);
     set(jComboTestPermut, 'ItemStateChangedCallback', @ComboUpdatePanel);
     set(jComboTestSimple, 'ItemStateChangedCallback', @ComboUpdatePanel);
     set(jCheckCluster,    'ActionPerformedCallback',  @UpdatePanel);
     set(jTabbedStat,      'StateChangedCallback',     @UpdatePanel);
     % Update panel
     drawnow();
     isUpdateAvailable = 1;
     UpdatePanel();
             
           
                              
%% =================================================================================
%  === INTERNAL CALLBACKS ==========================================================
%  =================================================================================            
%% ===== COMBOBOX : UPDATE PANEL =====
    function ComboUpdatePanel(hObject, ev)
        if (ev.getStateChange() == ev.SELECTED)
            UpdatePanel();
        end
    end

%% ===== CHECKBOX : "ABSOLUTE VALUES" =====
    function CheckAbsoluteValues_Callback(varargin)
        if ~jCheckAbsoluteValues.isSelected()
            isConfirmed = java_dialog('confirm', ['Please keep this option selected, unless you know exactly what you are doing.' 10 10 ...
                                      'Are you sure you want to use relative values for sources activations ?'], 'Processes');
            if ~isConfirmed
                jCheckAbsoluteValues.setSelected(1);
            end
        end
    end

%% ===== UPDATE OUTPUT PANEL =====
    function UpdateOutput(varargin)
        % Force condition path
        isDatabase = jRadioOutputDatabase.isEnabled() && jRadioOutputDatabase.isSelected();
        jCheckOutputCond.setEnabled(isDatabase);
        jTextOutputCond.setEnabled(isDatabase);
        if ~isDatabase
            jCheckOutputCond.setSelected(0);
        end
        % Condition path
        isForceCond = jCheckOutputCond.isSelected();
        jTextOutputCond.setVisible(isForceCond);
        % Cannot select both options at the same time
        if isForceCond
            jCheckOverwriteFiles.setSelected(0);
        end
    end

%% ===== FILL PROCESSES COMBO BOX =====
    function FillProcessComboBox(jCombo, sList)
        import org.brainstorm.list.BstListItem;
        % Fill the combo box
        for i = 1:length(sList)
            % Convert labels to HTML
            label = sList(i).Comment;
            if isempty(sList(i).Name)
                label = ['<HTML><P style="margin: 2px 0px 2px 0px;">' label];
            else
                label = ['<HTML><P style="margin: 2px 0px 2px 15px;">' label];
            end
            % Add item in combo list
            jCombo.addItem(BstListItem(sList(i).Name, '', label, sList(i).Description));
        end
    end

%% ===== RUN =====
    function ButtonRun_Callback(varargin)
        CallBatch();
    end

%% ===== GET SELECTED PROCESS =====
    function [sProcess, selectedTab] = GetSelectedProcess()
        % Get selected tab
        if isempty(jTabbedStat)
            selectedTab = 0;
        else
            selectedTab = jTabbedStat.getSelectedIndex();
        end
        % Get the selected combo box
        switch (selectedTab)
            case 0
                jCombo = jComboTestOp;
                sList = sProcesses;
            case 1
                jCombo = jComboTestSimple;
                sList = sSimpleTests;
            case 2
                jCombo = jComboTestPermut;
                sList = sPermTests;
            case 3
                jCombo = jComboAnova;
                sList = sAnova;
        end
        % Get selected process
        jItem = jCombo.getSelectedItem();
        if isempty(jItem)
            sProcess = [];
            return
        end
        processName = jItem.getType();
        % Find in it in processes list
        iProcess = find(strcmpi({sList.Name}, processName));
        sProcess = sList(iProcess(1));
    end

%% ===== UPDATE PANEL =====
    function UpdatePanel(varargin)
        if ~isUpdateAvailable
            return
        end
        % Get selected process
        [sProcess, selectedTab] = GetSelectedProcess();
        if isempty(sProcess)
            return
        end
        isProcessTitle = isempty(sProcess.Category);
        % Convert description to HTML
        processDesc = ['<HTML>' strrep(sProcess.Description, char(10), '<BR>')];
        % Update tabbed panels
        switch(selectedTab)
            % === PROCESSES ===
            case 0
                jLabelDescriptionOp.setText(processDesc);
            % === SIMPLE TESTS ===
            case 1
                jLabelDescriptionSimple.setText(processDesc);
            % === PERM TESTS ===
            case 2
            	jLabelDescriptionPermut.setText(processDesc);
                % Compute maximum number of permutations
                Na = nbSamplesA;
                Nb = nbSamplesB;
                if sProcess.isPaired
                    % nbPermMax = 2^(Na)-1;
                    nbPermMax = 2^(Na-1)-1;
                else
                    nbPermMax = factorial(Na+Nb) / (factorial(Na)*factorial(Nb)) - 1;
                end
                % Limit default number of permutations
                NB_PERM_LIMIT = 10000;
                nbPerm = min(nbPermMax, NB_PERM_LIMIT);
                % Update spinner model
                spinmodel = awtinvoke(jSpinnerNbPermut, 'getModel()');
                awtinvoke(spinmodel, 'setValue(Ljava.lang.Object;)',       java.lang.Double(nbPerm));
                awtinvoke(spinmodel, 'setMaximum(Ljava.lang.Comparable;)', java.lang.Double(nbPermMax));
        end
        
        % ===== UPDATE COMMENT =====
        % Get time 
        TimeRange = GetTimeWindows(TimeUnit);
        % Format comment
        Comment = FormatComment(sProcess, Conditions, TimeRange);
        % Too long comment
        if (length(Comment) > 80)
            % Replace comment by date
            c = clock;
            strTime = sprintf('%02.0f%02.0f%02.0f_%02.0f%02.0f', c(1)-2000, c(2:5));
            Comment = [sProcess.Name ': ' strTime];
        end
        % Update comment
        awtinvoke(jTextComment, 'setText(Ljava.lang.String;)', Comment);

        % ===== UPDATE TIME WINDOW PANEL =====
        if ~isempty(jTextTimeStartB)
            % Time window
            jLabelTimeA.setEnabled(~isProcessTitle);
            jTextTimeStartA.setEnabled(~isProcessTitle);
            jTextTimeStopA.setEnabled(~isProcessTitle);
            jLabelSeparatorA.setEnabled(~isProcessTitle);
            jLabelTimeUnitA.setEnabled(~isProcessTitle);
            % Baseline
            jLabelTimeB.setEnabled(sProcess.UseBaseline);
            jTextTimeStartB.setEnabled(sProcess.UseBaseline);
            jTextTimeStopB.setEnabled(sProcess.UseBaseline);
            jLabelSeparatorB.setEnabled(sProcess.UseBaseline);
            jLabelTimeUnitB.setEnabled(sProcess.UseBaseline);
        end
        
        % ===== UPDATE SOURCES PANEL =====
        jCheckAbsoluteValues.setSelected(sProcess.isSourceAbsolute > 0);
        jCheckAbsoluteValues.setEnabled(sProcess.isSourceAbsolute ~= 2);

        % ===== UPDATE CLUSTER PANEL =====
        % Cluster checkbox
        isAllowCluster = ismember(sProcess.Category, {'Extract'});
        if ~isempty(jCheckCluster)
            jCheckCluster.setEnabled(isAllowCluster);
            if ~isAllowCluster
                jCheckCluster.setSelected(0);
            end
            % Cluster jlists
            isCluster = ~isempty(jCheckCluster) && jCheckCluster.isSelected();
            if ~isempty(jListCluster)
                jListCluster.setEnabled(isCluster);
            end
            if ~isempty(jCheckAvgCluster)
                jCheckAvgCluster.setEnabled(isCluster);
            end
        else
            isCluster = 0;
        end
        
        % ===== UPDATE OUTPUT PANEL =====
        if ~isempty(jRadioOutputDatabase)
            AllowExport = ismember(sProcess.Category, {'Extract'});
            % Enable Database: only if no cluster defined
            jRadioOutputDatabase.setEnabled(~isCluster && ~isProcessTitle);
            % Enable File/Matlab
            jRadioOutputFile.setEnabled(AllowExport > 0);
            jRadioOutputMatlab.setEnabled(AllowExport > 0);
            % Select "File": if cluster, or time/mean, time/var, or extract
            if (isCluster || AllowExport)
                % Change selection only if Database is selected
                if ~jRadioOutputMatlab.isSelected()
                    jRadioOutputFile.setSelected(1);
                end
            else
                jRadioOutputDatabase.setSelected(1);
            end   

            % "Overwrite file" checkbox
            AllowOverwrite = ismember(sProcess.Category, {'Filter'});
            isOverwriteEnabled = jRadioOutputDatabase.isEnabled() && AllowOverwrite;
            jCheckOverwriteFiles.setEnabled(isOverwriteEnabled);
            isOverwriteSelected = isOverwriteEnabled  && sProcess.DefaultOverwrite;
            jCheckOverwriteFiles.setSelected(isOverwriteSelected);
            % Update object selections
            UpdateOutput();
        end
    end


%% ===== GET TIME WINDOWS =====
    function [Time, Baseline, iTime, iBaseline] = GetTimeWindows(TimeUnit)
        % Get time window to process
        Time = [getValue(jTextTimeStartA), getValue(jTextTimeStopA)];
        % Get baseline, if defined
        if ~isempty(jTextTimeStartB)
            Baseline = [getValue(jTextTimeStartB), getValue(jTextTimeStopB)];
        else
            Baseline = [];
        end
        % Apply correct time units
        switch(TimeUnit)
            case 'ms'
                % Convert miliseconds -> seconds
                Time = Time / 1000;
                Baseline = Baseline / 1000;
            otherwise
                % Nothing to do
        end
        % Get indices in intial FileTimeVector
        iTimeBounds = findclosest(Time, FileTimeVector);
        % If whole data wanted and sampling frequency very high: might lack of time precision...
        % Try to correct this and select the last sample if it is obviously this that the user wants
        if (iTimeBounds(2) ~= length(FileTimeVector)) && (FileTimeVector(end)-FileTimeVector(iTimeBounds(2)) < 1e-5)
            iTimeBounds(2) = length(FileTimeVector);
        end
        % Build time indices
        iTime = iTimeBounds(1) : iTimeBounds(2);
        iBaselineBounds = findclosest(Baseline, FileTimeVector);
        iBaseline = iBaselineBounds(1) : iBaselineBounds(2);
    end

%% ===== GET VALUES =====
    function val = getValue(jText)
        % Get and check value
        val = str2double(char(jText.getText()));
        if isnan(val) || isempty(val)
            val = [];
        end
    end


%% ===== COMPUTE TEST =====
    function CallBatch()
        % ===== PREPARE OPTIONS =====
        OPTIONS = struct();
        % Is processing recordings or results
        OPTIONS.isData = isData;
        % Get new file comment
        OPTIONS.Comment = deblank(strtrim(char(jTextComment.getText())));
        % Is absolute values (for sources only)
        OPTIONS.isAbsoluteValues = ~isData && jCheckAbsoluteValues.isSelected();
        % Get selected process
        [OPTIONS.sProcess, selectedTab] = GetSelectedProcess();       
        if isempty(OPTIONS.sProcess) || isempty(OPTIONS.sProcess.Name)
            bst_error('Please select a process.', 'Processes', 0);
            return
        end
        % Get number of permutations
        if ~isempty(jSpinnerNbPermut)
            OPTIONS.nbPermutation = jSpinnerNbPermut.getValue();
        else
            OPTIONS.nbPermutation = 0;
        end
        % List factors associated with each dataset
        if ~isempty(jTextFactors)
            OPTIONS.Factors= char(jTextFactors.getText());
        else
            OPTIONS.Factors = [];
        end
        
        % Overwrite initial files ?
        OPTIONS.isOverwriteFiles = ~isempty(jCheckOverwriteFiles) && jCheckOverwriteFiles.isSelected();
        % Get output mode
        if isempty(jRadioOutputDatabase) || jRadioOutputDatabase.isSelected()
            OPTIONS.OutputType = 'database';
        elseif jRadioOutputFile.isSelected()
            OPTIONS.OutputType = 'file';
        elseif jRadioOutputMatlab.isSelected()
            OPTIONS.OutputType = 'matlab';
        end
        % Force output condition
        if ~isempty(jCheckOutputCond) && jCheckOutputCond.isSelected()
            % Get the user defined condition name
            outputCond = char(jTextOutputCond.getText());
            % Split condition path
            condPath = strSplit(outputCond);
            % Check if condition name is valid
            if isempty(outputCond) || (~strcmpi(outputCond,'@inter') && (length(condPath) ~= 2))
                bst_error(['Invalid condition path.' 10 10 ...
                           'Condition path must be one the following:' 10 ...
                           '   - SubjectName/ConditionName' 10 ...
                           '   - SubjectName/@intra' 10 ...
                           '   - @inter'], 'Processes', 0);
                return
            end
            % === Convert SubjectName in SubjectPath ===
            if (length(condPath) == 2)
                % Get subject and condition names
                SubjectName = condPath{1};
                ConditionName = condPath{2};
                % Get subject
                sSubject = bst_getContext('Subject', SubjectName, 1);
                if isempty(sSubject)
                    bst_error(['Subject does not exist: "' SubjectName '"'], 'Processes', 0);
                    return
                end
                % Build new output condition path
                SubjectPath = fileparts(sSubject.FileName);
                outputCond = fullfile(SubjectPath, ConditionName);
            end
            % Valid
            OPTIONS.ForceOutputCond = outputCond;
        else
            OPTIONS.ForceOutputCond = [];
        end
        % Is "Cluster" analysis
        OPTIONS.isCluster = ~isempty(jCheckCluster) && jCheckCluster.isSelected();
        OPTIONS.isClusterAverage = OPTIONS.isCluster && ~isempty(jCheckAvgCluster) && jCheckAvgCluster.isSelected();
        % Get selected clusters
        if OPTIONS.isCluster
            if OPTIONS.isData
                % Get selected clusters
                iClusters = jListCluster.getSelectedIndices() + 1;
                sClusters = panel_clusters('GetClusters', iClusters);
                % If no cluster selected: ERROR
                if isempty(iClusters)
                    error('No channel selected in cluster panel.');
                end
                % If user asked to merge clusters
                if OPTIONS.isClusterAverage
                    sClustersAvg.Sensors = unique(cat(2, sClusters.Sensors));
                    sClustersAvg.Label   = ['Clusters:', sprintf(' %s', sClusters.Label)];
                    OPTIONS.Clusters = sClustersAvg;
                else
                    OPTIONS.Clusters = sClusters;
                end
                % Get clusters options
                OPTIONS.ClustersOptions = panel_clusters('GetClusterDisplayType');
            else
                % Get selected scouts
                iSelScouts = jListCluster.getSelectedIndices() + 1;
                % If no scout selected: ERROR
                if isempty(iSelScouts)
                    error('No scout selected in cluster panel.');
                end
                % Get scouts description
                [sScouts, iScouts] = panel_scouts('GetCurrentScouts');
                iScouts = iScouts(iSelScouts);
                sScouts = panel_scouts('GetScouts', iScouts);
                % If user asked to merge scouts
                if OPTIONS.isClusterAverage
                    sScoutsAvg = sScouts(1);
                    sScoutsAvg.Vertices = unique([sScouts.Vertices]);
                    sScoutsAvg.Label    = ['Scouts:', sprintf(' %s', sScouts.Label)];
                    OPTIONS.Clusters = sScoutsAvg;
                else
                    OPTIONS.Clusters = sScouts;
                end
                % Get scouts options
                OPTIONS.ClustersOptions = panel_scouts('GetScoutDisplayType');
            end
        else
            OPTIONS.sClusters = [];
            OPTIONS.ClustersOptions = [];
        end
        % Get time 
        [OPTIONS.Time, OPTIONS.Baseline, OPTIONS.iTime, OPTIONS.iBaseline] = GetTimeWindows(TimeUnit);
        
        % Get files to batch
        OPTIONS.Conditions = Conditions;
        % Close panel
        gui_hidePanel('panel_statRun');
        
        % ===== PERFORM SOME VERIFICATIONS =====
        % Not supposed to compute zscore on recordings
        if OPTIONS.isData && strcmpi(OPTIONS.sProcess.Name, 'zscore')
            res = java_dialog('confirm', ['Warning: You are about to compute the z-score normalization on recordings.' 10 10 ...
                                          'We recommand first to solve the inverse problem, and then to ' 10 ...
                                          'apply the zscore normalization on the cortical sources.' 10 10 ...
                                          'Are you sure you want to compute the z-score of the recordings ?'], 'Warning');
            if ~res
                return;
            end
        end
        
        % ===== CALL BATCH FUNCTION =====
        bst_batch(OPTIONS);
        
        % Update "Processes" panels
        if OPTIONS.isOverwriteFiles
            panel_processes('ResetPanel');
        else
            if (Conditions.NbSamplesSets == 1) && ~gui_stat_common('CheckConditions', 'Processes')
                panel_processes('ResetPanel');
            elseif (Conditions.NbSamplesSets == 2) && ~gui_stat_common('CheckConditions', 'Statistics')
                panel_stat('ResetPanel');
            end
        end
    end
end


%% =================================================================================
%  === EXTERNAL CALLBACKS ==========================================================
%  =================================================================================
%% ===== CANCEL =====
function ButtonCancel_Callback(varargin)
    % Close panel
    gui_hidePanel('panel_statRun');
end


%% ===== BUILD LIST OF PROCESSES =====
% USAGE:  [sProcesses, sSimpleTests, sPermTests, sAnova] = GetProcessesList(NbSamplesSets, nbSamplesA, nbSamplesB, isData)
%         [sProcesses, sSimpleTests, sPermTests, sAnova] = GetProcessesList('All')
function [sProcesses, sSimpleTests, sPermTests, sAnova] = GetProcessesList(NbSamplesSets, nbSamplesA, nbSamplesB, isData)
    % If get all processes: ignore all other arguments
    isAll = strcmpi(NbSamplesSets, 'All');
    % Initialize list
    sModel = struct('Name',        '', ...
                    'Comment',     '', ...
                    'Description', '', ...
                    'FileTag',     '', ...
                    'Category',    '', ...
                    'UseBaseline',      0, ...
                    'DefaultOverwrite', 0, ...
                    'isSourceAbsolute', 1, ... % If value=2, absolute value for sources is FORCED
                    'isPaired',         0, ...
                    'blockDimension',   0, ... % Dimension in which the data matrix can be split (0=none, 1=channels, 2=time)
                    'isAvgRef',         1);    % Compute EEG average reference before processing
    sProcesses   = repmat(sModel, 0);
    sSimpleTests = repmat(sModel, 0);
    sPermTests   = repmat(sModel, 0);
    sAnova       = repmat(sModel, 0);

    % ===== "A" PROCESSES =====
    if isAll || (NbSamplesSets == 1)
        % === FILTERS TO APPLY TO FILES ===
        sProcess = sModel;
        sProcess.Comment = '<B>==== PROCESS FILES ===========</B>';
        sProcess.Description = 'Please select a process...';
        sProcess.isSourceAbsolute = 2;
        sProcesses(end + 1) = sProcess;
        % Z-SCORE
        sProcess = sModel;
        sProcess.Name        = 'zscore';
        sProcess.Comment     = '   Z-score noise normalization';
        sProcess.FileTag     = '| zscore';
        sProcess.Description = ['For each channel:' 10 ...
                                '1) Compute mean <I>m</I> and variance <I>v</I> for baseline.' 10 ...
                                '2) For each time sample, substract <I>m</I> and divide by <I>v</I>.'];
        sProcess.Category    = 'Filter';
        sProcess.UseBaseline = 1;
        sProcess.isSourceAbsolute = 2;   
        sProcess.blockDimension = 1;
        sProcess.isAvgRef = 0;
        sProcesses(end + 1) = sProcess;
        % BASELINE REMOVAL
        sProcess = sModel;
        sProcess.Name        = 'baseline';
        sProcess.Comment     = '   Remove baseline mean (DC offset)';
        sProcess.FileTag     = '| bl';
        sProcess.Description = ['For each channel:' 10 ...
                                '1) Compute the mean <I>m</I> for the baseline.' 10 ...
                                '2) For all the time samples, substract <I>m</I>.'];
        sProcess.Category    = 'Filter';
        sProcess.UseBaseline      = 1;
        sProcess.isSourceAbsolute = 0;
        sProcess.DefaultOverwrite = 1;
        sProcess.blockDimension = 1;
        sProcess.isAvgRef = 0;
        sProcesses(end + 1) = sProcess;
        % EEG AVERAGE REFERENCE
        if isAll || isData
            sProcess = sModel;
            sProcess.Name        = 'avgref';
            sProcess.Comment     = '   EEG Average reference';
            sProcess.FileTag     = '| avgref';
            sProcess.Description = ['Note that all the processes that are not in the "Process files" category use average reference by default. ' 10 ...
                                    'No effect on MEG recordings.'];
            sProcess.Category    = 'Filter';
            sProcess.UseBaseline      = 0;
            sProcess.isSourceAbsolute = 0;
            sProcess.DefaultOverwrite = 1;
            sProcess.blockDimension = 2;
            sProcesses(end + 1) = sProcess;
        end
        % BANDPASS FILTERING
        sProcess = sModel;
        sProcess.Name        = 'bandpass';
        sProcess.Comment     = '   Bandpass filtering';
        sProcess.FileTag     = '| bandpass';
        sProcess.Description = 'Apply a frenquency filter to all the files.';
        sProcess.Category    = 'Filter';
        sProcess.isSourceAbsolute = 0;
        sProcess.blockDimension = 1;
        sProcess.isAvgRef = 0;
        sProcesses(end + 1) = sProcess;
        % SPATIAL SMOOTHING
        if isAll || ~isData
            sProcess = sModel;
            sProcess.Name        = 'ssmooth';
            sProcess.Comment     = '   Spatial smoothing';
            sProcess.FileTag     = '| ssmooth';
            sProcess.Description = 'Spatial smoothing of the sources.';
            sProcess.Category    = 'Filter';
            sProcess.isSourceAbsolute = 2;
            sProcess.blockDimension = 0;
            sProcess.isAvgRef = 0;
            sProcesses(end + 1) = sProcess;
        end
        % RESAMPLE
        if isAll || isData
            sProcess = sModel;
            sProcess.Name        = 'resample';
            sProcess.Comment     = '   Resample recordings';
            sProcess.FileTag     = '| resample';
            sProcess.Description = 'Resample all the files with a new sampling frequency.';
            sProcess.Category    = 'Filter';
            sProcess.isSourceAbsolute = 0;
            % sProcess.blockDimension = 1;   % PROBLEM WITH PROCESSING BY BLOCKS: DIMENSIONS CHANGE
            sProcess.blockDimension = 0;
            sProcess.isAvgRef = 0;
            sProcesses(end + 1) = sProcess;
        end
        % CUT STIMULATION ARTIFACT
        if isAll || isData
            sProcess = sModel;
            sProcess.Name        = 'cutstim';
            sProcess.Comment     = '   Cut stimulation artifact';
            sProcess.FileTag     = '| cutstim';
            sProcess.Description = ['Remove the values in the "baseline" time window.' 10 ...
                                    'Replace them with a linear interpolation.'];
            sProcess.Category    = 'Filter';
            sProcess.UseBaseline = 1;
            sProcess.DefaultOverwrite = 1;
            sProcess.blockDimension = 1;
            sProcess.isAvgRef = 0;
            sProcesses(end + 1) = sProcess;
        end
        % OPPOSITE VALUES
        sProcess = sModel;
        sProcess.Name        = 'opposite';
        sProcess.Comment     = '   Opposite values: -A';
        sProcess.FileTag     = '| opposite';
        sProcess.Description = 'Save opposite values for A files.';
        sProcess.Category    = 'Filter';
        sProcess.DefaultOverwrite = 1;
        sProcess.isSourceAbsolute = 0;
        sProcess.blockDimension   = 1;
        sProcess.isAvgRef = 0;
        sProcesses(end + 1) = sProcess;

        % === AVERAGING ===          
        if isAll || (nbSamplesA >= 2)
            sProcess = sModel;
            sProcess.Comment = '<B>==== AVERAGING =============</B>';
            sProcess.Description = 'Please select a process...';
            sProcess.isSourceAbsolute = 2;
            sProcesses(end + 1) = sProcess;
            % GRAND-AVERAGE A (MEAN/CONDITION)
            sProcess = sModel;
            sProcess.Name        = 'GAVE';
            sProcess.Comment     = '   Average by condition (Grand-average)';
            sProcess.FileTag     = '';
            sProcess.Description = ['Grand averages for each condition' 10 ...
                                    'One output file per condition.'];
            sProcess.Category    = 'Average';
            sProcesses(end + 1) = sProcess;
            % AVERAGE BY SUBJECT
            sProcess = sModel;
            sProcess.Name        = 'SubjAvg';
            sProcess.Comment     = '   Average by subject';
            sProcess.FileTag     = '';
            sProcess.Description = ['Average all the recordings for each subject.' 10 ...
                                    'One output file per subject.'];
            sProcess.Category    = 'Average';
            sProcesses(end + 1) = sProcess;
            % AVERAGE A
            sProcess = sModel;
            sProcess.Name        = 'meanA';
            sProcess.Comment     = '   Average everything';
            sProcess.FileTag     = '<#A#>';
            sProcess.Description = ['Average of all files.' 10 'Only one output file.'];
            sProcess.Category    = 'Average';
            sProcesses(end + 1) = sProcess;
        end

        % === DATA EXTRACTION ===
        sProcess = sModel;
        sProcess.Comment = '<B>==== EXTRACT DATA ===========</B>';
        sProcess.Description = 'Please select a process...';
        sProcess.isSourceAbsolute = 2;
        sProcesses(end + 1) = sProcess;
        % MEAN FOR A TIME WINDOW
        sProcess = sModel;
        sProcess.Name        = 'timemean';
        sProcess.Comment     = '   Average over a time window';
        sProcess.FileTag     = '| timemean#TIME#';
        sProcess.Description = ['Average for each file over the selected time window.' 10 ...
                                'Use absolute values for sources.'];
        sProcess.Category    = 'Extract';
        sProcesses(end + 1) = sProcess;
        % VARIANCE FOR A TIME WINDOW
        sProcess = sModel;
        sProcess.Name        = 'timevar';
        sProcess.Comment     = '   Variance over a time window';
        sProcess.FileTag     = '| timevar#TIME#';
        sProcess.Description = 'Variance for each file over the selected time window.';
        sProcess.Category    = 'Extract';
        sProcesses(end + 1) = sProcess;
        % EXTRACT DATA FROM SAMPLES
        sProcess = sModel;
        sProcess.Name        = 'extract';
        sProcess.Comment     = '   Extract data block (cluster,time)';
        sProcess.FileTag     = '| extract#TIME#';
        sProcess.Description = 'Get a block of data from each file.';
        sProcess.Category    = 'Extract';
        sProcess.isSourceAbsolute = 0;       
        sProcesses(end + 1) = sProcess;

        % === NEUROMAG RECORDINGS ===
        if isAll || isData
            sProcess = sModel;
            sProcess.Comment = '<B>==== NEUROMAG RECORDINGS =====</B>';
            sProcess.Description = 'Please select a process...';
            sProcess.isSourceAbsolute = 2;
            sProcesses(end + 1) = sProcess;
            % GRADIOMETERS NORM
            sProcess = sModel;
            sProcess.Name        = 'gradnorm';
            sProcess.Comment     = '   Norm of gradiometers couples';
            sProcess.FileTag     = '| gradnorm';
            sProcess.Description = 'Compute the norm for each gradiometer couple.';
            sProcess.Category    = 'Filter';
            sProcess.UseBaseline = 0; 
            sProcess.isAvgRef    = 0;
            sProcesses(end + 1) = sProcess;
        end

        % === SPECTRAL ANALYSIS ===   
        if isAll || ~isData
            sProcess = sModel;
            sProcess.Comment = '<B>==== SPECTRAL ANALYSIS ========</B>';
            sProcess.isSourceAbsolute = 2;
            sProcess.Description = 'Please select a process...';
            sProcesses(end + 1) = sProcess;
            % Frequency-Band SAMPLE SPECTRAL DECOMPOSITION 
            sProcess = sModel;
            sProcess.Name        = 'spectDecomp';
            sProcess.Comment     = '   Spectral decomposition and statistics';
            sProcess.FileTag     = '';
            sProcess.Description = ['Computes power in multiple, standard frequency bands.' 10 ...
                'Yields average, standard deviation and t-statistics across samples.' 10 ...
                'WARNING: Only applies to KERNEL sources files.'];
            sProcess.Category    = 'Spectral';
            sProcess.isSourceAbsolute = 0;
            sProcesses(end + 1) = sProcess;

            % Power spectrum analysis
            sProcess = sModel;
            sProcess.Name        = 'powerSpectrum';
            sProcess.Comment     = '   Fourier magnitude';
            sProcess.FileTag     = '';
            sProcess.Description = ['Transforms each time series in file into spectral domain (modulus of Fourier transform). ' ...
                'Time vector is replaced by corresponding frequency bin used in Fourier tranform.' 10 ...
                'WARNING: Only applies to KERNEL sources files.'];
            sProcess.Category    = 'Spectral';
            sProcess.isSourceAbsolute = 0;
            sProcesses(end + 1) = sProcess;
        end

        % === RECURRENCE MAPS===
        if isAll || ~isData
            sProcess = sModel;
            sProcess.Comment = '<B>==== RECURRENCE MAPS ========</B>';
            sProcess.isSourceAbsolute = 2;
            sProcess.Description = 'Please select a process...';
            sProcesses(end + 1) = sProcess;
             sProcess = sModel;
            sProcess.Name        = 'recMaps';
            sProcess.Comment     = '   Recurrence maps of activations';
            sProcess.FileTag     = '';
            sProcess.Description = ['Computes recurrence maps across samples.' 10 ...
                'Source maps above 75% activation are thresholded and binarized before being summed across samples.' 10 ...
                'WARNING: Only applies to KERNEL sources files.'];
            sProcess.Category    = 'Recurrence';
            sProcess.isSourceAbsolute = 1;
            sProcesses(end + 1) = sProcess;
        end

         % === SCOUTS functional Connectivity ===
        if isAll || ~isData
            sProcess = sModel;
            sProcess.Comment = '<B>==== Scouts f-Connectivity ========</B>';
            sProcess.isSourceAbsolute = 2;
            sProcess.Description = 'Please select a process...';
            sProcesses(end + 1) = sProcess;
             sProcess = sModel;
            sProcess.Name        = 'fScoutConnect';
            sProcess.Comment     = '   Functional connectivity between cortical scouts';
            sProcess.FileTag     = '';
            sProcess.Description = ['Evaluate functional connectivity between cortical scouts.' 10 ...
                'Under development: use with caution.' 10 ...
                'WARNING: Only applies to KERNEL sources files.'];
            sProcess.Category    = 'fConnectivity';
            sProcess.isSourceAbsolute = 0;
            sProcesses(end + 1) = sProcess;
        end
    end

    % ===== "A/B" PROCESSES =====
    if isAll || (NbSamplesSets == 2)
        % Differences : same number of samples in each set
        if isAll || (nbSamplesA == nbSamplesB)
            % DIFFERENCE: A - B
            sProcess = sModel;
            sProcess.Name        = 'diffAB';
            sProcess.Comment     = '   A - B';
            sProcess.FileTag     = '#A#-#B#';
            sProcess.Description = ['Difference of each couple of samples (A-B).' 10 10 ...
                                    'Each pair must share the same anatomy.' 10 ...
                                    'Result is stored in a new condition.'];
            sProcess.Category = 'Filter2';
            sProcesses(end + 1)  = sProcess;
            % AVERAGE: Average(A,B)
            sProcess = sModel;
            sProcess.Name        = 'meanAB';
            sProcess.Comment     = '   Average(A,B)';
            sProcess.FileTag     = 'Average(#A#,#B#)';
            sProcess.Description = ['Average of each couple of samples (A,B).' 10 10 ...
                                    'Each pair must share the same anatomy.' 10 ...
                                    'Result is stored in a new condition.'];
            sProcess.Category = 'Filter2';
            sProcesses(end + 1) = sProcess;
        end
    end


    % ===== SIMPLE T-TESTS =====
    % NEW: t-test equal variance
    sTest = sModel;
    sTest.Name        = 'ttest';
    sTest.Comment     = '   t-test (equal variances)';
    sTest.FileTag     = 'ttest: #A# vs. #B#';
    sTest.Description = ['Student''s t-test for equal variances.' 10 10 ...
                         'New version: use much less memory.'];
    sTest.Category    = 'TTest';       
    sSimpleTests(end + 1) = sTest;
    % NEW: t-test unequal variance
    sTest = sModel;
    sTest.Name        = 'uttest';
    sTest.Comment     = '   t-test (unequal variances)';
    sTest.FileTag     = 'uttest: #A# vs. #B#';
    sTest.Description = ['Student''s t-test for unequal variances.' 10 10 ...
                         'New version: use much less memory.'];
    sTest.Category    = 'TTest';       
    sSimpleTests(end + 1) = sTest;
    % Paired t-test and old versions need the same number of samples in both sets
    if isAll || (nbSamplesA == nbSamplesB)
        % NEW: paired t-test
        sTest = sModel;
        sTest.Name        = 'pttest';
        sTest.Comment     = '   t-test (paired)';
        sTest.FileTag     = 'pttest: #A# vs. #B#';
        sTest.Description = ['Student''s t-test for paired samples.' 10 10 ...
                             'Use for testing conditions across different subjects.' 10 ...
                             'New version: use much less memory.'];
        sTest.Category    = 'TTest';
        sTest.isPaired    = 1;
        sSimpleTests(end + 1) = sTest;
        % OLD: t-test equal variances
        sTest = sModel;
        sTest.Name        = 'old_ttest';
        sTest.Comment     = '   OLD t-test (equal variances)';
        sTest.FileTag     = 'old_ttest: #A# vs. #B#';
        sTest.Description = ['Student''s t-test for equal variances.' 10 10 ...
                             'Old version: might be faster and more precise.'];
        sTest.Category    = 'TTest';       
        sSimpleTests(end + 1) = sTest;
        % OLD: t-test unequal variance
        sTest = sModel;
        sTest.Name        = 'old_uttest';
        sTest.Comment     = '   OLD t-test (unequal variances)';
        sTest.FileTag     = 'old_uttest: #A# vs. #B#';
        sTest.Description = ['Student''s t-test for unequal variances.' 10 10 ...
                             'Old version: might be faster and more precise.'];
        sTest.Category    = 'TTest';       
        sSimpleTests(end + 1) = sTest;
        % OLD: paired t-test
        sTest = sModel;
        sTest.Name        = 'old_pttest';
        sTest.Comment     = '   OLD t-test (paired)';
        sTest.FileTag     = 'old_pttest: #A# vs. #B#';
        sTest.Description = ['Student''s t-test for paired samples.' 10 10 ...
                             'Use for testing conditions across different subjects.' 10 ...
                             'Old version: might be faster and more precise.'];
        sTest.isPaired    = 1;
        sTest.Category    = 'TTest';       
        sSimpleTests(end + 1) = sTest;
    end


    % ===== PERMUTATION TESTS =====
    % PERM: t-test (independent)
    sTest = sModel;
    sTest.Name        = 'ttest';
    sTest.Comment     = '   t-test (independent)';
    sTest.FileTag     = 'ttest: #A# vs. #B#';
    sTest.Description = 'Student''s t-test for independent samples.';
    sTest.Category    = 'PermTest';       
    sPermTests(end + 1) = sTest;
    % PERM: t-test (paired)
    sTest = sModel;
    sTest.Name        = 'pairedttest';
    sTest.Comment     = '   t-test (paired)';
    sTest.FileTag     = 'pairedttest: #A# vs. #B#';
    sTest.Description = 'Student''s t-test for paired samples.';
    sTest.Category    = 'PermTest';   
    sTest.isPaired    = 1;
    sPermTests(end + 1) = sTest;
    % PERM: Sign of the differences
    sTest = sModel;
    sTest.Name        = 'signtest';
    sTest.Comment     = '   signtest (paired)';
    sTest.FileTag     = 'signtest: #A# vs. #B#';
    sTest.Description = 'Sign of the differences.';
    sTest.Category    = 'PermTest';      
    sTest.isPaired    = 1;
    sPermTests(end + 1) = sTest;
    % PERM: Wilcoxon
    sTest = sModel;
    sTest.Name        = 'wilcoxon';
    sTest.Comment     = '   wilcoxon (paired)';
    sTest.FileTag     = 'wilcoxon: #A# vs. #B#';
    sTest.Description = 'Signed ranks.';
    sTest.Category    = 'PermTest';       
    sTest.isPaired    = 1;
    sPermTests(end + 1) = sTest;
    % PERM: Difference of the means
    sTest = sModel;
    sTest.Name        = 'difftest';
    sTest.Comment     = '   Difference of the means';
    sTest.FileTag     = 'difftest: #A# vs. #B#';
    sTest.Description = 'Difference of the means.';
    sTest.Category    = 'PermTest';       
    sPermTests(end + 1) = sTest;
    
    % ===== ANOVA =====
    % 
        sTest = sModel;
        sTest.Name        = 'RM-Anova';
        sTest.Comment     = 'Anova (under dev.)';
        sTest.FileTag     = 'Anova';
        sTest.Description = 'Repeated measures parametric Analysis of Variance';
        sTest.Category    = 'Anova';       
        sAnova(end + 1) = sTest;

end

    

%% ===== FORMAT CONDITIONS STRING =====
function str = FormatConditionsString(Samples, Default)
    % If no samples
    if isempty(Samples)
        str = '';
        return
    end
    % Get the best way to display the sets names
    uniqueCond = unique({Samples.Condition});
    uniqueSubj = unique({Samples.SubjectName});
    isUniqueCond = (length(uniqueCond) == 1);
    isUniqueSubj = (length(uniqueSubj) == 1);
    % Switch
    if isUniqueCond && isUniqueSubj
        str = fullfile(uniqueSubj{1}, uniqueCond{1});
    elseif isUniqueCond
        str = uniqueCond{1};
    elseif isUniqueSubj
        str = uniqueSubj{1};
    else
        str = Default;
    end
end


%% ===== FORMAT COMMENT =====
function Comment = FormatComment(sProcess, Conditions, TimeRange)  
    % ===== BUILD COMMENT STRINGS =====
    sA = Conditions.SamplesA;
    sB = Conditions.SamplesB;
    CommentA = '';
    CommentB = '';
    % Extract some more information
    isSampleBySample = ismember(sProcess.Category, {'Filter2', 'Filter', 'Extract'});

    % === SAMPLE BY SAMPLE: A/B ===
    if isSampleBySample && (length(sA) == 1) && (length(sB) == 1)
        if strcmpi(sA.SubjectFile, sB.SubjectFile) && strcmpi(sA.Condition, sB.Condition)
            CommentA = sA.Comment;
            CommentB = sB.Comment;
        elseif io_compareFileNames(sA.SubjectFile, sB.SubjectFile)
            CommentA = sA.Condition;
            CommentB = sB.Condition;
        elseif strcmpi(sA.Condition, sB.Condition)
            CommentA = fullfile(sA.SubjectName, sA.Condition);
            CommentB = fullfile(sB.SubjectName, sB.Condition);
        else
            CommentA = fullfile(sA.SubjectName, sA.Condition);
            CommentB = fullfile(sB.SubjectName, sB.Condition);
        end
    % === AVERAGE ===
    elseif ~isSampleBySample
        CommentA = FormatConditionsString(sA, 'A');
        CommentB = FormatConditionsString(sB, 'B');
        if strcmpi(CommentA, CommentB)
            CommentA = '';
            CommentB = '';
        end
    end

    % Build string for time interval
    if (max(abs(TimeRange)) > 2)
        strTime = sprintf('(%1.2fs,%1.2fs)', TimeRange);
    else
        strTime = sprintf('(%dms,%dms)', round(TimeRange * 1000));
    end
    % Apply process naming
    if ~isempty(CommentA) || isempty(sB)
        Comment = sProcess.FileTag;
        Comment = strrep(Comment, '#A#', CommentA);
        Comment = strrep(Comment, '#B#', CommentB);
        Comment = strrep(Comment, '#TIME#', strTime);
    else
        Comment = '';
    end
end
    
    
%% ===== GET CLUSTERS =====
% OUTPUT:
%    - sClusters : -1, if no channel file available for at least one sample
%                  -2, if no clusters available
%                  Else, return an array of Cluster structures
function [sClusters, iClusters] = GetClusters(Cond)
    % Get unique list of studies
    iStudies = unique([Cond.SamplesA.iStudy, Cond.SamplesB.iStudy]);
    % Process all studies
    for i = 1:length(iStudies)
        % Get study structure
        iStudy = iStudies(i);
        %sStudy = bst_getContext('Study', iStudy);
        sChannel = bst_getContext('ChannelForStudy', iStudy);
        % Check that a ChannelFile is defined for this study
        if isempty(sChannel)
            sClusters = -1;
            iClusters = [];
            return
        end
    end
    % Get the scouts available for this surface
    [sClusters, iClusters] = panel_clusters('GetClusters');
    % If no scout avaialable: error
    if isempty(sClusters)
        sClusters = -2;
        iClusters = [];
        return;
    end
end


%% ===== GET SCOUTS =====
% OUTPUT:
%    - sScouts : -1, if all samples do not refer to the same cortical surface
%                -2, if no scout avaialable
%                Else, return an array of scout structures
function [sScouts, iScouts] = GetScouts(Cond)
    iScouts = [];
    % Get studies and results indices
    iStudies = [Cond.SamplesA.iStudy, Cond.SamplesB.iStudy];
    iResults = [Cond.SamplesA.iItem,   Cond.SamplesB.iItem];
    SurfaceFile = [];
    % Process all studies
    for i = 1:length(iStudies)
        iStudy = iStudies(i);
        sStudy = bst_getContext('Study', iStudy);
        % Get result file
        ResultsMat = in_results_bst(sStudy.Result(iResults(i)).FileName, 0, 'SurfaceFile');
        % If it is first results: store the surface file
        if isempty(SurfaceFile)
            SurfaceFile = ResultsMat.SurfaceFile;
        % If surface file is not the same than previous files: error
        elseif ~io_compareFileNames(ResultsMat.SurfaceFile, SurfaceFile)
            sScouts = -1;
            return
        end
    end
    % Get the scouts available for this surface
    [sScouts, iScouts] = panel_scouts('GetScoutsWithSurface', SurfaceFile);
    % If no scout avaialable: error
    if isempty(sScouts)
        sScouts = -2;
        return;
    end
end


%% ================================================================================================
%  ===== HELPERS ==================================================================================
%  ================================================================================================
%% ===== GET FILE TIME VECTOR =====
function TimeVector = GetFileTimeVector(iStudy, iItem, isData)
    TimeVector = [];
    % Get protocols directories
    ProtocolInfo = bst_getContext('ProtocolInfo');
    % Get study
    sStudy = bst_getContext('Study', iStudy);
    % Load time range from this file
    if (isData)
        % Build filename
        filename = fullfile(ProtocolInfo.STUDIES, sStudy.Data(iItem).FileName);
        % Load time vector
        DataMat = load(filename, 'Time');
        if ~isempty(DataMat) && isfield(DataMat, 'Time') && ~isempty(DataMat.Time)
            TimeVector = DataMat.Time;
        end
    else
        % Build filename
        refFilename = fullfile(ProtocolInfo.STUDIES, sStudy.Result(iItem).FileName);
        % Resvole link
        refFilename = resolveResultsLink(refFilename);
        % Is results file is a kernel-only file
        isKernel = ~isempty(strfind(refFilename, 'KERNEL'));
        % KERNEL
        if isKernel
            % No time information available in file => Use DataMat results
            DataFile     = strrep(sStudy.Result(iItem).DataFile, ProtocolInfo.STUDIES, '');
            DataFileFull = fullfile(ProtocolInfo.STUDIES, DataFile);
            DataMat      = load(DataFileFull, 'Time');
            if ~isempty(DataMat) && isfield(DataMat, 'Time') && ~isempty(DataMat.Time)
                TimeVector = DataMat.Time;
            end
        % FULL RESULTS FILE
        else
            % Load time vector
            ResultMat = in_results_bst(refFilename, 0, 'ImageGridTime');
            if ~isempty(ResultMat) && isfield(ResultMat, 'ImageGridTime')
                TimeVector = ResultMat.ImageGridTime;
            end
        end
    end
end


