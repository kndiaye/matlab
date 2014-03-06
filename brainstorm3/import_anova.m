function [sTargetStudy] = import_anova(Conditions, sProcess, OPTIONS, TimeVector, pmap, tmap)
% [] = import_anova(Conditions, sProcess, OPTIONS, TimeVector,pmap, fmap)

SamplesA = Conditions.SamplesA;

% % Get condition StimRightThumb
% [sStudy, iStudy] = bst_getContext('StudyWithCondition', 'Subject01/StimRightThumb');
% 
% 
% %% ===== SELECT FILES =====
% % Get the two kernels computed in tutorial #7: the regular and the shared one
% iRes1 = find(~cellfun(@(c)isempty(strfind(c, 'MN: kernel')), {sStudy.Result.Comment}));
% iRes2 = find(~cellfun(@(c)isempty(strfind(c, 'MN: shared')), {sStudy.Result.Comment}) & ...
%              io_compareFileNames({sStudy.Result.DataFile}, sStudy.Data(1).FileName));
% % Define the two sets of files, A and B
% FilesA = {sStudy.Result(iRes1(1)).FileName};
% FilesB = {sStudy.Result(iRes2(1)).FileName};
% 



% === BUILD NEW FILES ===
% Display waitbar
% bst_progressBar('start', 'Processes', 'Saving results...');

% NB: Format de la structure des arguments :
%
% sProcess =
%                 Name: 'RM-Anova'
%              Comment: 'Anova (under dev.)'
%          Description: 'Repeated measures parametric Analysis of Variance'
%              FileTag: 'Anova'
%             Category: 'Anova'
%          UseBaseline: 0
%     DefaultOverwrite: 0
%     isSourceAbsolute: 1
%             isPaired: 0
%       blockDimension: 0
%             isAvgRef: 1
%
% SamplesA = 
% 1x60 struct array with fields:
%     iStudy
%     iItem
%     FileName
%     FullFileName
%     Comment
%     Condition
%     SubjectFile
%     DataFile
%     SubjectName
%
% SamplesA(1)
% ans = 
%           iStudy: 5
%            iItem: 1
%         FileName: 'S11\avg_HighCorrect\data_lena_CONFINUM.mat'
%     FullFileName: 'I:\data\confinum\brainstorm\data\S11\avg_HighCorrect\data_lena_CONFINUM.mat'
%          Comment: 'avg_HighCorrect'
%        Condition: 'avg_HighCorrect'
%      SubjectFile: 'S11/brainstormsubject.mat'
%         DataFile: []
%      SubjectName: 'S11'
% SamplesA(2)
% ans = 
%           iStudy: 14
%            iItem: 1
%         FileName: 'S12\avg_HighCorrect\data_lena_CONFINUM.mat'
%     FullFileName: 'I:\data\confinum\brainstorm\data\S12\avg_HighCorrect\data_lena_CONFINUM.mat'
%          Comment: 'avg_HighCorrect'
%        Condition: 'avg_HighCorrect'
%      SubjectFile: 'S12/brainstormsubject.mat'
%         DataFile: []
%      SubjectName: 'S12'
% SamplesA(15)
% ans = 
%           iStudy: 131
%            iItem: 1
%         FileName: 'S27\avg_HighCorrect\data_lena_CONFINUM.mat'
%     FullFileName: 'I:\data\confinum\brainstorm\data\S27\avg_HighCorrect\data_lena_CONFINUM.mat'
%          Comment: 'avg_HighCorrect'
%        Condition: 'avg_HighCorrect'
%      SubjectFile: 'S27/brainstormsubject.mat'
%         DataFile: []
%      SubjectName: 'S27'
% SamplesA(16)
% ans = 
%           iStudy: 6
%            iItem: 1
%         FileName: 'S11\avg_HighIncorrect\data_lena_CONFINUM_05.mat'
%     FullFileName: 'I:\data\confinum\brainstorm\data\S11\avg_HighIncorrect\data_lena_CONFINUM_05.mat'
%          Comment: 'avg_HighIncorrect'
%        Condition: 'avg_HighIncorrect'
%      SubjectFile: 'S11/brainstormsubject.mat'
%         DataFile: []
%      SubjectName: 'S11'
%      
%
% OPTIONS =
%               isData: 1
%              Comment: 'Anova'
%     isAbsoluteValues: 0
%             sProcess: [1x1 struct]
%        nbPermutation: 10000
%              Factors: []
%     isOverwriteFiles: 0
%           OutputType: 'database'
%      ForceOutputCond: []
%            isCluster: 0
%     isClusterAverage: 0
%            sClusters: []
%      ClustersOptions: []
%                 Time: [-0.2998 0.5996]
%             Baseline: [-0.2998 3.3000e-004]
%                iTime: [1x921 double]
%            iBaseline: [1x308 double]
%           Conditions: [1x1 struct]



% load bst_stat_struct.mat    


sProcess.Name =  'RM-ANOVA'

[sTargetStudy, iTargetStudy isNewConditions, Comment] = GetOutputStudy(sProcess, SamplesA, SamplesA([]), OPTIONS);

ChannelFlag = [];
% Get default structure
newFileMat = CreateDefaultStruct(sProcess, SamplesA(1).FileName, OPTIONS.isData, TimeVector, OPTIONS.iTime, ChannelFlag, 0, 0);

% Comment
newFileMat.Comment = OPTIONS.Comment ;
% if 0% numel(fx{i_fx}) == 1
%     newFileMat.Comment = [newFileMat.Comment ' - Main effect of '];
% else
%     newFileMat.Comment = [newFileMat.Comment ' - Interaction of '];
% end
%newFileMat.Comment = [newFileMat.Comment sprintf('%s * ',Factors.Names{fx{i_fx}})];

% Save P and F maps

newFileMat.pmap = pmap;
newFileMat.tmap = tmap;
% Save new file and register in database
sTargetStudy = SaveNewFile(newFileMat, sProcess, OPTIONS.isData, iTargetStudy, sTargetStudy, SamplesA(1).FileName);
end

%% ======================================================================================
%  ===== HELPERS ========================================================================
%  ======================================================================================
%% ===== CREATE DEFAULT OUTPUT STRUCTURE =====
function sFileMat = CreateDefaultStruct(sProcess, FileName, isData, TimeVector, iTime, ChannelFlag, isOneOutputMat, isSampleBySample)
% Default structures for stat
isStat = 1% ismember(sProcess.Category, {'TTest', 'PermTest', 'Anova'});
if isStat
    sStat = struct(...
        'Type',        '', ...
        'Comment',     '', ...
        'Time',        TimeVector, ...
        'ChannelFlag', ChannelFlag, ...
        'pmap',        [], ...
        'tmap',        [], ...
        'pThreshold',  0.05);
end

% If recordings
if isData
    % Load file
    sFileMat = load(FileName);
    % Stat
    if isStat
        sStat.Type = 'data';
        sStat.Comment = sFileMat.Comment;
        sFileMat = sStat;
        % Data
    else
        sFileMat.Time = TimeVector;
        sFileMat.F = [];
    end
    % Else: sources
else
    % Get protocol directories
    ProtocolInfo = bst_get('ProtocolInfo');
    % Resolve link, if it is a link
    [FileName, DataFile] = resolveResultsLink(FileName);
    % Load file
    sFileMat = load(FileName);
    % Stat
    if isStat
        sStat.Type = 'presults';
        sStat.Comment = sFileMat.Comment;
        sFileMat = sStat;
    else
        % Time
        sFileMat.Time = iTime;
        sFileMat.ImageGridTime = TimeVector;
        % Reset some fields
        sFileMat.OPTIONS.Data  = [];
        sFileMat.Fsynth        = [];
        sFileMat.ImagingKernel = [];
        sFileMat.ImageGridAmp  = [];
        if ~isSampleBySample
            sFileMat.DataFile = [];
        elseif ~isempty(DataFile)
            sFileMat.DataFile = strrep(DataFile, ProtocolInfo.STUDIES, '');
        end
    end
    % Remove "Kernel" indications in the Comment field
    sFileMat.Comment = strrep(sFileMat.Comment, '(Kernel)', '');
    sFileMat.Comment = strrep(sFileMat.Comment, 'Kernel', '');
end
% Bad channels list
sFileMat.ChannelFlag = ChannelFlag;

% Add some fields for exported results
if isOneOutputMat
    sFileMat.DescFileName   = {};
    sFileMat.DescCluster    = {};
    sFileMat.DescProcessType= sProcess.Name;
end

end


%% ===== SAVE NEW FILE =====
function sTargetStudy = SaveNewFile(newFileMat, sProcess, isData, iTargetStudy, sTargetStudy, InputFile)
% Get protocol directories
ProtocolInfo = bst_get('ProtocolInfo');
% Get default output file
OutputDir = fullfile(ProtocolInfo.STUDIES, fileparts(sTargetStudy.FileName));
FullFileName = GetDefaultFileName(sProcess, isData, OutputDir, InputFile);
% Save in database
save(FullFileName, '-struct', 'newFileMat');
% Register in database
isStat = 1 % ismember(sProcess.Category, {'TTest', 'PermTest', 'Anova'});

% why removing the path ??
FileName = strrep(FullFileName, ProtocolInfo.STUDIES, '');
sTargetStudy = RegisterNewFile(newFileMat, FileName, isData, isStat, iTargetStudy);

end


% ===== GET OUTPUT STUDY =====
function [sOutputStudy, iOutputStudy, isNewConditions, Comment] = GetOutputStudy(sProcess,SamplesA,SamplesB,OPTIONS)
% Get some properties of the filter
isMixedSubjectsAB = isempty(SamplesB) || ~isequal({SamplesA.SubjectFile}, {SamplesB.SubjectFile});
isSampleBySample = ismember(sProcess.Category, {'Filter2', 'Filter', 'Extract'});
isConditionByCondition = strcmpi(sProcess.Name, 'GAVE');
isNewConditions = 0;
% Get the list of involved studies
uniqueStudiesInd = unique([SamplesA.iStudy, SamplesB.iStudy]);
%     Comment = OPTIONS.Comment;
Comment = '';

% ===== CHECK SUBJECT UNICITY =====
% Get full subjects list without repetitions
uniqueSubjectFiles = unique(cat(2, {SamplesA.SubjectFile}, {SamplesB.SubjectFile}));
% For stat on sources: all the results files must be computed on the same surface.
% => else, the number of sources might be different between different files
% => user should realign surfaces before going on
if (length(uniqueSubjectFiles) > 1)
    isUniqueSubject = 0;
    if ~isSampleBySample && ~OPTIONS.isData
        % If there is more than one subjects involved: need to check that all
        % the subjects use the default anatomy
        for i = 1:length(uniqueSubjectFiles)
            sSubject = bst_get('Subject', uniqueSubjectFiles{i});
            if ~sSubject.UseDefaultAnat
                gui_hidePanel('panel_statRun');
                sOutputStudy = [];
                iOutputStudy = [];
                bst_error(['The sources files you selected use different anatomies.' 10 ...
                    'In order to perform any computation on sources, all the files' 10 ...
                    'should use the same anatomy.' 10 10 ...
                    'You have to project all your results on a template anatomy.' 10 ...
                    'Popup menu: "Project sources on default anatomy".'], 'Processes', 0);
                return;
            end
        end
    end
else
    isUniqueSubject = 1;
end

% ===== GET OUTPUT STUDY =====
% SUBJECT AVERAGE
if strcmpi(sProcess.Name, 'SubjAvg')
    % Get subject
    [sSubject, iSubject] = bst_get('Subject', SamplesA(1).SubjectFile);
    % Get "intra" study for this subject
    [sOutputStudy, iOutputStudy] = bst_get('AnalysisIntraStudy', iSubject);
    % Comment
    Comment = ['SubjectAvg(' SamplesA(1).SubjectName ')'];
    % UNIQUE STUDY (OR OVERWRITE)
elseif (length(uniqueStudiesInd) == 1) || OPTIONS.isOverwriteFiles
    % Get this unique study
    [sOutputStudy, iOutputStudy] = bst_get('Study', uniqueStudiesInd(1));
    % MULTIPLE STUDIES : SAMPLE BY SAMPLE
elseif isSampleBySample && ~isMixedSubjectsAB
    % Target study is a new condition (name = test comment)
    % Get subject path
    newCondPath = fileparts(SamplesA(1).SubjectFile);
    % Get new condition name
    localCond = struct('SamplesA',SamplesA,'SamplesB',SamplesB);
    newCondName = panel_statRun('FormatComment', sProcess, localCond, OPTIONS.Time);
    newCondName = io_standardizeFileName(newCondName);
    % Comment
    Comment = sProcess.FileTag;
    Comment = strrep(Comment, '#A#', localCond.SamplesA(1).Comment);
    Comment = strrep(Comment, '#B#', localCond.SamplesB(1).Comment);
    % Try to get an existing condition with this path
    [sOutputStudy, iOutputStudy] = bst_get('StudyWithCondition', fullfile(newCondPath,newCondName));
    % If does not exist: Create a new condition
    if isempty(sOutputStudy)
        iOutputStudy = db_addCondition(newCondPath, newCondName, 'NoRefresh');
        sOutputStudy = bst_get('Study', iOutputStudy);
        isNewConditions = 1;
    end
    % MULTIPLE STUDIES : CONDITION BY CONDITION
elseif isConditionByCondition
    Comment = ['GAVE(' SamplesA(1).Condition ')'];
    % Grand average: stored in 'analysis-inter' node
    [sOutputStudy, iOutputStudy] = bst_get('AnalysisInterStudy');
    % MULTIPLE STUDIES : GLOBAL
else
    % UNIQUE SUBJECT : 'analysis-intra'
    if isUniqueSubject
        % Subject file is the same for all the studies => find common subject
        [sSubject, iSubject] = bst_get('Subject', SamplesA(1).SubjectFile);
        % Get 'analysis-intra' node of this subject
        [sOutputStudy, iOutputStudy] = bst_get('AnalysisIntraStudy', iSubject);
        % MULTIPLE SUBJECTS : 'analysis-inter'
    else
        % Get 'analysis-inter' node in current protocol
        [sOutputStudy, iOutputStudy] = bst_get('AnalysisInterStudy');
    end
end
% Error ?
if isempty(sOutputStudy)
    error('Cannot find an analysis study to store the results.');
end

% ===== COMBINE CHANNEL FILES =====
% If source and target studies are not the same
if ~isequal(uniqueStudiesInd, iOutputStudy)
    % Destination study for new channel file
    [tmp__, iChanStudyDest] = bst_get('ChannelForStudy', iOutputStudy);
    % Source channel files studies
    [tmp__, iChanStudySrc] = bst_get('ChannelForStudy', uniqueStudiesInd);
    % If target study has no channel file: create a new one by combination of the others
    isNewChannelFile = db_combineChannelFiles(unique(iChanStudySrc), iChanStudyDest, [], ~OPTIONS.isData);
    % Reload target study if it changed (new channel file)
    if isNewChannelFile
        sOutputStudy = bst_get('Study', iOutputStudy);
        tree_updateModel();
    end
end
end


%% ===== GET DEFAULT FILE NAME =====
function OutputFile = GetDefaultFileName(sProcess, isData, OutputDir, InputFile)
    % Get date and time for filename
    c = clock;
    strTime = sprintf('_%02.0f%02.0f%02.0f_%02.0f%02.0f', c(1)-2000, c(2:5));
    
    % Output file tag
    
    if ismember(sProcess.Category, {'TTest', 'PermTest', 'ANOVA'})
        if isData
            fileTag = 'pdata';
        else
            fileTag = 'presults';
        end
    else
        if isData
            fileTag = 'data';
        else
            fileTag = 'results';
        end
    end
    
    % Other tags present in input file
    if ~isempty(strfind(InputFile, '_zscore'))
        strInputTags = '_zscore';
    else
        strInputTags = '';
    end

    % Default filename
    defFileName = [fileTag '_' sProcess.Name strTime strInputTags '.mat'];
    % File in the target study
    OutputFile = fullfile(OutputDir, defFileName);
    % Make filename unique
    OutputFile = io_makeUniqueFilename(OutputFile);
end




%% ===== REGISTER NEW FILE =====
function sStudy = RegisterNewFile(FileMat, FileName, isData, isStat, iStudy)
    % Get study
    sStudy = bst_get('Study', iStudy);
    % Stat
    if isStat
        % Create new stat file descriptor
        % sNewStat = db_getDataTemplate('Stat');
        sNewStat = db_template('stat');
        sNewStat.FileName   = FileName;
        sNewStat.Comment    = FileMat.Comment;
        sNewStat.Type       = FileMat.Type;
        sNewStat.pThreshold = FileMat.pThreshold;
        % Add it to study
        sStudy.Stat(end+1) = sNewStat;
    % Data
    elseif isData
        % Create new data descriptor
        sNewData = db_template('data');
        sNewData.FileName = FileName;
        sNewData.Comment  = FileMat.Comment;
        % Add it to study
        sStudy.Data(end+1) = sNewData;
    % Results
    else
        % Create new results descriptor
        sNewResult = db_template('results');
        sNewResult.FileName = FileName;
        sNewResult.Comment  = FileMat.Comment;
        sNewResult.DataFile = FileMat.DataFile;
        % Add it to study
        sStudy.Result(end+1) = sNewResult;
    end
    % Update database
    bst_set('Study', iStudy, sStudy);
end