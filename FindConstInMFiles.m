function FindConstInMFiles
%FindConstInMFiles() finds the contant variables in .m files
% FindConstInMFiles() searches in all the .m files under a chosen directory and
% writes to an output file (results.txt) all the assignments of constant
% values to variables. The core of the programme is the regular expression.
% Everything else is just a recursive algorithm to search all the files.
% Regular expression: [a-zA-Z][\.\w+]*\s*=\s*[\.\d]+([eE][\+\-]?\d+)?\s*[;\n]
% [a-zA-Z] : variables have to start with a letter
% [\.\w+]* : to take into account structure variables
% *\s*=\s* : multiple spaces before and/or after the '=' sign
% [\.\d]+  : number with or without decimal separation
% ([eE][\+\-]?\d+)? : exponential symbol, +/- characters, number
% \s*[;\n] : white-spaces, end of statement, end of line

clc;
clear;
DirPath = uigetdir(); % Get directory where to search
if ~DirPath, return, end
fid = fopen('results.txt','wt'); % open output file
if fid == -1
    disp('Error creating output file')
    return
end
StartFind(DirPath,fid); %start search for files
fclose(fid); % close output file

%% StartFind
function StartFind(DirPath,fid)
DirContent = dir(DirPath); % gets the content of the current directory
files   = {DirContent(~[DirContent.isdir]').name};  % gets only the files
folders = {DirContent([DirContent.isdir]').name};  % gets only the directories
for i = 1:length(files) % for all the files
    file = fullfile(DirPath,files{i});  % get the full file name
    [pathstr, name, ext] = fileparts(files{i}); % get the extension
    if ~strcmp(ext,'.m') % Test for .m extension and continue to next file if it's not
        continue
    end
    FileContent = fileread(file);   % read to a string the contents of the files
    [str ind] = regexp(FileContent,'[a-zA-Z][\.\w+]*\s*=\s*[\.\d]+([eE][\+\-]?\d+)?\s*[;\n]','match','start'); % regular expression
    if ~isempty(str) % if there are valid results...
        fprintf(fid,'\n%s\n',file);     % Print the file name
        endofline = regexp(FileContent,'\n','start');   % Get all the indexes of all the lines
        for j = 1:length(str)   % for all valid results...
            fprintf(fid,'Line %d: %s\n',find(ind(j)<endofline,1),strtrim(str{j})); % print the results
        end
    end
end

% go to next directories
for i = 1:length(folders)
    if strcmp(folders{i},'.') || strcmp(folders{i},'..')
        continue
    end
    StartFind([DirPath '\' folders{i}],fid);
end
  
    
    