function  [] = write_sef(seffile,eeg,varargin)
%write_sef - Writes a Simple EEG Format file (Cartool)
%   [] = write_sef(EEG)
%
%   Example
%       >> write_sef
%
%   See also: 

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2007 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2007-04-04 Creation
%                   
% ----------------------------- Script History ---------------------------------

if isfield(eeg,'chanlocs')
    % EEGLAB format
    EEG=eeg;
    eeg=[];
    eeg.data=EEG.data;
    [eeg.NumElectrodes, eeg.NumTimeFrames] = size(EEG.data)
    eeg.TSefChannelName = strvcat({EEG.chanlocs.labels});
    eeg.TSefChannelName =[eeg.TSefChannelName repmat(' ', size(eeg.TSefChannelName,1), max(0,8-size(eeg.TSefChannelName,2)))];
    eeg.TSefChannelName(eeg.TSefChannelName==32)=0;
    if eeg.NumElectrodes ~= EEG.nbchan | eeg.NumElectrodes ~= numel(eeg.TSefChannelName)/8
        error('check electrode number, size of data and chanlocs')
    end
    eeg.NumAuxElectrodes = eeg.NumElectrodes-64;
    eeg.SamplingFrequency =  EEG.srate;

elseif isnumeric(eeg)
    data=eeg;
    eeg=[];
    eeg.data=data;
    eeg.NumElectrodes = size(eeg.data,1);
    eeg.NumAuxElectrodes = 0;
    eeg.TSefChannelName = sprintf('e%03d\0\0\0\0',1:eeg.NumAuxElectrodes);
    
    clear data;
else
    error('Wrong type of input: Should be raw data OR EEGLAB structure.')
end

fid=fopen(seffile, 'wb');
eeg.Year                = 0;
eeg.Month               = 0;
eeg.Day                 = 0;
eeg.Hour                = 0;
eeg.Minute              = 0;
eeg.Second              = 0;
eeg.Millisecond         = 0;  

eeg.Version = 'SE01';

fwrite(fid,eeg.Version, 'uchar');
fwrite(fid,eeg.NumElectrodes,'int32');
fwrite(fid,eeg.NumAuxElectrodes,'int32');
fwrite(fid,eeg.NumTimeFrames,'int32');
fwrite(fid,eeg.SamplingFrequency,'float32');

fwrite(fid,eeg.Year,'int16');
fwrite(fid,eeg.Month,'int16');
fwrite(fid,eeg.Day,'int16');
fwrite(fid,eeg.Hour,'int16');
fwrite(fid,eeg.Minute,'int16');
fwrite(fid,eeg.Second,'int16');
fwrite(fid,eeg.Millisecond,'int16');   

fwrite(fid,eeg.TSefChannelName(:,:)','uchar');
fwrite(fid,eeg.data,'float32')

fclose(fid)
