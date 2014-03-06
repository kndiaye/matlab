function  [] = exit(input,varargin)
%EXIT - Safe exit of matlab
%   exit() simply asks before exiting Matlab...
%
%   Example
%       >> exit.m
%
%   See also: 

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2009 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2009-02-02 Creation
%                   
% ----------------------------- Script History ---------------------------------

if isequal(questdlg('Sure you want to quit Matlab?', 'Exit', 'No'), 'Yes')
a=which('-all','exit');
cd(fileparts(a{2}((findstr('(',a{2})+1):(findstr(')',a{2})-1))))
exit
end