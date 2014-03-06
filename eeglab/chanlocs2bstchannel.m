function [ Channel ] = chanlocs2bstchannel( chanlocs )
%bstchannel2chanlocs - Converts EEGLAB chanlocs structure to BrainStorm Channel
%   [ Channel ] = chanlocs2bstchannel( chanlocs )

% First converts to Cartesian coordinates
chanlocs = convertlocs(chanlocs, 'topo2all');



return

for i=1:length(Channel)    
    eloc(i).X=Channel(i).Loc(1);
    eloc(i).Y=Channel(i).Loc(2);
    eloc(i).Z=Channel(i).Loc(3);
    eloc(i).labels=Channel(i).Name;
end
chanlocs=convertlocs(eloc, 'cart2all')