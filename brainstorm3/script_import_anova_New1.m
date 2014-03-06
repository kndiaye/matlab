% TUTORIAL_10_STAT: Script that follows Brainstorm online tutorial #10: "Statistics"
%
% USAGE:
%     1) Run first the previous tutorials (#2, #3, #5, #6, #7)
%     2) Run this script

% DESCRIPTION: Compute the difference between the two sources files that were computed in tutorial #7.

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
% Author: Francois Tadel, 2010


%% ===== START BRAINSTORM =====
% Add brainstorm.m path to the path
addpath(fileparts(fileparts(fileparts(mfilename('fullpath')))));
% If brainstorm is not running yet: Start brainstorm without the GUI
if ~brainstorm('status')
    brainstorm nogui
end

CONDITIONS = {'avg_HighCorrect' 'avg_HighIncorrect' 'avg_LowCorrect' 'avg_LowIncorrect' }
SUBJECTS = cellstr(reshape(sprintf('S%02d',[11 12 14:23 25:27]),3,[])');
%% Creat File List
i= 1;
clear FilesA
for i_sub=1:length(SUBJECTS)
    for i_cond = 1:4

        % Get condition StimRightThumb
        [sStudy, iStudy] = bst_getContext('StudyWithCondition', [ SUBJECTS{i_sub} '/' CONDITIONS{i_cond}]);

        %% ===== SELECT FILES =====
        % Get the two kernels computed in tutorial #7: the regular and the shared one
        iRes1 = find(~cellfun(@(c)isempty(strfind(c, 'MN: EEG (scalp)(Kernel)')), {sStudy.Result.Comment}));

        iRes1 = iRes1(1);
        % Define the list of files A
        FilesA(i) = {['I:\data\confinum\brainstorm\data' sStudy.Result(iRes1(1)).FileName]};
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


Baseline =[]
iBaseline =[]
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

n_effects=1
for i_effects = 1:n_effects
% Call processing function
%OutputFiles = bst_batch(OPTIONS);
p = rand(15028,921);
F = rand(15028,921);
[sTargetStudy] = import_anova(Conditions, sProcess, OPTIONS, TimeVector, p, F)
end


