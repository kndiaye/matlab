function [ chanlocs ] = bstormchannels2chanlocs( Channel , device )
%bstormchannels2chanlocs - Converts BrainStorm channels to EEGLAB chanlocs structure
%   [ chanlocs ] = bstormchannels2chanlocs( Channel , device )
%
%INPUTS:
%   Channel : a BrainStorm Channel structure
%Importing Electrodes to EEGLAB format

error('NOT IMPLEMENTED YET')
return

channelflags=zeros(length(Channel),1);
ChannelTypes = unique({Channel.Type});
if nargin <2 
    if length(ChannelTypes)>1 
        DEVICES = ChannelTypes;
        [s,v] = listdlg('PromptString','Select a device:',...
            'SelectionMode','multiple',...
            'ListString',DEVICES);
        device={};
        if all(v)
            for strread(DEVICES(s), '%s', 'delimiter', ',')
            end
        else

        end
    else % There is only one type of channels
        device=ChannelTypes;
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
chanlocs=convertlocs(eloc, 'cart2all')