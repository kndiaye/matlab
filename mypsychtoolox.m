function  mypsychtoolox
%MYPSYCHTOOLOX - Add paths to run Psychtoolbox
%  
%   See also: 

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2010 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2010-01-17 Creation
%                   
% ----------------------------- Script History ---------------------------------
lcd=cd;
pwd=fullfile(fileparts(fileparts(mfilename('fullpath'))), 'mtoolbox', 'psychtoolbox');
cd(pwd)
SetupPsychtoolbox
addpath(fullfile(mymatlabpath,'psychtoolbox'));
cd(lcd)


return

addpath(pwd)
addpath(fullfile(pwd,'PsychBasic'))
addpath(fullfile(pwd,'PsychCal'))
addpath(fullfile(pwd,'PsychFiles'))
addpath(fullfile(pwd,'PsychGamma'))
addpath(fullfile(pwd,'PsychHardware'))
addpath(fullfile(pwd,'PsychInitialize'))
addpath(fullfile(pwd,'PsychJava'))
addpath(fullfile(pwd,'PsychOneliners'))
addpath(fullfile(pwd,'PsychOpenGL'))
addpath(fullfile(pwd,'PsychPriority'))
addpath(fullfile(pwd,'PsychProbability'))
addpath(fullfile(pwd,'PsychRects'))
addpath(fullfile(pwd,'PsychSignal'))
addpath(fullfile(pwd,'PsychOpenGL'))
addpath(fullfile(pwd,'PsychSound'))
