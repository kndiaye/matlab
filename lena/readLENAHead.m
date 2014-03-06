function [Header lena_tree] = fastReadLENAHead(lena_file,dim_to_read)

%   This function reads a lena format file.
%
% Parameters :
%  Input :
%    - lena_file ( String ) : name of LENA file, or lenaTree object if
%                             file as already been read
%  Optional
%      - dim_to_read ( cell ) : sample to read indices for each dimension
%  
%   
%
%  Output :
%    - Header : a structure containing the header information that can be
%    manipulated by the user: Only the dimensions specified inside
%    dim_to_read parameter will be found in the Header structure. If dim_to_read is
%    not used, all the dimensions will be found in Header structure
%  
% Usage :
%   H=fastReadLENA('/path/to/file/test.lena');
%       will return a matrix containing all data
%
%   H=fastReadLENA('/path/to/file/test.lena',{ 2 , [ ] , [5:12] });
%       will return a matrix containing data for :
%           - 2nd element in first dimension
%           - all elements in second dimension
%           - elements 5 to 12 in third dimension
%
% CNRS LENA UPR 640

% Check argument number :
 if nargin <3
   smart = 1;
 end

level=[];

% First check lena_file argument, and read the header :

if strcmp(class(lena_file),'xmltree')
  lena_tree = lena_file;
  lena_file = getfilename(lena_tree);
elseif exist(lena_file)==2
  lena_tree = lenaTree( lena_file );
else
    error(lena_file,'Provided file name doesn t seem to exist, or is not a valid object')
    return
end

% Get the header location :
[lena_path,lena_name]=fileparts(lena_file);


% Check present dimensions :

 
history=getHistory(lena_tree);



    
dimensions_names = getDimensions_names(lena_tree);
if iscell(dimensions_names)
length_dimensions_names=length(dimensions_names);
else if ischar(dimensions_names)
        length_dimensions_names=1;
    else if isempty(dimensions_names)
            length_dimensions_names=0;
        end
    end 
end



if iscell(dimensions_names)
for i=1:length_dimensions_names
    if strcmp(dimensions_names{i},'frequency_range')
        frequency_dim=i;
    elseif strcmp(dimensions_names{i},'sensor_range')
        sensor_dim=i;
    elseif strcmp(dimensions_names{i},'time_range')
        time_dim=i;
    elseif strcmp(dimensions_names{i},'datablock_range')
        datablock_dim=i;
    else
        error(strcat('Found unexpected dimension : ',dimensions_names{i}))
    end
end

else if ischar(dimensions_names)
        if strcmp(dimensions_names,'frequency_range')
            frequency_dim=1;
        elseif strcmp(dimensions_names,'sensor_range')
            sensor_dim=1;
        elseif strcmp(dimensions_names,'time_range')
            time_dim=1;
        elseif strcmp(dimensions_names,'datablock_range')
            datablock_dim=1;
        else
        error(strcat('Found unexpected dimension : ',dimensions_names{i}))
        end
    else
% to do
    end
        
end 

% If no dimension to read is provided, read all :
if nargin == 1
    for i = 1:length_dimensions_names
        dim_to_read{i}='';
    end
else  
       if length( dim_to_read) <length_dimensions_names
           for i = length( dim_to_read)+1:length_dimensions_names
               dim_to_read{i}='';
           end
           
    end
end


% Get data file :
data_filename = getData_filename(lena_tree,lena_file);
if exist(data_filename)~=2
    error('Can t find data file, provided file name seems to not exist: %s',data_filename);
    return
end
Header.data_filename = data_filename ;

% Check data_format and open data file
data_format = getData_format(lena_tree);
if strcmp(data_format,'LittleEndian')
    data_fid = fopen(data_filename,'r','l');
elseif strcmp(data_format,'BigEndian')
    data_fid = fopen(data_filename,'r','b');
else
    warning('No data_format provided');
    data_fid = fopen(data_filename,'r');
end

% Read the offset :
data_offset = getData_offset(lena_tree);

fread(data_fid,data_offset);

% get data type :
data_type = getData_type(lena_tree);
switch(data_type)
    case 'unsigned fixed'
        data_type='uint';
    case 'fixed'
        data_type='int';
    case 'floating'
        data_type='float';
   
    %case 'float32'
     %   data_type='float';
        
    otherwise
        error('Error : data_type wasn t found, which is required.')
        return
end
% Get the data size :
data_size = getData_size(lena_tree);
%data_type=strcat(data_type,num2str(8*data_size));




if exist('sensor_dim')
   % sensor_sample_number = getSensors_number(lena_tree);
    %level(sensor_dim)=sensor_sample_number;
[leveldim, sensorList, sensorSample] =ProcessSensorDim(lena_tree, sensor_dim,dimensions_names, dim_to_read);
level(sensor_dim)=leveldim;

    Header.sensors=sensorList;
 
    Header.sensorSamples= sensorSample;
 


end

if exist('time_dim')

    
    [leveldim, time_pretrigger,sample_rate, time_samples] =ProcessTimeDim(lena_tree, time_dim,dimensions_names, dim_to_read);
    level(time_dim)=leveldim;
    
    
 
    Header.timeSamples=time_samples;
   
    
   
    Header.sampleRate=sample_rate;
   
    
   
    Header.preTrigger=time_pretrigger;
    
    
    
end

if exist('frequency_dim')
    frequency_sample_number = getFrequency_sample_number(lena_tree);
    level(frequency_dim)=frequency_sample_number;
    frequencies = getFrequencies(lena_tree);
    frequencysamples=getSuperfrequency_list(lena_tree);
    
    dim=(dim_to_read{frequency_dim});
    if  ~ isempty(dim)
        frequencies=frequencies(dim(1):dim(end));
        frequencysamples=frequencysamples(dim(1):dim(end));
    end
    
     
    %if exist('frequencies')
    Header.frequencies=frequencies;
    %end

    %if exist('frequencysamples')
    Header.frequencysamples=reshape(frequencysamples, 1,length(frequencysamples));
    %end

    
end

if exist('datablock_dim')
    datablock_samples_number = getDatablock_samples_number(lena_tree);
    level(datablock_dim)=datablock_samples_number;
    datablocks = getDatablocks(lena_tree);
    
    dim=(dim_to_read{datablock_dim});
    if  ~ isempty(dim)
        datablocks=datablocks(dim(1):dim(end));
           end
    
    
    Header.datablocks=datablocks;
end
 

% get the parameters


   
%     for i=1: sensor_sample_number
%     list_sensor_name{i} =  getSensor_name(lena_tree,i);
% 
%     end
% 
% if (~ isempty(list_sensor_name))
%        
%         for i=1:length(list_sensor_name)
%             sensor_categories{i} = getSensor_category(lena_tree,list_sensor_name{i} ); 
%              sensor_coils{i}=    getSensor_coil_geometry(lena_tree,list_sensor_name{i} );
%         end 
%   end
%  
%   sensorList.name=list_sensor_name;
%  sensorList.category=sensor_categories;
%  sensorList.coils=sensor_coils;
% 
%  time_pretrigger=getPre_trigger(lena_tree);
%  Supersensor_list = getSupersensor_list(lena_tree); 
% 
%  sensorSample=select_sensors_in(list_sensor_name, lena_tree);
% 
    
    Header.data_format=data_format;
    Header.data_type=data_type;
    Header.data_size=data_size;
    Header.dimensions_names=dimensions_names;
    
    if ~isempty(history)
        Header.history=history;
    end
    
    
    
%     if exist('frequencies')
%     Header.frequencies=frequencies;
%     end
% 
%     if exist('frequencysamples')
%     Header.frequencysamples=frequencysamples;
%     end
% 
%     
%     if exist('time_samples')
%     Header.timeSamples=time_samples;
%     end
%     
%     if exist('sample_rate')
%     Header.sampleRate=sample_rate;
%     end
%     
%     if exist('time_pretrigger')
%     Header.preTrigger=time_pretrigger;
%     end
%     
    

% Check which dimensions are provided and which are empty in dim_to_read :






if ~ exist('dim_to_read');
 
dim_to_read='';
end

for i = 1:length(dim_to_read)
    if isempty(dim_to_read{i})
        dim_to_read{i}=1:level(i);
    % Specific traitement for time_range
    elseif exist('time_dim')
        if dim_to_read{i} == time_dim
            if length(dim_to_read{i})==2
            % Compute total time samples :
            linspace(getPre_trigger(lenaTree) ,...
                getPre_trigger(lenaTree)+(getTime_samples(lena_tree)/getSample_rate(lena_tree)),...
                getTime_samples(lena_tree));
            % Search wished time samples :
            dim_to_read{i}=find(Time>dim_to_read{i}(1)&Time<dim_to_read{i}(2));
        end
        end
    end
end


if nargin<2
    samples_to_read=[1,0];
    for i=1:length(dim_to_read)
        
        samples_to_read(1)=samples_to_read(1)*length(dim_to_read{i});
    end
else
 %   samples_to_read = getBlocktoread(fliplr(dim_to_read),fliplr(level));
    end

% Extract datas :
%samples = extractBINblocksRevised(data_fid,dim_to_read,level,data_type,data_size);

%samples = extractBINblocksRevised4SensorsBis(data_fid,dim_to_read,dimensions_names,level,data_type,data_size);


if exist ('dim_to_read') & ~ isempty(dim_to_read)
for k=1:length(dim_to_read)
    size_to_read(k)=length(dim_to_read{k});
end
else size_to_read=[];
end


% if (length(size_to_read)>1)
% F=convertBlocs2matrix(samples, size_to_read);
% else F=cell2mat (samples);
% end

fclose (data_fid);
% Search Supersensor scales to apply :

% if exist('sensor_dim')
% coef = getSupersensor_scale(lena_tree,dim_to_read{sensor_dim});
% % Apply gains :
% if sensor_dim==1
%     size_to_read(sensor_dim)=1;
%     coef_mat = repmat(coef',size_to_read);
% else
%     s_t_r_temp=[1,size_to_read(1:sensor_dim-1),size_to_read(sensor_dim+1:end)];
%     test=repmat(coef',s_t_r_temp);
%     coef_mat=permute(test,[2:sensor_dim,1,sensor_dim+1:length(size_to_read)]);
% end
% 
% if (length(size_to_read)>1)
% F=coef_mat.*F;
% else  F=coef.*F;
% end
% end
%if smart
 %   F=squeeze(F);
%end

return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [leveldim, sensorList, sensorSample]=ProcessSensorDim(lena_tree, sensor_dim,dimensions_names, dim_to_read)

     
sensors_number = getSensors_number(lena_tree);
   
    
    
     Supersensors_number = getSensor_sample_number(lena_tree);
    leveldim=Supersensors_number;
    
    
    for i=1: sensors_number
    list_sensor_name{i} =  getSensor_name(lena_tree,i);
    end
    
    
     for i=1: Supersensors_number
%     list_Supersensor_name{i} =  getSupersensor_name(lena_tree,i);
coef{i} = getSupersensor_scale(lena_tree,i);

     end
    
    
list_Supersensor_name=    getSupersensor_list(lena_tree);

s=[];
 dim=(dim_to_read{sensor_dim});
    if  ~ isempty(dim)
        s_list= list_sensor_name(dim(1):dim(end));
        
        
        
      for i=1:length(s_list) 
%            s(i)= rank_sensor(a_listsensor, sensorList(i));
             s1= rank_sensor(list_Supersensor_name, s_list(i));
            s=[s s1];

        end
        
    else
         
            s= [1:length(list_Supersensor_name)];
        
        
    end
             
     




if (~ isempty(list_sensor_name))
       
        for i=1:length(list_sensor_name)
            sensor_categories{i} = getSensor_category(lena_tree,list_sensor_name{i} ); 
             sensor_coils{i}=    getSensor_coil_geometry(lena_tree,list_sensor_name{i} );
        end  
  end
 
 sensorList.name=list_sensor_name;
 sensorList.category=sensor_categories;
 sensorList.coils=sensor_coils;

 %sensorSample=select_sensors_in(list_sensor_name, lena_tree);

 sensorSample=Supersensors_in(s, list_Supersensor_name );
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sample_sensors=Supersensors_in(sel_sensor, Supersensor_list )

dim=size(Supersensor_list,2);
res=1;
if dim >1
    
        for i=1: length(sel_sensor)
         for i1=1:dim
             rank=sel_sensor(i);
         Superlist_sensors{i,i1}=Supersensor_list{rank,i1};
         end
        Superlist_unit{i,:}='unknown unit'; %getSupersensor_unit(lenafile,i);
        Superlist_scale{i,:}=1;%getSupersensor_scale(lenafile,i);
        %res=res+1;
    end
    
else  
    
    
%        
      for i=1: length(sel_sensor)
             rank=sel_sensor(i);
         Superlist_sensors{i,:}=(Supersensor_list{rank,:});
                Superlist_unit{i,:}=''; %getSupersensor_unit(lenafile,i);
        Superlist_scale{i,:}=1;%getSupersensor_scale(lenafile,i);
        %res=res+1;
    end
    
end

if exist('Superlist_sensors')
dim=size(Superlist_sensors,2);
dim1=size(Superlist_sensors,1);
if dim>1
sample_sensors.list_sensors=reshape (Superlist_sensors,dim1,dim);

 
else
sample_sensors.list_sensors=reshape (Superlist_sensors,length(Superlist_sensors),1);
end
sample_sensors.unit=reshape (Superlist_unit,length(Superlist_unit),1);
sample_sensors.scale=reshape (Superlist_scale,length(Superlist_scale),1);
end

end
      


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [leveldim, time_pretrigger,sample_rate, timesamples_toread]=ProcessTimeDim(lena_tree, time_dim,dimensions_names, dim_to_read)


time_samples = getTime_samples(lena_tree);
    sample_rate=getSample_rate(lena_tree);
    leveldim=time_samples;
    time_pretrigger=getPre_trigger(lena_tree);
    
    
    if iscell(dimensions_names)
        
    for i=1: length( dimensions_names)
        if strcmp(dimensions_names{i}, 'time_range')
            if isempty(cell2mat(dim_to_read(i)))
                timesamples_toread=time_samples;
            else
            timesamples_toread=cell2mat(dim_to_read(i));
            
            end
            break;
        end
    end
    else if strcmp(dimensions_names,'time_range')
            if isempty(cell2mat(dim_to_read(1)))
                timesamples_toread=time_samples;
            else
            timesamples_toread=cell2mat(dim_to_read(1));
            
            end
        end
    end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function        s= rank_sensor(a_listsensor, sensor)

found=false;
s=-1;
i=1;
k=1;
while (i< length(a_listsensor)) & ~found
    tab=((strmatch(char(sensor),char(a_listsensor{i,:}))));
      if ~isempty(tab)
    %    found =true;
        s(k)= i;
        k=k+1;
     
    end
    i=i+1;
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
