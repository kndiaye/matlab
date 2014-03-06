DIRS = {'\\Serveur_meg\homes\mtoolbox\brainstorm3' , '~/mtoolbox/brainstorm3' };
for i=1:length(DIRS)
    if exist(DIRS{i}, 'dir')
        addpath(DIRS{i})
        break;
    end
end
if i>length(DIRS)
    error('No directory found for brainstorm3')
end
brainstorm