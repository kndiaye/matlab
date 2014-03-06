function thedata=computedataagainstref(thedata,ref)
% computedataagainstref: changes the reference of a data set
%
% inputs: data as a 2-D numeric array where dimension 1 contains the
% timeframes, dimension 2 contains the channels; ref as either a number
% (1-D numeric array) or the 'avgref' string for average reference
%
% outputs: data as a 2-D numeric array where dimension 1 contains the
% timeframes, dimension 2 contains the channels
%
% Cartool: http://brainmapping.unige.ch/Cartool.htm
%
% author of this script: pierre.megevand@medecine.unige.ch


% define number of channels and time frames
numtimeframes=size(thedata,1);
numchannels=size(thedata,2);

% compute data against selected reference
if ischar(ref)==1&strcmp(ref,'avgref')==1
    avgref=computeavgref(thedata);
    for i=1:numtimeframes
        thedata(i,:)=thedata(i,:)-avgref(i);
    end
elseif ischar(ref)==1&strcmp(ref,'avgref')==0
    error('Unknown code for reference');
elseif isnumeric(ref)==1&ref>=1&ref<=numchannels
    for i=1:numtimeframes
        thedata(i,:)=thedata(i,:)-thedata(i,ref);
    end
elseif isnumeric(ref)==1&(ref<1|ref>numchannels);
    error('Reference specified does not exist');
end