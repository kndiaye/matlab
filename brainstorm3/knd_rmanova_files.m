function [p,F,fx,ChannelFlag, TimeVector] = knd_rmanova_files(SamplesA,OPTIONS)
% knd_rmanova_files - repeated measure anova

%SamplesA = SamplesA([SamplesA.iItem]== 4)

%OPTIONS.iTime = 599:630

[X1, ChannelFlag, TimeVector] = buildDataArray({SamplesA.FullFileName}, OPTIONS.iTime);
if OPTIONS.isAbsoluteValues
    X1 = abs(X1);
end
%TimeVector=round(mean(TimeVector)); 
% X1=mean(X1,3);
sX=size(X1);
% X= subj * C/I * H/L
X1=reshape(X1,[15 2 2 sX(2:end)]);
% X= C/I * H/L * Subj * vertices
X1=permute(X1,[2 3 1 4:ndims(X1)]);
[p,F,fx]=myrmanova(X1,2,1:2,[],0);
return



% %% Get conditions common to all subjects
% function [isCommon]=GetCommonConditions(Samples)
% [C,iC,jC] = unique({Conditions.Samples.Condition}');
% [S,jS,jS] = unique({Samples.SubjectName});
% isCommon(iC) = 0*jC;
% for i = 1:numel(C)
%     if isempty(setdiff(1:NS,jS(jC==i)))
%         isCommon(jC==i) = 1;
%     end
% end
% end
% 

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

return


%function [p, t, ChannelFlag, TimeA, TimeB] = knd_ttest_files(FilesListA, FilesListB, wtest, iTimeA, iTimeB, varargin)

% KND_TTEST_FILES: Student's t-tests for EEG/MEG recordings or sources, across trials or subjects.
%
% USAGE:  [p, t, ChannelFlag, TimeA, TimeB] = knd_ttest_files(FilesListA, FilesListB, wtest, iTimeA, iTimeB)
%         [p, t, ChannelFlag, TimeA, TimeB] = knd_ttest_files(FilesListA, FilesListB, wtest)
%         [p, t, ChannelFlag, TimeA, TimeB] = knd_ttest_files(FilesListA, FilesListB)
%         [p, t, ChannelFlag, TimeA, TimeB] = knd_ttest_files(..., 'AbsoluteValues');



%
% DESCRIPTION:
%      Gives the probability that Student's t calculated on sets A and B, sampled from two
%      distributions is higher than observed, i.e. the "significance" level.
%      This is used to test whether two samples have significantly different means.
%
% INPUT:
%    - FilesListA : Cell-array of paths to brainstorm recordings or sources files.
%    - FilesListB : Cell-array of paths to brainstorm recordings or sources files.
%    - wtest      : String that specifies the test to be used. Possible values:
%                    - 'ttest'  : t-test for equal variances [default]
%                    - 'uttest' : t-test for unequal variances
%                    - 'pttest' : t-test for paired samples
%    - iTimeA     : Time indices used from samples A
%    - iTimeB     : Time indices used from samples B
%    - AbsoluteValues : Use absolute values of samples
%
% OUTPUT:
%    - P : Probability map
%          The smaller P is, the more significant the difference between the means.
%          E.g. if P = 0.05 or 0.01, it is very likely that the two sets are
%          sampled from distributions with different means.
%    - T : Value of Student's t
%    - ChannelFlag : Array with one entry per channel:
%                    -1 means that the channel was marked as bad in at least one of the input files
%                     1 means that the channel was marked as good in all the input files

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
% Authors: K. N'Diaye, 2005 (Adapted from C. Goutte's functions)
% ----------------------------- Script History ---------------------------------
% KND 20-Apr-2005  Creation
% FT  24-Jun-2008  Adaptation for brainstorm3
% ------------------------------------------------------------------------------






%% ===== PARSE INPUTS =====
if (nargin < 5)
    iTimeA = [];
    iTimeB = [];
end
% OPTIONS
isAbsoluteValues = 0;
if (length(varargin) >= 1)
    if any(strcmpi(varargin, 'AbsoluteValues'))
        isAbsoluteValues = 1;
    end
end
% Dimensions
n1 = length(FilesListA);
n2 = length(FilesListB);
% There must be at least two samples in each set
if (n1 <= 1) || (n2 <= 1)
    error('There must be at least two samples in each set.');
end
% If paired test: number of samples must be equal
if strcmpi(wtest, 'pttest') && (n1 ~= n2)
    error('For a paired t-test, number of samples must be equal in the two datasets');
end
if (length(iTimeA) ~= length(iTimeB))
    error('You must specify the same numer of time samples for both datasets.');
end