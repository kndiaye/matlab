function [numchannels,numtimeframes,samplingrate,thedata]=openeph(openfilename)
% openeph: opens a Cartool evoked potential data file (.ep(h))
%
% inputs: full path and name of the file to open
%
% outputs: number of channels, number of timeframes (and sampling rate for
% .eph files) as 1-D numeric arrays; data as a 2-D numeric array where
% dimension 1 contains the timeframes, dimension 2 contains the channels
%
% Cartool: http://brainmapping.unige.ch/Cartool.htm
%
% author of this script: pierre.megevand@medecine.unige.ch


% open filename for reading in text mode
fid=fopen(openfilename,'rt');

% for .eph files
if strcmp(openfilename(end-3:end),'.eph')==1
    
    % read header
    eph=textscan(fid,'%s','delimiter','/n');
    eph=eph{1};
    numchannels=sscanf(eph{1},'%f',1);
    numtimeframes=sscanf(eph{1},'%*f %f',1);
    samplingrate=sscanf(eph{1},'%*f %*f %f',1);
    
    % prepare for reading data
    formatstring='%f';
    if numchannels>1
        for i=1:numchannels-1
            formatstring=[formatstring ' %f'];
        end
    end

    % read data
    thedata=zeros(numtimeframes,numchannels);
    for i=1:numtimeframes
        thedata(i,:)=sscanf(eph{i+1},formatstring);
    end

% for .ep files
elseif strcmp(openfilename(end-2:end),'.ep')==1
    thedata='';
    while ~feof(fid)
        thedataline=fgetl(fid);
        thedata=strvcat(thedata,thedataline);
    end
    thedata=str2num(thedata);
    numtimeframes=size(thedata,1);
    numchannels=size(thedata,2);
    samplingrate=0;
    
else
    error('incorrect file type');
end

% close file
fclose(fid);