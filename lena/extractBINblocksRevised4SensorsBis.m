function echantillons = extractBINblocks(fid,dim_to_read,dim_names,level,data_type,data_size)
% function echantillons = extractBINblocks(fid,mat,data_type,data_size)
%
%   Function to read only parts of a bin file ( cf LENA data format )
%
% Inputs :
%   - fid ( integer ) : fid of the bin file
%   - mat ( double array ) : matrix of samples to read. Size must be N x 2,
%   ie first column for samples to read, second for samples to skip
%   - data_type ( string ) : data type and size ( example : int16 )
%   - data_size ( integer ) : data format size
%dim
% Ouputs :
%   - echantillons ( cells ) : read datas stored in cells

size_dim=length(dim_to_read);
trial_dim=[];
frequency_dim=[];
sensor_dim=[];
time_dim=[];

first_pos_trial=0;
first_pos_frequency=0;
first_pos_sensor=0;
first_pos_time=0;

[trial_dim, trial_level,frequency_dim, frequency_level, sensor_dim, sensor_level, time_dim, time_level ]=GetDimensionsValues(dim_to_read, dim_names, level);

if ~isempty(trial_dim)
    trial_dim=cell2mat(trial_dim);
    first_pos_trial=Get_First_Pos_Trial(trial_dim, frequency_level, sensor_level,time_level);
end
if ~isempty(sensor_dim)
    sensor_dim=cell2mat(sensor_dim);
    first_pos_sensor=Get_First_Pos_Sensor(sensor_dim, time_level);
end
if ~isempty(frequency_dim)
    if isempty(sensor_dim)
        sensor_dim=1;
    end
    frequency_dim=cell2mat(frequency_dim);
    [first_pos_frequency, first_pos_sensor]=Get_First_Pos_Frequency_Sensor(frequency_dim,sensor_dim,frequency_level,sensor_level,time_level, dim_names);
end
if ~isempty(time_dim)
    time_dim=cell2mat(time_dim);
    first_pos_time=time_dim(1);%-1;
end
first_pos=(first_pos_time+first_pos_sensor+first_pos_frequency+first_pos_trial);
fseek(fid,data_size*first_pos,'bof');
if ~isempty(trial_dim)
    first_trial=trial_dim(1);
    last_trial=trial_dim(end);
else
    first_trial=1;
    last_trial=1;
end
if ~isempty(frequency_dim)
    first_frequency=frequency_dim(1);
    last_frequency=frequency_dim(end);
else
    first_frequency=1;
    last_frequency=1;
end
if ~isempty(sensor_dim)
    first_sensor=sensor_dim(1);
    last_sensor=sensor_dim(end);
else
    first_sensor=1;
    last_sensor=1;
end
if ~isempty(time_dim)
    first_time=time_dim(1);
    last_time=time_dim(end);
else
    first_time=1;
    last_time=1;
end
if exist('time_level') && ~ isempty(time_dim) && (time_level-time_dim(end))>0
    remainder_time=time_level-time_dim(end)-1;
else
    remainder_time=0;
end
k=1;
echantillons=[];

%% Nouvelle tentative
if (isempty(trial_dim) && isempty(trial_level))
    first_pos_trial=0;
    if ~isempty(frequency_level) & ~isempty(sensor_level) & ~isempty(time_level)
        [rank_sensor,  rank_frequency]=getRankSensorFrequency(dim_names);
        if rank_sensor > rank_frequency
            [k, echantillon]= Process_Frequency_Sensor(fid,data_size, data_type,first_pos_trial, first_pos_sensor,frequency_dim,sensor_dim, time_dim, k,frequency_level, time_level, sensor_level); % frequence/temps
            echantillons= [echantillons echantillon];
        else
            [k, echantillon]= Process_Sensor_Frequency(fid,data_size, data_type,first_pos_trial, first_pos_frequency, frequency_dim,sensor_dim, time_dim, k,frequency_level, time_level, sensor_level); % frequence/temps
            echantillons= [echantillons echantillon];
        end
    else
        if ~isempty(sensor_level) & ~isempty(time_level)
            first_pos_frequency=0;%1;
            [k, echantillon]= Process_Sensor(fid,data_size, data_type,first_pos_trial, first_pos_frequency,sensor_dim, time_dim,sensor_level,time_level,k);
            echantillons= [echantillons echantillon];
        else
            if ~isempty(frequency_level) & ~isempty(time_level)
                [k, echantillon]= Process_Frequency(fid,data_size, data_type,first_pos_trial, frequency_dim,time_dim, k,frequency_level, time_level); % frequence/temps
                echantillons= [echantillons echantillon];
            else
                if  ~isempty(sensor_level) & isempty(frequency_level) & isempty(time_level)
                    [k, echantillon]= Process_Sensor(fid,data_size, data_type,first_pos_trial, first_pos_frequency,sensor_dim, time_dim,sensor_level,time_level,k);
                    echantillons= [echantillons echantillon];
                else
                    if  isempty(sensor_level) & ~isempty(frequency_level) & isempty(time_level)
                        [k, echantillon]= Process_Frequency(fid,data_size, data_type,first_pos_trial, frequency_dim,time_dim, k,frequency_level, time_level); % frequence/temps
                        echantillons= [echantillons echantillon];
                    else
                        if isempty(sensor_level) & isempty(frequency_level) & ~isempty(time_level)
                            fseek(fid,data_size*first_pos,'bof');
                            echantillons{k}=  fread(fid,length(time_dim),data_type);
                        else
                            fseek(fid,0,'bof');
                            echantillons{k}=  fread(fid,1,data_type);
                        end
                    end
                end
            end
        end
    end
else
    if ~isempty(trial_dim)
        limit_trial=length(trial_dim);
    else
        if ~isempty(trial_level)
            limit_trial=trial_level;
        end
    end
    for i_dim_trial=1:limit_trial
        if ~isempty(frequency_level) & ~isempty(sensor_level) & ~isempty(time_level)
            first_pos_trial=(trial_dim(i_dim_trial)-1)*(frequency_level*sensor_level*time_level);
            [rank_sensor,  rank_frequency]=getRankSensorFrequency(dim_names);
            if rank_sensor > rank_frequency
                [k, echantillon]= Process_Frequency_Sensor(fid,data_size, data_type,first_pos_trial, first_pos_sensor,frequency_dim,sensor_dim, time_dim, k,frequency_level, time_level, sensor_level); % frequence/temps
                echantillons= [echantillons echantillon];
            else
                [k, echantillon]= Process_Sensor_Frequency(fid,data_size, data_type,first_pos_trial, first_pos_frequency, frequency_dim,sensor_dim, time_dim, k,frequency_level, time_level, sensor_level); % frequence/temps
                echantillons= [echantillons echantillon];
            end
        else
            if ~isempty(sensor_level) & ~isempty(time_level)
                first_pos_trial=(trial_dim(i_dim_trial)-1)*(sensor_level*time_level);
                first_pos_frequency=0;
                [k, echantillon]= Process_Sensor(fid,data_size, data_type,first_pos_trial, first_pos_frequency,sensor_dim, time_dim,sensor_level,time_level,k);
                echantillons= [echantillons echantillon];
            else
                if ~isempty(frequency_level) & ~isempty(time_level)
                    first_pos_trial=(trial_dim(i_dim_trial)-1)*(frequency_level*time_level);
                    [k, echantillons]= Process_Frequency(fid,data_size, data_type,first_pos_trial, frequency_dim,time_dim, k,frequency_level, time_level); % frequence/temps                    
                else
                    if  ~isempty(sensor_level) & isempty(frequency_level) & isempty(time_level)
                        [k, echantillons]= Process_Sensor(fid,data_size, data_type,first_pos_trial, first_pos_frequency,sensor_dim, time_dim,sensor_level,time_level,k);
                    end
                end
            end
        end
    end
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [trial_dim, trial_level,frequency_dim, frequency_level, sensor_dim, sensor_level, time_dim, time_level ]=GetDimensionsValues(dim_to_read, dim_names, level)

trial_dim=[];
frequency_dim=[];
sensor_dim=[];
time_dim=[];

trial_level=[];
frequency_level=[];
sensor_level=[];
time_level=[];

size= length(dim_to_read);
if size==1
    switch dim_names
        case 'datablock_range'
            trial_dim=dim_to_read; trial_level=level;
        case 'frequency_range'
            frequency_dim=dim_to_read; frequency_level=level;
        case 'sensor_range'
            sensor_dim=dim_to_read; sensor_level=level;
        case 'time_range'
            time_dim=dim_to_read; time_level=level;
    end
else
    for i=1:length(dim_to_read)
        switch dim_names{i}
            case 'datablock_range'
                trial_dim=dim_to_read(i); trial_level=level(i);
            case 'frequency_range'
                frequency_dim=dim_to_read(i); frequency_level=level(i);
            case 'sensor_range'
                sensor_dim=dim_to_read(i); sensor_level=level(i);
            case 'time_range'
                time_dim=dim_to_read(i); time_level=level(i);
        end
    end
end
if iscell (dim_names)
    for i=1:length(level)
        switch dim_names{i}
            case 'datablock_range'
                if isempty(trial_dim) & isempty(trial_level)
                    trial_dim=num2cell(level(i)); trial_level=level(i);
                end
            case 'frequency_range'
                if isempty(frequency_dim) & isempty(frequency_level)
                    frequency_dim=num2cell(level(i)); frequency_level=level(i);
                end
            case 'sensor_range'
                if isempty(sensor_dim) & isempty(sensor_level)
                    sensor_dim=num2cell(level(i)); sensor_level=level(i);
                end
            case 'time_range'
                if isempty(time_dim) & isempty(time_level)
                    time_dim=num2cell(level(i)-1); time_level=level(i);
                end
        end
    end
else
    if ~ isempty( dim_names)
        switch dim_names
            case 'datablock_range'
                if isempty(trial_dim) & isempty(trial_level)
                    trial_dim=num2cell(level); trial_level=level;
                end
            case 'frequency_range'
                if isempty(frequency_dim) & isempty(frequency_level)
                    frequency_dim=num2cell(level); frequency_level=level;
                end
            case 'sensor_range'
                if isempty(sensor_dim) & isempty(sensor_level)
                    sensor_dim=num2cell(level); sensor_level=level;
                end
            case 'time_range'
                if isempty(time_dim) & isempty(time_level)
                    time_dim=num2cell(level-1); time_level=level;
                end
        end
    end
end
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [k, echantillons]= Process_Frequency_Sensor(fid,data_size, data_type,first_pos_trial, first_pos_frequency, frequency_dim,sensor_dim, time_dim, k,frequency_level, time_level, sensor_level)
% frequence/temps
echantillons=[];
if ~isempty(frequency_dim)
    limit_frequency=length(frequency_dim);
else    limit_frequency=frequency_level;
end
for i_dim_frequency=1:limit_frequency
    first_pos_frequency=(frequency_dim(i_dim_frequency)-1)*(sensor_level*time_level);
    [k, echantillon]=    Process_Sensor(fid,data_size, data_type,first_pos_trial,first_pos_frequency, sensor_dim, time_dim,sensor_level,time_level,k);
    echantillons=[echantillons echantillon];
end
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [k, echantillons]= Process_Sensor_Frequency(fid,data_size, data_type,first_pos_trial, first_pos_frequency, frequency_dim,sensor_dim, time_dim, k,frequency_level, time_level, sensor_level); % frequence/temps
echantillons=[];
if ~isempty(sensor_dim)
    limit_sensor=length(sensor_dim);
else    limit_sensor=sensor_level;
end
for i_dim_sensor=1:limit_sensor

    first_pos_sensor=(sensor_dim(i_dim_sensor)-1)*(frequency_level*time_level);
    [k, echantillon]=    Process_Frequency(fid,data_size, data_type,first_pos_trial,first_pos_sensor,frequency_dim,time_dim, k,frequency_level, time_level);
    echantillons=[echantillons echantillon];
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [k, echantillon]= Process_Frequency(fid,data_size, data_type,first_pos_trial, first_pos_sensor, frequency_dim,time_dim, k,frequency_level, time_level)
% function  Process_Frequency(first_pos_trial)
if ( isempty(frequency_dim) & isempty(frequency_level) & isempty(time_dim) & isempty(time_level) )
    fseek(fid,0,'bof');
    echantillons{k}=  fread(fid,1,data_type);
    %k=1;
    %echantillons=[];
    return;
end
if (~ isempty(time_dim) & ~isempty(time_level))
    first_pos_time=time_dim(1);%-1;
    if time_level==time_dim(end)
        remainder_time=0;
    else
        remainder_time=time_level-time_dim(end)-1;
    end
    dim_time=length(time_dim);
else
    first_pos_time=0;
    remainder_time=0;
    time_level=1;
    dim_time=1;
end
if ~isempty(frequency_dim)
    limit_frequency=length(frequency_dim);
else
    limit_frequency=frequency_level;
end
k1=1;
for i_dim_frequency=1:limit_frequency
    first_pos=first_pos_trial+first_pos_sensor+ (frequency_dim(i_dim_frequency)-1)*(time_level) + first_pos_time;
    %Lecture
    fseek(fid,data_size*first_pos,'bof');
    echantillon{k1}=  fread(fid,dim_time,data_type);
    k1=k1+1;
    k=k+1;
end
return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function  Process_Sensor(first_pos_trial,  first_pos_frequency)
function [k, echantillons]= Process_Sensor(fid,data_size, data_type,first_pos_trial, first_pos_frequency,sensor_dim, time_dim,sensor_level,time_level,k)
if ( isempty(sensor_dim) & isempty(sensor_level) & isempty(time_dim) & isempty(time_level) )
    fseek(fid,0,'bof');
    echantillons{k}=  fread(fid,1,data_type);
    return;
end
if (~ isempty(time_dim) & ~isempty(time_level))
    first_pos_time=time_dim(1);
    if time_level==time_dim(end)+1;
        remainder_time=0;
    else
        remainder_time=time_level-time_dim(end)-1;
    end
    dim_time=length(time_dim);
else
    first_pos_time=0;
    remainder_time=0;
    time_level=1;
    dim_time=1;
end
if ~isempty(sensor_dim)
    limit_sensor=length(sensor_dim);
else
    limit_sensor=sensor_level;
end
k1=1;
for i_dim_sensor=1:limit_sensor
    first_pos_sensor=(sensor_dim(i_dim_sensor)-1)*(time_level);
    first_pos=first_pos_trial+first_pos_frequency+ first_pos_sensor + first_pos_time;
    %Lecture
    fseek(fid,data_size*first_pos,'bof');
    echantillons{k1}=  fread(fid,dim_time,data_type);
    k1=k1+1;
    k=k+1;
end
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function  first_pos_trial=Get_First_Pos_Trial(trial_dim, frequency_level, sensor_level,time_level)
if isempty(frequency_level)
    frequency_level=1;
end
if isempty(sensor_level)
    sensor_level=1;
end
if isempty(time_level)
    time_level=1;
end

first_pos_trial=(trial_dim(1)-1)*(frequency_level*sensor_level*time_level);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [rank_sensor,  rank_frequency]=getRankSensorFrequency(dim_names)
rank_sensor=0;
rank_frequency=0;
for i=1:length(dim_names)
    if strcmp (dim_names{i}, 'frequency_range')
        rank_frequency=i;
    else
        if strcmp (dim_names{i}, 'sensor_range')
            rank_sensor=i;
        end
    end
end
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  [first_pos_frequency,first_pos_sensor] =Get_First_Pos_Frequency_Sensor(frequency_dim, sensor_dim, frequency_level,sensor_level,time_level, dim_names)
[rank_sensor,  rank_frequency]=getRankSensorFrequency(dim_names);
if isempty(time_level)
    time_level=1;
end
if isempty(sensor_level)
    sensor_level=1;
end
if rank_frequency ~= 0 &  rank_frequency > rank_sensor & rank_sensor ~= 0
    % rajouter  le cas ou frequency est apres sensors
    first_pos_frequency=(frequency_dim(1)-1)*(time_level);
    first_pos_sensor=(sensor_dim(1)-1)*(frequency_level*time_level);
else if rank_frequency ~= 0 &  rank_sensor > rank_frequency & rank_sensor ~= 0
        first_pos_sensor=(sensor_dim(1)-1)*(time_level);
        first_pos_frequency=(frequency_dim(1)-1)*(sensor_level*time_level);
    else if rank_frequency == 0
            first_pos_sensor=(sensor_dim(1)-1)*(time_level);
        else if rank_sensor == 0
                first_pos_frequency=(frequency_dim(1)-1)*(time_level);
            end
        end
    end
end
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  first_pos_sensor=Get_First_Pos_Sensor(sensor_dim, time_level)
if isempty(time_level)
    time_level=1;
end
first_pos_sensor=(sensor_dim(1)-1)*(time_level);
return
