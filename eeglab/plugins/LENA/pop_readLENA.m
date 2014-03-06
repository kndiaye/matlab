% pop_readLENA() - load LENA Data files (pop out window if no arguments).
%
% Usage:
%   >> EEG = pop_readLENA;             % a window pops up
%   >> EEG = pop_readLENA( lenafile );
%
% Inputs:
%   datafile       - A LENA header file
% 
% Outputs:
%   EEG            - EEGLAB data structure
%
% Author: Karim N'Diaye, CNRS-UPR640, 01 Jan 2004
%
% See also: eeglab(), readLENA()

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) 2009, Karim N'Diaye (karim.ndiaye@upmc.fr)
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function [EEG, command] = pop_readLENA(datafile)
    
EEG = [];
command = '';
if nargin < 1 
	% ask user
    try
	cd('\data\confinum\RAWDATA\EEG5330');
	catch
	try
        cd('ndiayek\data\confinum\RAWDATA\EEG5330');
    catch
         cd('d:\ndiayek\data\confinum\RAWDATA\EEG5330');
    end
	end	
	[filename, filepath] = uigetfile('*.lena', 'Choose a datafile in a DS folder -- pop_readLENA()');
    drawnow;
	if filename == 0 return; end;    
	datafile = fullfile(filepath,filename);    
end;

% load data
% ---------
EEG = eeg_emptyset;
 [header data] = read_lena(datafile);
%[header data] = fastReadLENAHeadBin(datafile);

EEG.setname 		= 'LENA data';
[EEG.filepath,filename ,ext] = fileparts(datafile);
EEG.filename = [filename ext];
EEG.data_filename = a%data_filename;
EEG.pnts            = header.timeSamples;
EEG.nbchan          = length(header.sensors.name);
if isempty(strmatch('datablock_dim', header.dimensions_names))
    EEG.trials          = 1;
else
    error ('Don''t know how to deal with multi trial data!')
end
EEG.srate           = header.sampleRate;
EEG.xmin            = header.preTrigger/header.sampleRate;
EEG.xmax            = (header.timeSamples-1-header.preTrigger)/header.sampleRate;
EEG.data = data;
EEG.times = EEG.xmin:1./EEG.srate:EEG.xmax;

try;
    EEG.comments = header.history;
end
EEG.ref = ['nose'];



%% Channel info
for chan = 1:EEG.nbchan
    EEG.chanlocs(chan).labels = header.sensors.name{chan};
    fn=fieldnames(header.sensorSamples);
    i=strmatch('list_sensors',fn, 'exact');
    if ~isempty(i)
%         for i_fn=setdiff(1:numel(fn), i)            
%             EEG.chanlocs(chan) = setfield(fn{i_fn},            
%             getfield(header.sensorSamples, fn{i_fn})
%             labels = header.sensors.name{chan};
%         end
    end
    
end

% if isempty([chanlocs.scale])
%     chanlocs = rmfield(chanlocs, 'scale');
% end

EEG = eeg_checkset(EEG);
command = sprintf('EEG = pop_readLENA(''%s'');', datafile);

% This 
ptxfile = [ data_filename(1:end-5) '.ptx'];
if ~exist(ptxfile)
    return
end


return
% importing the events
% --------------------
if ~isempty(Eventdata)
    orinbchans = EEG.nbchan;
    for index = size(Eventdata,1):-1:1
        EEG = pop_chanevent( EEG, orinbchans-size(Eventdata,1)+index, 'edge', 'leading', ...
                             'delevent', 'off', 'typename', Head.eventcode(index,:), ...
                             'nbtype', 1, 'delchan', 'on');
    end;
end;
return

%EEG = 
%
%             setname: 'Continuous EEG Data epochs'
%            filename: 'eeg_demo_squareepochs.set'
%            filepath: ''
%                pnts: 384
%              nbchan: 32
%              trials: 80
%               srate: 128
%                xmin: -1
%                xmax: 1.9922
%                data: [32x384x80 single]
%             icawinv: []
%           icasphere: []
%          icaweights: []
%              icaact: []
%               event: [1x157 struct]
%               epoch: [1x80 struct]
%            chanlocs: [1x32 struct]
%            comments: [9x769 char]
%              averef: 'no'
%                  rt: []
%    eventdescription: {[2x29 char]  [2x63 char]  [2x36 char]  ''}
%    epochdescription: {}
%            specdata: []
%          specicaact: []
%              reject: [1x1 struct]
%               stats: [1x1 struct]
%          splinefile: []
%                 ref: 'averef'
%             history: [11x108 char]
%               times: [1x384 double]

% EEG.event
% 1x157 struct array with fields:
%    type: 'square' or 'rt'
%    position: [1] or [2]
%    latency: in ms from the beginning of the continuous recording
%    epoch: the epoch in which the event falls (indexed from 1)

%  EEG.epoch
% 1x80 struct array with fields:
%    event: the index of the events that fall in that one epoch
%    eventlatency: the latency of each event
%    eventposition: the position of each event
%    eventtype: the type of each event


