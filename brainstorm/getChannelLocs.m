function [pos]=getChannelLocs(Channel)
for i=1:length(Channel)
    pos(i,1:3)=reshape(Channel(i).Loc(1:3), 1,3);
end