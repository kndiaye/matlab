function swr_import_DICOM(source_directory, target_directory)
%
% This function attempts to find all DICOM files in the specified source
% directory and all its (sub-sub-...)-directiories, perform a conversion to
% NIfTI format using SPM5 functions, and place the NIfTI files in
% appropriately named folders which will be created in the specified target
% directory. If no directories are specified, the user will be prompted for
% directory names.
%
% If there are too many (i.e. thousands) DICOM files in one single
% directory (which is unlikely to be the case with DICOM compliant storage,
% except if you scan someone for hours without a break), this routine may
% cause MatLab to run out of memory and crash. I might think about fixing
% this in a later version if it turns out to be a problem in real life.
% 
% Sebastian W Rieger - LabNIC, Geneva University - 2008-09-02
% 


% If the function was called without input arguments, use a dialog box to
% ask the user for the directory names:
if nargin < 1
    source_directory = uigetdir(pwd, ...
        'Select directory to be searched for DICOM files:');
end

if nargin < 2
    target_directory = uigetdir(pwd, ...
        'Select target directory for NIfTI files:');
end

% Start stopwatch and initialise file counter:
tic;
DICOM_file_counter = 0;
disp(' ');
disp('Starting swr_import_DICOM...');
disp(' ');

% Remember the current working directory:
previous_working_directory = pwd;

% Create the target directory, if it does not already exist:
if ~isdir(target_directory)
    disp(['swr_import_DICOM: Creating target directory (' ...
        target_directory ')...']);
    disp(' ');
    mkdir(target_directory);
else
    disp(['swr_import_DICOM: Target directory ' target_directory ...
        ' already exists.']);
    disp('Existing files in target directory may be overwritten!');
    disp(' ');
end

% Change working directory to target directory:
cd(target_directory);

% Generate a list of all (sub-sub-...)directories of the source directory, 
% which will be searched for DICOM files:
disp(['swr_import_DICOM: Looking for source directory (' ...
    source_directory ')']);
disp('and its sub-directories...')
source_dir_list = find_sub_directories(source_directory);
disp([num2str(length(source_dir_list)) ' directories found.']);
disp(' ');
 
% Repeat for each directory in the list:
for dir_index = 1 : length(source_dir_list)
    
    disp(['swr_import_DICOM: Searching files in directory ' ...
        num2str(dir_index) ' / ' ...
        num2str(length(source_dir_list)) '...']);

    % Create a list of all file names in the directory:
    DICOM_file_names = list_full_files(source_dir_list{dir_index}, '*.*');
    disp([num2str(size(DICOM_file_names, 1)) ' file(s) found.']);
    disp(' ');
      
    % Create list of DICOM file headers from list of file names:
    disp('swr_import_DICOM: Attempting to read DICOM headers...');
    
    % Turn off warnings but remember current warning status first:
    previous_warning_status = warning('off', 'all');
   
    % Attempt to read DICOM headers, using strvcat to convert the cell
    % array of file names into a matrix as needed by the SPM5 function
    % spm_dicom_headers:
    DICOM_headers = spm_dicom_headers(strvcat(DICOM_file_names));
    disp([num2str(size(DICOM_headers, 2)) ' DICOM file(s) found.']);
    disp(' ');
    DICOM_file_counter = DICOM_file_counter + size(DICOM_headers, 2);

    % Restore previous warning status:
    warning(previous_warning_status);
    
    % If DICOM files have been found:
    if ~isempty(DICOM_headers)
        % Attempt DICOM-to-NIfTI conversion:
        disp('swr_import_DICOM: Attempting DICOM-to-NIfTI conversion...');
        disp(' ');
        spm_dicom_convert(DICOM_headers, 'all', 'patid', 'nii');
        disp(' ');
        disp('DICOM-to-NIfTI conversion complete.');    
        disp(' ');
    end
end % of for loop

% Change back to the previous working directory:
cd(previous_working_directory);

% Say goodbye:
disp(['swr_import_DICOM: Finished. Processed ' ...
    num2str(DICOM_file_counter) ' DICOM file(s) in ', ...
    num2str(round(toc)), ' seconds.'] );
disp(' ');

end % of function swr_import_DICOM

function directory_list = find_sub_directories(start_dir)
% This function returns a cell array containing the names list of all
% directories, sub-directories, % sub-sub-directories, 
% sub-sub-sub-directories, sub-sub-sub-sub-directories... (well you get the
% idea) found in the starting directory specified in the function call. The
% name of the start directory itself is also included in the list. If it
% fails (e. g. if the specified start directory does not exist), the
% function returns {}.
% 
% Sebastian W Rieger - LabNIC, Geneva University - 2008-08-28
%

try
    % find directories using recursive genpath function:
    directory_list = genpath(start_dir);
    
    % convert resulting ';'-delimited string into a cell array:
    directory_list = textscan(directory_list, '%s', 'delimiter', ';');
    directory_list = directory_list{1};
    
% in case of failure, return empty matrix:
catch
    directory_list = {};
end
    
end % of function find_sub_directories


function file_list = list_full_files(varargin)
%
% This function returns a list of files in a directory. It works the same
% way as list_files, except it returns file names including the full path
% string. For example, this is useful for reading DICOM file header
% information using the SPM5 function spm_DICOM_headers, which expects full
% paths as input.
%
% Optionally, the directory to be searched can be specified (default:
% current working directory), and results can be filtered (for example to
% include only certain file types). Any number of filter strings may be
% used, for example '*.DCM', '*.IMA' to find DICOM files with either
% extension. The function returns {} if the specified directory cannot be
% found.
% 
% Examples:
%
% list_full_files finds all files in the current working directory.
%
% list_full_files(MyDirName) finds all files in the directory called
% MyDirName. 
%
% list_full_files(MyDirName, '*.mat') finds all *.mat files in the
% directory called MyDirName. 
%
% list_full_files(MyDirName, '*.dcm', '*.ima') finds all DICOM files in the
% directory called MyDirName.
%
% Sebastian W Rieger - LabNIC, Geneva University - 2008-08-28
%

% Remember the old working directory:
previous_working_directory = pwd;

% Read name of directory to be searched from function input arguments, or
% set to default value if not specified:
if nargin < 1
    directory = pwd;
else
    directory = varargin{1};
end

% Read filter strings from function input arguments, or set to default
% value if not specified:
if nargin < 2
    filter = {'*.*'};
else
    filter = varargin(2 : end);
end


% Create an empty list, to be filled with names of files found: 
file_list = {};

% Try to go to the specified directory, and abandon function execution
% if it does not exist:
try
    cd(directory);
catch
    disp(['Directory not found: ' directory]);
    return;
end

% For each filter string specified...
for filter_index = 1 : length(filter)
    % ...find matching files:
    directory_contents = dir(filter{filter_index});
    disp(filter(filter_index));
    % Go through the list of items found...
    for file_index = 1 : size(directory_contents)
        % ... and add them to the file list without including directory
        % names:
        if ~directory_contents(file_index).isdir
            file_list = [file_list; ...
                pwd filesep directory_contents(file_index).name];
        end
    end % of for loop (list of items found in directory)
end % of for loop (list of filter strings)

% Change back to the old working directory:    
cd(previous_working_directory);

end % of function list_full_files