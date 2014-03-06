function dh = datahandler(varargin)
% datahandler - A class to handle MEEG data
%
% dh = datahandler(varargin)
%
% KND

%     properties
%         F = [];
%         file = struct('path', '', 'header', []);
%         dimensions = []
%         time
%         channel
%         trial
%         marker
%         class
%         badchannel
%     end

% 
DATA_DIMENSIONS = {'supersensors','time','trial'};

dh.F = [];
dh.file = struct('path',[],'header',[]);

% Data dimensions
% DIMENSION_TYPES = {'double','nominal','logical','struct'}
dh.dimensions = struct('names',[],'size',[],'synonyms',[]);
% dh.dimensions.names = {'supersensors','time','trial'};
dh.supersensor = [];
dh.time = [];
dh.trial = [];

% Extra info
dh.marker = [];
dh.class = [];
dh.badchannel = [];

if nargin==0

    dh = class(dh, 'datahandler');
else
    v = varargin{1};
    if isa(v,'datahandler')
        dh = v;
    elseif ischar(v)
        % if (exist(v, 'filename') || exist(v,'dir'))
        dh.file.path = v;
        try
            dh = import(dh.file.path,varargin{2:end});
            
        catch ME
            rethrow(ME);
        end
        dh = class(dh, 'datahandler');
    elseif isnumeric(v)
        dh.F = v ;
        dh = class(dh, 'datahandler');
    else
        error('[datahandler] Bad input argument');
    end
end

function dh = import(filename,varargin)

% Import data from file
[dh.file.header,dh.F,dh.time] = read_lena(filename,varargin{:});
dh.file.path = filename;
% classes = read_lena_classes
% markers = read_lena_events
dh.badchannel = [];

%% Sensors and supersensors
sensor_range = dh.file.header.description.sensor_range;
sensornames = {sensor_range.sensor_list.sensor.CONTENT};
n = length(sensor_range.sensor_samples.supersensor);
supersensor = sensor_range.sensor_samples.supersensor;
dh.supersensor = struct([]);
for i=1:n
    dh.supersensor(i).name = supersensor(i).sensor;
    dh.supersensor(i).idx  = strmatch(dh.supersensor(i).name, sensornames);
    dh.supersensor(i).unit = supersensor(i).ATTRIBUTE.unit ;
    dh.supersensor(i).scale= supersensor(i).ATTRIBUTE.scale;
    dh.supersensor(i).bad  = ismember(dh.supersensor(i).idx, dh.badchannel);
end

