% opens a Cartool electrode coordinates file (.els)
%
% Cartool: http://brainmapping.unige.ch/Cartool.htm
%
% author of this script: pierre.megevand@medecine.unige.ch


% check whether filename exists
if exist('filename')==0
    error('filename is not defined')
end

% open filename for reading in text mode
fid=fopen(openfilename,'rt');

% read file
els=textscan(fid,'%s','delimiter','/n');
els=els{1};
magicnumber=els{1};
totalnumelectrodes=str2num(els{2});
numclusters=str2num(els{3});
pointer=4;

for i=1:numclusters
    clusters(i).name=els{pointer};
    clusters(i).numelectrodes=str2num(els{pointer+1});
    clusters(i).dimension=str2num(els{pointer+2});
    pointer=pointer+3;
    for j=1:clusters(i).numelectrodes
        clusters(i).electrodes(j).name=sscanf(els{pointer},'%*f %*f %*f %s',1);
        clusters(i).electrodes(j).x=sscanf(els{pointer},'%f',1);
        clusters(i).electrodes(j).y=sscanf(els{pointer},'%*f %f',1);
        clusters(i).electrodes(j).z=sscanf(els{pointer},'%*f %*f %f',1);
        pointer=pointer+1;
    end
end

fclose(fid);