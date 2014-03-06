function [ chanlocs ] = bstchannel2chanlocs( Channel )
%bstchannel2chanlocs - Converts BrainStorm Channel struct to EEGLAB chanlocs structure
%   [ chanlocs ] = bstchannels2chanlocs( Channel )
%
%NB: All Channel shoud be of the same type, of course...
for i=1:length(Channel)    
    eloc(i).X=Channel(i).Loc(1);
    eloc(i).Y=Channel(i).Loc(2);
    eloc(i).Z=Channel(i).Loc(3);
    eloc(i).labels=Channel(i).Name;
end
chanlocs=convertlocs(eloc, 'cart2all')