function [numchannels,numfrequencies,numblocks,samplingrate,channels,frequencies,thedata]=openfreq(openfilename)
% openfreq: opens a Cartool frequency data file (.freq)
%
% inputs: full path and name of the file to open
%
% outputs: number of channels, number of frequencies, number of blocks and 
% sampling rate as 1-D numeric arrays; frequencies as 1-D numeric array
% containing the frequencies; data as a 2-D numeric array where dimension 1
% contains the frequencies, dimension 2 contains the channels, dimension 3
% contains the blocks (=timeframes)
%
% ATTENTION: this function is unable to read FFT Complex files yet!
%
% Cartool: http://brainmapping.unige.ch/Cartool.htm
%
% author of this script: pierre.megevand@medecine.unige.ch


% open file for reading
fid=fopen(openfilename,'r');

% read fixed part of header
version=strcat(fread(fid,4,'int8=>char')');
type=strcat(fread(fid,32,'int8=>char')');
numchannels=fread(fid,1,'int32');
numfrequencies=fread(fid,1,'int32');
numblocks=fread(fid,1,'int32');
samplingrate=fread(fid,1,'double');
blockfrequency=fread(fid,1,'double');
year=fread(fid,1,'int16');
month=fread(fid,1,'int16');
day=fread(fid,1,'int16');
hour=fread(fid,1,'int16');
minute=fread(fid,1,'int16');
second=fread(fid,1,'int16');
millisecond=fread(fid,1,'int16');

% read variable part of header
channels=strcat(fread(fid,[8,numchannels],'int8=>char')');
frequencies=strcat(fread(fid,numfrequencies*16,'int8=>char')');

% read data
thedata=zeros(numfrequencies,numchannels,numblocks);
if strcmp(type,'FFT Norm')|strcmp(type,'FFT Norm2')|strcmp(type,'FFT Approximation')==1
    for i=1:numblocks
        thedata(:,:,i)=fread(fid,[numfrequencies,numchannels],'float32');
    end
elseif strcmp(type,'FFT Complex')==1
    error('Sorry, I do not know how to read FFT Complex files yet! :)');
end

% close file
fclose(fid);