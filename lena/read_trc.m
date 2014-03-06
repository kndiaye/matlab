%TRC import
% after:
% http://neuralensemble.org/trac/OpenElectrophy/browser/trunk/pyssdh/OpenElectrophy/filereader/generic/read_trc.py?rev=77c 	char 	string of length 1 	 

%Python struct alias read_f format:
% b 	signed char 	integer     schar    
% B 	unsigned char 	integer     uchar     
% h 	short 	integer             int16
% H 	unsigned short 	integer 	uint16 
% i 	int / integer               int32
% I 	unsigned integer or long	uint32
% http://docs.python.org/library/struct.html


clear TRC
TRC.Filename='\\Serveur_meg\datalinks\CONFINUM\intra\micromed\patients\PAT_2\EEG_3.TRC';
fid=fopen(TRC.Filename);
%% Read Patient info
fseek(fid,64,-1);
TRC.PatientName = deblank(fread(fid, 22, 'int8=>char')');
TRC.PatientSurname = deblank(fread(fid, 20, 'uint8=>char')');

%% Read date
fseek(fid,128,-1);
TRC.Datenum = datenum(fliplr(fread(fid,3,'int8')')+[1900 0 0]);
TRC.Date = datestr(TRC.Datenum);

%% Header
fseek(fid,175,-1);
TRC.HeaderVersion = fread(fid,1,'int8');
if TRC.HeaderVersion ~= 4
    error('*.trc file is not Micromed System98 Header type 4')
end

%% Data description
fseek(fid,138,-1);
TRC.DataStartOffset = fread(fid,1,'uint32')
TRC.NumberOfChannels = fread(fid,1,'uint16')
TRC.Multiplexer = fread(fid,1,'uint16')
TRC.SamplingRate = fread(fid,1,'uint16')
TRC.Bytes = fread(fid,1,'uint16')
TRC.Precision = sprintf('uint%d', 8*TRC.Bytes);
fseek(fid,176+8,-1);
TRC.Code_Area = fread(fid,1,'uint32')
TRC.Code_Area_Length = fread(fid,1,'uint32')
fseek(fid,192+8,-1)
TRC.Electrode_Area = fread(fid,1,'uint32')
TRC.Electrode_Area_Length = fread(fid,1,'uint32')
fseek(fid,400+8,-1)
TRC.Trigger_Area =fread(fid,1,'uint32')
TRC.Trigger_Area_Length=fread(fid,1,'uint32')

%% Read Code Info
fseek(fid,TRC.Code_Area,-1)
TRC.Code = fread(fid, TRC.NumberOfChannels, 'uint16')
units = { ...
    -1  1e-9
    0   1e-6
    1   1e-3
    2   1
    100 'percent'
    101 'bpm'
	102 'Adim'};

%units = {-1:1e-9, 0:1e-6, 1:1e-3, 2:1, 100:'percent', 101:'bpm', 102:'Adim'}
for c=1:TRC.NumberOfChannels
    Channel.chan_record = TRC.Code(c)
    fseek(fid, TRC.Electrode_Area+TRC.Code(c)*128+2,-1)
    Channel.positive_input = sprintf('%02d-%s', c, char(fread(fid, 6, 'uchar')));
    Channel.negative_input = sprintf('%02d-%s', c, char(fread(fid, 6, 'uchar')));
    Channel.logical_min = fread(fid,1,'int32');
    Channel.logical_max = fread(fid,1,'int32');
    Channel.logical_ground = fread(fid,1,'int32');
    Channel.physical_min = fread(fid,1,'int32');
    Channel.physical_max = fread(fid,1,'int32');
    try
        Channel.measurement_unit = units{fread(fid,1,'int16')==[units{:,1}],2};
    catch
        Channel.measurement_unit = 10e-6;
    end
    fseek(fid, 8,0);
    Channel.rate_coef = fread(fid,1,'uint16');
    Channel
    TRC.Channel(c) = Channel;
    
end

%% Read Raw data
fseek(fid,TRC.DataStartOffset,-1);
% Skip 1h40 minutes of data
% 

if 0 % read all channels
%TRC.Data = fread(fid,70000*TRC.NumberOfChannels,'uint16');
%TRC.Data = reshape(TRC.Data,64, []);
end
% Skip ... min of data
fseek(fid,TRC.Bytes*TRC.NumberOfChannels*TRC.SamplingRate*(0*60),0)
% Skip 24 Channels to read Channel 25
fseek(fid,TRC.Bytes*24,0)
TRC.Data =fread(fid,Inf,'uint16', 63*TRC.Bytes + TRC.Bytes*TRC.NumberOfChannels*TRC.SamplingRate )';
plot(TRC.Data)

%% RAWDATA rescaling matrix
factor = ([TRC.Channel.physical_max]-[TRC.Channel.physical_min])./([TRC.Channel.logical_max]-[TRC.Channel.logical_min]);
if ~all(cell2mat({TRC.Channel.measurement_unit})==units{[units{:,1}]==0,2})
    error('Don''t know how to read multiple measurement units in a single file')
end

for i=1:size(TRC.Data,1)
    TRC.F(i,:) = (TRC.Data(i,:)-TRC.Channel(i).logical_ground)*factor(i);
end

%% 

TRC

%% Close fid
%fclose(fid);
