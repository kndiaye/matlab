function gfp=computegfp(thedata)
% computegfp: calculates the global field power of a data set
%
% inputs: data as a 2-D numeric array where dimension 1 contains the
% timeframes, dimension 2 contains the channels
%
% outputs: global field power as a 1-D numeric array that contains the
% global field power at each timeframe
%
% Cartool: http://brainmapping.unige.ch/Cartool.htm
%
% author of this script: pierre.megevand@medecine.unige.ch


% define number of channels and time frames
numtimeframes=size(thedata,1);
numchannels=size(thedata,2);

% compute global field power
gfp=zeros(numtimeframes,1);
avgref=computeavgref(thedata);
for i=1:numtimeframes
    gfp(i)=sqrt(sum((thedata(i,:)-avgref(i)).^2)/numchannels);
end