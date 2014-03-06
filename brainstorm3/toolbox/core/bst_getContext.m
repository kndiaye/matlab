function [bstContext, bstIndex, bstSubIndex] = bst_getContext( varargin )
% BST_GETCONTEXT: Get a Brainstorm structure.
% This function is used to abstract the way that these structures are stored.
%
% USAGE :
% ====== DIRECTORIES ==================================================================
%    - bst_getContext('UserDir')               : User home directory
%    - bst_getContext('BrainStormHomeDir')     : Application directory of brainstorm
%    - bst_getContext('BrainStormUserDir')     : User home directory for brainstorm (<home>/.brainstorm/)
%    - bst_getContext('BrainStormTmpDir')      : User brainstorm temporary directory (Default: <home>/.brainstorm/tmp/)
%    - bst_getContext('BrainStormTmpDir', isForcedDefault)   : User DEFAULT brainstorm temporary directory (<home>/.brainstorm/tmp/)
%    - bst_getContext('BrainStormMexDir')      : User brainstorm temporary directory (<home>/.brainstorm/mex/)
%    - bst_getContext('BrainStormDbFile')      : User brainstorm.mat file (<home>/.brainstorm/brainstorm.mat)
%    - bst_getContext('BrainStormDbDir')       : User database directory (contains all the brainstorm protocols)
%    - bst_getContext('DirDefaultSubject')     : Directory name of the default subject
%    - bst_getContext('DirDefaultStudy')       : Directory name of the default study for each subject
%    - bst_getContext('DirAnalysisInter')      : Directory name of the inter-subject analysis study 
%    - bst_getContext('DirAnalysisIntra')      : Directory name of the intra-subject analysis study (for each subject)
%    - bst_getContext('NormalizedSubjectName') : Name of the subject with a normalized anatomy
%    - bst_getContext('AnatomyDefaults')       : Get the contents of directory bstDir/defaults/anatomy
%    - bst_getContext('EEGDefaults')           : Get the contents of directory bstDir/defaults/eeg
%    - bst_getContext('LastUsedDirs')          : Structure with all the last used directories (last used)
%
% ====== PROTOCOLS ====================================================================
%    - bst_getContext('ProtocolsListInfo')     : List of protocols (definition)
%    - bst_getContext('ProtocolsListSubjects') : List of protocols (subjects)
%    - bst_getContext('ProtocolsListStudies')  : List of protocols (studies)
%    - bst_getContext('iProtocol')             : Indice of current protocol 
%    - bst_getContext('ProtocolInfo')          : Definition structure for current protocol
%    - bst_getContext('ProtocolSubjects')      : Subjects list for current protocol
%    - bst_getContext('ProtocolStudies')       : Studies list for current protocol
%
% ====== STUDIES ======================================================================
%    - bst_getContext('Study', StudyFileName)  : Get one study in current protocol with its file name
%    - bst_getContext('Study', iStudies)       : Get one or more studies
%    - bst_getContext('Study')                 : Get current study in current protocol
%    - bst_getContext('StudyCount')            : Get number of studies in the current protocol
%    - bst_getContext('StudyWithSubject',   SubjectFile)          : Find studies associated with a given subject file (WITHOUT the system studies ('intra_subject', 'default_study'))
%    - bst_getContext('StudyWithSubject',   ..., 'intra_subject') : Find studies ... INCLUDING 'intra_subject' study
%    - bst_getContext('StudyWithSubject',   ..., 'default_study') : Find studies ... INCLUDING 'default_study' study
%    - bst_getContext('StudyWithCondition', ConditionPath)        : Find studies for a given condition path
%    - bst_getContext('StudyWithSubjectAndCondition', SubjectFile, ConditionsList)
%    - bst_getContext('ChannelStudiesWithSubject', iSubjects)     : Get all the studies where there should be a channel file for a list of subjects
%    - bst_getContext('AnalysisIntraStudy', iSubject)    : Get the default analysis study for target subject
%    - bst_getContext('AnalysisInterStudy')              : Get the default analysis study for inter-subject analysis
%    - bst_getContext('DefaultStudy', iSubject)          : Get the default study for target subject (by subject indice)
%    - bst_getContext('DefaultStudy')                    : Get the global default study (common to all subjects)
%    - bst_getContext('DefaultStudy', BrainStormSubject) : Get the default study for target subject (by filename)
%    - bst_getContext('ChannelFile', ChannelFile)        : Find a channel file in current protocol
%    - bst_getContext('ChannelFileForStudy', StudyFile/DataFile)  : Find a channel file in current protocol
%    - bst_getContext('ChannelForStudy',     iStudies)   : Return current Channel struct for target study
%    - bst_getContext('HeadModelForStudy',   iStudy)     : Return current HeadModel struct for target study
%    - bst_getContext('DataFile',    DataFile)           : Find a DataFile in current protocol
%    - bst_getContext('DataForDataList', iStudy, DataListName) : Find all the DataFiles grouped by a data list
%    - bst_getContext('DataForStudy', iStudy)                  : Find all the Data files that are dependent on the channel/headmodel of a given study
%    - bst_getContext('DataForStudies', iStudies)
%    - bst_getContext('DataForChannelFile', ChannelFile)       : Find all the DataFiles that use the given ChannelFile
%    - bst_getContext('ResultsFile', ResultsFile)              : Find a ResultsFile in current protocol
%    - bst_getContext('ResultsForDataFile', DataFile)          : Find all results computed based on DataFile
%    - bst_getContext('StatFile', StatFile)                    : Find a StatFile in current protocol
%    - bst_getContext('StatForDataFile', DataFile, iStudies)
%    - bst_getContext('StatForDataFile', DataFile)
%    - bst_getContext('GetFileNames')
%    - bst_getContext('BestFittingSphere', ChannelFile) : Get a spherical approximation to head shape in the headmodels
%
% ====== SUBJECTS ======================================================================
%    - bst_getContext('Subject', SubjectFileName, isRaw) : Find a subject in current protocol with its file name
%    - bst_getContext('Subject', SubjectDir, isRaw)      : Find a subject in current protocol with its directory
%    - bst_getContext('Subject', iSubject)               : Get a subject (normal or default if iSubject==0)
%    - bst_getContext('Subject')                         : Get current subject in current protocol
%    - bst_getContext('SubjectWithName', Name)           : Find a subject in current protocol with its name
%    - bst_getContext('SubjectCount')                    : Get number of studies in the current protocol
%    - bst_getContext('ConditionsForSubject', SubjectFile)           : Find all conditions for a given subject
%    - bst_getContext('SurfaceFile',          SurfaceFile)           : Find a surface in current protocol
%    - bst_getContext('SurfaceFileByType',    iSubject,    SurfaceType) : Find the default surface for subject #i
%    - bst_getContext('SurfaceFileByType',    SurfaceName, SurfaceType) : Find the default surface for subject that also has surface SurfaceName
%    - bst_getContext('SurfaceFileByType',    MriName,     SurfaceType) : Find the default surface for subject that also has MRI MriName 
%    - bst_getContext('MriFile',              MriFile)               : Find a MRI in current protocol
% 
% ====== GUI =================================================================
%    - bst_getContext('GUI')            : Get GUI structure (handles of Java panels and windows)
%    - bst_getContext('Layout')         : Configuration of the main Brainstorm window
%    - bst_getContext('LayoutManager')  : Name of the function that re-arrange automatically the figures
%    - bst_getContext('ProgressBar')    : Handle to Brainstorm progress bar
%    - bst_getContext('PanelContainer')                : Display list of registered panel containers
%    - bst_getContext('PanelContainer', ContainerName) : Get a panel container handle
%    - bst_getContext('Panel')                         : Display list of registered panels
%    - bst_getContext('Panel',         PanelName)      : Find a panel with its name
%    - bst_getContext('PanelControls', PanelName)      : Get the controls of a panel
%    - bst_getContext('PanelElement',  PanelName, ElementName) : Get an element (control, callback, ...) in a panel
%    - bst_getContext('PanelElement',  ElementName)            : Search for an element (control, callback, ...) in all the panels
%
% ====== CONFIGURATION =================================================================
%    - bst_getContext('Version')               : Brainstorm version
%    - bst_getContext('ByteOrder')             : {'l','b'} - Byte order used to read and save binary files 
%    - bst_getContext('DisplayGFP')            : {0,1} - If 1, the GFP is displayed on all the time series figures
%    - bst_getContext('ExpandTrialsLists')     : {0,1} - If 1, the trials lists are automatically expanded in the tree
%    - bst_getContext('DefaultFormats')        : Default formats for importing/exporting data, channels, ... (last used)
%    - bst_getContext('BEMOptions')            : BEM options
%    - bst_getContext('BFSProperties')         : Conductivities and thicknesses for 3-shell spherical forward model
%    - bst_getContext('ImportCTFOptions')      : Importation options for CTF format
%    - bst_getContext('ImportFIFOptions')      : Importation options for FIF format
%    - bst_getContext('ImportEegRawOptions')   : Importation options for RAW EEG format
%    - bst_getContext('BugReportOptions')      : Bug reporter options
%    - bst_getContext('InverseOptions')        : Importation options for RAW EEG format
%    - bst_getContext('DefaultSurfaceDisplay') : Default display options for surfaces (smooth, data threshold, curvature)
%    - bst_getContext('MagneticExtrapOptions') : Structure with the options for magnetic field extrapolation
%    - bst_getContext('UniformizeTimeSeriesScales') : {0,1} - If 1, the Y-axis of all the time series figures have the scale
%    - bst_getContext('DisplayAverageReference')    : {0,1} - If 1, the EEG recordings will be displayed in average reference
%    - bst_getContext('ReloadDbAtStartup')          : {0,1} - If 1, reload automatically database at each startup
%    - bst_getContext('UseDoubleScreen')            : {0,1} - If 1, if two available display, use both; else use only the first one
%    - bst_getContext('UseSigProcToolbox')     : Use Matlab's Signal Processing Toolbox when available
%
% SEE ALSO bst_setContext

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


%% ==== PARSE INPUTS ====
if ((nargin >= 1) && ischar(varargin{1}))
    contextName = varargin{1};
else
    return
end
% Initialize returned variable
bstContext = [];
bstIndex   = [];
bstSubIndex   = [];


% Get required context structure
switch lower(contextName)
%% ==== BRAINSTORM CONFIGURATION ====
    case 'version'
        if ispref('BrainStorm', 'Version')
            bstContext = getpref('BrainStorm', 'Version');
        else
            bstContext = [];
        end
        
    case 'brainstormhomedir'
        if ispref('BrainStorm', 'brainstormHomeDir')
            bstContext = getpref('BrainStorm', 'brainstormHomeDir');
        else
            bstContext = [];
        end

    case 'userdir'
        try
            userDir = char(java.lang.System.getProperty('user.home'));
        catch
            userDir = '';
        end
        if isempty(userDir)
            userDir = bst_getContext('BrainstormHomeDir');
        end
        bstContext = userDir;
        
    case 'brainstormuserdir'
        bstUserDir = fullfile(bst_getContext('UserDir'), '.brainstorm');
        if ~isdir(bstUserDir)
            res = mkdir(bstUserDir);
            if ~res
                error(['Cannot create Brainstorm user directory: "' bstUserDir '".']); 
            end
        end
        bstContext = bstUserDir;
        
    case 'brainstormtmpdir'
        tmpDir = '';
        isForcedDefault = ((nargin >= 2) && varargin{2});
        % If temporary directory is set in the preferences
        if  ~isForcedDefault && ispref('BrainStorm', 'BrainstormTempDir')
            tmpDir = getpref('BrainStorm', 'BrainstormTempDir');
        end 
        % Else: use directory userdir/tmp
        if isempty(tmpDir)
            tmpDir = fullfile(bst_getContext('BrainStormUserDir'), 'tmp');
        end
        % Create directory if it does not exist yet
        if ~isdir(tmpDir)
            res = mkdir(tmpDir);
            if ~res
                error(['Cannot create Brainstorm temporary directory: "' tmpDir '".']); 
            end
        end
        bstContext = tmpDir;
        
    case 'brainstormmexdir'
        mexDir = fullfile(bst_getContext('BrainStormUserDir'), 'mex');
        if ~isdir(mexDir)
            res = mkdir(mexDir);
            if ~res
                error(['Cannot create Brainstorm mex-files directory: "' mexDir '".']); 
            end
        end
        bstContext = mexDir;
        
    case 'brainstormdbfile'
        bstContext = fullfile(bst_getContext('BrainStormUserDir'), 'brainstorm.mat');
        
    case 'brainstormdbdir'
        BrainStormDbDir = getappdata(0, 'BrainStormDbDir');
        if ~isempty(BrainStormDbDir);
            bstContext = BrainStormDbDir;
            bstIndex   = 1;
        else
            % Ask user where is located
            bstContext = fullfile(bst_getContext('UserDir'), 'brainstorm_db');
            bstIndex   = 0;
        end
        
    
%% ==== PROTOCOLS LIST ====
    case 'protocolslistinfo'
        bstContext = getappdata(0, 'ProtocolInfo');
    case 'protocolslistsubjects'
        bstContext = getappdata(0, 'ProtocolSubjects');
    case 'protocolsliststudies'
        bstContext = getappdata(0, 'ProtocolStudies'); 
        
        
%% ==== PROTOCOL ====
    case 'iprotocol'
        bstContext = getappdata(0, 'iProtocol');
        if isempty(bstContext)
            bstContext = 0;
        end
    case {'protocolinfo', 'protocolsubjects', 'protocolstudies'}
        % Get protocols list (if empty : return)
        ProtocolsList = getappdata(0, contextName);
        if isempty(ProtocolsList)
            return
        end;
        % Get protocol index
        bstIndex = getappdata(0, 'iProtocol');
        % Check index integrity
        if ((bstIndex <= 0) || (bstIndex > length(ProtocolsList))), warning('Brainstorm:InvalidIndex', 'Invalid index'), return, end
        % Get requested protocol structure
        bstContext = ProtocolsList(bstIndex);

        
%% ==== STUDY ====
    % Usage: [sStudy, iStudy] = bst_getContext('Study', StudyFileName)
    %        [sStudy, iStudy] = bst_getContext('Study')
    %        [sStudy, iStudy] = bst_getContext('Study', iStudies)
    case 'study'
        % Get list of current protocol description
        ProtocolInfo = bst_getContext('ProtocolInfo');
        % Get list of current protocol studies
        ProtocolStudies = bst_getContext('ProtocolStudies');
        if isempty(ProtocolStudies) || isempty(ProtocolInfo) % || isempty(ProtocolInfo.iStudy)
            return;
        end
        % ===== PARSE INPUTS =====
        if (nargin < 2)
            % Call: bst_getContext('Study');
            iStudies = ProtocolInfo.iStudy;
            StudyFileName = [];
        elseif (isnumeric(varargin{2})) 
            iStudies = varargin{2};
            StudyFileName = [];
        elseif (ischar(varargin{2}))
            iStudies = [];
            StudyFileName = strrep(varargin{2}, ProtocolInfo.STUDIES, '');
        end
        % Indices
        iAnalysisStudy = -2;    % CANNOT USE -1 => DISABLES SEARCH FUNCTIONS
        iDefaultStudy  = -3;
        % Indices > 0: normal studies indiced in ProtocolStudies.Study array
            
        % ===== GET STUDY BY INDEX =====
        % Call: bst_getContext('Study', iStudies);
        if ~isempty(iStudies) 
            bstContext = repmat(db_getDataTemplate('Study'), 0);
            % Get analysis study
            iTargetAnalysis = find(iStudies == iAnalysisStudy);
            if ~isempty(iTargetAnalysis) 
                bstContext(iTargetAnalysis) = repmat(ProtocolStudies.AnalysisStudy, size(iTargetAnalysis));
                bstIndex(iTargetAnalysis)   = repmat(iAnalysisStudy, size(iTargetAnalysis));
            end
            % Get default study
            iTargetDefault = find(iStudies == iDefaultStudy);
            if ~isempty(iTargetDefault) 
                try
                    bstContext(iTargetDefault) = repmat(ProtocolStudies.DefaultStudy, size(iTargetDefault));
                catch ME
                    if isempty(bstContext)
                        bstContext= repmat(ProtocolStudies.DefaultStudy, size(iTargetDefault));
                    else
                        rethrow(ME)
                    end
                end
                bstIndex(iTargetDefault)   = repmat(iDefaultStudy, size(iTargetDefault));
            end
            % Get normal studies
            iTargetNormal = find((iStudies >= 1) & (iStudies <= length(ProtocolStudies.Study)));
            if ~isempty(iTargetNormal)
                bstContext(iTargetNormal) = ProtocolStudies.Study(iStudies(iTargetNormal));
                bstIndex(iTargetNormal)   = iStudies(iTargetNormal);
            end
            % Error
            if isempty(bstContext)
                %warning('Brainstorm:InvalidIndex', 'Invalid study indice.');
                bstContext = [];
                ProtocolInfo.iStudy = [];
                bst_setContext('ProtocolInfo', ProtocolInfo);
            end
            
        % ===== GET STUDY BY FILENAME =====
        % Call: bst_getContext('Study', StudyFileName);
        elseif ~isempty(StudyFileName)
            % NORMAL STUDY
            iStudy = find(io_compareFileNames({ProtocolStudies.Study.FileName}, StudyFileName), 1);
            % If a study is found : return it
            if ~isempty(iStudy)
                bstContext = ProtocolStudies.Study(iStudy);
                bstIndex   = iStudy;
            % DEFAULT STUDY
            elseif ~isempty(ProtocolStudies.DefaultStudy) && io_compareFileNames({ProtocolStudies.DefaultStudy.FileName}, StudyFileName)
                bstContext = ProtocolStudies.DefaultStudy;
                bstIndex   = iDefaultStudy;
            % ANALYSIS STUDY
            elseif ~isempty(ProtocolStudies.AnalysisStudy) && io_compareFileNames({ProtocolStudies.AnalysisStudy.FileName}, StudyFileName)
                bstContext = ProtocolStudies.AnalysisStudy;
                bstIndex   = iAnalysisStudy;
            end
        else
            return
        end
 
        
%% ==== STUDY WITH SUBJECT FILE ====
    % Usage : [sStudies, iStudies] = bst_getContext('StudyWithSubject', SubjectFile) : WITHOUT the system studies ('intra_subject', 'default_study')
    %         [sStudies, iStudies] = bst_getContext(..., 'intra_subject', 'default_study') : WITH the system studies: 'intra_subject' | 'default_study'
    case 'studywithsubject'
        % Parse inputs
        if (nargin < 2) || ~ischar(varargin{2})
            error('Invalid call to bst_getContext()');
        end
        if (nargin > 2)
            IntraStudies   = any(strcmpi(varargin(3:end), 'intra_subject'));
            DefaultStudies = any(strcmpi(varargin(3:end), 'default_study'));
        else
            IntraStudies   = 0;
            DefaultStudies = 0;
        end
        SubjectFile = {varargin{2}};
        
        % Get list of current protocol description
        ProtocolInfo    = bst_getContext('ProtocolInfo');
        ProtocolStudies = bst_getContext('ProtocolStudies');
        if isempty(ProtocolStudies) || isempty(ProtocolInfo)
            return;
        end
        
        % Get default subject
        sDefaultSubject = bst_getContext('Subject', 0);
        % If SubjectFile is the default subject filename
        if ~isempty(sDefaultSubject) && ~isempty(sDefaultSubject.FileName) && io_compareFileNames( SubjectFile{1}, sDefaultSubject.FileName)
            % Get all the subjects files that use default anatomy
            ProtocolSubjects = bst_getContext('ProtocolSubjects');
            iSubjectUseDefaultAnat = find([ProtocolSubjects.Subject.UseDefaultAnat]);
            if isempty(iSubjectUseDefaultAnat)
                return
            end
            SubjectFile = {ProtocolSubjects.Subject(iSubjectUseDefaultAnat).FileName};
            % Also updates inter-subject node
            isInterSubject = 1;
        else
            isInterSubject = 0;
        end
        % Search all the current protocol's studies
        iStudies = [];
        for i=1:length(SubjectFile)
            iStudies = [iStudies, find(io_compareFileNames({ProtocolStudies.Study.BrainStormSubject}, SubjectFile{i}))];
        end
        % Return results
        if ~isempty(iStudies)
            % Remove "analysis_intra" and "default_study" studies from list
            if ~IntraStudies
                iStudies(strcmpi({ProtocolStudies.Study(iStudies).Name}, bst_getContext('DirAnalysisIntra'))) = [];
            end
            if ~DefaultStudies
                iStudies(strcmpi({ProtocolStudies.Study(iStudies).Name}, bst_getContext('DirDefaultStudy'))) = [];
            end
            % Return studies
            bstContext = ProtocolStudies.Study(iStudies);
            bstIndex   = iStudies;
        else
            bstContext = repmat(db_getDataTemplate('Study'), 0);
            bstIndex   = [];
        end
        % Add inter-subject node, if needed
        if isInterSubject
            [sInterStudy, iInterStudy] = bst_getContext('AnalysisInterStudy');
            bstContext = [bstContext, sInterStudy];
            bstIndex   = [bstIndex,   iInterStudy];
        end
              
        
%% ==== STUDY WITH CONDITION PATH ====
    % Usage : [sStudies, iStudies] = bst_getContext('StudyWithCondition', ConditionPath)
    % Condition path can have two formats :
    %    - 'subjectName/condition1/subCondition1...' : target condition for the specified subject
    %    - '*/condition1/subCondition1...'           : target condition for all the subjects
    case 'studywithcondition'
        % Parse inputs
        if (nargin ~= 2) || ~ischar(varargin{2})
            error('Invalid call to bst_getContext()');
        end
        ConditionPath = varargin{2};
        % Get list of current protocol description
        ProtocolInfo     = bst_getContext('ProtocolInfo');
        ProtocolStudies  = bst_getContext('ProtocolStudies');
        if isempty(ProtocolStudies) || isempty(ProtocolInfo)
            return;
        end
        
        % Split Condition path string
        Conditions = strSplit(ConditionPath);
        if (length(Conditions) < 2)
            % If only one element in condition path 
            % => consider as if there were a '*/' before (all subjects)
            iStudies = 1:length(ProtocolStudies.Study);
        else
            % If first element is '*', search for condition in all the studies
            if (Conditions{1}(1) == '*')
                iStudies = 1:length(ProtocolStudies.Study);
            % Else : search for condition only in studies that are linked to the subject specified in the ConditionPath
            else
                iStudies = find(cellfun(@(f)strcmpi(fileparts(f), Conditions{1}), {ProtocolStudies.Study.BrainStormSubject}));
            end
            Conditions = Conditions(2:end);
        end
        
        % Search all the current protocol's studies
        iStudies = iStudies(cellfun(@(c)isequal(Conditions, c), {ProtocolStudies.Study(iStudies).Condition}));
        % Return results
        if ~isempty(iStudies)
            % Remove "analysis_intra" and "default_study" studies from list
            iStudies(strcmpi({ProtocolStudies.Study(iStudies).Name}, bst_getContext('DirAnalysisIntra'))) = [];
            iStudies(strcmpi({ProtocolStudies.Study(iStudies).Name}, bst_getContext('DirDefaultStudy'))) = [];
            % Sort by subject
            if (length(iStudies) > 1)
                SubjNameList = cell(1,length(iStudies));
                % For each study, get subject name
                for i = 1:length(iStudies)
                    sSubject = bst_getContext('Subject', ProtocolStudies.Study(iStudies(i)).BrainStormSubject);
                    SubjNameList{i} = sSubject.Name;
                end
                % Sort subjects names
                [sortSubjList, iSort] = sort(SubjNameList);
                % Apply same sorting to studies
                iStudies = iStudies(iSort);
            end
            % Return studies
            bstContext = ProtocolStudies.Study(iStudies);
            bstIndex   = iStudies;
        else
            bstContext = repmat(db_getDataTemplate('Study'), 0);
            bstIndex   = [];
        end
        
        
%% ==== STUDY WITH CONDITION AND SUBJECT ====
    % Usage: [sNewStudy, iNewStudy, ConditionPath] = bst_getContext('StudyWithSubjectAndCondition', SubjectFile, ConditionList)
    case 'studywithsubjectandcondition'
        % Parse inputs
        if (nargin ~= 3) || ~ischar(varargin{2}) || ~iscell(varargin{3})
            error('Invalid call to bst_getContext()');
        end
        SubjectFile   = varargin{2};
        ConditionList = varargin{3};
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % === VERSION 1 : USE SUBJECTS DIR ===
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get subject's base subdirectory
        subjectsSubDir = fileparts(SubjectFile);
        iFirstSlash = min([findstr(subjectsSubDir, '/'), findstr(subjectsSubDir, '\')]);
        if ~isempty(iFirstSlash)
            subjectsSubDir(iFirstSlash:end) = [];
        end
        % Get study with subject AND condition
        ConditionPath = fullfile(subjectsSubDir, ConditionList{:});
        [sStudy, iStudy] = bst_getContext('StudyWithCondition', ConditionPath);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % === VERSION 2 : USE STUDIES DIR ===
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if isempty(sStudy)
            % Get a study associated to subject (to get the studies subdirectory)
            [sStudy, iStudy] = bst_getContext('StudyWithSubject', SubjectFile);
            if ~isempty(sStudy)
                % Get subject's studies base subdirectory
                studiesSubDir = fileparts(sStudy(1).FileName);
                iFirstSlash = min([findstr(studiesSubDir, '/'), findstr(studiesSubDir, '\')]);
                if ~isempty(iFirstSlash)
                    studiesSubDir(iFirstSlash:end) = [];
                end
                % Get study with subject AND condition
                ConditionPath = fullfile(studiesSubDir, ConditionList{:});
                [sStudy, iStudy] = bst_getContext('StudyWithCondition', ConditionPath);
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
        % Returned values
        bstContext = sStudy;
        bstIndex   = iStudy;
        if isempty(sStudy)
            bstSubIndex = '';
        else
            bstSubIndex = ConditionPath;
        end
        
%% ==== CHANNEL STUDIES WITH SUBJECT ====
    % Usage: iStudies = bst_getContext('ChannelStudiesWithSubject', iSubjects, 'NoIntra')
    case 'channelstudieswithsubject'
        % Parse inputs
        if (nargin >= 2) && isnumeric(varargin{2})
            iSubjects = varargin{2};
        else
            error('Invalid call to bst_getContext()');
        end
        if (nargin == 3) && strcmpi(varargin{3}, 'NoIntra')
            NoIntra = 1;
        else
            NoIntra = 0;
        end
        % Process all subjects
        iStudies = [];
        for i=1:length(iSubjects)
            iSubject = iSubjects(i);
            sSubject = bst_getContext('Subject', iSubject, 1);
            % No subject: error
            if isempty(sSubject) 
                continue
            % If subject uses default channel file    
            elseif (sSubject.UseDefaultChannel ~= 0)
                % Get default study for this subject
                [tmp___, iStudiesNew] = bst_getContext('DefaultStudy', iSubject);
                iStudies = [iStudies, iStudiesNew];
            % Else: get all the studies belonging to this subject
            else
                if NoIntra
                    [tmp___, iStudiesNew] = bst_getContext('StudyWithSubject', sSubject.FileName);
                else
                    [tmp___, iStudiesNew] = bst_getContext('StudyWithSubject', sSubject.FileName, 'intra_subject');
                end
                iStudies = [iStudies, iStudiesNew];
            end
        end
        bstContext = iStudies;
    
%% ==== CHANNEL STUDY WITH STUDY ====
    % Usage: iStudies = bst_getContext('ChannelStudiesWithSubject', iSubjects, 'NoIntra')
    case 'channelstudieswithsubject'
        % Parse inputs
        if (nargin >= 2) && isnumeric(varargin{2})
            iSubjects = varargin{2};
        else
            error('Invalid call to bst_getContext()');
        end
        if (nargin == 3) && strcmpi(varargin{3}, 'NoIntra')
            NoIntra = 1;
        else
            NoIntra = 0;
        end
        % Process all subjects
        iStudies = [];
        for i=1:length(iSubjects)
            iSubject = iSubjects(i);
            sSubject = bst_getContext('Subject', iSubject, 1);
            % No subject: error
            if isempty(sSubject) 
                continue
            % If subject uses default channel file    
            elseif (sSubject.UseDefaultChannel ~= 0)
                % Get default study for this subject
                [tmp___, iStudiesNew] = bst_getContext('DefaultStudy', iSubject);
                iStudies = [iStudies, iStudiesNew];
            % Else: get all the studies belonging to this subject
            else
                if NoIntra
                    [tmp___, iStudiesNew] = bst_getContext('StudyWithSubject', sSubject.FileName);
                else
                    [tmp___, iStudiesNew] = bst_getContext('StudyWithSubject', sSubject.FileName, 'intra_subject');
                end
                iStudies = [iStudies, iStudiesNew];
            end
        end
        bstContext = iStudies;

        
%% ==== STUDIES COUNT ====
    % Usage: [nbStudies] = bst_getContext('StudyCount')
    case 'studycount'
        % Get list of current protocol studies
        ProtocolStudies = bst_getContext('ProtocolStudies');
        bstContext = length(ProtocolStudies.Study);

%% ==== SUBJECTS COUNT ====
    % Usage: [nbSubjects] = bst_getContext('SubjectCount')
    case 'subjectcount'
        % Get list of current protocol studies
        ProtocolSubjects = bst_getContext('ProtocolSubjects');
        bstContext = length(ProtocolSubjects.Subject);
        
%% ==== ANALYSIS STUDY (INTRA) ====
    % Usage: [sAnalStudy, iAnalStudy] = bst_getContext('AnalysisIntraStudy', iSubject) 
    case 'analysisintrastudy'
        % Parse inputs
        if (nargin == 2) && isnumeric(varargin{2})
            iSubject = varargin{2};
        else
            error('Invalid call to bst_getContext()');
        end
        % Get subject
        sSubject = bst_getContext('Subject', iSubject, 1);
        % Get studies related to subject
        [sSubjStudies, iSubjStudies] = bst_getContext('StudyWithSubject', sSubject.FileName, 'intra_subject');
        % Look for the 'AnalysisIntra' study
        iFound = find(cellfun(@(c)ismember(bst_getContext('DirAnalysisIntra'), c), {sSubjStudies.Condition}));
        iAnalStudy = iSubjStudies(iFound);
        sAnalStudy = sSubjStudies(iFound);
        % If no study found: need to create one
        if isempty(iAnalStudy)
            % Build new study
            iAnalStudy = db_addCondition(fileparts(sSubject.FileName), bst_getContext('DirAnalysisIntra'));
            sAnalStudy = bst_getContext('Study', iAnalStudy);
        end
        bstContext = sAnalStudy;
        bstIndex   = iAnalStudy;        
        
        
%% ==== ANALYSIS STUDY (INTER) ====
    % Usage: [sAnalStudyInter, iAnalStudyInter] = bst_getContext('AnalysisInterStudy') 
    case 'analysisinterstudy'
        iAnalStudyInter = -2;
        [bstContext, bstIndex] = bst_getContext('Study', iAnalStudyInter);
        
       
%% ==== DEFAULT STUDY ====
    % Usage: [sDefaulStudy, iDefaultStudy] = bst_getContext('DefaultStudy', iSubject)
    %        [sDefaulStudy, iDefaultStudy] = bst_getContext('DefaultStudy')           : iSubject=0
    %        [sDefaulStudy, iDefaultStudy] = bst_getContext('DefaultStudy', BrainStormSubject)
    case 'defaultstudy'
        % Parse inputs
        if (nargin == 1)
            iSubject = 0;
        elseif (nargin == 2) && isnumeric(varargin{2})
            iSubject = varargin{2};
        elseif (nargin == 2) && ischar(varargin{2})
            BrainStormSubject = varargin{2};
            % Get subject attached to study
            [sSubject, iSubject] = bst_getContext('Subject', BrainStormSubject, 1);
            if isempty(sSubject) || ~sSubject.UseDefaultChannel
                return;
            end
        else
            error('Invalid call to bst_getContext()');
        end
        % === DEFAULT SUBJECT ===
        % => Return global default study
        if (iSubject == 0)
            % Get protocol's studies
            ProtocolStudies = bst_getContext('ProtocolStudies');
            % Return Global default study
            bstContext = ProtocolStudies.DefaultStudy;
            bstIndex   = -3;
        % === NORMAL SUBJECT ===
        else
            % Get subject
            sSubject = bst_getContext('Subject', iSubject, 1);
            % === GLOBAL DEFAULT STUDY ===
            if sSubject.UseDefaultChannel == 2
                % Get protocol's studies
                ProtocolStudies = bst_getContext('ProtocolStudies');
                % Return Global default study
                bstContext = ProtocolStudies.DefaultStudy;
                bstIndex   = -3;
            % === SUBJECT'S DEFAULT STUDY ===
            elseif sSubject.UseDefaultChannel == 1
                % Get studies related to subject
                [sSubjStudies, iSubjStudies] = bst_getContext('StudyWithSubject', sSubject.FileName, 'default_study');
                % Look for the 'DefaultStudy' study
                iFound = find(cellfun(@(c)ismember(bst_getContext('DirDefaultStudy'), c), {sSubjStudies.Condition}));
                iDefaultStudy = iSubjStudies(iFound);
                sDefaultStudy = sSubjStudies(iFound);
                % If no study found: need to create one
                if isempty(iDefaultStudy)
                    % Build new study
                    iDefaultStudy = db_addCondition(fileparts(sSubject.FileName), bst_getContext('DirDefaultStudy'));
                    sDefaultStudy = bst_getContext('Study', iDefaultStudy);
                end
                bstContext = sDefaultStudy;
                bstIndex   = iDefaultStudy;        
            end
        end
        
        
        
%% ==== SUBJECT ====
    % Usage : [sSubject, iSubject] = bst_getContext('Subject', iSubject, isRaw)
    %         [sSubject, iSubject] = bst_getContext('Subject', SubjectFileName, isRaw);
    %         [sSubject, iSubject] = bst_getContext('Subject');
    % If isRaw is set: force to return the real brainstormsubject description
    % (ignoring wether it uses protocol's default anatomy or not)
    case 'subject' 
         % Get list of current protocol subjects
        ProtocolSubjects = bst_getContext('ProtocolSubjects');
        if isempty(ProtocolSubjects)
            return
        end 
        sSubject = [];
        % ISRAW parameter
        if (nargin < 3)
            isRaw = 0;
        else
            isRaw = varargin{3};
        end
        % Call: bst_getContext('subject', iSubject, isRaw);
        if (nargin >= 2) && isnumeric(varargin{2})
            iSubject = varargin{2};
            if (iSubject > length(ProtocolSubjects.Subject))
                error('Invalid subject indice.');
            end
            % If required subject is default subject (iSubject = 0)
            if (iSubject == 0)
                % Default subject available
                if ~isempty(ProtocolSubjects.DefaultSubject)
                    sSubject = ProtocolSubjects.DefaultSubject;
                % Default subject not available
                else
                    return
                end
            % Normal subject 
            else
                sSubject = ProtocolSubjects.Subject(iSubject);
            end
            
        % Call: bst_getContext('subject', SubjectFileName, isRaw);
        % Call: bst_getContext('subject', SubjectDir, isRaw);
        elseif (nargin >= 2) && isempty(varargin{2})
            % If study name is empty: use DefaultSubject
            SubjectFileName = ProtocolSubjects.DefaultSubject.FileName;
        elseif (nargin >= 2) && (ischar(varargin{2}))
            [fName, fBase, fExt] = fileparts(varargin{2});
            % Argument is a Matlab .mat filename
            if strcmpi(fExt, '.mat')
                SubjectFileName = varargin{2};
            % Else : assume argument is a directory
            else
                % Find subject file in this directory
                ProtocolInfo = bst_getContext('ProtocolInfo');
                subjPath = strrep(varargin{2}, ProtocolInfo.SUBJECTS, '');
                subjFile = dir(fullfile(ProtocolInfo.SUBJECTS, subjPath, '*brainstormsubject*.*'));
                if (length(subjFile) == 1)
                    SubjectFileName = fullfile(subjPath, subjFile.name);
                else
                    return
                end
            end
                            
        % Call: bst_getContext('subject');   => looking for current subject 
        elseif (nargin < 2)
            % Get current subject filename in current study
            sStudy = bst_getContext('Study');
            if isempty(sStudy)
                return
            end
            SubjectFileName = sStudy.BrainStormSubject;
            % If study's subject is not defined, get DefaultSubject
            if isempty(SubjectFileName) && ~isempty(ProtocolSubjects.DefaultSubject)
                SubjectFileName = ProtocolSubjects.DefaultSubject.FileName;
            end
        else
            error('Invalid call to bst_getContext()');
        end

        % If Subject is defined by its filename
        if isempty(sSubject)
            % Look in Default Subject
            if ~isempty(ProtocolSubjects.DefaultSubject) && io_compareFileNames(ProtocolSubjects.DefaultSubject.FileName, SubjectFileName)
                sSubject = ProtocolSubjects.DefaultSubject;
                iSubject = 0;
            % If not found : find target subject file name in normal subjects
            else
                iSubject = find(io_compareFileNames({ProtocolSubjects.Subject.FileName}, SubjectFileName), 1);
                sSubject = ProtocolSubjects.Subject(iSubject);
            end
        end
        
        % Return found subject
        if ~isempty(iSubject) && ~isempty(sSubject)
            % If subject uses default subject
            if sSubject.UseDefaultAnat && ~isRaw && ~isempty(ProtocolSubjects.DefaultSubject) && ~isempty(ProtocolSubjects.DefaultSubject.FileName)
                % Return default subject (WITH REAL SUBJECT'S NAME)
                bstContext                   = ProtocolSubjects.DefaultSubject;
                bstContext.Name              = sSubject.Name;
                bstContext.UseDefaultAnat    = sSubject.UseDefaultAnat;
                bstContext.UseDefaultChannel = sSubject.UseDefaultChannel;
                bstIndex                     = iSubject;
            % Else, return found subject
            else
                bstContext  = sSubject;
                bstIndex    = iSubject;
            end
        end
                
%% ==== SUBJECT WITH NAME ====
    % Usage : [sSubject, iSubject] = bst_getContext('Subject', SubjectName)
    case 'subjectwithname' 
        % Parse inputs
        if (nargin ~= 2) || ~ischar(varargin{2})
            error('Invalid call to bst_getContext()');
        end
        SubjectName = varargin{2};
        % Get list of current protocol subjects
        ProtocolSubjects = bst_getContext('ProtocolSubjects');
        if isempty(ProtocolSubjects)
            return
        end
        % Search all subjects
        iSubject = find(strcmpi({ProtocolSubjects.Subject.Name}, SubjectName), 1);
        if ~isempty(iSubject)
        	bstContext  = ProtocolSubjects.Subject(iSubject);
        	bstIndex    = iSubject;
        end

        
%% ==== SURFACE FILE ====
    % Usage : [sSubject, iSubject, iSurface] = bst_getContext('SurfaceFile', SurfaceFile)
    case 'surfacefile'
        % Get list of current protocol subjects
        ProtocolSubjects = bst_getContext('ProtocolSubjects');
        ProtocolInfo     = bst_getContext('ProtocolInfo');
        if isempty(ProtocolSubjects)
            return
        end;
        
        % Parse inputs
        if (nargin == 2)
            SurfaceFile = varargin{2};
        else
            error('Invalid call to bst_getContext().');
        end

        % Remove SUBJECTS path from SurfaceFile
        SurfaceFile = strrep(SurfaceFile, ProtocolInfo.SUBJECTS, '');
        % Look for surface file in DefaultSubject
        if ~isempty(ProtocolSubjects.DefaultSubject)
            % Find the first surface that matches the SurfaceFile
            iSurface = find(io_compareFileNames(SurfaceFile, {ProtocolSubjects.DefaultSubject.Surface.FileName}), 1);
            % If a surface was found in default subject : return it
            if ~isempty(iSurface)
                bstContext  = ProtocolSubjects.DefaultSubject;
                bstIndex    = 0;
                bstSubIndex = iSurface;
                return
            end
        end
        % Look for surface file in all the surfaces of all subjects
        for iSubj = 1:length(ProtocolSubjects.Subject)
            % Find the first surface that matches the SurfaceFile
            iSurface = find(io_compareFileNames(SurfaceFile, {ProtocolSubjects.Subject(iSubj).Surface.FileName}), 1);
            % If a surface was found in current subject : return it
            if ~isempty(iSurface)
                bstContext  = ProtocolSubjects.Subject(iSubj);
                bstIndex    = iSubj;
                bstSubIndex = iSurface;
                return
            end
        end
            
        
%% ==== SURFACE FILE BY TYPE ====
    % Usage : [sSurface, iSurface] = bst_getContext('SurfaceFileByType', iSubject,    SurfaceType)
    %         [sSurface, iSurface] = bst_getContext('SurfaceFileByType', SurfaceFile, SurfaceType)
    %         [sSurface, iSurface] = bst_getContext('SurfaceFileByType', MriFile,     SurfaceType)
    case 'surfacefilebytype'
        % Get subject
        if ischar(varargin{2})
            FileName = varargin{2};
            [fileFormat, fileTypes] = io_getFileType(FileName);
            if ismember('tess', fileTypes)
                [sSubject, iSubject] = bst_getContext('SurfaceFile', FileName);
            else
                [sSubject, iSubject] = bst_getContext('MriFile', FileName);
            end
        else
            iSubject = varargin{2};
            sSubject = bst_getContext('Subject', iSubject);
        end
        SurfaceType = varargin{3};
        % Look for required surface type
        field = ['i' SurfaceType];
        if ~isfield(sSubject, field) || isempty(sSubject.(field))
            return
        end
        bstContext = sSubject.Surface(sSubject.(field));
        bstIndex = sSubject.(field);       
        
        
%% ==== MRI FILE ====
    % Usage : [sSubject, iSubject, iMri] = bst_getContext('MriFile', MriFile)
    case 'mrifile'
        % Get list of current protocol subjects
        ProtocolSubjects = bst_getContext('ProtocolSubjects');
        ProtocolInfo     = bst_getContext('ProtocolInfo');
        if isempty(ProtocolSubjects)
            return
        end;
        
        % Parse inputs
        if (nargin == 2)
            MriFile = varargin{2};
        else
            error('Invalid call to bst_getContext().');
        end

        % Remove SUBJECTS path from MriFile
        MriFile = strrep(MriFile, ProtocolInfo.SUBJECTS, '');
        % Look for MRI file in DefaultSubject
        if ~isempty(ProtocolSubjects.DefaultSubject)
            % Find the first MRI that matches the MriFile
            iMri = find(io_compareFileNames(MriFile, {ProtocolSubjects.DefaultSubject.Anatomy.FileName}), 1);
            % If a MRI was found in default subject : return it
            if ~isempty(iMri)
                bstContext  = ProtocolSubjects.DefaultSubject;
                bstIndex    = 0;
                bstSubIndex = iMri;
                return
            end
        end
        % Look for MRI file in all the MRIs of all subjects
        for iSubj = 1:length(ProtocolSubjects.Subject)
            % Find the first MRI that matches the MriFile
            iMri = find(io_compareFileNames(MriFile, {ProtocolSubjects.Subject(iSubj).Anatomy.FileName}), 1);
            % If a MRI was found in current subject : return it
            if ~isempty(iMri)
                bstContext  = ProtocolSubjects.Subject(iSubj);
                bstIndex    = iSubj;
                bstSubIndex = iMri;
                return
            end
        end
        
        
%% ==== CHANNEL FILE ====
    % Usage: [sStudy, iStudy, iChannel] = bst_getContext('ChannelFile', ChannelFile)
    case 'channelfile'
        ProtocolInfo = bst_getContext('ProtocolInfo');
        % Parse inputs
        if (nargin == 2)
            ChannelFile = varargin{2};
            ChannelFile = strrep(ChannelFile, ProtocolInfo.STUDIES, '');
        else
            error('Invalid call to bst_getContext().');
        end
        % Look for Channel file in all the surfaces of all subjects
        [bstContext, bstIndex, bstSubIndex] = findFileInStudies('Channel.FileName', ChannelFile);
        
        
%% ==== CHANNEL FILE FOR STUDY ====
    % Usage: [ChannelFile] = bst_getContext('ChannelFileForStudy', StudyFile/DataFile)
    case 'channelfileforstudy'
        % Parse inputs
        if (nargin == 2)
            StudyFile = varargin{2};
        else
            error('Invalid call to bst_getContext().');
        end
        % Get study in database
        sStudy = bst_getContext('Study', StudyFile);
        % Look if it is a DataFile
        if isempty(sStudy)
            sStudy = bst_getContext('DataFile', StudyFile);
        end
        if ~isempty(sStudy) && ~isempty(sStudy.Channel)
            % Study has a channel file defined
            ChannelFile = sStudy.Channel.FileName;
        % Study not in database: look in StudyFile directory
        else
            % Get absolute path to StudyFile
            ProtocolInfo = bst_getContext('ProtocolInfo');
            StudyFile = strrep(StudyFile, ProtocolInfo.STUDIES, '');
            dirPath = fileparts(fullfile(ProtocolInfo.STUDIES, StudyFile)); 
            % Get the directory to the data file
            
            % List all channel files in this dir
            channelFileNames = dir(fullfile(dirPath, '*channel*.mat'));
            % Check number of Channel files
            if isempty(channelFileNames)
                warning('Brainstorm:DBError', ['No channel file in directory "' strrep(dirPath,'\','\\') '".']);
                ChannelFile = [];
            elseif (length(channelFileNames) > 1)
                warning('Brainstorm:DBError', ['Multiple channel files in "' strrep(dirPath,'\','\\') '".' 10 ...
                       'Please alter this folder''s content so that it contains a single channel file.']);
                ChannelFile = [];
            else
                ChannelFile = fullfile(fileparts(StudyFile), channelFileNames(1).name);
            end
        end
        % Return Channel filename (relative)
        bstContext = ChannelFile;        
        
        
%% ==== CHANNEL STRUCT FOR STUDY ====
    % Usage: [sChannel, iChanStudy] = bst_getContext('ChannelForStudy', iStudies)
    case 'channelforstudy'
        % Parse inputs
        if (nargin == 2)
            iStudies = varargin{2};
        else
            error('Invalid call to bst_getContext().');
        end
        iChanStudies = [];
        sListChannel = [];
        for i = 1:length(iStudies)           
            % Get study 
            iStudy = iStudies(i);
            sStudy = bst_getContext('Study', iStudy);
            iChanStudy = iStudy;
            % === Analysis-Inter node ===
            iAnalysisInter      = -2;
            iGlobalDefaultStudy = -3;
            if (iStudy == iAnalysisInter)
                % If no channel file is defined in 'Analysis-intra' node: look in 
                if isempty(sStudy.Channel)
                    % Get global default study
                    sStudy = bst_getContext('Study', iGlobalDefaultStudy);
                    iChanStudy = iGlobalDefaultStudy;
                end
            % === All other nodes ===
            else
                % Get subject attached to study
                [sSubject, iSubject] = bst_getContext('Subject', sStudy.BrainStormSubject, 1);
                if isempty(sSubject)
                    return;
                end
                % Subject uses default channel/headmodel
                if (sSubject.UseDefaultChannel ~= 0)
                    [sStudy, iChanStudy] = bst_getContext('DefaultStudy', iSubject);
                    if isempty(sStudy)
                        return
                    end
                end
            end
            iChanStudies = [iChanStudies, iChanStudy];
            sListChannel = [sListChannel, sStudy.Channel];
        end
        % Return Channel structure
        bstContext = sListChannel;
        bstIndex = iChanStudies;


%% ==== HEADMODEL STRUCT FOR STUDY ====
    % Usage: [sHeadModel] = bst_getContext('HeadModelForStudy', iStudy)
    case 'headmodelforstudy'
        % Parse inputs
        if (nargin == 2)
            iStudy = varargin{2};
        else
            error('Invalid call to bst_getContext().');
        end
        % Get study 
        sStudy = bst_getContext('Study', iStudy);
        % === Analysis-Inter node ===
        iAnalysisInter      = -2;
        iGlobalDefaultStudy = -3;
        if (iStudy == iAnalysisInter)
            % If no channel file is defined in 'Analysis-intra' node: look in 
            if isempty(sStudy.iHeadModel)
                % Get global default study
                sStudy = bst_getContext('Study', iGlobalDefaultStudy);
            end
        % === All other nodes ===
        else
            % Get subject attached to study
            [sSubject, iSubject] = bst_getContext('Subject', sStudy.BrainStormSubject, 1);
            if isempty(sSubject)
                return;
            end
            % Subject uses default channel/headmodel
            if (sSubject.UseDefaultChannel ~= 0)
                sStudy = bst_getContext('DefaultStudy', iSubject);
                if isempty(sStudy)
                    return
                end
            end
        end
        % Return HeadModel structure
        if ~isempty(sStudy.iHeadModel)
            bstContext = sStudy.HeadModel(sStudy.iHeadModel(1));
        else
            bstContext = [];
        end


%% ==== DATA FILE ====
    % Usage: [sStudy, iStudy, iData] = bst_getContext('DataFile', DataFile)
    case 'datafile'
        % Parse inputs
        ProtocolInfo = bst_getContext('ProtocolInfo');
        if (nargin == 2)
            DataFile = varargin{2};
            DataFile = strrep(DataFile, ProtocolInfo.STUDIES, '');
        else
            error('Invalid call to bst_getContext().');
        end
        % Look for surface file in all the surfaces of all subjects
        [bstContext, bstIndex, bstSubIndex] = findFileInStudies('Data.FileName', DataFile);
        

%% ==== DATA FOR DATA LIST ====
    % Usage: [iFoundData] = bst_getContext('DataForDataList', iStudy, DataListName)
    case 'datafordatalist'
        iStudy = varargin{2};
        DataListName = varargin{3};
        % Get study structure
        sStudy = bst_getContext('Study', iStudy);
        % Get all the data files held by this datalist
        removedTrialsFiles = cellfun(@strRemoveTrialTag, {sStudy.Data.FileName}, 'UniformOutput', 0);
        iFoundData = find(strcmpi(removedTrialsFiles, DataListName));
        % Return found data files
        bstContext = iFoundData;
        
        
%% ==== DATA FOR STUDY (INCLUDING SHARED STUDIES) ====
    % Usage: [iStudies, iDatas] = bst_getContext('DataForStudy', iStudy)
    case 'dataforstudy'
        % Get target study
        iStudy = varargin{2};
        sStudy = bst_getContext('Study', iStudy);
        isDefaultStudy  = strcmpi(sStudy.Name, bst_getContext('DirDefaultStudy'));
        isGlobalDefault = (iStudy == -3);
        
        % If study is the global default study
        sStudies = [];
        iStudies = [];
        if isGlobalDefault
            % Get all the subjects of the protocol
            nbSubjects = bst_getContext('SubjectCount');
            for iSubject = 1:nbSubjects
                sSubject = bst_getContext('Subject', iSubject, 1);
                if sSubject.UseDefaultChannel
                    [tmp_sStudies, tmp_iStudies] = bst_getContext('StudyWithSubject', sSubject.FileName);
                    sStudies = [sStudies, tmp_sStudies];
                    iStudies = [iStudies, tmp_iStudies];
                end
            end
        % Else, if study is a subject's default study (ie. channel file is shared by all studies of one subject)
        elseif isDefaultStudy
            % Get all the subject's studies
            [sStudies, iStudies] = bst_getContext('StudyWithSubject', sStudy.BrainStormSubject, 'intra_subject', 'default_study');
        else
            % Normal: one channel per condition
            sStudies = sStudy;
            iStudies = iStudy;
        end
        % Get all the DataFiles for all these studies
        for i = 1:length(sStudies)
            nData = length(sStudies(i).Data);
            bstContext = [bstContext, repmat(iStudies(i), [1,nData])];
            bstIndex   = [bstIndex, 1:nData];
        end
       
        
%% ==== DATA FOR STUDIES (INCLUDING SHARED STUDIES) ====
    % Usage: [iStudies, iDatas] = bst_getContext('DataForStudies', iStudies)
    case 'dataforstudies'
        iStudies = varargin{2};
        for i = 1:length(iStudies)
            [tmp_iStudies, tmp_iDatas] = bst_getContext('DataForStudy', iStudies(i));
            bstContext = [bstContext, tmp_iStudies];
            bstIndex   = [bstIndex,   tmp_iDatas];
        end
        
%% ==== DATA FILE FOR CHANNEL FILE ====
    % Usage: DataFiles = bst_getContext('DataForChannelFile', ChannelFile)
    case 'dataforchannelfile'
        ChannelFile = varargin{2};
        DataFiles = {};
        % Get study for the given channel file
        [sStudy, iStudy] = bst_getContext('ChannelFile', ChannelFile);
        if isempty(sStudy)
            return;
        end
        % Get dependent data files
        [iStudies, iDatas] = bst_getContext('DataForStudy', iStudy);
        % Get all the Data filenames
        for i = 1:length(iStudies)
            sStudy = bst_getContext('Study', iStudies(i));
            DataFiles = cat(2, DataFiles, {sStudy.Data(iDatas(i)).FileName});
        end
        bstContext = DataFiles;
                
        
%% ==== RESULTS FILE ====
    % Usage: [sStudy, iStudy, iResult] = bst_getContext('ResultsFile', ResultsFile)
    case 'resultsfile'
        ProtocolInfo = bst_getContext('ProtocolInfo');
        % Parse inputs
        if (nargin == 2)
            ResultsFile = varargin{2};
            ResultsFile = strrep(ResultsFile, ProtocolInfo.STUDIES, '');
        else
            error('Invalid call to bst_getContext().');
        end
        % Look for surface file in all the surfaces of all subjects
        [bstContext, bstIndex, bstSubIndex] = findFileInStudies('Result.FileName', ResultsFile);
       
        
%% ==== RESULTS FOR DATA FILE ====
    % Usage: [sStudy, iStudy, iResults] = bst_getContext('ResultsForDataFile', DataFile)           : search the whole protocol
    % Usage: [sStudy, iStudy, iResults] = bst_getContext('ResultsForDataFile', DataFile, iStudies) : search only the specified studies
    case 'resultsfordatafile'
        ProtocolInfo = bst_getContext('ProtocolInfo');
        % Parse inputs
        if (nargin >= 2)
            DataFile = varargin{2};
            DataFile = strrep(DataFile, ProtocolInfo.STUDIES, '');
        else
            error('Invalid call to bst_getContext().');
        end
        % Determine in which studies to search for ResultsFile
        if (nargin >= 3)
            % Studies specified in argument
            iStudies = varargin{3};
        else
            % Get study in which DataFile is located
            [sStudies, iStudies] = bst_getContext('DataFile', DataFile);
            if isempty(iStudies)
                return;
            end
        end
        % Search selected studies
        [bstContext, bstIndex, bstSubIndex] = findFileInStudies('Result.DataFile', DataFile, iStudies);


        
%% ==== STAT FILE ====
    % Usage: [sStudy, iStudy, iData] = bst_getContext('StatFile', StatFile)
    case 'statfile'
        % Parse inputs
        ProtocolInfo = bst_getContext('ProtocolInfo');
        if (nargin == 2)
            StatFile = varargin{2};
            StatFile = strrep(StatFile, ProtocolInfo.STUDIES, '');
        else
            error('Invalid call to bst_getContext().');
        end
        % Look for surface file in all the surfaces of all subjects
        [bstContext, bstIndex, bstSubIndex] = findFileInStudies('Stat.FileName', StatFile);
        
        
        
%% ==== STAT FOR DATA FILE ====
    % Usage: [sStudy, iStudy, iResults] = bst_getContext('StatForDataFile', DataFile)           : search the whole protocol
    % Usage: [sStudy, iStudy, iResults] = bst_getContext('StatForDataFile', DataFile, iStudies) : search only the specified studies
    case 'resultsfordatafile'
        ProtocolInfo = bst_getContext('ProtocolInfo');
        % Parse inputs
        if (nargin >= 2)
            DataFile = varargin{2};
            DataFile = strrep(DataFile, ProtocolInfo.STUDIES, '');
        else
            error('Invalid call to bst_getContext().');
        end
        % Determine in which studies to search for ResultsFile
        if (nargin >= 3)
            % Studies specified in argument
            iStudies = varargin{3};
        else
            % Get study in which DataFile is located
            [sStudies, iStudies] = bst_getContext('DataFile', DataFile);
            if isempty(iStudies)
                return;
            end
        end
        % Search selected studies
        [bstContext, bstIndex, bstSubIndex] = findFileInStudies('Stat.DataFile', DataFile, iStudies);
        
        
%% ==== ALL CONDITIONS FOR ONE SUBJECT ====
    % Usage: [Conditions] =  bst_getContext('ConditionsForSubject', SubjectFile)
    case 'conditionsforsubject'
        % Parse inputs
        if (nargin == 2)
            SubjectFile = varargin{2};
        else
            error('Invalid call to bst_getContext().');
        end
        % Get list of studies associated with subject
        sStudies = bst_getContext('StudyWithSubject', SubjectFile);
        % Get Conditions for each study
        Conditions = {};
        for i = 1:length(sStudies)
            % Test if the condition of this study was not added previously
            isNewCondition = 1;
            for iCond = 1:length(Conditions)
                % If new condition is found 
                % (and excludes DirAnalysisIntra and DirDefaultSubject from list)
                if isequal(sStudies(i).Condition, Conditions(iCond)) || ...
                   strcmpi(sStudies(i).Condition{1}, bst_getContext('DirAnalysisIntra')) || ...
                   strcmpi(sStudies(i).Condition{1}, bst_getContext('DirDefaultSubject'))
                    isNewCondition = 0;
                    break;
                end
            end
            % If Condition is not added yet : add it to the list
            if isNewCondition
                Conditions{end+1} = sStudies(i).Condition;
            end
        end
        % Return conditions list
        bstContext = Conditions;
        
        
%% ==== ANATOMY DEFAULTS ====
    % Returns an array of struct(fullpath, dir, name) of all the Brainstorm anatomy defaults
    case 'anatomydefaults'
        % Get template directory
        baseDir = fullfile(bst_getContext('BrainStormHomeDir'), 'defaults', 'anatomy');
        % Get subdirectories
        fileList = dir(baseDir);
        defaultsList = repmat(struct('fullpath','', 'dir','', 'name',''), 0);
        % Find all the valid defaults (subdirectory with a brainstormsubject.mat in it)
        for i=1:length(fileList)
            % Entry is a directory W/ a name that does not start with a '.' 
            if fileList(i).isdir && (fileList(i).name(1) ~= '.')
                tmpDir = fileList(i).name;
                tmpFullpath = fullfile(baseDir, tmpDir);
                % Look for a 'brainstormsubject.mat'
                SubjectFileList = dir(fullfile(tmpFullpath, '*brainstormsubject*.mat'));
                % If there is only brainstorm subject file : accept template as valid
                if (length(SubjectFileList) == 1)
                    tmpFile = fullfile(tmpFullpath, SubjectFileList(1).name);
                    % Load the 'Name' field of the 'brainstormsubject.mat' file (default subject's name)
                    try
                        % Load file
                        SubjectMat = load(tmpFile, 'Name');
                        % Add an entry to the defaults list
                        defaultsList(end + 1) = struct('fullpath',  tmpFullpath, ...
                                                        'dir',      tmpDir, ...
                                                        'name',     SubjectMat.Name);
                    catch
                        % Error loading file => go to next iteration
                        continue
                    end
                end
            end
        end
        % Return defaults list
        bstContext = defaultsList;
        
        
%% ==== EEG DEFAULTS ====
    % Returns an array of struct(fullpath, name) of all the Brainstorm eeg nets defaults
    % Usage: eegDefaults = bst_getContext('EEGDefaults')
    case 'eegdefaults'
        fullDefaultsList = repmat(struct('contents','', 'name',''), 0);
        % Get template directory
        eegDefaultsDir = fullfile(bst_getContext('BrainStormHomeDir'), 'defaults', 'eeg');
        % Get directory
        dirList = dir(fullfile(eegDefaultsDir, '*'));
        % For each template directory
        for iDir = 1:length(dirList)
            % Excludes '.' and '..'
            if (dirList(iDir).name(1) == '.')
                continue;
            end
            % Get full dir
            fulldirName = fullfile(eegDefaultsDir, dirList(iDir).name);
            if isdir(fulldirName)
                % Get files list
                fileList = dir(fullfile(fulldirName, '*channel*.mat'));
                defaultsList = repmat(struct('fullpath','', 'name',''), 0);
                % Find all the valid defaults (channel files)
                for iFile = 1:length(fileList)
                    defaultsList(iFile).fullpath = fullfile(fulldirName, fileList(iFile).name);
                    [tmp__, baseName] = fileparts(fileList(iFile).name);
                    defaultsList(iFile).name = strrep(baseName, 'channel_', '');
                    defaultsList(iFile).name = strrep(defaultsList(iFile).name, '_channel', '');
                    defaultsList(iFile).name = strrep(defaultsList(iFile).name, '_', ' ');
                end
                % Add files list to defaults list
                if ~isempty(defaultsList)
                     fullDefaultsList(end + 1) = struct('contents', defaultsList, ...
                                                        'name',     dirList(iDir).name);
                end
            end
        end
        
        % Return defaults list
        bstContext = fullDefaultsList;
        
        
%% ==== GET FILENAMES ====
    case 'getfilenames'
        iStudies = varargin{2};
        iItems = varargin{3};
        DataType = varargin{4};
        FileNames = cell(1, length(iStudies));
        for i = 1:length(iStudies)
            % Get study definition
            sStudy = bst_getContext('Study', iStudies(i));
            % Recordings or sources
            if strcmpi(DataType, 'data')
                FileNames{i} = sStudy.Data(iItems(i)).FileName;
            else
                FileNames{i} = sStudy.Result(iItems(i)).FileName;
            end
        end
        bstContext = FileNames;

        
%% ==== BEST FITTING SPHERE ====
    % Get a spherical approximation to head shape in the headmodels
    % USAGE:  [bfs_center, bfs_radius] = bst_getContext('BestFittingSphere', ChannelFile)
    case 'bestfittingsphere'
        % Parse inputs
        if (nargin == 2)
            ChannelFile = varargin{2};
        else
            error('Invalid call to bst_getContext().');
        end
        % Find study associated with this channel file
        sStudy = bst_getContext('ChannelFile', ChannelFile);
        if isempty(sStudy) || isempty(sStudy.HeadModel)
            return
        end
        % Get protocol description
        ProtocolInfo = bst_getContext('ProtocolInfo');
        % Load channel file
        ChannelMat = load(fullfile(ProtocolInfo.STUDIES, sStudy.Channel.FileName));
        % Get MEG and EEG channels indices
        iMeg = good_channel(ChannelMat.Channel, [], 'MEG');
        iEeg = good_channel(ChannelMat.Channel, [], 'EEG');
        % Get the list of head models to process (starting with the default one)
        listHeadModels = [sStudy.iHeadModel, setdiff(1:length(sStudy.HeadModel), sStudy.iHeadModel)];
        % Initialize returned values
        bfs_center = [];
        bfs_radius = [];
        % Process all the headmodels
        for i = 1:length(listHeadModels)
            iHeadModel = listHeadModels(i);
            % Load "Param" structure from headmodel file
            HeadModelFile = fullfile(ProtocolInfo.STUDIES, sStudy.HeadModel(iHeadModel).FileName);
            warning off
            HeadModelMat = load(HeadModelFile, 'Param', 'MEGMethod', 'EEGMethod');
            warning on
            % Find a MEG spherical model in headmodel
            if isfield(HeadModelMat, 'MEGMethod') && strcmpi(HeadModelMat.MEGMethod, 'meg_sphere') && ~isempty(iMeg)
                bfs_center = HeadModelMat.Param(iMeg(1)).Center;
                bfs_radius = max(HeadModelMat.Param(iMeg(1)).Radii);
                break;
            end
            % Find an EEG spherical model in headmodel
            if isfield(HeadModelMat, 'EEGMethod') && ismember(HeadModelMat.EEGMethod, {'eeg_sphere','eeg_3sphereBerg', 'eeg_3sphere'}) && ~isempty(iEeg)
                bfs_center = HeadModelMat.Param(iEeg(1)).Center;
                bfs_radius = max(HeadModelMat.Param(iEeg(1)).Radii);
                break;
            end
        end
        % Return BFS if found somewhere
        bstContext = bfs_center;
        bstIndex = bfs_radius;
        
        
%% ==== GUI ====
    case 'gui'
        bstContext = getappdata(0, 'BrainStormGUI');

    case 'progressbar'
        bstContext = getappdata(0, 'BrainStormProgressBar');
        
    case 'layout'
        if ispref('BrainStorm', 'sLayout')
            bstContext = getpref('BrainStorm', 'sLayout');
        else
            bstContext = [];
        end 
    
    case 'layoutmanager'
        if ispref('BrainStorm', 'LayoutManager')
            bstContext = getpref('BrainStorm', 'LayoutManager');
        else
            bstContext = 'TileWindows';
        end 

    case 'byteorder'
        if ispref('BrainStorm', 'ByteOrder')
            bstContext = getpref('BrainStorm', 'ByteOrder');
        else
            bstContext = 'l';
        end 

    case 'uniformizetimeseriesscales'
        if ispref('BrainStorm', 'UniformizeTimeSeriesScales')
            bstContext = getpref('BrainStorm', 'UniformizeTimeSeriesScales');
        else
            bstContext = 1;
        end 
        
    case 'displayaveragereference'
        if ispref('BrainStorm', 'DisplayAverageReference')
            bstContext = getpref('BrainStorm', 'DisplayAverageReference');
        else
            bstContext = 1;
        end 
        
    case 'autoupdates'
        if ispref('BrainStorm', 'AutoUpdates')
            bstContext = getpref('BrainStorm', 'AutoUpdates');
        else
            bstContext = 1;
        end 
    case 'displaygfp'
        if ispref('BrainStorm', 'DisplayGFP')
            bstContext = getpref('BrainStorm', 'DisplayGFP');
        else
            bstContext = 1;
        end 

    
    case 'tsdisplaymode'
        if ispref('BrainStorm', 'TSDisplayMode')
            bstContext = getpref('BrainStorm', 'TSDisplayMode');
        else
            bstContext = 'Butterfly';
        end 
        
    case 'expandtrialslists'
        if ispref('BrainStorm', 'ExpandTrialsLists')
            bstContext = getpref('BrainStorm', 'ExpandTrialsLists');
        else
            bstContext = 0;
        end 
            
    case 'reloaddbatstartup'
        if ispref('BrainStorm', 'ReloadDbAtStartup')
            bstContext = getpref('BrainStorm', 'ReloadDbAtStartup');
        else
            bstContext = 0;
        end 
               
    case 'usedoublescreen'
        if ispref('BrainStorm', 'UseDoubleScreen')
            bstContext = getpref('BrainStorm', 'UseDoubleScreen');
        else
            bstContext = 1;
        end 
        
    case 'usesigproctoolbox'
        % Check if Signal Processing Toolbox is installed
        isToolboxInstalled = exist('fir2') || exist('myfir2');
        % Return user preferences
        if ~isToolboxInstalled
            bstContext = 0;
        elseif ispref('BrainStorm', 'UseSigProcToolbox')
            bstContext = getpref('BrainStorm', 'UseSigProcToolbox');
        else
            bstContext = 1;
        end
        
    case 'lastuseddirs'
        LastUsedDirs = struct('ImportData',      '', ...
                              'ImportChannel',   '', ...
                              'ImportAnat',      '', ...
                              'Export',          '');
        % Check if preference is weel defined
        if ispref('BrainStorm', 'LastUsedDirs') && all(ismember(fieldnames(LastUsedDirs), fieldnames(getpref('BrainStorm', 'LastUsedDirs'))))
            bstContext = getpref('BrainStorm', 'LastUsedDirs');
            % Check if directories still exist
            if ~exist(bstContext.ImportData, 'dir')
                bstContext.ImportData = '';
            end
            if ~exist(bstContext.ImportChannel, 'dir')
                bstContext.ImportChannel = '';
            end
            if ~exist(bstContext.ImportAnat, 'dir')
                bstContext.ImportAnat = '';
            end
            if ~ischar(bstContext.Export)
                bstContext.Export = '';
                warning('*** LastUsedDirs.Export = 0 ***');
            elseif ~exist(bstContext.Export, 'dir')
                bstContext.Export = '';
            end
        else
            bstContext = LastUsedDirs;
            setpref('BrainStorm', 'LastUsedDirs', LastUsedDirs);
        end
        
    case 'defaultformats'
        bstContext = struct('DataIn',     '', ...
                            'DataOut',    '', ...
                            'ChannelIn',  '', ...
                            'ChannelOut', '', ...
                            'NoiseCovIn', '', ...
                            'ResultsIn',  '', ...
                            'ResultsOut', '', ...
                            'MriIn',      '', ...
                            'MriOut',     '', ...
                            'SurfaceIn',  '', ...
                            'SurfaceOut', '');
        if ispref('BrainStorm', 'DefaultFormats') 
            bstPref = getpref('BrainStorm', 'DefaultFormats');
            if ~isempty(bstPref) && all(isfield(bstPref, fieldnames(bstContext)))
                bstContext = bstPref; 
            end
        end
        
    case 'bemoptions'
        bstContext = struct(...
                'Interpolative',        0, ...
                'Basis',                'linear', ...
                'Test',                 'collocation', ...
                'ISA',                  1, ...
                'checksurf',            1, ...
                'NVertMax',             1000, ...
                'ForceXferComputation', 1);
        if ispref('BrainStorm', 'BEMOptions') 
            bstPref = getpref('BrainStorm', 'BEMOptions');
            if ~isempty(bstPref) && all(isfield(bstPref, fieldnames(bstContext)))
                bstContext = bstPref; 
            end
        end

    case 'bfsproperties'
        if ispref('BrainStorm', 'BFSProperties') && ~isempty(getpref('BrainStorm', 'BFSProperties'))
            bstContext = getpref('BrainStorm', 'BFSProperties');
        else
            bstContext = [.33 .0042 .33 .88 .93];
        end
        
    case 'importctfoptions'
        bstContext = struct('UseAllTrials',     1, ...
                            'TrialsTimeRange',  [], ...
                            'MarkersTimeRange', [-.05, .2], ...
                            'KeepNativeFormat', 0, ...
                            'UseMarkers',       1, ...
                            ... 'EEGRef',           0, ...
                            'MarkersSelection', 'all', ... {'all', 'common', 'individual'}
                            'DCOffset',         0 ... {0:do no remove, 1:remove/whole, 2:remove/pretrigger}
                           );
        if ispref('BrainStorm', 'ImportCTFOptions') 
            bstPref = getpref('BrainStorm', 'ImportCTFOptions');
            if ~isempty(bstPref) && all(isfield(bstPref, fieldnames(bstContext)))
                bstContext = bstPref; 
            end
        end

    case 'importfifoptions'
        bstContext = struct('UseEvents',        1, ...
                            'EventsTimeRange',  [-.05, .2], ...
                            'SplitRaw',         1, ...
                            'SplitLength',      4, ...
                            'KeepNativeFormat', 0, ...
                            'Resample',         0, ...
                            'ResampleFreq',     0, ...
                            'UseCtfCompensators', 0, ...
                            'LastCtfCompensator', 3, ...
                            'UseNeuromagSSP',   0);
        if ispref('BrainStorm', 'ImportFifOptions') 
            bstPref = getpref('BrainStorm', 'ImportFifOptions');
            if ~isempty(bstPref) && all(isfield(bstPref, fieldnames(bstContext)))
                bstContext = bstPref; 
            end
        end
        
    case 'importeegrawoptions'
        bstContext = struct('isCanceled',        0, ...
                            'BaselineDuration',  0, ...
                            'SamplingRate',      1000, ...
                            'MatrixOrientation', 'channelXtime', ... % {'channelXtime', 'timeXchannel'}
                            'VoltageUnits',      'V', ...            % {'\muV', 'mV', 'V'}
                            'SkipLines',         0);
        if ispref('BrainStorm', 'ImportEegRawOptions')
            bstPref = getpref('BrainStorm', 'ImportEegRawOptions');
            if ~isempty(bstPref) && all(isfield(bstPref, fieldnames(bstContext)))
                bstContext = bstPref; 
            end
        end
        
    case 'bugreportoptions'
        bstContext = struct('isEnabled',  0, ...
                            'SmtpServer', 'mailhost.chups.jussieu.fr', ...
                            'UserEmail',  '');
        if ispref('BrainStorm', 'BugReportOptions')
            bstPref = getpref('BrainStorm', 'BugReportOptions');
            if ~isempty(bstPref) && all(isfield(bstPref, fieldnames(bstContext)))
                bstContext = bstPref; 
            end
        end
        
    case 'inverseoptions'
        if ispref('BrainStorm', 'InverseOptions') && ~isempty(getpref('BrainStorm', 'InverseOptions'))
            bstContext = getpref('BrainStorm', 'InverseOptions');
        end
        if isempty(bstContext) || ~isfield(bstContext.LMMS, 'UseNoiseCov')
            bstContext = struct('LMMS',            struct(...
                                    'FFNormalization', 1, ...
                                    'Tikhonov',        10, ...
                                    'ComputeKernel',   1, ...
                                    'UseNoiseCov',     1), ...
                                'LCMV',            struct(...
                                    'NNormalization',  0, ...
                                    'Tikhonov',        10, ...
                                    'isConstrained',   1, ...
                                    'OutputFormat',    2));
        end
        
    case 'defaultsurfacedisplay'
        bstContext = struct('SurfShowCurvature',      0, ...
                            'SurfSmoothValue',        0, ...
                            'DataIntThreshold',          0.5,...
                            'DataExtThreshold',          0);
        if ispref('BrainStorm', 'DefaultSurfaceDisplay')
            bstPref = getpref('BrainStorm', 'DefaultSurfaceDisplay');
            if ~isempty(bstPref) && all(isfield(bstPref, fieldnames(bstContext)))
                bstContext = bstPref; 
            end
        end
        
    case 'magneticextrapoptions'
        bstContext = struct('ForceWhitening', 0, ...
                            'EpsilonValue',   0.0001);
        if ispref('BrainStorm', 'MagneticExtrapOptions')
            bstPref = getpref('BrainStorm', 'MagneticExtrapOptions');
            if ~isempty(bstPref) && all(isfield(bstPref, fieldnames(bstContext)))
                bstContext = bstPref; 
            end
        end
               
        
%% ==== PANEL CONTAINERS ====
    case 'panelcontainer'    
        % Get Brainstorm GUI context structure
        bst_GUI = getappdata(0, 'BrainStormGUI');
        if (isempty(bst_GUI) || ~isfield(bst_GUI, 'panelContainers'))
            error('Brainstorm GUI is not yet initialized');
        end
        
        % Get ContainerName in argument
        if ((nargin >= 2) && (ischar(varargin{2})))
            ContainerName = varargin{2};
        % If no container name in argument : just display all the container names
        else
            disp('Registered panel containers :');
            for iContainer = 1:length(bst_GUI.panelContainers)
                disp(['    - ' bst_GUI.panelContainers(iContainer).name]);
            end
            return
        end

        % Look for containerName in all the registered panel containers
        iContainer = 1;
        found = 0;
        while (~found (iContainer <= length(bst_GUI.panelContainers)))
             if (strcmpi(ContainerName, bst_GUI.panelContainers(iContainer).name))
                 found = 1;
             else
                 iContainer = iContainer + 1;
             end
        end
        % If container is found : return it
        if (found)
            bstContext = bst_GUI.panelContainers(iContainer).jHandle;
        else
            warning('Brainstorm:InvalidContainer', 'Container ''%s'' could not be found.', ContainerName);
        end

        
%% ==== PANELS ====
    case 'panel'    
        % Get Brainstorm GUI context structure
        bst_GUI = getappdata(0, 'BrainStormGUI');
        if (isempty(bst_GUI) || ~isfield(bst_GUI, 'panels'))
            return
        end
        % Get Panel in argument
        if ((nargin >= 2) && (ischar(varargin{2})))
            PanelName = varargin{2};
        % If no panel name in argument : just display all the panels names
        else
            disp('Registered panels :');
            for iContainer = 1:length(bst_GUI.panels)
                disp(['    - ' get(bst_GUI.panels(iContainer), 'name')]);
            end
            return
        end
        % Look for panelName in all the registered panels
        iPanel = find(strcmpi(PanelName, get(bst_GUI.panels, 'name')), 1);
        if ~isempty(iPanel)
            bstContext = bst_GUI.panels(iPanel);
            bstIndex   = iPanel;
        end
                
        
%% ==== PANEL CONTROLS ====
%  Calls : bst_getContext('PanelControls', PanelName)
    case 'panelcontrols'
        % Get Panel name in argument
        if ((nargin >= 2) && (ischar(varargin{2})))
            PanelName = varargin{2};
        else
            error('Invalid call to bst_getContext()');
        end
        % Find BstPanel with this name
        bstPanel = bst_getContext('Panel', PanelName);
        % If panel was found : return its controls
        if ~isempty(bstPanel)
            bstContext = get(bstPanel, 'sControls');
        end
        
        
%% ==== PANEL ELEMENTS ====
%  Calls : bst_getContext('PanelElement',  PanelName, ElementName)
%          bst_getContext('PanelElement',  ElementName)
    case 'panelelement'
        % Get Panel name in argument
        if ((nargin == 2) && (ischar(varargin{2})))
            panelName = '';
            objectName = varargin{2};
        elseif ((nargin == 3) && (ischar(varargin{2}) && (ischar(varargin{2}))))
            panelName = varargin{2};
            objectName = varargin{3};
        else
            error('Invalid call to bst_getContext()');
        end
        
        % Look for control
        % If panel name is known
        if ~isempty(panelName)
            % Get panel that holds the object
            bstPanel = bst_getContext('Panel', panelName);
            if (isempty(bstPanel)), return, end
            % Get the object name in the objects referenced in this panel
            panelElement = get(bstPanel, objectName); 
            if (isempty(panelElement))
                warning('Brainstorm:InvalidElement', 'Object ''%s'' could not be found in panel ''%s''.', objectName, panelName);
                return
            end

        % If panel name is not defined : need to search all panels
        else
            % Get Brainstorm GUI context structure
            bst_GUI = bst_getContext('GUI');
            if (isempty(bst_GUI) || ~isfield(bst_GUI, 'panels'))
                error('Brainstorm GUI is not yet initialized');
            end
            % Process all panels
            [panelElement, bstPanel] = get(bst_GUI.panels, objectName);
        end
        
        % If element was found : return object and panel 
        if (~isempty(panelElement))
            bstContext = panelElement;
            bstIndex   = bstPanel;
        end

       
%% ==== DIRECTORIES ====
    case 'dirdefaultsubject'
        bstContext = '@default_subject';
    case 'dirdefaultstudy'
        bstContext = '@default_study';
    case 'diranalysisintra'
        bstContext = '@intra';
    case 'diranalysisinter'
        bstContext = '@inter';
    case 'normalizedsubjectname'
        bstContext = 'Group analysis';
 		% bstContext = 'Default subject';
        


%% ==== ERROR ====
    otherwise
        error(sprintf('Invalid context : "%s"', contextName));
end
end




%% ==== HELPERS ====
% Return all the protocol studies that have a given file in its structures
% Possible field names: Result.DataFile, Result.FileName, Data.FileName, Channel.FileName
%
% USAGE:  [sFoundStudy, iFoundStudy, iItems] = findFileInStudies(fieldName, fieldFile, iStudiesList)
%         [sFoundStudy, iFoundStudy, iItems] = findFileInStudies(fieldName, fieldFile)
function [sFoundStudy, iFoundStudy, iItems] = findFileInStudies(fieldName, fieldFile, iStudiesList)
    sFoundStudy = [];
    iFoundStudy = [];
    iItems      = [];
    % Get protocol information
    ProtocolInfo  = bst_getContext('ProtocolInfo');
    ProtocolStudies = bst_getContext('ProtocolStudies');
    % Remove STUDIES path from fieldFile
    fieldFile = strrep(fieldFile, ProtocolInfo.STUDIES, '');      
    % List studies to process
    if (nargin < 3)
        iStudiesList = 1:length(ProtocolStudies.Study);
    else
        % Remove default studies (processed anyway)
        iStudiesList = setdiff(iStudiesList, [-2 -3]);
    end
      
    try
        % NORMAL STUDIES: Look for surface file in all the surfaces of all subjects
        for iStudy = iStudiesList
            % Get list of fields of this study
            try
                studyList = eval(['{ProtocolStudies.Study(iStudy).', fieldName, '}']);
            catch
                continue
            end
            % Nothing found: continue with next study
            if isempty(studyList)
                continue;
            end
            % Replace empty cells with empty strings
            iEmtpyCells = find(cellfun(@isempty, studyList));
            for i = 1:length(iEmtpyCells)
                studyList{iEmtpyCells(i)} = '';
            end
            % Remove STUDIES path from all elements in list
            studyList = strrep(studyList, ProtocolInfo.STUDIES, '');
            % Find target in this list
            iItems = find(io_compareFileNames(studyList, fieldFile));
            if ~isempty(iItems)
                sFoundStudy  = ProtocolStudies.Study(iStudy);
                iFoundStudy  = iStudy;
                return
            end
        end
        % SPECIAL INDICES
        iAnalysisStudy = -2;    
        iDefaultStudy  = -3;
        % ANALYSIS STUDY
        if isempty(iItems) && ~isempty(ProtocolStudies.AnalysisStudy)
            % Get list of fields of this study
            studyList = eval(['{ProtocolStudies.AnalysisStudy.', fieldName, '}']);
            % Remove STUDIES path from all elements in list
            studyList = strrep(studyList, ProtocolInfo.STUDIES, '');
            % Find target in this list
            iItems = find(io_compareFileNames(studyList, fieldFile));
            if ~isempty(iItems)
                sFoundStudy = ProtocolStudies.AnalysisStudy;
                iFoundStudy = iAnalysisStudy;
                return
            end
        end
        % DEFAULT STUDY
        if isempty(iItems) && ~isempty(ProtocolStudies.DefaultStudy)
            % Get list of fields of this study
            studyList = eval(['{ProtocolStudies.DefaultStudy.', fieldName, '}']);
            % Remove STUDIES path from all elements in list
            studyList = strrep(studyList, ProtocolInfo.STUDIES, '');
            % Find target in this list
            iItems = find(io_compareFileNames(studyList, fieldFile));
            if ~isempty(iItems)
                sFoundStudy = ProtocolStudies.DefaultStudy;
                iFoundStudy = iDefaultStudy;
                return
            end
        end
    catch
        warning('Database error. Please reload all the protocol.');
    end
end







