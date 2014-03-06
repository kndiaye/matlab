function icatb_check_path
% Check path

% Check startup file
checkStartup;

% Check required paths for the toolboxes
checkReqdPaths;

% run only on windows
icatb_openMatlabServer;


function checkStartup
% check gift start up file

if (exist('gift_startup.m', 'file') == 2) || (exist('gift_startup.m', 'file') == 6)
    fprintf( 'Executing gift_startup ...\n' );
    % execute gift start up file
    gift_startup;
    
else
    
    % Get the full file path of the gift file
    giftPath = which('gift.m');
    % Folder location of the gift
    giftPath = fileparts(giftPath);
    
    % all directories on path
    pathstr = path;
    
    % Get the directories on path
    allDirs = strread(pathstr, '%s', 'delimiter', pathsep);
    
    if ~isempty(allDirs)
        
        [indices] = regexp(allDirs, 'icatb$');
        indices = good_cells(indices);
        matchedDirs = allDirs(indices);
        matchedDirs(good_cells(regexp(matchedDirs, 'matlab')))=[];
        
        if length(matchedDirs) > 1
            error(['Fix MATLAB path such that it has only one version of GIFT at a time']);
        elseif length(matchedDirs) == 1
            if strcmpi(giftPath, matchedDirs{1})
                return;
            else
                error(['Fix MATLAB path such that it has only one version of GIFT at a time']);
            end
        end
        
    end
    
end
% end for adding path

function ind = good_cells( mycell )

if ~iscell(mycell)
    mycell = {mycell};
end

for j=1:length(mycell)
    ind(j)=~isempty(mycell{j});
end


function checkReqdPaths
% Check required paths

% Get the full file path of the gift file
giftPath = which('gift.m');
% Folder location of the gift
giftPath = fileparts(giftPath);

reqdDirs = str2mat(giftPath, strcat(giftPath, filesep, str2mat('icatb_analysis_functions', 'icatb_batch_files', 'icatb_display_functions', ...
    'icatb_helpManual', 'icatb_helper_functions', 'icatb_io_data_functions', 'icatb_spm2_files', ...
    'icatb_spm5_files', ['toolbox', filesep, 'eegiftv1.0a'])));

pathstr = path;

allDirs = strread(pathstr, '%s', 'delimiter', pathsep);

% Add required paths
for nDir = 1:size(reqdDirs, 1)
    currentPath = deblank(reqdDirs(nDir, :));    
    check = strmatch(currentPath, allDirs, 'exact');
    if isempty(check) 
        addpath(genpath(currentPath), '-end');
    end
end
% End for adding required paths