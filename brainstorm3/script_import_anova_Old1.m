% import des r?sultats de l'anovabst de Lydia dans BrainSotmr
% inspir? de TUTORIAL_10_STAT: Script that follows Brainstorm online
% tutorial #10: "Statistics"
%Auteurs: Karim N'Diaye, CTB

%Alancer avec BrainSorm ouvert, onglet Statistics actif et case "cources"
%coch?e
% Appel import_anova

%%% constantes
CONDITIONS = {'ALL_EURO' 'ALL_DOLLAR' 'ALL_FRANC' 'ALL_MARK' 'ALL_SCR_EURO' 'ALL_SCR_DOLLAR' 'ALL_SCR_FRANC' 'ALL_SCR_MARK'}
SUBJECTS = {'sujet_01' 'sujet_02' 'sujet_03' 'sujet_04' 'sujet_05' 'sujet_06' ...
            'sujet_08' 'sujet_09' 'sujet_10' 'sujet_11' 'sujet_12' 'sujet_13' ...
            'sujet_21' 'sujet_22' 'sujet_23' 'sujet_pilote'};
path2bst='/pclxserver/raid6/data/MONEY/BrainStormData/MONEY/data/'
path2anovares='/pclxserver/raid6/data/MONEY/Analyze16suj/StatSources/Raw/'
StructName='Sources3way';
FilesToFind='MN: MEG(Full,Constr)'
liste_effects=[1 2 3 12 13 23 123];
FileComment='Raw_An3F';   %%% Attention: nom sous lequel le fichier apparaitra dans la base BST

%% Creat File List
i= 1;
clear FilesA
for i_sub=1:length(SUBJECTS)
    for i_cond = 1:length(CONDITIONS)

        % Get condition StimRightThumb
        [sStudy, iStudy] = bst_getContext('StudyWithCondition', [ SUBJECTS{i_sub} '/' CONDITIONS{i_cond}]);

        %% ===== SELECT FILES =====
        % Get the two kernels computed in tutorial #7: the regular and the shared one
        iRes1 = find(~cellfun(@(c)isempty(strfind(c, FilesToFind)), {sStudy.Result.Comment}));

        iRes1 = iRes1(1);
        % Define the list of files A
        FilesA(i) = {[path2bst sStudy.Result(iRes1(1)).FileName]};
        i=i+1;
    end
end
% Remove previous nodes in the Statistics panel
panel_stat('ResetPanel');
% Add files to the Statistics panel
nFilesA = gui_stat_common('SetFilesToProcess', 'StatA', FilesA);

        % Set types of files to process: data/results
isData = 0;
if isData
    panel_stat('SetFileType', 'data');
else
    panel_stat('SetFileType', 'presults');
end
% Conditions: structure that define the files in the Processes list
Conditions = gui_stat_common('GetConditions', 'Statistics');


%% ===== GET PROCESS =====
% Get processes list, and pick a process in it
[sProcessesList, sSimpleTests, sPermTests] = panel_statRun('GetProcessesList', 'All');
% Find a process using its name
ProcessName = 'diffAB';
iProc = find(strcmpi({sProcessesList.Name}, ProcessName));
if isempty(iProc)
    error('Process not found.');
end
% Process to use
sProcess = sProcessesList(iProc);

sProcess.Name='ANOVA'
sProcess.Description = '';
sProcess.Category = 'ANOVA';
sProcess.FileTag = ''

%% ===== TIME =====
% Use all the time samples
TimeVector = panel_statRun('GetFileTimeVector', Conditions.SamplesA(1).iStudy, Conditions.SamplesA(1).iItem, isData);
Time  = [TimeVector(1), TimeVector(end)];
iTime = 1:length(TimeVector);


Baseline =[];
iBaseline =[];
%% ===== DEFINE OPTIONS =====
OPTIONS.Conditions       = Conditions;    % Files to process
OPTIONS.sProcess         = sProcess;      % Process to apply
OPTIONS.isData           = isData;        % Process data or recordings
OPTIONS.Comment          = 'anovalena';   % Default comment for output files (might be overridden)
OPTIONS.OutputType       = 'database';    % Where o store the results: {database, file, matlab}
OPTIONS.ForceOutputCond  = [];            % When you want to store the result in a specific condition (used only when OutputType='database')=> Ex. 'Subject01/@intra'
OPTIONS.isOverwriteFiles = 0;             % Overwrite input files, only in the case of filters (one input file = one output file)
OPTIONS.isAbsoluteValues = 1;             % Compute the absolute value of the data before applying the process (usually 1 for sources, 0 for recordings)
OPTIONS.Time             = Time;          % Time window to process [tStart, tStop] in seconds
OPTIONS.iTime            = iTime;         % Time window: Indices in time vector for the full file
OPTIONS.Baseline         = Baseline;      % Some processes requires a baseline definition (it is the case for the zscore)
OPTIONS.iBaseline        = iBaseline;     % => Baseline and iBaseline work exactly the same way as Time and iTime
% Other options we do not use here:
OPTIONS.nbPermutation    = 0;    % For permuation tests only
OPTIONS.isCluster        = 0;    % Extract only some clusters/scouts values
OPTIONS.isClusterAverage = 0;    % If 1, group all the clusters/scouts; If 0, consider they are separate
OPTIONS.sClusters        = [];   % Array of scouts/clusters structures
OPTIONS.ClustersOptions  = [];   % Structure that defines how the clusters/scouts values are computed (fields: function, isAbsolute)
OPTIONS.Baseline         = [];
OPTIONS.iBaseline        = [];


n_effects=size(liste_effects,2);
for i_effects = 1:n_effects
% Call processing function
%OutputFiles = bst_batch(OPTIONS);
load (strcat(path2anovares, StructName, 'F', num2str(liste_effects(i_effects)),'.mat'))
load (strcat(path2anovares, StructName, 'p', num2str(liste_effects(i_effects)),'.mat'))
p = tempStructp.ImageGridAmp;
F = tempStructF.ImageGridAmp;
OPTIONS.Comment=strcat(FileComment,'_F',num2str(liste_effects(i_effects)))
[sTargetStudy] = import_anova(Conditions, sProcess, OPTIONS, TimeVector, p, F);
end


