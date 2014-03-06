function import_data(varargin)
% IMPORT_DATA: Imports a list of datafiles in a Study of Brainstorm database
% 
% USAGE:  import_data(iStudyInit, DataFiles, FileFormat)
%         import_data(iStudyInit, DataFiles, FileFormat, DataCfg)
%         import_data(iStudyInit)
%         import_data( [], iSubjectInit) : imports data in the target subject (after having created a default condition)
%         import_data()                  : Rely on data filenames to create automatically subjects/conditions
%
% INPUT:
%    - iStudyInit: Indices of the studies where to import the Data
%                  If 0, a study is created automatically before importation (iSubject must be specified)
%    - DataFiles : Cell array of full filenames of the data files to import (format is autodetected)
%                    => if not specified : file to import is asked to the user
%    - iSubjectInit: The subject indice must be specified if and only if iStudyInit is not defined (0)
%                  => in this case, a default study is created for the target subject
%
% NOTE : Some data filenames can be interpreted as subjects/conditions/run :
%    - cell<i>_<conditionName>_obs<j>.erp     : subject #j, condition #i, conditionName

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

% ===== Parse inputs =====
DataFiles = {};
FileFormat = '';
iSubjectInit = 0;
% Check command line
if (nargin==0)
    iStudyInit = 0;
elseif (nargin==1) && isnumeric(varargin{1}) && (varargin{1} > 0) 
    iStudyInit = varargin{1};
elseif (nargin>=2) && isnumeric(varargin{1})
    iStudyInit = varargin{1};
    if ischar(varargin{2})
        DataFiles = {varargin{2}};
    elseif iscell(varargin{2})
        DataFiles = varargin{2};
    elseif isnumeric(varargin{2})
        iSubjectInit = varargin{2};
    end
    if nargin>=3
        FileFormat = varargin{3};
    end
    if nargin>=4
        sSubject = varargin{4};
    end
else
    error('Usage: import_data(iStudyInit, [,DataFiles || iSubjectInit])');
end
% Get Protocol information
ProtocolInfo = bst_getContext('ProtocolInfo');
% Get current byte order
ByteOrder = bst_getContext('ByteOrder');


%% ===== SELECT DATA FILE =====
% If MRI file to load was not defined : open a dialog box to select it
if isempty(DataFiles) 
    % Get default import directory and formats
    LastUsedDirs = bst_getContext('LastUsedDirs');
    DefaultFormats = bst_getContext('DefaultFormats');
    % Get MRI file
    [DataFiles, FileFormat, FileFilter] = java_fileSelector( 'open', ...
        'Import EEG/MEG recordings...', ...         % Window title
        LastUsedDirs.ImportData, ...                 % Last used directory
        'multiple', 'files_and_dirs', ...           % Selection mode
        {{'.meg4','.res4'},      'MEG/EEG: CTF (*.ds;*.meg4;*.res4)',        'CTF' ; ... 
         {'.fif'},               'MEG/EEG: Neuromag FIFF (*.fif)',           'FIF'; ...
         {'_data'},              'MEG/EEG: Brainstorm MAT (*data*.mat)',     'BST-MAT'; ...
         {'.lena'},              'MEG/EEG: LENA (*.lena)',                   'LENA-BIN'; ...
         {'.raw'},               'EEG: EGI Netstation epoch-marked RAW (*.raw)', 'EEG-EGI-RAW'; ...
         {'.set'},               'EEG: EEGLab (*.set)',                      'EEG-EEGLAB'; ...
         {'.sef','.ep','.eph'},  'EEG: Cartool (*.sef;*.ep;*.eph)',          'EEG-CARTOOL'; ...
         {'.erp','.hdr'},        'EEG: ERPCenter (*.hdr;*.erp)',             'EEG-ERPCENTER'; ...
         {'.eeg'},               'EEG: BrainAmp (*.eeg)',                    'EEG-BRAINAMP'; ...
         {'.cnt','.avg','.eeg','.dat'}, 'EEG: Neuroscan (*.cnt;*.eeg;*.avg;*.dat)', 'EEG-NEUROSCAN'; ...
         {'.mat'}                'EEG: Matlab matrix (*.mat)',               'EEG-MAT';
         {'*'},                  'EEG: ASCII text (*.*)',                    'EEG-ASCII' ...
        }, DefaultFormats.DataIn);
    % If no file was selected: exit
    if isempty(DataFiles)
        return
    end
    % Save default import directory
    LastUsedDirs.ImportData = fileparts(DataFiles{1});
    bst_setContext('LastUsedDirs', LastUsedDirs);
    % Save default import format
    DefaultFormats.DataIn = FileFormat;
    bst_setContext('DefaultFormats',  DefaultFormats);
    % Process the selected directories :
    %    1) If they are .ds/ directory with .meg4 and .res4 files : keep them as "files to open"
    %    2) Else : add all the data files they contains (subdirectories included)
    DataFiles = ExpandDataFilesList(FileFilter, DataFiles);
    if isempty(DataFiles)
        bst_error(['No data ' FileFormat ' file in the selected directories.'], 'Import EEG/MEG recordings...', 0);
        return
    end
end

%% ===== CHECK DATA FORMAT =====
if isempty(FileFormat)
    error('Unknown FileFormat');
end


%% ===== IMPORT SELECTED DATA =====
% Reset data selection in study
nbCall = 0;
iNewAutoSubject = [];
isReinitStudy = 0;
iAllStudies = [];
iAllSubjects = [];
% Process all the selected data files
for iFile = 1:length(DataFiles)  
    nbCall = nbCall + 1;
    DataFile = DataFiles{iFile};
    [DataFile_path, DataFile_base] = fileparts(DataFile);
    % Check file location (a file cannot be directly inside the brainstorm directories)
    itmp = strfind(DataFile_path, ProtocolInfo.STUDIES);
    if ~isempty(itmp) && (itmp(1) == 1)
         error(['You are not supposed to put your original files in the Brainstorm data directory.' 10 ...
                'This directory is part of the Brainstorm database and its content can be altered only' 10 ...
                'by the Brainstorm GUI.' 10 10 ...
                'Please create a new folder somewhere else, move all you original recordings files in it, ' 10 ...
                'and then try again to import them.']);
    end
    
    % List or directories where to copy the channel file
    iStudies = [];
    iStudyCopyChannel = [];
    % If needed: reinitialize target study
    if isReinitStudy
        iStudyInit = 0;
    end
    
    % ===== CONVERT DATA FILE =====
    bst_progressBar('start', 'Import MEG/EEG recordings', ['Loading file "' DataFile '"...']);
    bst_message_window(sprintf('Loading MEG/EEG "%s"...', DataFile));
    % Load file(s)
    [ImportedDataMat, ChannelMat, loadedFiles] = in_data(DataFile, FileFormat, ByteOrder, nbCall);
    if isempty(ImportedDataMat)
        continue
    end
    % Detect auxiliary EEG channels
    if ~isempty(ChannelMat)
        ChannelMat = channel_detectType(ChannelMat);
    end

    % ===== CREATE STUDY (IIF SUBJECT IS DEFINED) =====
    bst_progressBar('start', 'Import MEG/EEG recordings', 'Preparing output studies...');
    % Check if subject/condition is in filenames
    [SubjectName, ConditionName] = ParseDataFilename(ImportedDataMat(1).FileName,loadedFiles);
    % If subj/cond are defined in filenames => default (ignore node that was clicked)
    if ~isempty(SubjectName)
        iSubjectInit = NaN;
    end
    if ~isempty(ConditionName)
        iStudyInit = NaN;
    end
        
    % If study is already known
    if (iStudyInit ~= 0) 
        iStudies = iStudyInit;
    % If a study needs to be created AND subject is already defined
    elseif (iStudyInit == 0) && (iSubjectInit ~= 0)
        % Get the target subject
        sSubject = bst_getContext('Subject', iSubjectInit, 1);
        % Try to get default study
        [sStudies, iStudies] = bst_getContext('StudyWithCondition', fullfile(fileparts(sSubject.FileName), DataFile_base));
        % If does not exist yet: Create the default study
        if isempty(iStudies)
            iStudies = db_addCondition(fileparts(sSubject.FileName), DataFile_base);
            if isempty(iStudies)
                error('Default study could not be created : "%s".', DataFile_base);
            end
            isReinitStudy = 1;
        end
        iStudyInit = iStudies;
    % If need to create Subject + Condition + Study : do it file per file
    else
        iSubjectInit = NaN;
        iStudyInit   = NaN;
        iStudies     = [];
    end
    
    % ===== STORE IMPORTED FILES IN DB =====
    bst_progressBar('start', 'Import MEG/EEG recordings', 'Saving imported files in database...', 0, length(ImportedDataMat));
    % Store imported data files in Brainstorm database
    for iImported = 1:length(ImportedDataMat)
        bst_progressBar('inc', 1);
        % ===== CREATE STUDY (IF SUBJECT NOT DEFINED) =====
        % Need to get a study for each imported file
        if isnan(iSubjectInit) || isnan(iStudyInit)
            % === PARSE FILENAME ===
            % Try to get subject name and condition name out of the filename
            [SubjectName, ConditionName] = ParseDataFilename(ImportedDataMat(iImported).FileName,loadedFiles);
            sSubject = [];
            % === SUBJECT NAME ===
            if isempty(SubjectName)
                % If subject is defined by the input node: use this subject's name
                if (iSubjectInit ~= 0) && ~isnan(iSubjectInit)
                    [sSubject, iSubject] = bst_getContext('Subject', iSubjectInit);
                end
            else
                % Find the subject in DataBase
                [sSubject, iSubject] = bst_getContext('SubjectWithName', SubjectName);
                % If subject is not found in DB: create it 
                if isempty(sSubject)
                    [sSubject, iSubject] = db_addSubject(SubjectName);
                    % If subject cannot be created: error: stop everything
                    if isempty(sSubject)
                        bst_error(['Could not create subject "' SubjectName '"'], 'Import MEG/EEG recordings');
                        return;
                    end
                end
            end
            % If a subject creation is needed
            if isempty(sSubject)
                SubjectName = 'NewSubject';
                % If auto subject was not created yet 
                if isempty(iNewAutoSubject)
                    % Try to get a subject with this name in database
                    [sSubject, iSubject] = bst_getContext('Subject', SubjectName);
                    % If no subject with automatic name exist in database, create it
                    if isempty(sSubject)
                        [sSubject, iSubject] = db_addSubject(SubjectName);
                        iNewAutoSubject = iSubject;
                    end
                % If auto subject was created for the previous imported file 
                else
                    [sSubject, iSubject] = bst_getContext('Subject', iNewAutoSubject);
                end
            end
            % === CONDITION NAME ===
            if isempty(ConditionName)
                % If a condition is defined by the input node
                if (iStudyInit ~= 0) && ~isnan(iStudyInit)
                    sStudyInit = bst_getContext('Study', iStudyInit);
                    ConditionName = sStudyInit.Condition{1};
                else
                    ConditionName = 'Default';
                end
            end
            % Get real subject directory (not the default subject directory, which is the default)
            sSubjectRaw = bst_getContext('Subject', iSubject, 1);
            ConditionPath = fileparts(sSubjectRaw.FileName);
            % Find study (subject/condition) in database
            [sNewStudy, iNewStudy] = bst_getContext('StudyWithCondition', fullfile(ConditionPath, ConditionName));
            % If study does not exist : create it
            if isempty(iNewStudy)
                iNewStudy = db_addCondition(ConditionPath, ConditionName, 'NoRefresh');
                if isempty(iNewStudy)
                    warning(['Cannot create condition : "' fullfile(ConditionPath, ConditionName) '"']);
                    continue;
                end
            end
            iStudies = [iStudies, iNewStudy];   
        else
            iSubject = iSubjectInit;
            sSubject = bst_getContext('Subject', iSubject);
            iStudies = iStudyInit;
        end
        % ===== CHANNEL FILE TARGET =====
        % If subject uses default channel
        if (sSubject.UseDefaultChannel)
            % Add the DEFAULT study directory to the list
            [sDefaultStudy, iDefaultStudy] = bst_getContext('DefaultStudy', iSubject);
            iStudyCopyChannel(iImported) = iDefaultStudy;
        else
            % Else add study directory in the list
            iStudyCopyChannel(iImported) = iStudies(end);
        end
        
        % ===== MOVE IMPORTED FILES IN STUDY DIRECTORY =====
        % Current study
        sStudy = bst_getContext('Study', iStudies(end));
        % Get study subdirectory
        studySubDir = fileparts(sStudy.FileName);
        % Get the directory in which the file was stored by the in_data() function
        [importedPath, importedBase, importedExt] = fileparts(ImportedDataMat(iImported).FileName);
        % Remove ___COND and ___SUBJ tags
        importedBase = removeStudyTags(importedBase);
        % Build final filename
        finalImportedFile = fullfile(ProtocolInfo.STUDIES, studySubDir, [importedBase, importedExt]);
        finalImportedFile = io_makeUniqueFilename(finalImportedFile);
        % If data file is not in study subdirectory : need to move it
        if ~io_compareFileNames(importedPath, fileparts(finalImportedFile))
            bst_message_window(sprintf('Moving file : "%s" => "%s"...', ImportedDataMat(iImported).FileName, finalImportedFile));
            movefile(ImportedDataMat(iImported).FileName, finalImportedFile, 'f');
            ImportedDataMat(iImported).FileName = strrep(finalImportedFile, ProtocolInfo.STUDIES, '');
        end
    
        % ===== STORE DATA FILE IN DATABASE ======
        % New data indice in study
        nbData = length(sStudy.Data) + 1;
        % Add data to subject
        sStudy.Data(nbData) = ImportedDataMat(iImported);
        % Store current study
        bst_setContext('Study', iStudies(end), sStudy);
        % Record all subjects
        iAllSubjects = [iAllSubjects, iSubject];
    end
    clear iStudy sStudy studySubDir

    % Remove NaN and duplicated values in studies list
    iStudies = unique(iStudies(~isnan(iStudies)));
    iStudyCopyChannel = unique(iStudyCopyChannel(~isnan(iStudyCopyChannel)));
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% SECTION A REFAIRE COMPLETEMENT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% FONCTION "SET CHANNEL" SEPAREE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % If a channel file was imported
    if ~isempty(ChannelMat)
        for i=1:length(iStudyCopyChannel)
            iStudy = iStudyCopyChannel(i);
            sStudy = bst_getContext('Study', iStudy);
            studySubDir = fileparts(sStudy.FileName);
            
            % ===== SAVE CHANNEL FILE =====
            % Delete all the other channel files in the study directory
            channelFiles = dir(fullfile(ProtocolInfo.STUDIES, studySubDir, '*channel*.mat'));
            if ~isempty(channelFiles)
                io_deleteFile({fullfile(ProtocolInfo.STUDIES, studySubDir, channelFiles.name)}, 1);
            end
            % Add comment field if it does not exist
            if ~isfield(ChannelMat, 'Comment')
                %ChannelMat.Comment = DataFile_base;
                ChannelMat.Comment = [FileFormat ' channels'];
            end
            % Base channel filename
            ChannelFile_base = DataFile_base;
            
            % VECTORVIEW 306: 204 Gradiometers + 102 Magnetometers
            if (nnz(strcmpi({ChannelMat.Channel.Type}, 'MEG GRAD')) == 204) && ...
                    (nnz(strcmpi({ChannelMat.Channel.Type}, 'MEG MAG')) == 102)
                % Add a tag in the filename
                ChannelFile_base = [ChannelFile_base, '_vectorview306'];
            % CTF: 29 references
            elseif (nnz(strcmpi({ChannelMat.Channel.Type}, 'MEG REF')) > 26)
                % Check if accuracy is 1 (MEG channel = axial gradio = 8 points)
                iMeg = find(strcmpi({ChannelMat.Channel.Type}, 'MEG'));
                if (size(ChannelMat.Channel(iMeg(1)).Loc, 2) == 8)
                    ChannelFile_base = [ChannelFile_base, '_ctf_acc1'];
                end
            end

            % Produce a default channel filename
            BstChannelFile = fullfile(ProtocolInfo.STUDIES, studySubDir, ['channel_' ChannelFile_base '.mat']);
            % Save new ChannelFile in Brainstorm format
            save(BstChannelFile, '-struct', 'ChannelMat');
            bst_message_window(sprintf('   => Channels list saved in "%s".', strrep(BstChannelFile, ProtocolInfo.STUDIES, '')))

            % ===== STORE NEW CHANNEL IN DATABASE ======
            % New channel structure
            newChannel = db_getDataTemplate('Channel');
            newChannel(1).FileName   = strrep(BstChannelFile, ProtocolInfo.STUDIES, '');
            newChannel(1).nbChannels = length(ChannelMat.Channel);
            newChannel(1).Comment    = sprintf('%s (%d)', ChannelMat.Comment, length(ChannelMat.Channel));
            newChannel(1).Modalities = getChannelModalities( ChannelMat.Channel );
            % Save displayable types list
            newChannel(1).DisplayableSensorTypes = getChannelModalities( ChannelMat.Channel, 5 );

            % Add channel to study
            sStudy.Channel = newChannel;
            % Store studies database
            bst_setContext('Study', iStudy, sStudy);
        end
    end   
    iAllStudies = [iAllStudies, iStudies, iStudyCopyChannel];
end
bst_progressBar('stop');

% === UPDATE DISPLAY ===
% Update links
if ~isempty(iAllSubjects)
    iAllSubjects = unique(iAllSubjects);
    for i = 1:length(iAllSubjects)
        db_updateLinkResults('Subject', iAllSubjects(i));
    end
end
% Update tree
if ~isempty(iAllStudies)
    iAllStudies = unique(iAllStudies);
    tree_updateNode('Study', iAllStudies);
    if (length(iAllStudies) == 1)
        tree_selectStudyNode(iAllStudies(1));
    end
end
% Edit new subject (if a new subject was created automatically)
if ~isempty(iNewAutoSubject)
    db_editSubject(iNewAutoSubject);
end
% Save database
bst_saveDatabase();

return
end




%% ================================================================================
%  ===== HELPER FUNCTIONS =========================================================
%  ================================================================================
% Expands a list of paths :
%    1) If it is a file => keep it unchanged
%    2) If they are .ds/ directory with .meg4/.res4 files,
%       or ERPCenter directories with .hdr/.erp files,
%       => keep them as "files to open"
%    3) Else : add all the data files they contains (subdirectories included)
function ExpFiles = ExpandDataFilesList(FileFilter, Files)
    ExpFiles = {};
    for i = 1:length(Files)
        % DIRECTORIES
        if isdir(Files{i})  
            isFormatCTF = strcmpi(FileFilter.getFormatName(), 'CTF');
            isFormatERP = strcmpi(FileFilter.getFormatName(), 'EEG-ERPCenter');
            isDirFile = 0;
            % If CTF/ERP format
            if isFormatCTF || isFormatERP
                if isFormatCTF
                    % Check if there are .meg4 or .res4 files in directory
                    dirFiles = [dir(fullfile(Files{i}, '*.meg4'));
                                dir(fullfile(Files{i}, '*.res4'))];
                else
                    % Check if there are .hdr file in directory
                    dirFiles = dir(fullfile(Files{i}, '*.hdr'));
                end
                j = 1;
                while (~isDirFile && (j <= length(dirFiles)))
                    if FileFilter.accept(java.io.File(fullfile(Files{i}, dirFiles(j).name)))
                        isDirFile = 1;
                        ExpFiles = cat(2, ExpFiles, Files{i});
                    else
                        j = j + 1;
                    end
                end
            end
            
            % If directory is not a CTF/ERP dir to be opened
            if ~isDirFile
                % Get all files in this directory
                dirFiles = dir(fullfile(Files{i}, '*'));
                % Build a new files list
                dirFullFiles = {};
                for j = 1:length(dirFiles)
                    % Process all the files that do not start with a '.'
                    if (dirFiles(j).name(1) ~= '.')
                        dirFullFiles{end + 1} = fullfile(Files{i}, dirFiles(j).name);
                    end
                end
                % And call function recursively
                ExpFiles = cat(2, ExpFiles, ExpandDataFilesList(FileFilter, dirFullFiles));
            end

        % SINGLE FILE
        else
            % Test if is accepted by FileFilter
            if FileFilter.accept(java.io.File(Files{i}))
                % If single file is CTF : get the parent 
                if strcmpi(FileFilter.getFormatName(), 'CTF')
                    ExpFiles{end+1} = fileparts(Files{i});
                else
                    ExpFiles{end+1} = Files{i};
                end
            end
        end
    end
end


% Parse filename to detect subject/condition/run
function [SubjectName, ConditionName] = ParseDataFilename(filename,loadedFiles)
    SubjectName   = '';
    ConditionName = '';
    % Get only short filename without extension
    [fPath, fName, fExt] = fileparts(filename);
    
    % IMPORTED FILENAMES : '....___SUBJsubjectname___CONDcondname___...'
    % Get subject tag
    iTag_subj = strfind(fName, '___SUBJ');
    if ~isempty(iTag_subj)
        iStartSubj = iTag_subj + 7;
        % Find closing tag
        iCloseSubj = strfind(fName(iStartSubj:end), '___');
        % Find closing tag
        if ~isempty(iCloseSubj)
            SubjectName = fName(iStartSubj:iStartSubj + iCloseSubj - 2);
        end
    elseif nargin>1
        % Uses path of the loaded files to define subject name
        [p,n]=fileparts(loadedFiles{1});
        [p,SubjectName]=fileparts(p);
    end
    
    % Get condition tag
    iTag_cond = strfind(fName, '___COND');
    if ~isempty(iTag_cond)
        iStartCond = iTag_cond + 7;
        % Find closing tag
        iCloseCond = strfind(fName(iStartCond:end), '___');
        % Find closing tag
        if ~isempty(iCloseCond)
            ConditionName = fName(iStartCond:iStartCond + iCloseCond - 2);
        end
    end
end

% Remove study tags (___COND and ___SUBJ)
function fname = removeStudyTags(fname)
    iTags = findstr(fname, '___');
    if iTags >= 2
        iStart = iTags(1);
        if (iTags(end) + 2 == length(fname))
            iStop  = iTags(end) + 2;
        else
            % Leave at least one '_' as a separator
            iStop  = iTags(end) + 1;
        end
        fname(iStart:iStop) = [];
    end
end

