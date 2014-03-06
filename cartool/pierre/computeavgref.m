function avgref=computeavgref(thedata)
% computeavgref: computes the average reference of a data set
%
% inputs: data as a 2-D numeric array where dimension 1 contains the
% timeframes, dimension 2 contains the channels
%
% outputs: average reference as a 1-D numeric array that contains the
% average reference at each timeframe
%
% Cartool: http://brainmapping.unige.ch/Cartool.htm
%
% author of this script: pierre.megevand@medecine.unige.ch


% define number of channels and time frames
numtimeframes=size(thedata,1);
numchannels=size(thedata,2);

% compute average reference
avgref=zeros(numtimeframes,1);
for i=1:numtimeframes
    avgref(i)=sum(thedata(i,:))/numchannels;
end