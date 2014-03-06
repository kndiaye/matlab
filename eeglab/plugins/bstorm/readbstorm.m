% readbstorm() - read BrainStorm datafiles
%
% Usage:
%   >> [study channel data dsfolder] = readbstorm(datafile,device)
%
% Required Input:
%   datafile = Data file within a DS folder 
%              (all data_*_[1..N] will be imported)
%
% Optional Input:
%   device = ['MEG'|'EEG'|'EEG+MEG'|'ALL'] 
%
% Outputs:
%   study = study info
%   channel = sensor positions
%   data = cell array of data (one cell by trial)
%
% Author: Karim N'Diaye, CNRS-UPR640, 01 Jan 2004
%
% See also: 
%   POP_READBSTORM, EEGLAB 

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) 2004, CNRS - UPR640, N'Diaye Karim,
% karim.ndiaye@chups.jussieu.Fr
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

% $Log: readegi.m,v $
% Revision 0.1  2004/01/01 
% First alpha version for EEGLAB release 4.301

function [Study,chanlocs,Data,dsfolder] = readbstorm(datafile,device)

if nargin < 1
	help(mfilename);
	return;
end;	

[dsfolder, filename]=fileparts(datafile)
studyname=strtok(filename,'_')
p=findstr(filename, '_')
database=filename(1:p(3))
prev_dir=cd;
cd(dsfolder)
Study=load([studyname '_brainstormstudy']);

fprintf('Importing channel location information')
Channel=getfield(load([studyname '_channel']), 'Channel');
chanlocs=bstormchannels2chanlocs( Channel );
    
i=1;
%datafilename=sprintf('%s%d.mat', database , i);
f=dir(sprintf('%s*.mat', database));
f=strvcat({f.name});
f=f(:,length(database)+1:end);
trials=str2num(char(strrep(cellstr(f), '.mat', '')));
trials=sort(trials);

h = waitbar(0,'Importing Datafiles. Please wait...');
for i=1:length(trials)
    waitbar(i/length(trials),h)
    datafilename=sprintf('%s%d.mat', database , trials(i));
    fprintf('Importing %s\n', datafilename)
    Data(i)=load(datafilename);
    %channelflag=channelflags & Data(i).ChannelFlag;
    channelflag=channelflags;
    Data(i).F=Data(i).F(find(channelflag),:);  
end
close(h)

return
