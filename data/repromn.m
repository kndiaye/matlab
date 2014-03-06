% REPROMN - Prepare Matlab for REPROMN study

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2006 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2006-01-06 Creation
%                   
% ----------------------------- Script History ---------------------------------
[HOMEDIR,USBDIR]=mypath;
if isnan(USBDIR)
    MATLABDIR=fullfile(HOMEDIR, 'matlab');
else    
    MATLABDIR=fullfile(USBDIR, 'matlab');
end

% Brainstorm tools
addpath(fullfile(HOMEDIR, 'mtoolbox', 'brainstorm','Toolbox'));
addpath(genpath(fullfile(HOMEDIR, 'mtoolbox', 'brainstorm', 'PublicToolbox')));

% SPM2 Tools
addpath(fullfile(HOMEDIR, 'mtoolbox','spm2'));

% EEGLAB
addpath(fullfile(HOMEDIR, 'mtoolbox', 'eeglab4.5b'));
addpath(fullfile(HOMEDIR, 'mtoolbox', 'eeglab4.5b', 'functions'));
% Native mat2cell & cell2mat are better:
addpath(fullfile(matlabroot, 'toolbox', 'matlab', 'datatypes'))

% CTF/MRI plugin for EEGLAB
addpath(fullfile(HOMEDIR, 'mtoolbox', 'ctf'));

addpath(MATLABDIR)
addpath(fullfile(MATLABDIR, 'behavioral'))
addpath(fullfile(MATLABDIR, 'ctf'))
addpath(fullfile(MATLABDIR, 'ctfimport'))
addpath(fullfile(MATLABDIR, 'brainstorm2', 'Developer'))
addpath(fullfile(MATLABDIR, 'stormvisa'))

addpath(fullfile(HOMEDIR, 'data', 'studies', 'repromn' ,'matlab'))
if not(isnan(USBDIR))
    addpath(fullfile(USBDIR, 'data', 'studies', 'repromn' ,'matlab'))
end

cd(fullfile(HOMEDIR, 'data', 'studies', 'repromn'))

if (isnan(USBDIR))
    clear USBDIR
end
