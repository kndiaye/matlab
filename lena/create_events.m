function events = create_events(onsets,names,trials,durations,offsets)
% create_events() - Create EEGLAB events
% Usage:
%   >> events = create_events(onsets,names,trials,durations,offsets)
%
% Author: Karim N'Diaye, CNRS-UPR640, 01 Jan 2010
%
% See also: read_ptx

events = struct('type',[],'position',[],'latency',[],'urevent',[0]);
n=length(onsets);
events = repmat(events,n,1);
for i=1:n
    events(i) = setfield(events(i),'latency', onsets(i));
    events(i) = setfield(events(i),'type', names{i});
end