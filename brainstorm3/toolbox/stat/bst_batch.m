function bst_batch(OPTIONS)
% BST_BATCH: Apply a process defined with panel_statRun, to a list a file.
%
% USAGE:  bst_batch('CreatePanel', OPTIONS)
% 
% INPUTS: (OPTIONS structure)
%     - Conditions       : Structure describing the files to process (from panel_stat and panel_process)
%     - sProcess         : Process to apply (defined in panel_statRun/GetProcessesList)
%     - isData           : 1 if files to process are recordings, 0 if they are cortical sources
%     - Comment          : Default comment for output files
%     - isAbsoluteValues : For sources, apply "abs" before applying the process
%     - nbPermutation    : Number of permutations to perform
%     - isOverwriteFiles : For filters, if 1 the input files will be replaced
%     - OutputType       : {'database', 'file', 'matlab'}
%     - isCluster        : If 1, use the clusters/scouts (only for data extraction functions)
%     - isClusterAverage : If 1, merge the input clusters/scouts
%     - sClusters        : Clusters/scouts to apply (if isCluster = 1)
%     - ClustersOptions  : Structure that describes the way to compute the clusters/scouts values
%     - Time             : Time bounds to compute values
%     - Baseline         : Baseline bounds
%     - iTime            : Indices of the time samples to process
%     - iBaseline        : Indices of the baseline

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
% FT  17-Jul-2009  Creation
% ------------------------------------------------------------------------------

% Get samples lists
SamplesA = OPTIONS.Conditions.SamplesA;
SamplesB = OPTIONS.Conditions.SamplesB;

% ===== APPLY PROCESS =====
sProcess = OPTIONS.sProcess;
% Switch according to category
switch (sProcess.Category)
    case 'Filter'
        iStudyToRedraw = BatchFilter(SamplesA, OPTIONS);
        isNewConditions = 0;
    case 'Extract'
        iStudyToRedraw = BatchExtract(SamplesA, OPTIONS);
        isNewConditions = 0;
    case 'Filter2'
        iStudyToRedraw = BatchFilter2(SamplesA, SamplesB, OPTIONS);
        isNewConditions = 0;
    case 'Average'
        % === Grand-average (by condition) ===
        % Call several time the average function (once per condition)
        if strcmpi(sProcess.Name, 'GAVE')
            % Initial values
            iStudyToRedraw = [];
            isNewConditions = 0;
            % Process each condition independently
            uniqueConditions = unique({SamplesA.Condition});
            for i = 1:length(uniqueConditions)
                % Process the average of condition #i
                iSampCond = find(strcmpi(uniqueConditions{i}, {SamplesA.Condition}));
                [tmpStudyToRedraw, tmpNewConditions] = BatchAverage(SamplesA(iSampCond), OPTIONS);
                % Save the results
                iStudyToRedraw = [iStudyToRedraw tmpStudyToRedraw];
                isNewConditions = isNewConditions || tmpNewConditions;
            end
            
        % === Average by subject ===
        % Call several time the average function (once per condition)
        elseif strcmpi(sProcess.Name, 'SubjAvg')
            % Initial values
            iStudyToRedraw = [];
            isNewConditions = 0;
            % Process each subject independently
            uniqueSubjects = unique({SamplesA.SubjectFile});
            for i = 1:length(uniqueSubjects)
                % Process the average of subject #i
                iSampSubj = find(strcmpi(uniqueSubjects{i}, {SamplesA.SubjectFile}));
                [tmpStudyToRedraw, tmpNewConditions] = BatchAverage(SamplesA(iSampSubj), OPTIONS);
                % Save the results
                iStudyToRedraw = [iStudyToRedraw tmpStudyToRedraw];
                isNewConditions = isNewConditions || tmpNewConditions;
            end
            
        % Else, just call function once to average everything
        else
            [iStudyToRedraw, isNewConditions] = BatchAverage(SamplesA, OPTIONS);
        end
        
    case {'Spectral'}
        [iStudyToRedraw, isNewConditions] = BatchSpectralDecomposition(SamplesA, OPTIONS);
        
    case {'Recurrence'}
        [iStudyToRedraw, isNewConditions] = BatchRecurrenceMaps(SamplesA, OPTIONS);
                
    case {'TTest', 'PermTest'}
        iStudyToRedraw = BatchStat(SamplesA, SamplesB, OPTIONS);
        isNewConditions = 0;
                
    case {'Anova'}
        iStudyToRedraw = BatchStat(SamplesA,[],OPTIONS);
        isNewConditions = 0;
end

% ===== UPDATE INTERFACE =====
% OUTPUT TYPE: DATABASE ONLY
if strcmpi(OPTIONS.OutputType, 'database') && ~isempty(iStudyToRedraw)
    iStudyToRedraw = unique(iStudyToRedraw);
    % Unload all datasets
    bst_dataSetsManager('UnloadAll', 'Forced');
    % Update results links in target study
    db_updateLinkResults('Study', iStudyToRedraw);
    % Update tree model
    if isNewConditions
        tree_updateModel();
    else
        tree_updateNode('Study', iStudyToRedraw);
    end
    % Select target study as current node
    tree_selectStudyNode( iStudyToRedraw(1) );
    % Save database
    bst_saveDatabase();
end

% Hide waitbar
bst_progressBar('stop');


end



%% ======================================================================================
%  ===== BATCH FUNCTIONS ================================================================
%  ======================================================================================

%% ===== BATCH: FILTERS =====
function iStudyToRedraw = BatchFilter(SamplesA, OPTIONS)
    % === SOME VERIFICATIONS ===
    % OUTPUT: DATABASE ONLY
    if ~strcmpi(OPTIONS.OutputType, 'database')
        error('Filtering results can only be stored in database.'); 
    end
    % Get process
    sProcess = OPTIONS.sProcess;
    nbSamplesA = length(SamplesA);
    iStudyToRedraw = [];
    % Prepare OPTIONS structure for process_apply function
    filterOPTIONS = struct('fcnFilter',        str2func(['process_' sProcess.Name]), ...
                           'FileA',            '', ...
                           'iTime',            OPTIONS.iTime, ...
                           'iBaseline',        OPTIONS.iBaseline, ...
                           'FileTag',          sProcess.Name, ...
                           'Comment',          OPTIONS.Comment, ...
                           'isAbsoluteValues', OPTIONS.isAbsoluteValues, ...
                           'blockDimension',   sProcess.blockDimension, ...
                           'isAvgRef',         sProcess.isAvgRef);
    
    % === FILES LOOP ===
    bst_progressBar('start', ['Apply process: ' sProcess.Name], 'Initialization...', 0, nbSamplesA);
    % Process all the files
    for i = 1:nbSamplesA
        % Progress bar
        bst_progressBar('text', ['File: ' SamplesA(i).FileName]);
        bst_progressBar('inc', 1);
        % Output study: same as input file
        iTargetStudy = SamplesA(i).iStudy;
        sTargetStudy = bst_getContext('Study', iTargetStudy);
        % Ignore computation for files that are already processed
        if ~isempty(strfind(SamplesA(i).FileName, ['_' sProcess.Name]))
            res = java_dialog('confirm', ['The following file has already been processed with this filter: ' 10 SamplesA(i).FileName '.' 10  10 'Apply this process again ?'], 'Processes');
            if ~res
                continue
            end
        end
        % Update this study
        iStudyToRedraw(end + 1) = iTargetStudy;
        
        % === COMPUTE FILTER ===
        % Complete filter configuration
        filterOPTIONS.FileA = SamplesA(i).FullFileName;       
        % Apply process
        [sNewFile, filterOPTIONS] = process_apply(filterOPTIONS);
        % If process cancelled
        if isempty(sNewFile)
            return
        end
        
        % === UPDATE STUDY ===
        % Overwrite initial file 
        if OPTIONS.isOverwriteFiles
            % Delete the intial file
            io_deleteFile(SamplesA(i).FullFileName, 1);
        end
        % Add new file to database
        if OPTIONS.isData
            if OPTIONS.isOverwriteFiles
                iItem = SamplesA(i).iItem;
            else
                iItem = length(sTargetStudy.Data) + 1;
            end
            % Add new descriptor it to study
            sTargetStudy.Data(iItem) = sNewFile;
        else
            if OPTIONS.isOverwriteFiles
                iResult = SamplesA(i).iItem;
            else
                iResult = length(sTargetStudy.Result) + 1;
            end
            % Add new descriptor it to study
            sTargetStudy.Result(iResult) = sNewFile;
        end
        bst_setContext('Study', iTargetStudy, sTargetStudy);
    end
end


%% ===== BATCH: EXTRACT =====
function iStudyToRedraw = BatchExtract(SamplesA, OPTIONS)
    % Get process
    sProcess = OPTIONS.sProcess;
    nbSamplesA = length(SamplesA);
    iStudyToRedraw = [];
    isOneOutputMat = ~strcmpi(OPTIONS.OutputType, 'database');
    initTimeVector = [];
    ProtocolInfo = bst_getContext('ProtocolInfo');

    % === FILES LOOP ===
    bst_progressBar('start', 'Data extraction', 'Initialization...', 0, nbSamplesA);
    % Process all the files
    for iSample = 1:nbSamplesA
        % Progress bar
        bst_progressBar('text', ['File: ' SamplesA(iSample).FileName]);
        bst_progressBar('inc', 1);
        % Output study: same as input file
        iTargetStudy = SamplesA(iSample).iStudy;
        sTargetStudy = bst_getContext('Study', iTargetStudy);
        % Update this study
        iStudyToRedraw(end + 1) = iTargetStudy;
        
        % === READ FILE ===
        if sProcess.isAvgRef
            [matValues, matName, ChannelFlag, TimeVector] = bst_readMatrixInFile(SamplesA(iSample).FullFileName, []);
        else
            [matValues, matName, ChannelFlag, TimeVector] = bst_readMatrixInFile(SamplesA(iSample).FullFileName, [], 'NoAvgRef');
        end
        
        % === TIME ===
        % Check time vectors
        if (iSample == 1)
            initTimeVector = TimeVector;
        elseif (length(initTimeVector) ~= length(TimeVector)) || ~all(abs(initTimeVector - TimeVector) < 1e-6)
            filedesc = fullfile(fileparts(SamplesA(iSample).FileName), SamplesA(iSample).Comment);
            bst_error(['Time definition should be the same for all the files.' 10 10 'Ignoring file: "' filedesc '"'], 'bst_batch', 0);
            return
        end
        % Keep only required time indices
        matValues = matValues(:, OPTIONS.iTime);
        TimeVector = TimeVector(OPTIONS.iTime);
        
        % === PROCESSES ===
        % Absolute values
        if OPTIONS.isAbsoluteValues
            matValues = abs(matValues);
        end
        % Process to apply to this block of data
        switch (sProcess. Name)
            case 'timemean'
                % Compute the average of all the time samples on the defined time window
                matValues = mean(matValues, 2);
                isTimeMean = 1;
            case 'timevar'
                % Compute the variance of all the time samples on the defined time window
                matValues = var(matValues, 0, 2);
                isTimeMean = 1;
            case 'extract'
                % Nothing to do
                isTimeMean = 0;
        end
        % TimeMean: Keep only the time window from which was computed the result
        if isTimeMean
            OPTIONS.iTime = OPTIONS.iTime([1,end]);
            TimeVector = TimeVector([1, end]);
        end

        % === APPLY CLUSTER ===
        if OPTIONS.isCluster
            % Process each cluster
            nbClusters = length(OPTIONS.Clusters);
            tmpMatValues = zeros(nbClusters, size(matValues, 2));
            DescCluster = cell(nbClusters, 1);
            for i = 1:nbClusters
                sCluster = OPTIONS.Clusters(i);
                % === GET ROWS INDICES ===
                if OPTIONS.isData
                    % Get channel file
                    [sStudy, iStudy] = bst_getContext('DataFile', SamplesA(iSample).FileName);
                    sChannel = bst_getContext('ChannelForStudy', iStudy);
                    % Load channel file
                    ChannelFile = fullfile(ProtocolInfo.STUDIES, sChannel.FileName);
                    ChannelMat = load(ChannelFile, 'Channel');
                    % CLUSTERS: Get cluster channels
                    iRows = panel_clusters('GetChannelsInCluster', sCluster, ChannelMat.Channel, ChannelFlag);
                    if isempty(iRows)
                        return;
                    end
                else
                    % SCOUTS: Get the indices of the sources of this scout
                    iRows = sCluster.Vertices;
                end
                
                % === COMPUTE CLUSTER VALUES ===
                % Scouts: absolute or relative values
                isDifference = strcmpi(sProcess.Name, 'diffAB');
                % If computing a difference : FORCE RELATIVE VALUES
                if ~OPTIONS.ClustersOptions.isAbsolute || isDifference
                    tmp = matValues(iRows, :);
                else
                    tmp = abs(matValues(iRows, :));
                end
                % Scouts computation operation : mean or max
                switch (OPTIONS.ClustersOptions.function)
                    case 'Max'
                        tmpMatValues(i,:) = max(tmp, [], 1);
                    case 'Power'
                        tmpMatValues(i,:) = sum(tmp .^ 2, 1);
                    case 'Mean'
                        tmpMatValues(i,:) = mean(tmp, 1);
                    otherwise
                        bst_error(['Cannot extract automatically all values.' 10 ...
                                   'Please change scout options: "Scouts" panel > View > Time series options'], ...
                                   'bst_batch', 0);
                        return;
                end
                % Save the name of the scout
                DescCluster{i} = sCluster.Label;
            end
            % Return results matrix averaged by scout
            matValues = tmpMatValues;
        else
            DescCluster = {};
        end        
                       
        % ===== OUTPUT STRUCTURE ====
        % Create new output structure
        if ~isOneOutputMat || (iSample == 1)
            newFileMat = CreateDefaultStruct(sProcess, SamplesA(iSample).FullFileName, OPTIONS.isData, TimeVector, OPTIONS.iTime, ChannelFlag, isOneOutputMat, 1);
            % Append comment
            newFileMat.Comment = [newFileMat.Comment, ' ', OPTIONS.Comment];
        end
        % If new file to be saved at each loop: copy matValues
        if ~isOneOutputMat
            if isTimeMean
                newFileMat.(matName) = repmat(matValues, [1, 2]);
            else
                newFileMat.(matName) = matValues;
            end
        else
            % Get new matrix
            prevMat = newFileMat.(matName);
            % Check the orientation in which the new data should be appended:
            %   - Time mean : dimension 2 (time)
            %   - Channels mean : dimension 1 (channels)
            if isTimeMean
                % Check the number of electrodes
                if ~isempty(prevMat) && (size(prevMat,1) ~= size(matValues,1))
                    error(['The data files in samples set A do not have the same number of channels.' 10 ...
                           'It is impossible to store their averages in the same matrix.']); 
                end
                % Concatenate the results matrices & add description fields
                newFileMat.(matName)    = cat(2, prevMat, matValues);
                newFileMat.DescFileName = cat(2, newFileMat.DescFileName, repmat({SamplesA(iSample).FileName}, [1, size(matValues,2)]));
                newFileMat.DescCluster  = cat(2, newFileMat.DescCluster, DescCluster);
            else
                if ~isempty(prevMat) && (size(prevMat,2) ~= size(matValues,2))
                    error(['The files in samples set A do not have the same number of time samples.' 10 ...
                           'It is impossible to store their averages in the same matrix.']); 
                end
                % Concatenate the results matrices & add description fields
                newFileMat.(matName)    = cat(1, prevMat, matValues);
                newFileMat.DescFileName = cat(1, newFileMat.DescFileName, repmat({SamplesA(iSample).FileName}, [size(matValues,1), 1]));
                newFileMat.DescCluster  = cat(1, newFileMat.DescCluster, DescCluster);
            end
            % Add bad channels from current ChannelFlag
            newFileMat.ChannelFlag(ChannelFlag == -1) = -1;
        end

        % ===== SAVE FILE =====
        if ~isOneOutputMat
            SaveNewFile(newFileMat, sProcess, OPTIONS.isData, iTargetStudy, sTargetStudy, SamplesA(iSample).FileName);
        end
    end
    
    % === EXPORT DATA ===
    if isOneOutputMat
        % Display waitbar
        bst_progressBar('start', 'Processes', 'Saving results...');
        % Save file
        switch(OPTIONS.OutputType)
            case 'file'
                % Save in a user defined file
                if OPTIONS.isData || OPTIONS.isCluster
                    export_data(newFileMat);
                else
                    export_result(newFileMat);
                end
            case 'matlab'
                % Export to Matlab workspace
                export_matlab(newFileMat);
        end
    end
end


%% ===== BATCH: AVERAGE =====
function [iStudyToRedraw, isNewConditions] = BatchAverage(SamplesA, OPTIONS)
    % Get process
    sProcess = OPTIONS.sProcess;
    % Get output study
    [sTargetStudy, iTargetStudy isNewConditions, Comment] = GetOutputStudy(sProcess,SamplesA,repmat(SamplesA, 0),OPTIONS);
    % Update this study
    iStudyToRedraw = iTargetStudy;
    % If no valid output study can be found
    if isempty(iTargetStudy)
        return;
    end
        
    % === PROCESS AVERAGE ===
    bst_progressBar('start', ['Apply process: ' sProcess.Name], 'Initialization...', 0, length(SamplesA));
    % If absolute values
    if OPTIONS.isAbsoluteValues
        strAbsolute = 'AbsoluteValues';
    else
        strAbsolute = [];
    end
    Stat = bst_statFiles('mean', {SamplesA.FullFileName}, OPTIONS.iTime, 'PercentProgressBar', strAbsolute);

    % === SAVE RESULTS ===
    % Get default file structure
    newFileMat = CreateDefaultStruct(sProcess, SamplesA(1).FullFileName, OPTIONS.isData, Stat.Time, OPTIONS.iTime, Stat.ChannelFlag, 0, 0);
    % Add averaged values in it
    newFileMat.(Stat.MatName) = Stat.mean;
    % Comment
    if isempty(OPTIONS.Comment) && isempty(Comment)
        % Use default commet: "ProcessName: date"
        c = clock;
        strTime = sprintf('%02.0f%02.0f%02.0f_%02.0f%02.0f', c(1)-2000, c(2:5));
        newFileMat.Comment = [sProcess.Name ': ' strTime];
    elseif isempty(OPTIONS.Comment)
        newFileMat.Comment = Comment;
    else
        newFileMat.Comment = OPTIONS.Comment;
    end
    % Save and register file
    SaveNewFile(newFileMat, sProcess, OPTIONS.isData, iTargetStudy, sTargetStudy, SamplesA(1).FileName);
end


%% ===== BATCH: FILTER2 =====
function [iStudyToRedraw, isNewConditions] = BatchFilter2(SamplesA, SamplesB, OPTIONS)
    % Get process
    sProcess = OPTIONS.sProcess;
    nbSamplesA = length(SamplesA);
    iStudyToRedraw = [];

    % === FILES LOOP ===
    bst_progressBar('start', 'Comparisons', 'Initialization...', 0, nbSamplesA);
    % Process all the files
    for iSample = 1:nbSamplesA
        % Progress bar
        bst_progressBar('text', ['File: ' SamplesA(iSample).FileName]);
        bst_progressBar('inc', 1);
        % Get output study
        [sTargetStudy, iTargetStudy isNewConditions, Comment] = GetOutputStudy(sProcess,SamplesA(iSample),SamplesB(iSample),OPTIONS);
        % If no valid output study can be found
        if isempty(iTargetStudy)
            return;
        end
        % Update this study
        iStudyToRedraw(end + 1) = iTargetStudy;
        
        % === READ FILES ===
        if sProcess.isAvgRef
            % Sample A
            [matValuesA, matNameA, ChannelFlagA, TimeVectorA] = bst_readMatrixInFile(SamplesA(iSample).FullFileName, []);
            % Sample B
            [matValuesB, matNameB, ChannelFlagB, TimeVectorB] = bst_readMatrixInFile(SamplesB(iSample).FullFileName, []);
        else
            % Sample A
            [matValuesA, matNameA, ChannelFlagA, TimeVectorA] = bst_readMatrixInFile(SamplesA(iSample).FullFileName, [], 'NoAvgRef');
            % Sample B
            [matValuesB, matNameB, ChannelFlagB, TimeVectorB] = bst_readMatrixInFile(SamplesB(iSample).FullFileName, [], 'NoAvgRef');
        end

        % === TIME ===
        % Check time vectors
        if (length(TimeVectorA) ~= length(TimeVectorB)) || ~all(abs(TimeVectorA - TimeVectorB) < 1e-6)
            bst_error('Each couple of files (A,B) must have the same time definition.', 'bst_batch', 0);
            return
        elseif (length(ChannelFlagA) ~= length(ChannelFlagB)) 
            bst_error('Each couple of files (A,B) must have the same number of channels.', 'bst_batch', 0);
            return
        end
        % Keep only required time indices
        matValuesA = matValuesA(:, OPTIONS.iTime);
        matValuesB = matValuesB(:, OPTIONS.iTime);
        TimeVector = TimeVectorA(OPTIONS.iTime);
        % Combine bad channels
        ChannelFlag = ones(size(ChannelFlagA));
        ChannelFlag((ChannelFlagA == -1) | (ChannelFlagB == -1)) = -1;
        
        % === PROCESSES ===
        % Absolute values
        if OPTIONS.isAbsoluteValues
            matValuesA = abs(matValuesA);
            matValuesB = abs(matValuesB);
        end
        % Apply process
        switch (sProcess.Name)
            case 'diffAB'
                matValues = matValuesA - matValuesB;
            case 'meanAB'
                matValues = (matValuesA + matValuesB) / 2;
        end

        % ===== SAVE FILE ====
        % Create default structure
        newFileMat = CreateDefaultStruct(sProcess, SamplesA(iSample).FullFileName, OPTIONS.isData, TimeVector, OPTIONS.iTime, ChannelFlag, 0, 1);
        % Add averaged values in it
        newFileMat.(matNameA) = matValues;
        % Comment
        if isempty(OPTIONS.Comment)
            if ~isempty(Comment)
                newFileMat.Comment = Comment;
            else
                % Build comments based on the samples couple
                localCond = struct('SamplesA',SamplesA(iSample), 'SamplesB',SamplesB(iSample));
                newFileMat.Comment = panel_statRun('FormatComment', sProcess, localCond, OPTIONS.Time);
            end
        else
            newFileMat.Comment = OPTIONS.Comment;
        end
        % Save file
        SaveNewFile(newFileMat, sProcess, OPTIONS.isData, iTargetStudy, sTargetStudy, SamplesA(iSample).FileName);
    end
end


%% ===== BATCH: STAT =====
function iStudyToRedraw = BatchStat(SamplesA, SamplesB, OPTIONS)
    % Get process
    sProcess = OPTIONS.sProcess;
    testType = sProcess.Name;
    isPermTest = strcmpi(sProcess.Category, 'PermTest');
    % For old Karim t-test
    isOldSimpleTest = ~isempty(strfind(sProcess.Name, 'old'));
    if isOldSimpleTest
        testType = strrep(testType, 'old_', '');
    end
    isAnova = strcmpi(sProcess.Category, 'Anova');
    
    
    % Display progress bar
    bst_progressBar('start', 'Statistical test', 'Initialization...', 0, length(SamplesA));
    % Get output study
    if isAnova
        [sTargetStudy, iTargetStudy isNewConditions, Comment] = GetOutputStudy(sProcess, SamplesA, SamplesA([]), OPTIONS);
    else
        [sTargetStudy, iTargetStudy isNewConditions, Comment] = GetOutputStudy(sProcess, SamplesA, SamplesB, OPTIONS);
    end
    iStudyToRedraw = iTargetStudy;
    % If no valid output study can be found
    if isempty(iTargetStudy)
        return;
    end
    
    % === Load all the samples ===
    % Needed only for permutation t-test, and OLD KARIM T-TEST
    if isPermTest || isOldSimpleTest
        % Samples set A
        [X1, ChannelFlagA, TimeVector] = buildDataArray({SamplesA.FullFileName}, OPTIONS.iTime);
        % Samples set B
        [X2, ChannelFlagB] = buildDataArray({SamplesB.FullFileName}, OPTIONS.iTime);
        % If is absolute values
        if OPTIONS.isAbsoluteValues 
            X1 = abs(X1);
            X2 = abs(X2);
        end
        % Combine channel flag
        ChannelFlag = ChannelFlagA;
        ChannelFlag(ChannelFlagB == -1) = -1;
    end
    
    if isAnova
        %knd: to do
        warning('manually changed anova factors!')
        [pmap,Fmap,fx,ChannelFlag, TimeVector] = knd_rmanova_files(SamplesA,OPTIONS);
        
    % === SIMPLE TESTS (OLD) ===
    elseif ~isPermTest && isOldSimpleTest
        % Remove the "old" tag
        testType = strrep(testType, 'old_', '');
        % Set permutation dimension
        dim_p = 1;
        % Display waitbar
        bst_progressBar('start', 'Processes', 'Computing t-test...');
        % Compute test
        [pmap,tmap] = knd_ttest(X1, X2, dim_p, testType);

    % === SIMPLE TESTS ===
    elseif ~isPermTest
        % Compute test
        if OPTIONS.isAbsoluteValues
            [pmap,tmap,ChannelFlag, TimeVector] = knd_ttest_files({SamplesA.FullFileName}, {SamplesB.FullFileName}, testType, OPTIONS.iTime, OPTIONS.iTime, 'AbsoluteValues');
        else
            [pmap,tmap,ChannelFlag, TimeVector] = knd_ttest_files({SamplesA.FullFileName}, {SamplesB.FullFileName}, testType, OPTIONS.iTime, OPTIONS.iTime);
        end

    % === PERMUTATIONS TESTS ===
    elseif isPermTest
        tic
        % Set permutation dimension
        if sProcess.isPaired
            dim_p = 1;
        else
            dim_p = -1;
        end

        % Compute test
        [pmap,tmap] = permtest(X1, X2, {testType}, dim_p, [], OPTIONS.nbPermutation);
        % Display computation time
        timeLength = toc();
        bst_message_window(sprintf('\nTook: %3.2f secs', timeLength));
    
             
    end

    % === BUILD NEW FILES ===
    % Display waitbar
    bst_progressBar('start', 'Processes', 'Saving results...');
    
    if isAnova
        Factors.N = 3;
        NS = numel(unique({SamplesA.SubjectName}))
        [u,i,j] = unique([SamplesA.iItem])
        if numel(u)>1
            SelectedItem = listdlg('ListString', [strvcat({SamplesA(i).Condition}) repmat(' : ',length(u),1) strvcat({SamplesA(i).Comment})],'SelectionMode','single');
            if isempty(SelectedItem)
                return
            end
            SamplesA = SamplesA(j == SelectedItem);
        end        
        f = {SamplesA.Condition};
        f=reshape(f(1+[0:3]*NS),[2 2])
        fa=sprintf('%s+',f{1,:});
        fb=sprintf('%s+',f{2,:});        
        Factors.Names{1}=sprintf('%s vs. %s',fa(1:end-1),fb(1:end-1));
        fa=sprintf('%s+',f{:,1});
        fb=sprintf('%s+',f{:,2});        
        Factors.Names{2}=sprintf('%s vs. %s',fa(1:end-1),fb(1:end-1));
        
        %Factors.Names = { 'FB' 'Conf' 'Subj'};
        Factors.NLevels = [2 2 NS]
        Factors.Levels = { {'C' 'I'} {'H' 'L'} [] };
        Factors.X = [];
        %must loop on maps
        for i_fx=1:size(pmap,1)
            % Get default structure
            newFileMat = CreateDefaultStruct(sProcess, SamplesA(1).FullFileName, OPTIONS.isData, TimeVector, OPTIONS.iTime, ChannelFlag, 0, 0);
            % Comment
            newFileMat.Comment = OPTIONS.Comment ;
            if numel(fx{i_fx}) == 1
                newFileMat.Comment = [newFileMat.Comment ' - Main effect of '];
            else
                newFileMat.Comment = [newFileMat.Comment ' - Interaction of '];
            end
            newFileMat.Comment = [newFileMat.Comment sprintf('%s * ',Factors.Names{fx{i_fx}})];
            newFileMat.Comment(end-2:end)=[];
            % Save P and F maps
            sz=[size(pmap) 1];
            newFileMat.pmap = single(reshape(pmap(i_fx,:),sz(2:end)));
            newFileMat.tmap = single(reshape(Fmap(i_fx,:),sz(2:end)));
            % Save new file and register in database
            SaveNewFile(newFileMat, sProcess, OPTIONS.isData, iTargetStudy, sTargetStudy, SamplesA(1).FileName);
        end
    else
        % Get default structure
        newFileMat = CreateDefaultStruct(sProcess, SamplesA(1).FullFileName, OPTIONS.isData, TimeVector, OPTIONS.iTime, ChannelFlag, 0, 0);
        % Comment
        if isempty(OPTIONS.Comment)
            newFileMat.Comment = Comment;
        else
            newFileMat.Comment = OPTIONS.Comment;
        end
        % Save P and T maps
        newFileMat.pmap = single(pmap);
        newFileMat.tmap = single(tmap);
        % Save new file and register in database
        SaveNewFile(newFileMat, sProcess, OPTIONS.isData, iTargetStudy, sTargetStudy, SamplesA(1).FileName);
    end
end


%% ===== BATCH: SPECTRAL ANALYSIS ======
function [iStudyToRedraw, isNewConditions] = BatchSpectralDecomposition(SamplesA, OPTIONS)
    % Frequency bands of interest
    freqBands = ...
        [1 3.9;...
        4,7.9;...
        8,12.9;...
        13,34.9;...
        35,54.9;...
        65,85;...
        200,250];
    NamesFreqBands = {...
        'delta_1_4Hz',...
        'theta_4_8Hz',...
        'alpha_8_13Hz',...
        'beta_13_35Hz',...
        'gamma_35_55Hz',...
        'gamma_65_85Hz',...
        'gamma_200_250Hz'};

    % Get process
    sProcess = OPTIONS.sProcess;
    nbSamplesA = length(SamplesA);
    iStudyToRedraw = [];

    % === FILES LOOP ===
    bst_progressBar('start', 'Comparisons', 'Initialization...', 0, nbSamplesA);
    % Process all the files
    for iSample = 1:nbSamplesA
        % Progress bar
        bst_progressBar('text', ['File: ' SamplesA(iSample).FileName]);
        bst_progressBar('inc', 1);
        % Get output study
        [sTargetStudy, iTargetStudy isNewConditions, Comment] = GetOutputStudy(sProcess,SamplesA(iSample),repmat(SamplesA, 0),OPTIONS);
        % If no valid output study can be found
        if isempty(iTargetStudy)
            return;
        end
        % Update this study
        iStudyToRedraw(end + 1) = iTargetStudy;

        % === READ FILES ===
        % Resolve link
        [FileName, DataFile] = resolveResultsLink(SamplesA(iSample).FullFileName);
        % Load results file
        kernelMat = load(FileName);
%         dataMat = load(DataFile,'F', 'Time');
        dataMat = in_data_bst( DataFile, [], 'Time', 'F');
        
        %iMEG = good_channel(kernelMat.Channel,kernelMat.ChannelFlag, 'MEG'); %CBB: need to expand to EEG as well
        iMEG = kernelMat.OPTIONS.GoodChannel;
        dataMat.F = dataMat.F(iMEG, :);

        if iSample == 1
            F_RMS = zeros(size(kernelMat.ImagingKernel,1),length(NamesFreqBands),nbSamplesA);
        end
        sRate = abs(1/(dataMat.Time(2)-dataMat.Time(1)));
        nTime = size(dataMat.F,2);
        NFFT = 2^nextpow2(nTime); % Next power of 2 from length of y
        freqVec = sRate/2*linspace(0,1,NFFT/2);

        fftF = fft(dataMat.F,NFFT,2)/nTime;
        %powfftF = 2*abs(fftF(:,1:end/2));
        clear dataMat;
        for ifreq = 1:length(NamesFreqBands)
            VecInd  = findclosest(freqBands(ifreq,:),freqVec);
            %F = bandpassFilter_all(dataMat.F,sRate,freqBands(ifreq,1),freqBands(ifreq,2));
            F_RMS(:,ifreq,iSample) = sum(2*abs(kernelMat.ImagingKernel *  fftF(:, VecInd(1):VecInd(2))),2)...
                /length(VecInd(1):VecInd(2));
            % ImageGridAmp = sqrt(sum(ImageGridAmp.^2,2)/size(ImageGridAmp,2)); % compute root mean square power in current frequency band
        end    
    end
    
    clear dataMat fftF
    % Compute statistics
    %F_RMS(F_RMS<.05*max(F_RMS(:)))=0;
    aveStat = mean(F_RMS,3);
    stdStat = std(F_RMS,0,3);
    clear F_RMS
    for ifreq = 1:length(NamesFreqBands)
        current_aveStat = aveStat(:,ifreq);
        tmp_current_aveStat = current_aveStat;
        tmp_current_aveStat(tmp_current_aveStat<.5*max(tmp_current_aveStat))=0;
        current_stdStat = stdStat(:,ifreq);
        tStat = (tmp_current_aveStat./current_stdStat)*sqrt(nbSamplesA-1);
        %tStat(isnan(tStat))=0;

        % === SAVE RESULTS ===
        kernelMat.ImageGridAmp = repmat(current_aveStat,1,2);
        kernelMat.ImagingKernel = [];
        kernelMat.ImageGridTime = [1,2];
        kernelMat.Comment = sprintf('GAVE: %s',NamesFreqBands{ifreq});
        % Save and register file
        SaveNewFile(kernelMat, sProcess, OPTIONS.isData, iTargetStudy, sTargetStudy, SamplesA(1).FileName);

        kernelMat.ImageGridAmp = repmat(current_stdStat,1,2);
        kernelMat.ImagingKernel = [];
        kernelMat.ImageGridTime = [1,2];
        kernelMat.Comment = sprintf('STD: %s',NamesFreqBands{ifreq});
        % Save and register file
        SaveNewFile(kernelMat, sProcess, OPTIONS.isData, iTargetStudy, sTargetStudy, SamplesA(1).FileName);


        kernelMat.ImageGridAmp = repmat(tStat,1,2);
        kernelMat.ImagingKernel = [];
        kernelMat.ImageGridTime = [1,2];
        kernelMat.Comment = sprintf('T: %s',NamesFreqBands{ifreq});
        % Save and register file
        SaveNewFile(kernelMat, sProcess, OPTIONS.isData, iTargetStudy, sTargetStudy, SamplesA(1).FileName);

    end

end

%% ===== BATCH: RECURRENCE MAPS ======
function [iStudyToRedraw, isNewConditions] = BatchRecurrenceMaps(SamplesA, OPTIONS)
    % Frequency bands of interest
    ampThresh = .75; %Binarization Threshold 
    timeWindow = 30; % time window within which binarization is processed 
    bandPass1 = 1;
    bandPass2 = 250;
    
    % Get process
    sProcess = OPTIONS.sProcess;
    nbSamplesA = length(SamplesA);
    iStudyToRedraw = [];

    % === FILES LOOP ===
    bst_progressBar('start', 'Comparisons', 'Initialization...', 0, nbSamplesA);
    % Process all the files
    for iSample = 1:nbSamplesA
        % Progress bar
        bst_progressBar('text', ['File: ' SamplesA(iSample).FileName]);
        bst_progressBar('inc', 1);
        % Get output study
        [sTargetStudy, iTargetStudy isNewConditions, Comment] = GetOutputStudy(sProcess,SamplesA(iSample),repmat(SamplesA, 0),OPTIONS);
        % If no valid output study can be found
        if isempty(iTargetStudy)
            return;
        end
        % Update this study
        iStudyToRedraw(end + 1) = iTargetStudy;

        % === READ FILES ===
        % Resolve link
        [FileName, DataFile] = resolveResultsLink(SamplesA(iSample).FullFileName);
        % Load results file
        kernelMat = load(FileName);
%         dataMat = load(DataFile,'F', 'Time');
        dataMat = in_data_bst( DataFile, [], 'Time', 'F');
        iMEG = good_channel(kernelMat.Channel,kernelMat.ChannelFlag, 'MEG'); %CBB: need to expand to EEG as well
        dataMat.F = dataMat.F(iMEG, :);

        sRate = abs(1/(dataMat.Time(2)-dataMat.Time(1)));
        nTime = size(dataMat.F,2);

        VecInd  = findclosest([-timeWindow,timeWindow]/1000,dataMat.Time);
        timeVec = VecInd(1):VecInd(2);
        dataMat.F = bandpassFilter_all(dataMat.F,sRate, bandPass1,bandPass2);
        ImageGridAmp = abs(kernelMat.ImagingKernel *  dataMat.F(:, VecInd(1):VecInd(2)));

        % Thresholding
        if iSample == 1;
            iMask = zeros(size(ImageGridAmp,1),1);
            iTimeMask = zeros(size(ImageGridAmp,1),nbSamplesA);
        end
        %tmp = zeros(size(ImageGridAmp));
        %tmp(find(ImageGridAmp>ampThresh*max(ImageGridAmp(:)))) = 1;
        
        % time-relative max
        %         maxx = max(ImageGridAmp);
        %         maxx = repmat(maxx,size(ImageGridAmp,1),1);
        % time-absolute max
        maxx = max(ImageGridAmp(:));
        maxx = maxx*ones(size(ImageGridAmp));

        iMaxtmp = ImageGridAmp > (ampThresh * maxx);
        iTimeMask(:,iSample) = min(...
            iMaxtmp .* repmat(dataMat.Time(timeVec),size(ImageGridAmp,1),1), ...
            [],2);
        iMaxtmp = sum(iMaxtmp,2);
        
        iMask(find(iMaxtmp)) = iMask(find(iMaxtmp)) + 1; 
        %[I,J] = find(ImageGridAmp>ampThresh*max(ImageGridAmp(:)));
        %iMask(I) = iMask(I) + 1;
        %iTimeMask(I,iSample) = dataMat.Time(timeVec(J)); 
    end
    clear  dataMat
    iMask = 100*iMask/nbSamplesA;
    iTimeMask = 1000*mean(iTimeMask,2).*(iMask>0);
    
    % === SAVE RESULTS ===
    kernelMat.ImageGridAmp = repmat(iMask,1,2);
    kernelMat.ImagingKernel = [];
    kernelMat.ImageGridTime = [1,2];
    kernelMat.Comment = sprintf('Recurrence Map');
    % Save and register file
    SaveNewFile(kernelMat, sProcess, OPTIONS.isData, iTargetStudy, sTargetStudy, SamplesA(1).FileName);
    
    kernelMat.ImageGridAmp = repmat(iTimeMask,1,2);
    kernelMat.ImagingKernel = [];
    kernelMat.ImageGridTime = [1,2];
    kernelMat.Comment = sprintf('Recurrence Map (latencies)');
    % Save and register file
    SaveNewFile(kernelMat, sProcess, OPTIONS.isData, iTargetStudy, sTargetStudy, SamplesA(1).FileName);


end

%% ======================================================================================
%  ===== HELPERS ========================================================================
%  ======================================================================================
%% ===== CREATE DEFAULT OUTPUT STRUCTURE =====
function sFileMat = CreateDefaultStruct(sProcess, FileName, isData, TimeVector, iTime, ChannelFlag, isOneOutputMat, isSampleBySample)
% Default structures for stat
isStat = ismember(sProcess.Category, {'TTest', 'PermTest', 'Anova'});
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
        ProtocolInfo = bst_getContext('ProtocolInfo');
        % Resolve link, if it is a link
        [FileName, DataFile] = resolveResultsLink(FileName);
        % Load file
        sFileMat = load(FileName);
        % Stat
        if isStat
            sStat.Type = 'results';
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
    ProtocolInfo = bst_getContext('ProtocolInfo');
    % Get default output file
    OutputDir = fullfile(ProtocolInfo.STUDIES, fileparts(sTargetStudy.FileName));
    FullFileName = GetDefaultFileName(sProcess, isData, OutputDir, InputFile);
    % Save in database
    save(FullFileName, '-struct', 'newFileMat');
    % Register in database
    isStat = ismember(sProcess.Category, {'TTest', 'PermTest', 'Anova'});
    FileName = strrep(FullFileName, ProtocolInfo.STUDIES, '');
    sTargetStudy = RegisterNewFile(newFileMat, FileName, isData, isStat, iTargetStudy);
end


%% ===== GET DEFAULT FILE NAME =====
function OutputFile = GetDefaultFileName(sProcess, isData, OutputDir, InputFile)
    % Get date and time for filename
    c = clock;
    strTime = sprintf('_%02.0f%02.0f%02.0f_%02.0f%02.0f', c(1)-2000, c(2:5));
    
    % Output file tag
    if ismember(sProcess.Category, {'TTest', 'PermTest', 'Anova'})
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
    sStudy = bst_getContext('Study', iStudy);
    % Stat
    if isStat
        % Create new stat file descriptor
        sNewStat = db_getDataTemplate('Stat');
        sNewStat.FileName   = FileName;
        sNewStat.Comment    = FileMat.Comment;
        sNewStat.Type       = FileMat.Type;
        sNewStat.pThreshold = FileMat.pThreshold;
        % Add it to study
        sStudy.Stat(end+1) = sNewStat;
    % Data
    elseif isData
        % Create new data descriptor
        sNewData = db_getDataTemplate('Data');
        sNewData.FileName = FileName;
        sNewData.Comment  = FileMat.Comment;
        % Add it to study
        sStudy.Data(end+1) = sNewData;
    % Results
    else
        % Create new results descriptor
        sNewResult = db_getDataTemplate('Results');
        sNewResult.FileName = FileName;
        sNewResult.Comment  = FileMat.Comment;
        sNewResult.DataFile = FileMat.DataFile;
        % Add it to study
        sStudy.Result(end+1) = sNewResult;
    end
    % Update database
    bst_setContext('Study', iStudy, sStudy);
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
                sSubject = bst_getContext('Subject', uniqueSubjectFiles{i});
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
        [sSubject, iSubject] = bst_getContext('Subject', SamplesA(1).SubjectFile);
        % Get "intra" study for this subject
        [sOutputStudy, iOutputStudy] = bst_getContext('AnalysisIntraStudy', iSubject);
        % Comment
        Comment = ['SubjectAvg(' SamplesA(1).SubjectName ')'];
    % UNIQUE STUDY (OR OVERWRITE)
    elseif (length(uniqueStudiesInd) == 1) || OPTIONS.isOverwriteFiles
        % Get this unique study
        [sOutputStudy, iOutputStudy] = bst_getContext('Study', uniqueStudiesInd(1));
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
        [sOutputStudy, iOutputStudy] = bst_getContext('StudyWithCondition', fullfile(newCondPath,newCondName));
        % If does not exist: Create a new condition
        if isempty(sOutputStudy)
            iOutputStudy = db_addCondition(newCondPath, newCondName, 'NoRefresh');
            sOutputStudy = bst_getContext('Study', iOutputStudy);
            isNewConditions = 1;
        end
    % MULTIPLE STUDIES : CONDITION BY CONDITION
    elseif isConditionByCondition
        Comment = ['GAVE(' SamplesA(1).Condition ')'];
        % Grand average: stored in 'analysis-inter' node
        [sOutputStudy, iOutputStudy] = bst_getContext('AnalysisInterStudy');
    % MULTIPLE STUDIES : GLOBAL
    else
        % UNIQUE SUBJECT : 'analysis-intra'
        if isUniqueSubject
            % Subject file is the same for all the studies => find common subject 
            [sSubject, iSubject] = bst_getContext('Subject', SamplesA(1).SubjectFile);
            % Get 'analysis-intra' node of this subject
            [sOutputStudy, iOutputStudy] = bst_getContext('AnalysisIntraStudy', iSubject);
        % MULTIPLE SUBJECTS : 'analysis-inter'
        else
            % Get 'analysis-inter' node in current protocol
            [sOutputStudy, iOutputStudy] = bst_getContext('AnalysisInterStudy');
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
        [tmp__, iChanStudyDest] = bst_getContext('ChannelForStudy', iOutputStudy);
        % Source channel files studies
        [tmp__, iChanStudySrc] = bst_getContext('ChannelForStudy', uniqueStudiesInd);
        % If target study has no channel file: create a new one by combination of the others
        isNewChannelFile = db_combineChannelFiles(unique(iChanStudySrc), iChanStudyDest, [], ~OPTIONS.isData);
        % Reload target study if it changed (new channel file)
        if isNewChannelFile
            sOutputStudy = bst_getContext('Study', iOutputStudy);
            tree_updateModel();
        end
    end
end


%% ===== BUILD DATA ARRAY =====
function [X, ChannelFlag, Time] = buildDataArray(sampleFiles, iTime)
    % Read out the data from multiple files and store in larger array X
    % Parameters:
    %     - sampleFiles : cell array of data file names
    %     - Time        : time values of the samples to extract
    %     - isData      : a flag; 0 means read from Results file, 1 from surface data file
  
    % Open progress bar
    isNewProgressBar = ~bst_progressBar('isvisible');
    if isNewProgressBar
        bst_progressBar('start', 'Loading samples...', 'Processes', 0, length(sampleFiles));
    end
    ChannelFlag = [];
    
    % Process all the samples files
    for k = 1:length(sampleFiles)
        % Progress bar
        bst_progressBar('inc', 1);
        bst_progressBar('text', ['File: ' sampleFiles{k}]);
        % Read matrix
        [matValues, matName, tmpChannelFlag, TimeVector] = bst_readMatrixInFile(sampleFiles{k}, iTime);
        % Get time for the specified indices
        % Bug:  Time = TimeVector(iTime);
        Time = TimeVector;
        % Add bad channels to list of bad channels
        if isempty(ChannelFlag)
            ChannelFlag = tmpChannelFlag;
        else
            ChannelFlag(tmpChannelFlag == -1) = -1;
        end
        % Initialize large array
        if (k == 1)
            X = zeros(length(sampleFiles), size(matValues,1), size(matValues,2));
        end

        % Store read values in full data array
        try
            X(k,:,:) = matValues;
        catch
            error('Please first check that all the files in your samples have the same of channels/sources. Consider registering the MEG/EEG data to the same sensor cap');
        end
    end
    
    if isNewProgressBar
        bst_progressBar('stop');
    end
end
