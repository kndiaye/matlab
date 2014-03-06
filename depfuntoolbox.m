function Files = depfuntoolbox(input)
%DEPFUNTOOLBOX Locate dependent functions of an M/P-file by toolbox
%
% Files = depfuntoolbox(filename)
% Files = depfuntoolbox(traceList)
%
% This function uses the depfun function to determine the dependent
% functions of any m or p file, and then separates the files based on the
% Matlab toolbox to which they belong.
%
% Input variables:
%
%   filename:   string with m or p filename
%
%   traceList:  cell array output of depfun function
%
% Output variables:
%
%   Files:      1 x 1 structure.  Each field is the name of a toolbox
%               directory (for example, matlab = base Matlab, stats =
%               Statistics Toolbox, map = Mapping Toolbox, etc) and holds a
%               cell array of dependent function names associated with that
%               toolbox.  Dependent functions that are not part of a Matlab
%               toolbox are listed under the fieldname 'other'.

% Copyright 2006 Kelly Kearney

%----------------------------
% Check input, run depfun if
% necessary
%----------------------------

if ischar(input)
    allFiles = depfun(input, '-quiet');
elseif iscell(input)
    allFiles = input;
else
    error('Input must be a filename or cell array output of depfun');
end

%----------------------------
% Separate by toolbox
%----------------------------

matlabToolbox = fullfile(matlabroot, 'toolbox');
nchar = length(matlabToolbox);

isNotMatlabProper = cellfun(@isempty, strfind(allFiles, matlabToolbox));

matlabFiles = allFiles(~isNotMatlabProper);
matlabFiles2 = cellfun(@(a) a(nchar+2:end), matlabFiles, 'UniformOutput', false);

toolboxName = cellfun(@(a,b) a(1:b(1)-1), matlabFiles2, strfind(matlabFiles2, filesep), 'UniformOutput', false);
uniqueToolbox = unique(toolboxName);
filesInToolbox = cellfun(@(a) matlabFiles(strcmp(a, toolboxName)), uniqueToolbox, 'UniformOutput', false);

Files = cell2struct(filesInToolbox, uniqueToolbox, 1);
if any(isNotMatlabProper)
    Files.other = allFiles(isNotMatlabProper);
end


