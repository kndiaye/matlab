% importctf() - import CTF DataSets
%
% Usage:
%   >> [data channel study] = importctf(datafile,device)
%
% Required Input:
%   dasfolder = a Dataset (DS) folder 
%
% Optional Input:
%   device = ['MEG'|'EEG'|'EEG+MEG'|'ALL'] 
%
% Outputs:
%   data = cell array of data (one cell by trial)
%   channel = sensor positions
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
% Revision 0.1  2004/06/29 
% First alpha version for EEGLAB release 4.301

function [Data,Channel] = importctf(dsfolder,device)

if nargin < 1
    help(mfilename);
    return;
end;	

[ignore, studyname]=fileparts(dsfolder);
dsfolder

prev_dir=cd;
cd(dsfolder)
% Converrting Data to BrainStorm format

[Data.F,Channel,Data.imegsens,Data.ieegsens,Data.iothersens,Data.irefsens,Data.grad_order_no,Data.no_trials,Data.filter,Data.Time,Data.RunTitle] = ds2brainstorm(dsfolder,1,0);
% VERBOSE,READRES,CHANNELS, TIME, NO_TRIALS, DCOffset);


%Importing Electrodes to EEGLAB format
channelflags=zeros(length(Channel),1);
if nargin <2
    DEVICES={'EEG', 'MEG', 'EEG+MEG', 'ALL'};
    [s,v] = listdlg('PromptString','Select a device:',...
        'SelectionMode','single',...
        'ListString',{'EEG', 'MEG', 'EEG+MEG'});
    if not(all(v))
        s=3;
    end
    
    switch(s)
        case 1
            device={'EEG'}
        case 2, device={'MEG'}
        case 3, device = {'EEG', 'MEG'}
    end
        
end
for i=1:length(device)
    channelflags=channelflags + strcmp(device{i},{Channel.Type}');
end
%channelflags(strmatch('EEG', {Channel.Type}))=1;
%channelflags(strmatch('MEG', {Channel.Type}))=1;

Channel=Channel(find(channelflags));
for i=1:length(Data.F)
    Data.F{i}=Data.F{i}(find(channelflags),:);
end

return

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
