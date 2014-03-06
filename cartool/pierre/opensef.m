function [numchannels,numtimeframes,samplingrate,thedata]=opensef(openfilename)
% opensef: opens a Cartool simple EEG data file (.sef)
%
% inputs: full path and name of the file to open
%
% outputs: number of channels, number of timeframes and sampling rate as
% 1-D numeric arrays; data as a 2-D numeric array where dimension 1
% contains the timeframes, dimension 2 contains the channels
%
% Cartool: http://brainmapping.unige.ch/Cartool.htm
%
% author of this script: pierre.megevand@medecine.unige.ch


% open filename for reading
fid=fopen(openfilename,'r');

% read fixed part of header
version=strcat(fread(fid,4,'int8=>char')');
numchannels=fread(fid,1,'int32');
numauxchannels=fread(fid,1,'int32');
numtimeframes=fread(fid,1,'int32');
samplingrate=fread(fid,1,'float32');
year=fread(fid,1,'int16');
month=fread(fid,1,'int16');
day=fread(fid,1,'int16');
hour=fread(fid,1,'int16');
minute=fread(fid,1,'int16');
second=fread(fid,1,'int16');
millisecond=fread(fid,1,'int16');

% read variable part of header
channels=strcat(fread(fid,[8,numchannels],'int8=>char')');

% read data
thedata=fread(fid,[numchannels,numtimeframes],'float32')';

% close file
fclose(fid);