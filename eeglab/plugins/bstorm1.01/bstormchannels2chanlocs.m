% bstormchannels2chanlocs() - Converts brainstorm channels to EEGLAB chanlocs structure
%
% Usage:
%   >> [chanlocs channelflags] = bstormchannels2chanlocs( Channel , device)
%
% Required Input:
%   Channel = Brainstorm Channel structure 
%            (e.g. read from a study_channel.mat file)
%
% Optional Input:
%   device = ['MEG'|'EEG'|'EEG+MEG'|'ALL'] 
%
% Outputs:
%   channelocs = N sensor positions
%   channelflags = [Nx1] array of boolean, true if channel was imported
%
% Author: Karim N'Diaye, CNRS-UPR640, 01 Jan 2005
%
% See also: 
%   POP_READBSTORM, EEGLAB 

% $Log: bstormchannels2chanlocs.m,v $
% Revision 1.01  2005/02/01 00:07:38  knd
% pop_chanedit compatible (no sph_phi/theta_besa fields)


function [ chanlocs, channelflags ] = bstormchannels2chanlocs( Channel , device)
channelflags=zeros(length(Channel),1);
if nargin <2
    DEVICES={'EEG', 'MEG', 'EEG+MEG', 'ALL'};
    [s,v] = listdlg('PromptString','Select a device:',...
                      'SelectionMode','single',...
                      'ListString',{'EEG', 'MEG', 'EEG+MEG'});
    if all(v)
        switch(s)
            case 1
                device={'EEG'}
            case 2, device={'MEG'}
            case 3, device = {'EEG', 'MEG'}
        end
    end 
end
if not(iscell(device))
    device={device};
end
for i=1:length(device)
    channelflags=channelflags + strcmp(device{i},{Channel.Type}');
end
%channelflags(strmatch('EEG', {Channel.Type}))=1;
%channelflags(strmatch('MEG', {Channel.Type}))=1;

Channel=Channel(find(channelflags));

for i=1:length(Channel)    
    eloc(i).X=Channel(i).Loc(1);
    eloc(i).Y=Channel(i).Loc(2);
    eloc(i).Z=Channel(i).Loc(3);
    eloc(i).labels=Channel(i).Name;
end
% This ouptuts fields sph_theta_besa which are not compatible with
% pop_chanedit function (Revision 1.111)
% chanlocs=convertlocs(eloc, 'cart2all')
% 

chanlocs=pop_chanedit(eloc, 'convert', 'cart2topo', 'convert', 'cart2sph');

return
