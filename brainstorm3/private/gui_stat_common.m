function varargout = gui_stat_common(varargin)
% GUI_STAT_COMMON: Support functions, common to all the stat GUI.

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
% Authors: Francois Tadel, 2009
% ----------------------------- Script History ---------------------------------
% FT  10-Jul-2009  Creation
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


%% ===== CHECK CONDITIONS =====
function isOk = CheckConditions(PanelName)
    global GlobalData;
    isOk = 0;
    
    % ===== GET SAMPLES =====
    % Get conditions
    Conditions = gui_stat_common('GetConditions', PanelName);
    if isempty(Conditions)
        return
    end
    isData = strcmpi(Conditions.DataType, 'data');
    % Check samples number
    switch lower(PanelName)
        case 'statistics'
            iStudies = [Conditions.SamplesA.iStudy, Conditions.SamplesB.iStudy];
            iItems   = [Conditions.SamplesA.iItem, Conditions.SamplesB.iItem];
            SamplesFiles = cat(2, GlobalData.Stat.SampleFilesAA, GlobalData.Stat.SampleFilesAB);
        case 'processes'
            iStudies = [Conditions.SamplesA.iStudy];
            iItems   = [Conditions.SamplesA.iItem];
            SamplesFiles = GlobalData.Stat.SampleFilesA;
    end

    % ===== CHECK FOR MODIFICATIONS =====
    % Check number of elements
    if (length(SamplesFiles) ~= length(iStudies))
        return
    end
    % Check all the samples
    for i = 1:length(SamplesFiles)
        % Get study
        sStudy = bst_getContext('Study', iStudies(i));
        if isempty(sStudy)
            return
        end
        % Get filenames
        if isData
            if (iItems(i) > length(sStudy.Data))
                return
            end
            CurFile = sStudy.Data(iItems(i)).FileName;
        else
            if (iItems(i) > length(sStudy.Result))
                return
            end
            CurFile = sStudy.Result(iItems(i)).FileName;
        end
        % Compare with saved filename
        if ~io_compareFileNames(CurFile, SamplesFiles{i})
            return
        end
    end
    isOk = 1;
end


%% ===== TREE KEYBOARD CALLBACK =====
function TreeKeyboard_Callback(hObj, ev)
    % Switch between actions
    switch (ev.getKeyCode())
        % DELETE/BACKSPACE : DELETE NODE CALLBACK
        case {ev.VK_DELETE, ev.VK_BACK_SPACE}
            DeleteSelectedNodes(ev.getSource());
    end
end


%% ===== GET SELECTED DATA TYPE =====
function DataType = GetDataType(panelName)
    % Get panel controls
    ctrl = bst_getContext('PanelControls', panelName);
    % Get DataType
    if ctrl.jButtonRecordings.isSelected()
        DataType = 'data';
    else
        DataType = 'results';
    end
end


%% ===== DELETE SELECTED NODES =====
function DeleteSelectedNodes(bstTree)
    % Get selected nodes
    treeModel = awtinvoke(bstTree, 'getModel()');
    treeSelPaths = awtinvoke(bstTree, 'getSelectionPaths()');
    % Delete each selected node
    for iNode = 1:length(treeSelPaths)
        awtinvoke(treeModel, 'removeNodeFromParent(Ljavax.swing.tree.MutableTreeNode;)', ...
            treeSelPaths(iNode).getLastPathComponent());
    end
    awtinvoke(bstTree, 'refresh()');
end


%% ===== GET NODES IN TREE =====
function bstNodes = GetTreeNodes(bstTree)
    % Get root node
    nodeRoot = bstTree.getModel.getRoot();
    if (nodeRoot.getChildCount() == 0)
        bstNodes = [];
        return
    end
    % Get all the children
    bstNodes = javaArray('org.brainstorm.tree.BstNode', nodeRoot.getChildCount());
    for i = 1:nodeRoot.getChildCount()
        bstNodes(i) = nodeRoot.getChildAt(i-1);
    end
end


%% ===== UPDATE ITEM COUNTS =====
function UpdateItemProperties(bstTree, listName, isForced)
    global GlobalData;
    % Parse inputs
    if (nargin < 3)
        isForced = 0;
    end
    
    % === COUNT ITEMS DEPENDENCIES ===
    % Get nodes in target tree
    bstNodes = GetTreeNodes(bstTree);
    % Get options
    if strcmpi(listName, 'SampleFilesA')
        DataType = GetDataType('Processes');
    else
        DataType = GetDataType('Statistics');
    end
    iAllStudies = [];
    iAllItems   = [];
    % For each node: update item count in comment
    for iNode = 1:length(bstNodes)
        % Get number of dependent items
        [iDepStudies, iDepItems] = tree_getDependencies(bstNodes(iNode), DataType);
        iAllStudies = [iAllStudies, iDepStudies];
        iAllItems   = [iAllItems,   iDepItems];
        % Ignore nodes that were already processed
        nodeComment = char(bstNodes(iNode).getComment());
        if ~isempty(strfind(nodeComment, '[')) && ~isForced
            continue;
        end
        % Remove previous items count
        nodeComment = strRemoveParenthesis(nodeComment, '[');
        % Add items count
        nodeComment = sprintf('%s [%d]', nodeComment, length(iDepItems));
        % Update node comment
        awtinvoke(bstNodes(iNode), 'setComment(Ljava.lang.String;)', nodeComment);
    end
    % Compute total number of items
    totalNbItems = length(iAllItems);
    % Save the sample filenames (to be able to check for database modifications later)
    SampleFiles = bst_getContext('GetFileNames', iAllStudies, iAllItems, DataType);
    GlobalData.Stat.(listName) = SampleFiles;
    
    % === UPDATE TREE DISPLAY (items and title) ===
    jParentPanel = bstTree.getParent.getParent.getParent();
    titledBorder = jParentPanel.getBorder();
    strTitle = strRemoveParenthesis(char(titledBorder.getTitle()), '[');
    strTitle = sprintf('%s  [%d]', strTitle, totalNbItems);
    awtinvoke(titledBorder, 'setTitle(Ljava.lang.String;)', strTitle);
    %jParentPanel.updateUI(); 
    awtinvoke(bstTree,      'updateUI()');
    awtinvoke(jParentPanel, 'updateUI()');
end


%% ===== GET SAMPLES =====
% USAGE:  sSamples = GetSamples(jTree, DataType, FilterFileTag) : Return all the samples in JTree
%         sSamples = GetSamples()                               : Return an empty samples structure
function sSamples = GetSamples(jTree, DataType, FilterFileTag) 
    % Get protocol directories
    ProtocolInfo = bst_getContext('ProtocolInfo');
    % Samples structure
    sSamples = repmat(struct('iStudy', 0, ...
                             'iItem',  0, ...
                             'FileName', '', ...
                             'FullFileName', '', ...
                             'Comment',      '', ...
                             'Condition',    '', ...
                             'SubjectFile',  ''), 0);
    % If no argment: return the empty structure
    if (nargin == 0) || isempty(jTree)
        return
    end
    
    % === GET FILES IN TREE ===
    % Get tree nodes
    bstNodes = gui_stat_common('GetTreeNodes', jTree);
    % For each node: get dependencies
    iStudies = [];
    iItems   = [];
    for iNode = 1:length(bstNodes)
        [iNewStudies, iNewItems] = tree_getDependencies(bstNodes(iNode), DataType, FilterFileTag);
        iStudies = [iStudies, iNewStudies];
        iItems   = [iItems,   iNewItems];
    end
    
    % === GET SAMPLES DESCRIPTION === 
    for i = 1:length(iStudies)
        % Get study
        sStudy = bst_getContext('Study', iStudies(i));
        sSamples(i).iStudy = iStudies(i);
        sSamples(i).iItem  = iItems(i);
        % Get subject
        sSamples(i).SubjectFile = sStudy.BrainStormSubject;
        sSubject = bst_getContext('Subject', sSamples(i).SubjectFile);
        sSamples(i).SubjectName = sSubject.Name;
        % Data or results
        switch lower(DataType)
            case 'data'
                sSamples(i).FileName = sStudy.Data(iItems(i)).FileName;
                sSamples(i).Comment  = sStudy.Data(iItems(i)).Comment;
            case 'results'
                sSamples(i).FileName = sStudy.Result(iItems(i)).FileName;
                sSamples(i).Comment  = sStudy.Result(iItems(i)).Comment;
            otherwise
                error('???');
        end
        % Full filename
        sSamples(i).FullFileName = fullfile(ProtocolInfo.STUDIES, sSamples(i).FileName);
        % Condition
        if ~isempty(sStudy.Condition)
            sSamples(i).Condition = sStudy.Condition{1};
        else
            sSamples(i).Condition = sStudy.Name;
        end
    end
end

%% ===== GET CONDITIONS =====
% Return the current Conditions structure:
%    |- DataType: {'data', 'results'}
%    |- SamplesA: 
%    |     |- iStudies: Array of study indices
%    |     |- iItems:   Array of data or results indices
%    |- SamplesB: (NULL if only one condition)
%          |- iStudies: Array of study indices
%          |- iItems:   Array of data or results indices
%
% USAGE:  Cond = GetConditions()
%         Cond = GetConditions(FilterFileTag)
%
% INPUT:
%    - FilterFileTag: Put a condition to the filenames to be selected
%                     'normal' excludes file tags : 'zscore', 'timemean'
function Conditions = GetConditions(PanelName, FilterFileTag)
    % Parse inputs
    if (nargin < 2)
        FilterFileTag = '';
    end
    % Get data type
    Conditions.DataType = GetDataType(PanelName);   
    % Get panel controls
    ctrl = bst_getContext('PanelControls', PanelName);
    
    % What is the calling panel: stat or processes
    switch (PanelName)
        case 'Processes'
            Conditions.NbSamplesSets = 1;
            Conditions.SamplesA = GetSamples(ctrl.jTreeFiles, Conditions.DataType, FilterFileTag);
            Conditions.SamplesB = GetSamples();
        case 'Statistics'
            Conditions.NbSamplesSets = 2;
            Conditions.SamplesA = GetSamples(ctrl.jTreeFilesA, Conditions.DataType, FilterFileTag);
            Conditions.SamplesB = GetSamples(ctrl.jTreeFilesB, Conditions.DataType, FilterFileTag);
        otherwise
            error('???');
    end
end



