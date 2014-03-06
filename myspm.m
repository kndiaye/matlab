function  [spmpath] = myspm(varargin)
%MYSPM - Sets SPM path according to the specified version
%   [] = myspm('spm2')
%   [] = myspm('2')
%   Sets the path for SPM2 and runs it.
%
%   [] = myspm('ver','spm2','do',action)
%   Sets the path for SPM2 and performs the "action" ('run' [default] or 'nothing')
%
%   Example
%       >> myspm
%
%   See also:

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2008
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2008-10-31 Creation
%
% ----------------------------- Script History ---------------------------------
if nargin==1
    options=[{'ver'},varargin];
else
    options=varargin;
end
if nargin>0
    options=struct(options{:});
else
    options=[];
end
defaults=struct('ver', 'spm5', 'do', 'run', 'mymatlabpath', fileparts(mfilename('fullpath')), 'rmpath', 1);
options = mergestructs(defaults,options);

[hostname,hostname]=system('hostname');

if ~isempty(regexpi(hostname, 'chups.jussieu.fr'))
    tbxpath='~/mtoolbox';
    myspmpath=fullfile(options.mymatlabpath,'spm');
else
    switch upper(deblank(hostname))
        case 'D5BDS81J' % LABNIC Office compute
            switch options.ver
                case {'spm2', '2'}
                    tbxpath='c:\spm\';
                    myspmpath=fullfile(options.mymatabpath,'spm');
                otherwise
                    error('Unknown version: %s', options.ver);
            end
        case 'IMAGERIE2-PV' % steph's PC
        case 'MONTBLANC'
        case 'KARIMND'
            options.mymatabpath = 'e:\ndiaye\home\matlab';
            tbxpath='e:\mtoolbox\';
            myspmpath=fullfile(options.mymatabpath,'spm');
        otherwise
            tbxpath=fullfile(fileparts(options.mymatabpath),'mtoolbox');
            myspmpath=fullfile(options.mymatabpath,'spm');
    end
end
if isnumeric(options.ver)
    options.ver=num2str(options.ver);
end    
switch options.ver
    case {'spm2', '2'}
        options.ver = 'spm2';
        spmpath  =fullfile(tbxpath,'spm2');
        myspmpath=fullfile(myspmpath,'spm2');
    case {'spm5', '5'}
        options.ver = 'spm5';
        spmpath  =fullfile(tbxpath,'spm5');
        myspmpath=fullfile(myspmpath,'spm5');
    case {'spm8', '8'}
        options.ver='spm8';
        spmpath  =fullfile(tbxpath,'spm8');
        myspmpath=fullfile(myspmpath,'spm8');
    otherwise
        error('Unknown version: %s', options.ver);
end

if options.rmpath
    % Find current SPM-directories & subdirectories:
    s=lower(fileparts(which('spm')));
    if ~isempty(s) && ~isequal(s,spmpath)
        p=lower(path);
        if numel(strread(p,'%s', 'delimiter', ';'))==1
            % In later matlab, they use ":" as a delimiter
            p=strread(p,'%s', 'delimiter', ':');
        else
            p=strread(p,'%s', 'delimiter', ':');
        end
        p=p(:);
        for d=p(strmatch(s,p))'
            rmpath(d{1});
        end
    end
end
clear global
clear functions
%clear classes
addpath(spmpath,'-begin')

% Specific dll for R2007a and later
if ispc && (datenum(version('-date')) > datenum('2007-03-01'))
addpath(fullfile(spmpath,'..', [options.ver '_R2007a_winXP']),'-begin')
end
if exist(myspmpath)
    addpath(myspmpath,'-begin')
end

if isequal(options.do,'run')
    spm fmri
end
