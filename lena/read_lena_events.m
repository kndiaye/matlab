function [events,filename] = read_lena_events(filename)
%READ_LENA_EVENTS - Reads events in a LENA file
%   [events] = read_lena_events(filename)
%   events is a struct array with fields:
%         .name
%         .comments
%         .color
%         .epoch
%         .time
%         .duration
%         .offset
%
%   Example
%       >> read_lena_events('run1.lena')
%       >> read_lena_events('data.ptx')
%
%   See also: read_ptx

% Author: K. N'Diaye (kndiaye01<at>gmail.com)
% Copyright (C) 2010
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2010-10-18 Creation
%
% ----------------------------- Script History ---------------------------------
events = repmat(struct(...
    'name',[],...
    'comment',[],...
    'color',[],...
    'trial',[],...
    'time',[],...
    'duration',[],...
    'offset',[]),0);

folder = NaN;
if exist(filename, 'dir')
    folder = filename;
    % Default names for event files
    EVENTFILES = { 'data.event' 'data.events' };
    while ~isempty(EVENTFILES)
        filename = fullfile(folder,EVENTFILES{1});
        EVENTFILES(1)=[];
        if exist(filename,'file')
            break
        end
    end
end

if ~exist(filename,'file')
    if ~isnan(folder)
        return
    end
    error('File not found: %s must be a LENA folder or a ptx-formatted file',filename);
end

[onsets,names,epochs,durations,offsets,header] = read_ptx(filename);
if ~isempty(onsets)
    events = struct(...
        'name',names,...
        'comment',[],...
        'color',[],...
        'trial',num2cell(epochs),...
        'time',num2cell(onsets),...
        'duration',num2cell(durations),...
        'offset',num2cell(offsets));
end
if ~isempty(header)
    specs = regexp(header(strmatch('#TRIGGER COMMENTS',header)+1:end),...
        '#\s+(?<name>\w*)\s+(?<comment>.*)\s+#[cC][oO][lL][oO][rR]=(?<color>[#\w]*)','names');
    for i=1:numel(specs)
        if ~isempty(specs{i})
            [events(ismember({events.name},specs{i}.name)).color]=deal(specs{i}.color);
        end
    end
end
