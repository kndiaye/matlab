DIRS = {
    'I:/mtoolbox/brainstorm3',  
    'e:/mtoolbox/brainstorm3', 
    '/mount/usb/mtoolbox/brainstorm3', 
    '\\Serveur_meg\homes\mtoolbox\brainstorm3',
    '~/mtoolbox/brainstorm3' };

for i=1:length(DIRS)
    if exist(DIRS{i}, 'dir')
        addpath(DIRS{i})
        break;
    end
    i=i+1;
end

if i>length(DIRS)
    % try to guess where that folder could be
    DIRS{i} = fullfile(fileparts(fileparts(mfilename('fullpath'))),'mtoolbox','brainstorm3');
    if exist(DIRS{i},'dir')
        addpath(DIRS{i});
    else
        error('No directory found for brainstorm3')
    end
end
disp(['Launching Brainstorm from: ' DIRS{i}])
brainstorm