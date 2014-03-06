% readClassFile() - Reads Classes from CTF's ClassFile
%  
% [cls]=readClassFile(dsfolder)
%
% Input : 
%   dsfolder: the folder containing the ClassFile to be read
%             or the ClassFile filename itself
%
% Output:
%   cls: the classes
%
% Classrs have the following fields:
%   .name: their label e.g. 'Tr17'
%   .e: the trial in which they occur (indexed from 1)
%

% Not yet!
% Optional fields:
%   .color
%   .comment

function [cls] = readClassFile(dsfolder)

if exist(dsfolder, 'dir')
    [dspath, dsname]=fileparts(dsfolder);
    clsfile=fullfile(dsfolder, 'ClassFile.cls');
elseif exist(dsfolder, 'file')
    clsfile=dsfolder;
else
    error([mfilename ': .cls file not found!']);    
end

fprintf('Reading File: %s\n', clsfile)
txt=textread(clsfile,'%s','delimiter','\n','whitespace','');
n=0;

for i=1:size(txt,1)    
    if strcmp(txt{i}, 'NAME:')
      n=n+1;
      cls(n).name=char(txt{i+1});
    end
    
    if strcmp(txt{i}, 'NUMBER OF TRIALS:')
        nb_events(n)=str2num(txt{i+1});
    end
    
    if strmatch('TRIAL NUMBER', txt{i})
        for j=1:nb_events(n)
            [a]= strread(txt{i+j});
            cls(n).e(j)=a+1;
        end
    end
end
