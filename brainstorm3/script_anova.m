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

sTest = sModel;
sTest.Name        = 'RM-Anova';
sTest.Comment     = 'Anova (under dev.)';
sTest.FileTag     = 'Anova';
sTest.Description = 'Repeated measures parametric Analysis of Variance';
sTest.Category    = 'Anova';
sAnova(end + 1) = sTest;

OPTIONS = struct();

isData = 0;

% Is processing recordings or results
OPTIONS.isData = isData;


% Get new file comment
OPTIONS.Comment = deblank(strtrim(char(jTextComment.getText())));
% Is absolute values (for sources only)
OPTIONS.isAbsoluteValues = 0 ; % ~isData && jCheckAbsoluteValues.isSelected();
% Get selected process
[OPTIONS.sProcess, selectedTab] = GetSelectedProcess();

OPTIONS.Factors = [];

OPTIONS.isOverwriteFiles = 0;

OPTIONS.OutputType = 'database';
OPTIONS.ForceOutputCond = [];
OPTIONS.sClusters = [];
OPTIONS.ClustersOptions = [];

% Get time
[OPTIONS.Time, OPTIONS.Baseline, OPTIONS.iTime, OPTIONS.iBaseline] = GetTimeWindows(TimeUnit);

% Get files to batch
OPTIONS.Conditions = Conditions;

bst_batch(OPTIONS);
panel_stat('ResetPanel');