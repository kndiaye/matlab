function [diss,sc]=computedissandsc(thedata1,thedata2)
% computediss: computes dissimilarity and spatial correlation between 2
% data sets
%
% inputs: data as 2-D numeric arrays where dimension 1 contains the
% timeframes, dimension 2 contains the channels
%
% outputs: diss and sc as 1-D numeric arrays that contain the
% dissimilarity and spatial correlation at each timeframe
%
% Cartool: http://brainmapping.unige.ch/Cartool.htm
%
% author of this script: pierre.megevand@medecine.unige.ch


% verify equal number of channels and time frames
if size(thedata1,1)~=size(thedata2,1)
    error('Number of timeframes is different');
elseif size(thedata1,2)~=size(thedata2,2)
    error('Number of channels is different');
end

% compute dissimilarity
diss=zeros(size(thedata1,1),1);
for i=1:size(thedata1,1)
    diss(i)=sqrt(sum((thedata1(i,:)-thedata2(i,:)).^2)/size(thedata1,2));
end

% compute spatial correlation
sc=zeros(size(diss,1),1);
for i=1:size(diss,1)
    sc(i)=(2-diss(i)^2)/2;
end
