function varargout = convert(dh,format)
% convert (datahandler) - Convert LENA data to some format
%   [output] = convert(dh,format)
%   format may be:
%       'eeglab' -> ouput = EEG struct
%       'eeglab.data'  -> output EEGLAB event structure
%       'eeglab.chanlocs'  -> output EEGLAB channel structure
%       'eeglab.event'  -> output EEGLAB event structure
%       'eeglab.[...]'
%
%       'fieldtrip'  -> output FieldTrip structure
%
% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2010
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2010-04-22 Creation
%
% ----------------------------- Script History ---------------------------------
if nargin == 1
    format = 'eeglab';
end
[format,subformat]=strtok(format, '.');
switch lower(format)
    case 'eeglab'
        if exist('eeg_emptyset')==2
            EEG = eeg_emptyset;
        else % if no eeglab in the path, use local version...
            EEG = emptyset();
        end
        [EEG.nbchan EEG.trials EEG.pnts] = size(dh.F);
        [EEG.filepath EEG.filename] = fileparts(dh.file.path);
        eeg.chanlocs = chanlocs(data)
        
        if isempty(subformat) || isequal(subformat,'data')
            EEG.data = data(dh);
            if exist('eeg_checkset')==2
                EEG = eeg_checkset(EEG);
            else
                warning('Datahandler:Convert:NoEEGLABCheckset', 'EEGLAB''s eeg_checkset function missing.')
            end
        end
        if isempty(subformat)
            varargout = {EEG};
        else
            varargout = {EEG.(subformat)};
        end
        return;
end

function [EEG] = eeglab_emptyset()
EEG.data = [] ;

EEG.setname = '';
EEG.filename = '';
EEG.filepath = '';
EEG.trials = NaN;   % number of epochs (or trials) in the dataset.
%                     If data are continuous, this number is 1.
EEG.pnts = NaN;     % number of time points (or data frames) per trial (epoch).
%                     If data are continuous (trials=1), the total number
%                     of time points (frames) in the dataset
EEG.nbchan = NaN;   % number of channels
EEG.srate = NaN;    % data sampling rate (in Hz)
EEG.xmin = NaN;     % epoch start latency|time (in sec. relative to the
%                     time-locking event at time 0)
EEG.xmax = NaN;     % epoch end latency|time (in seconds)
EEG.times = NaN;    % vector of latencies|times in seconds (one per time point)
EEG.ref = NaN;      % ['common'|'averef'|integer] reference channel type or number
EEG.history = {};   % cell array of ascii pop-window commands that created
%                     or modified the dataset
EEG.comments = NaN; % comments about the nature of the dataset (edit this via
%                     menu selection Edit > About this dataset)
EEG.etc = NaN;      % miscellaneous (technical or temporary) dataset information
EEG.saved = 'no';   % ['yes'|'no'] 'no' flags need to save dataset changes before exit
% 
% EEG.chanlocs     - structure array containing names and locations of the channels on the scalp
% EEG.urchanlocs   - original (ur) dataset chanlocs structure containing all channels originally collected with these data (before channel rejection)
% EEG.chaninfo     - structure containing additional channel info
% EEG.ref          - type of channel reference ('common'|'averef'|+/-int]
% EEG.splinefile   - location of the spline file used by headplot() to plot data scalp maps in 3-D

function eeglab_chanlocs(dh)

for index = 1:length( eloc )
     eloc(index).X  = tmp(1); x(index) = tmp(1);
                    eloc(index).Y  = tmp(2); y(index) = tmp(2);
                    eloc(index).Z  = tmp(3); z(index) = tmp(3);
                    eloc(index).type = 'EEG';
end;
