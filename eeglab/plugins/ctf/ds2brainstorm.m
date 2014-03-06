function [F,Channel,imegsens,ieegsens,iothersens,irefsens,grad_order_no,no_trials,filter,Time, RunTitle] = ds2brainstorm(ds_directory,VERBOSE,READRES,CHANNELS,TIME, NO_TRIALS);
%DS2BRAINSTORM
% [F,Channel,imegsens,ieegsens,iothersens,irefsens,grad_order_no,no_trials,filter,Time, RunTitle] 
%                      ... = ds2brainstorm(ds_directory,VERBOSE,READRES,CHANNELS,TIME, NO_TRIALS);
% Reads CTF Systems Inc. Data and Resource file formats (4.1 MEG Data Format)
%
% This ALPHA version is optimized for small data sets only (e.g. averaged-trials data)
%
% INPUTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DS_DIRECTORY: full path to the .ds directory containing the orginal data set
%
% VERBOSE = 1 : Toggle VERBOSE mode ON
%               -> Activate screen display
%               -> Save channel information in channel_file.txt
%               -> Save coefficient information in coef_file.txt
%
% VERBOSE = 0 : Toggle VERBOSE mode OFF
%
%---> The rest of the input parameters are optionnal (more specific to data block extraction) 
%
% READRES = 1: Read the original .res4 file and writes out a file called **_res4.mat in the .ds folder, which is a shortened version of the CTF resources file
% READRES = 0: Do not read the original .res4 file assuming it has been read previously. Read the **_res4.mat instead 
% Set READRES to 0 when you want to extract another block of data after you have already read one block with READRES = 1.
%
% If READRES is left blank, the whole data are read - ATTENTION when data set is large - possible 'out of memory' issues
%
% If the optional fields below are left blank, ds2brainstorm only reads the res4 file and generates a *_res4.mat file in the current .ds folder 
% with all useful information regarding EEG, MEG channels etc. for subsequent data extraction.
%
% CHANNELS: the indices of the channels to be extracted as in IEEGSENS, IMEGSENS or IREFSENS
% If you don't know what are the indices of these channels, run ds2brainstorm with READRES = 1 first.
%
% TIME: the time window to be extracted in seconds within a trial; ie a subset of Time, a vector saved in **_res4.mat (see above)
%
% NO_TRIALS: a vector containing the number(s) of the trial(s) to be extracted.
%
%  Example; ds2brainstorm('tipouic.ds',1,0,[10:30],[-.5 3],2)
% .. extracts in VERBOSE mode from tipouic.ds, assuming tipouic_res4.mat was already created during a previous call to ds2brainstorm with READRES = 1
% channels 10 to 30 (could be MEG or other -> check IEEGSENS and IMEGSENS first), between -0.5sec and 3sec, in trial 2. 
% 
% %     
% OUTPUTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% CHANNEL - MEG,EEG, REFERENCE and OTHER channel information 
% CHANNEL is a cell array of structures following the BrainStorm data format.
% F - Data Matrix: One sensor per row; one time sample per column
% IMEGSENS - Indices of the MEG data rows in F
% IEEGSENS - Indices of the EEG data rows in F 
% IOTHERSENS - Indices of the OTHER data rows (not including reference coils) in F
% IREFSENS - Indices of the REFERENCE data rows in F
% GRAD_ORDER_NO - Order of the gradient correction to be taken into account in the forward model only
% NO_TRIALS - Number of trials in the .ds folder.
% FILTER - An array of structures; each structure containing information related to each filter
% TIME - A vector containing the time instants at every data sample
% RUNTITLE - A character array labelling the current run.
% 
% Please refer to CTF Systems Inc. Technical Note #1 for details on DataSet file formats

%-- Sylvain Baillet, Ph.D. / Denis Swchartz, Ph.D.
% Cognitive Neuroscience & Brain Imaging Laboratory - CNRS - Paris France
% MEG Center - Hopital de la Salpetriere - Paris - France.

%-- $RCSfile: ds2brainstorm.m,v $ -- $Revision: 7 $ -- $Date: 11/28/01 8:20a $
%-- Signal and Image Processing Institute
%-- University of Southern Califonia
%-- Los Angeles - USA
%-> with contributions from Line Garnero, Ph.D. and Antoine Ducorps
%     MEG Center 
%     &
%     Cognitive Neuroscience & Brain Imaging Laboratory - CNRS
%     La Salpetriere Hospital, Paris, France

% 14/08/03 - KND (kari n'diaye): Updated to include Virtual Channeln, lines 486-544
% 11/28/00 - SB: Updated to read the 3rd-roder gradient information
% 03/09/01 - SB: Data block extraction
% 15/11/01 - SB: Extraction of the ADC Input channels in iothersens, combined with the STIM channel
% 19/11/01 - SB: Save iothersens indices in the _res4.mat file
%*********************************************
%
% Check input arguments
%

if nargin == 2
    READRES = 1;
elseif nargin==5 % No Marker file and marker range are defined
    MARKER_FILE = 0;
    MARKER_RANGE = [];
elseif nargin==3    
    MARKER_FILE = 0;
    MARKER_RANGE = [];
    CHANNELS = [];
    TIME = [];
    NO_TRIALS = []; 
elseif nargin==1
    VERBOSE=0;
    READRES = 1;
    MARKER_FILE = 0;
    MARKER_RANGE = [];
    CHANNELS = [];
    TIME = [];
    NO_TRIALS = []; 
end

%% Checking files
current_dir=cd;
cd(ds_directory)
[path,rootname] = fileparts(ds_directory);
meg4file = [rootname,'.meg4'];
rec4file = [rootname,'.res4'];
res4_mat = [rootname,'_res4.mat'];

if ~exist(rec4file,'file') | ~exist(meg4file,'file') 
    errordlg([rec4file ' or ' meg4file ' missing'])
    return
end

if ~exist(res4_mat,'file') 
    % Force the reading the original .res4 file but skip the reading of the file
    READRES = 2;
end

if VERBOSE
    disp(['Working in...',ds_directory ])
    drawnow
end


%*********************************************    

if READRES == 1 | READRES == 2 % Read the .res4 file     
    
    %% Define constants
    MAX_COILS = 8;
    MAX_BALANCING = 50;
    SENSOR_LABEL = 31;
    MAX_AVERAGE_BINS = 8;
    
    %***** nfSetUp **** Data Structure
    gSetUp = struct('no_samples',[],'no_channels',[],'sample_rate',[],...
        'epoch_time',[],'no_trials',[],'preTrigPts',[],'no_trials_done',[],'no_trials_display',[],...
        'save_trials',[],'primaryTrigger',[],'secondaryTrigger',[],'triggerPolarityMask',[],...
        'trigger_mode',[],'accept_reject_Flag',[],'run_time_display',[],'zero_Head_Flag',[],...
        'artifact_mode',[]);
    
    nfSetUp = struct('nf_run_name','','nf_run_title','','nf_instruments','','nf_collectdescriptor','',...
        'nf_subject_id','','nf_operator','','nf_sensorFileName','');
    
    GenRes4 = struct('appName','','dataOrigin','','dataDescription','',...
        'no_trials_avgd',[],'data_time',[],'data_date',[],'gSetUp',gSetUp,'nfSetUp',nfSetUp,'rdlen',[]);
    
    %*********************************************
    
    
    %% Reading Resources------------------------------------------------------------------------
    [rec,message] = fopen(rec4file,'rb','s'); % Big-endian byte ordering
    if rec < 0
        errordlg(message)
        return
    end
    
    % Read HEADER
    header = fread(rec,8,'char')';
    if VERBOSE
        disp([char(header), ' file format'])
        drawnow
    end
    
    
    % Read nfSetUp
    GenRes4.appName = char(fread(rec,256,'char')');
    GenRes4.dataOrigin = char(fread(rec,256,'char')');
    GenRes4.dataDescription = char(fread(rec,256,'char')');
    
    GenRes4.no_trials_avgd = (fread(rec,1,'int16')');
    GenRes4.data_time = char(fread(rec,255,'char')');
    GenRes4.data_date = char(fread(rec,255,'char')');
    
    gSetUp.no_samples = (fread(rec,1,'int32')');
    gSetUp.no_channels = (fread(rec,1,'int16')');
    
    fseek(rec,ceil(ftell(rec)/8)*8,-1);
    gSetUp.sample_rate = (fread(rec,1,'double')');
    fseek(rec,ceil(ftell(rec)/8)*8,-1);
    gSetUp.epoch_time = (fread(rec,1,'double')');
    gSetUp.no_trials =  (fread(rec,1,'int16')');
    fseek(rec,ceil(ftell(rec)/4)*4,-1);
    gSetUp.preTrigPts =  (fread(rec,1,'int32')');
    gSetUp.no_trials_done = (fread(rec,1,'int16')');
    gSetUp.no_trials_display = (fread(rec,1,'int16')');
    fseek(rec,ceil(ftell(rec)/4)*4,-1);
    gSetUp.save_trials = (fread(rec,1,'int32')');
    gSetUp.primaryTrigger = char(fread(rec,1,'uchar')');
    gSetUp.secondaryTrigger = char(fread(rec,MAX_AVERAGE_BINS,'uchar')');
    gSetUp.triggerPolarityMask = char(fread(rec,1,'uchar')');
    
    gSetUp.trigger_mode = (fread(rec,1,'int16')');
    fseek(rec,ceil(ftell(rec)/4)*4,-1);
    gSetUp.accept_reject_Flag = (fread(rec,1,'int32')');
    gSetUp.run_time_display = (fread(rec,1,'int16')');
    fseek(rec,ceil(ftell(rec)/4)*4,-1);
    gSetUp.zero_Head_Flag = (fread(rec,1,'int32')');
    fseek(rec,ceil(ftell(rec)/4)*4,-1);
    gSetUp.artifact_mode = (fread(rec,1,'int32')');
    gSetUp.padding = (fread(rec,1,'int32')');
    
    
    nfSetUp.nf_run_name = char(fread(rec,32,'char')');
    nfSetUp.nf_run_title = char(fread(rec,256,'char')');
    
    RunTitle = nfSetUp.nf_run_title ;
    
    nfSetUp.nf_instruments = char(fread(rec,32,'char')');
    nfSetUp.nf_collect_descriptor = char(fread(rec,32,'char')');
    nfSetUp.nf_subject_id = char(fread(rec,32,'char')');
    nfSetUp.nf_operator = char(fread(rec,32,'char')');
    % DBG: The following line generates a warning 
    warnstate=warning;
    warning off
    nfSetUp.nf_sensorFileName = char(fread(rec,60,'char')'); 
    warning(warnstate)
    clear warnstate
    
    fseek(rec,ceil(ftell(rec)/4)*4,-1);
    nfSetUp.rdlen = fread(rec,1,'int32')';
    
    GenRes4.gSetUp = gSetUp;
    GenRes4.nfSetUp = nfSetUp;
    
    %----------------------------------------------------------------------------------------
    
    if VERBOSE
        fprintf('----------------------------------- Header information ---------------------------\n')
        fprintf('Collected %s starting at %s\n', GenRes4.data_date, GenRes4.data_time)
        fprintf('Run Name: %s\n', nfSetUp.nf_run_name)
        fprintf('Run Titl: %s\n', nfSetUp.nf_run_title)
        fprintf('Col Desc: %s\n', nfSetUp.nf_collect_descriptor)
        fprintf('Run Desc: %s\n', GenRes4.dataDescription)
        fprintf('Operator: %s\n', nfSetUp.nf_operator)
        fprintf('Subject : %s\n', nfSetUp.nf_subject_id)
        fprintf('Channels: %d\n',gSetUp.no_channels)
        fprintf('Samples : %d per trial\n', gSetUp.no_samples)
        fprintf('Rate    : %g samples/sec\n', gSetUp.sample_rate)
        fprintf('Trials  : %d (average of %d)\n', gSetUp.no_trials, GenRes4.no_trials_avgd)
        fprintf('Duration: %g seconds/trial\n', gSetUp.epoch_time/gSetUp.no_trials)
        fprintf('Pre-trig: %g samples\n', gSetUp.preTrigPts)
        fprintf('Sensor file name : %s\n', nfSetUp.nf_sensorFileName)
        ON_OFF = {'Off','On'};
        fprintf('Head zeroing: %s\n', ON_OFF{gSetUp.zero_Head_Flag+1})
        fprintf('----------------------------------- End Header information -----------------------\n')
    end
    
    
    %-------------------------------------------------------------------------------
    
    %----------------------------------READ FILTERS---------------------------------
    
    fseek(rec,1844,-1);
    
    % Run Description
    rundescript = char(fread(rec,nfSetUp.rdlen,'char'));
    if VERBOSE
        fprintf('\nRun Description: %s\n', rundescript );  
        drawnow
    end
    
    classType = {'CLASSERROR','BUTTERWORTH'};
    filtType = {'TYPERROR','LOWPASS','HIGHPASS','NOTCH'};
    
    
    % Number of filters
    no_filters = fread(rec,1,'int16');
    if VERBOSE
        fprintf('\n----------------------------------- Filter information ---------------------------\n')
        fprintf('Number of filters: %d\n', no_filters)
        drawnow
    end
    
    % JCM fixes 10/26/00, each of these should be looped through, not read in bulk
    % old
    if(0)
        filter.freq = fread(rec,no_filters,'double');
        filter.fClass = classType{fread(rec,no_filters,'int32')+1};
        filter.fType = filtType{fread(rec,no_filters,'int32')+1};
        filter.numParam = fread(rec,no_filters,'int16');
        
        filter.params = [];
        for fi = 1:no_filters
            for p = 1: filter(fi).numParam 
                filter(fi).params= fread(rec,filter(fi).numParam,'double');
            end
        end
    else % new
        [filter(1:no_filters)] = struct('freq',[],'fClass',[],'fType',[],'numParam',[],'params',[]);
        for fi = 1:no_filters,
            filter(fi).freq = fread(rec,1,'double');
            filter(fi).fClass = classType{fread(rec,1,'int32')+1};
            filter(fi).fType = filtType{fread(rec,1,'int32')+1};
            filter(fi).numParam = fread(rec,1,'int16');
            filter(fi).params= fread(rec,filter(fi).numParam,'double');
        end
    end
    
    if VERBOSE
        for fi = 1:no_filters
            fprintf('Filter - %d\n',fi)
            fprintf('->Frequency: \t%g\n',filter(fi).freq)
            fprintf('->Class: \t%s\n',filter(fi).fClass)
            fprintf('->Type: \t%s\n',filter(fi).fType)
            fprintf('->Number of parameters: \t%d\n',filter(fi).numParam)
            if ~isempty(filter(fi).params)
                fprintf('->Parameter Value(s): \t%g\n',filter(fi).params)
            end
        end 
        
        fprintf('\n------------------------------- End Filter Information ---------------------------\n')
        
        fprintf('\n------------------------------- Reading Channel Information.....------------------------------\n')
        drawnow 
    end
    
    % Channel Names
    for chan = 1:gSetUp.no_channels 
        channel_name{chan} = fread(rec,32,'char')'; 
        tmp = channel_name{chan};
        tmp(tmp>127) = 0; 
        tmp(tmp<0) = 0;
        channel_name{chan} = char(strtok(tmp,char(0)));
    end
    
    % Sensor Resources
    CoilType = {'CIRCULAR','SQUARE','???'};
    
    for chan = 1:gSetUp.no_channels 
        oldtell = ftell(rec);
        SensorRes(chan).sensorTypeIndex = fread(rec,1,'int16');
        SensorRes(chan).originalRunNum = fread(rec,1,'int16');
        
        id = fread(rec,1,'int32')+1;
        
        if isempty(id)
            id = -1;
        end
        
        if id > 3 | id <0 
            id = 3;
        end
        
        SensorRes(chan).coilShape = CoilType{id};
        
        SensorRes(chan).properGain = fread(rec,1,'double');
        SensorRes(chan).qGain = fread(rec,1,'double');
        SensorRes(chan).ioGain= fread(rec,1,'double');
        SensorRes(chan).ioOffset = fread(rec,1,'double');
        SensorRes(chan).numCoils = fread(rec,1,'int16');
        SensorRes(chan).grad_order_no = fread(rec,1,'int16');
        
        padding = fread(rec,1,'int32'); 
        
        for coil = 1:MAX_COILS
            SensorRes(chan).coilTbl(coil).position.x = fread(rec,1,'double');
            SensorRes(chan).coilTbl(coil).position.y = fread(rec,1,'double');
            SensorRes(chan).coilTbl(coil).position.z = fread(rec,1,'double');
            SensorRes(chan).coilTbl(coil).position.junk = fread(rec,1,'double');
            SensorRes(chan).coilTbl(coil).orient.x = fread(rec,1,'double');
            SensorRes(chan).coilTbl(coil).orient.y = fread(rec,1,'double');
            SensorRes(chan).coilTbl(coil).orient.z = fread(rec,1,'double');
            SensorRes(chan).coilTbl(coil).orient.junk = fread(rec,1,'double');
            SensorRes(chan).coilTbl(coil).numturns = fread(rec,1,'int16');
            padding = fread(rec,1,'int32');
            padding = fread(rec,1,'int16');
            SensorRes(chan).coilTbl(coil).area = fread(rec,1,'double');
        end
        
        for coil = 1:MAX_COILS
            SensorRes(chan).HdcoilTbl(coil).position.x = fread(rec,1,'double');
            SensorRes(chan).HdcoilTbl(coil).position.y = fread(rec,1,'double');
            SensorRes(chan).HdcoilTbl(coil).position.z = fread(rec,1,'double');
            SensorRes(chan).HdcoilTbl(coil).position.junk = fread(rec,1,'double');
            SensorRes(chan).HdcoilTbl(coil).orient.x = fread(rec,1,'double');
            SensorRes(chan).HdcoilTbl(coil).orient.y = fread(rec,1,'double');
            SensorRes(chan).HdcoilTbl(coil).orient.z = fread(rec,1,'double');
            SensorRes(chan).HdcoilTbl(coil).orient.junk = fread(rec,1,'double');
            SensorRes(chan).HdcoilTbl(coil).numturns = fread(rec,1,'int16');
            padding = fread(rec,1,'int32'); 
            padding = fread(rec,1,'int16'); 
            SensorRes(chan).HdcoilTbl(coil).area = fread(rec,1,'double');
        end
        
    end
    
    if VERBOSE
        SensorNames ={'Ref Magnetometer','Ref Gradiometer' ,''  , '' , '' ,'MEG Sensor','' , '', '','EEG Sensor','ADC Input','Stimulation input',''}; % CHEAT - added the 13th '' ofor testing purposes
        % SensorNames ={'Ref Magnetometer','Ref Gradiometer' ,''  , '' , '' ,'MEG Sensor','' , '', '','EEG Sensor','ADC Input','Stimulation input'); %OLD VERSION
        
        [channel_file, message] = fopen('channel_file.txt','wt+');
        if channel_file < 0
            errordlg(['Aborted - You need to the permission to write in ',ds_directory]);
            return
        end
        for chan = 1:gSetUp.no_channels
            fprintf(channel_file,'%s: sensor type Index %d (%s), %d coil(s), shape %s,Gains: proper %g q %g io %g, offset %g, gradient order %d\n',...
                channel_name{chan}, SensorRes(chan).sensorTypeIndex, SensorNames{SensorRes(chan).sensorTypeIndex+1}, SensorRes(chan).numCoils, SensorRes(chan).coilShape,...
                SensorRes(chan).properGain , SensorRes(chan).qGain ,  SensorRes(chan).ioGain, SensorRes(chan).ioOffset,SensorRes(chan).grad_order_no ) ;
            
            if SensorRes(chan).numCoils > 0
                fprintf(channel_file,'Dw:');
                PrintCoilPos(channel_file,SensorRes(chan).coilTbl, SensorRes(chan).numCoils );
                fprintf(channel_file,'Hd:');
                PrintCoilPos(channel_file,SensorRes(chan).HdcoilTbl, SensorRes(chan).numCoils );
            end
        end
        
        fprintf('Channel Information written to channel_file.txt\n');
        
        fprintf('\n------------------------------- End Channel Information --------------------------\n')
    end
    
    disp('-------------------Converting Channel Information.....----------------------------')     
    
    
    nchan= length(channel_name); % Number of channels
    
    % Explode data according to channel type
    SensorNames ={'Ref Magnetometer','Ref Gradiometer' ,''  , '' , '' ,'MEG Sensor','' , '', '','EEG Sensor','ADC Input','Stimulation input'};
    imegsens = find([SensorRes.sensorTypeIndex] == 5); % Indices of MEG sensors
    ieegsens = find([SensorRes.sensorTypeIndex] == 9); % Indices of EEG sensors
    iothersens = [find([SensorRes.sensorTypeIndex] == 11),find([SensorRes.sensorTypeIndex] == 10)]; % Indices of OTHER sensors ('Stimulation input' and 'ADC')
    irefsens = find([SensorRes.sensorTypeIndex] == 0); % Reference Channels
    irefsens = [irefsens,find([SensorRes.sensorTypeIndex] == 1)]; % Reference Channels
    
    
    ieeg = 0; imeg = 0; 
    iother = 0; 
    iother2 = 0; 
    eegID = [];
    otherID = [];
    other2ID = [];
    megID = [];
    
    iref = 0;
    refID = [];
    
    chaneeg = [];% Index of EEG channels 
    chanmeg = [];chanother = [];
    SensorNames ={'Ref Magnetometer','Ref Gradiometer' ,''  , '' , '' ,'MEG Sensor','' , '', '','EEG Sensor','ADC Input','Stimulation input',''}; % Added a 13th channel type, don't know why
    
    [Channel(1:nchan)] = deal(struct('Loc',[],'Orient',[],'Comment',[],'Weight',[],'Type',[],'RefChannel',[],'Gcoef',[],'Name',''));
    
    for chan = 1:nchan
        switch SensorRes(chan).sensorTypeIndex
        case {0,1} %'References coils   
            iref = iref+1;
            MAX_COILS = 2; % Take only into account the 2 first coils for every sensor 
            tmp = [SensorRes(chan).HdcoilTbl(:).position];              
            tmpx  = [tmp(1:MAX_COILS).x]/100; % In meters
            tmpy  = [tmp(1:MAX_COILS).y]/100;
            tmpz  = [tmp(1:MAX_COILS).z]/100;
            
            Channel(chan).Loc = ...
                [tmpx;tmpy;tmpz];
            
            tmp = [SensorRes(chan).HdcoilTbl(:).orient];
            tmpx  = [tmp(1:MAX_COILS).x];
            tmpy  = [tmp(1:MAX_COILS).y];
            tmpz  = [tmp(1:MAX_COILS).z];
            
            Channel(chan).Orient = ...
                [tmpx;tmpy;tmpz];
            
            
            % Reorient along the outward pointing normal
            loc =  Channel(chan).Loc';
            ps1=sum((loc(1,:).*Channel(chan).Orient(:,1)')')';
            ps2=sum((loc(2,:).*Channel(chan).Orient(:,2)')')';
            Channel(chan).Orient(:,1) = (sign(ps1)*ones(1,3).*Channel(chan).Orient(:,1)')';
            Channel(chan).Orient(:,2) = (sign(ps2)*ones(1,3).*Channel(chan).Orient(:,2)')';
            
            Channel(chan).Comment = [SensorNames{SensorRes(chan).sensorTypeIndex+1},' ',int2str(chan)];
            Channel(chan).Type = SensorNames{SensorRes(chan).sensorTypeIndex+1} ;
            if isempty(deblank(Channel(chan).Type))
                Channel(chan).Type = 'REF';
            end
            
            chanmeg = [chanmeg,chan];
            refID(iref) = chan; 
            Channel(chan).Weight = [1 -1] ;  
            
        case 5 % MEG (including Virtual !)
            
            if SensorRes(chan).coilTbl(1).area > 0% Not a virtual one... I guess !
                
                imeg = imeg+1;
                MAX_COILS = 2; % Take only into account the 2 first coils for every sensor 
                tmp = [SensorRes(chan).HdcoilTbl(:).position];              
                tmpx  = [tmp(1:MAX_COILS).x]/100; % In meters
                tmpy  = [tmp(1:MAX_COILS).y]/100;
                tmpz  = [tmp(1:MAX_COILS).z]/100;
                
                Channel(chan).Loc = ...
                    [tmpx;tmpy;tmpz];
                
                tmp = [SensorRes(chan).HdcoilTbl(:).orient];
                tmpx  = [tmp(1:MAX_COILS).x];
                tmpy  = [tmp(1:MAX_COILS).y];
                tmpz  = [tmp(1:MAX_COILS).z];
                
                Channel(chan).Orient = ...
                    [tmpx;tmpy;tmpz];
                
                % Reorient along the outward pointing normal
                loc =  Channel(chan).Loc';
                ps1=sum((loc(1,:).*Channel(chan).Orient(:,1)')')';
                ps2=sum((loc(2,:).*Channel(chan).Orient(:,2)')')';
                Channel(chan).Orient(:,1) = (sign(ps1)*ones(1,3).*Channel(chan).Orient(:,1)')';
                Channel(chan).Orient(:,2) = (sign(ps2)*ones(1,3).*Channel(chan).Orient(:,2)')';
                
                Channel(chan).Comment = [SensorNames{SensorRes(chan).sensorTypeIndex+1},' ',int2str(chan)];
                Channel(chan).Type = 'MEG';%SensorNames{SensorRes(chan).sensorTypeIndex+1} ;
                
                chanmeg = [chanmeg,chan];
                megID(imeg) = chan; 
                Channel(chan).Weight = [1 -1] ;  
                Channel(chan).Name = char(strtok(channel_name{chan},'-'));
            else                  
                %KND : To detect Virtual ones:
                % Head Coil Position = (0,0,0)
                %   ie. SensorRes(chanNumber).HdcoilTbl(1).position.x=0
                %       SensorRes(chanNumber).HdcoilTbl(1).position.y=0
                %       SensorRes(chanNumber).HdcoilTbl(1).position.z=0
                % could also use : 
                %       SensorRes(chan).coilTbl(coil).area = 0;
                %
                % disp([num2str(chan) ' is VIRTUAL']);
                
                Channel(chan).Loc = [];
                Channel(chan).Orient = [];
                Channel(chan).Comment = [SensorNames{SensorRes(chan).sensorTypeIndex+1},' ',int2str(chan)];
                Channel(chan).Type = 'VirtualMEG';                
                Channel(chan).Weight = [] ;  
                Channel(chan).Name = char(strtok(channel_name{chan},'-'));
                iother = iother+1;
                chanother = [chanother,chan];
                otherID(iother) = chan;
                %remove it from imegsens                
                imegsens=setdiff(imegsens, chan);
            end
            
        case 9 % EEG
            ieeg = ieeg + 1;
            MAX_COILS = 2; % Take only into account the 2 first coils for every sensor 
            tmp = [SensorRes(chan).HdcoilTbl(:).position]; 
            tmpx  = [tmp(1:MAX_COILS).x]/100;% In meters
            tmpy  = [tmp(1:MAX_COILS).y]/100;
            tmpz  = [tmp(1:MAX_COILS).z]/100;
            
            Channel(chan).Loc = ...
                [tmpx;tmpy;tmpz];
            
            Channel(chan).Orient = [];
            Channel(chan).Comment = [SensorNames{SensorRes(chan).sensorTypeIndex+1},' ',int2str(chan)];
            
            Channel(chan).Type = 'EEG';%SensorNames{SensorRes(chan).sensorTypeIndex+1} ;
            Channel(chan).Comment = [SensorNames{SensorRes(chan).sensorTypeIndex+1},' ',int2str(chan)];
            Channel(chan).Weight = [];   
            Channel(chan).Name = char(strtok(channel_name{chan},'-'));%int2str(ieeg) ;  
            chaneeg = [chaneeg,chan];
            eegID(ieeg) = chan; 
            
        case 11 % STIM
            iother = iother+1;
            Channel(chan).Loc = [];
            Channel(chan).Orient = [];
            Channel(chan).Type = SensorNames{SensorRes(chan).sensorTypeIndex+1} ;
            if isempty(deblank(Channel(chan).Type ))
                Channel(chan).Type = 'STIM';
            end
            Channel(chan).Comment = [SensorNames{SensorRes(chan).sensorTypeIndex+1},' ',int2str(chan)];
            Channel(chan).Weight = [];   
            chanother = [chanother,chan];
            otherID(iother) = chan;
            
        otherwise
            % KND for MicroMed EEG dataHandled... 
            % replaced line: iother2 = iother2+1; 
            % by : 
            iother = iother+1;
            Channel(chan).Loc = [];
            Channel(chan).Orient = [];            
            Channel(chan).Type = SensorNames{SensorRes(chan).sensorTypeIndex+1} ;
            if isempty(deblank(Channel(chan).Type ))
                Channel(chan).Type = 'OTHER';
                
            end
            Channel(chan).Comment = [SensorNames{SensorRes(chan).sensorTypeIndex+1},' ',int2str(chan)];
            Channel(chan).Weight = [];   
            chanother = [chanother,chan];
            other2ID(iother) = chan;
            
        end
    end
    
    
    disp('----------------------Channel Information Updated---------------------------------')
    
    %-------------------------------------------------------------------------------
    
    %----------------------------------READ Coefficients---------------------------------
    
    % Number of coefficient records
    nrec = fread(rec,1,'int16');
    
    
    % ----------------------------- Read Coefficient Information
    
    hexadef = {'00000000','47314252','47324252','47334252','47324f49','47334f49'};
    strdef = {'NOGRAD','G1BR','G2BR','G3BR','G2OI','G3OI'};
    
    CoefInfo = cell(length(channel_name),length(strdef)-1);
    
    %SensorCoefResRec
    if VERBOSE
        h = waitbar(0,'Reading Coefficient Information...');
    end
    
    for k = 1:nrec
        SensorCoefResRec(k).sensorName = char(fread(rec,32,'char')');
        SensorCoefResRec(k).coefType = (fread(rec,1,'bit32'));
        padding = fread(rec,1,'int32');
        SensorCoefResRec(k).CoefResRec.num_of_coefs = fread(rec,1,'int16');
        
        SensorCoefResRec(k).CoefResRec.sensor_list = char(fread(rec,[SENSOR_LABEL,MAX_BALANCING],'uchar')');  
        SensorCoefResRec(k).CoefResRec.coefs_list = fread(rec,MAX_BALANCING,'double');
        
        cchannel = strmatch( deblank(SensorCoefResRec(k).sensorName),(channel_name));
        CoefType = find(hex2dec(hexadef)==(SensorCoefResRec(k).coefType));
        
        if CoefType > 0
            
            CoefInfo{cchannel,CoefType-1}.num_of_coefs =  SensorCoefResRec(k).CoefResRec.num_of_coefs;
            
            for i=1:CoefInfo{cchannel,CoefType-1}.num_of_coefs 
                CoefInfo{cchannel,CoefType-1}.sensor_list(i) = irefsens(strmatch(strtok(SensorCoefResRec(k).CoefResRec.sensor_list(i,:),char(0)),channel_name(irefsens)));   
                CoefInfo{cchannel,CoefType-1}.coefs(i) = SensorCoefResRec(k).CoefResRec.coefs_list(i);
            end
        end  
        if VERBOSE
            waitbar(k/nrec)
        end
        
    end
    
    if VERBOSE
        delete(h)
    end
    
    
    % Channel Gains
    gain_chan = zeros(size(channel_name,1),1);
    gain_chan(imegsens) = ([SensorRes(imegsens).properGain]'.*[SensorRes(imegsens).qGain]');
    gain_chan(irefsens) = ([SensorRes(irefsens).properGain]'.*[SensorRes(irefsens).qGain]');
    %  gain_chan(ieegsens) = 1./([SensorRes(ieegsens).qGain]'*1e-6);
    gain_chan(ieegsens) = 1./([SensorRes(ieegsens).qGain]');
    gain_chan(iothersens) = ([SensorRes(iothersens).qGain]'); % Don't know exactly which gain to apply here
    
    if VERBOSE
        fprintf('\n--------------------------- Coefficient Information ------------------------------\n')
        fprintf('Number of coefficient records = %d \n', nrec);
        [coef_file, message] = fopen('coef_file.txt','wt+');
        if coef_file < 0
            errordlg(message)
            return
        end
        
        fprintf(coef_file,'Number of coefficient records = %d \n', nrec);
        
        for k = 1:nrec
            coefType = dec2hex(SensorCoefResRec(k).coefType);
            coefType = strdef{hex2dec(hexadef)==hex2dec(coefType)};
            
            fprintf(coef_file,'Channel %s type %s, ',SensorCoefResRec(k).sensorName, coefType);
            
            num_of_coefs = SensorCoefResRec(k).CoefResRec.num_of_coefs;
            fprintf(coef_file,'number = %d:\n', num_of_coefs);
            if 0
                for j=1:num_of_coefs
                    fprintf(coef_file,' %s ', SensorCoefResRec(k).CoefResRec.sensor_list{j});
                    fprintf(coef_file,' %g ',SensorCoefResRec(k).CoefResRec.coefs_list(j));
                end
                fprintf(coef_file,'\n');
            end
        end
        
        fprintf('Coefficient Information saved in coef_file.txt\n')
        
        fprintf('\n----------------------- End Coefficient Information ------------------------------\n')
        
    end
    
    grad_order_no = [SensorRes(:).grad_order_no];
    
    
    if length(imegsens)
        %     Channel(imegsens(1)).grad_order_no = grad_order_no;
        %     Channel(imegsens(1)).CoefInfo = CoefInfo;
        %     Channel(imegsens(1)).gain_chan = gain_chan;
        Channel(imegsens(1)).imegsens = imegsens;
        Channel(imegsens(1)).ieegsens = imegsens;
        Channel(imegsens(1)).irefsens = irefsens;
        Channel(imegsens(1)).RefChannel = Channel; % Store all channel information in that field: facilitates the set-up for the forward computation
        
        % Calculus of the matrix for nth-order gradient correction
        % Coefficients for unused reference channels are weigthed by zeros in
        % the correction matrix.
        
        Gcoef = zeros(length(imegsens),length(min(irefsens):max(irefsens)));
        
        for k = 1:length(imegsens)
            
            % Reference coils for channel k
            if grad_order_no(imegsens(k)) == 0
                %Data is saved as RAW
                %Save 3rd order gradient sensor-list for subsequent correction if requested later by the user
                [refs] = (CoefInfo{imegsens(k),3}.sensor_list);
                Gcoef(k,refs-min(irefsens)+1) = CoefInfo{imegsens(k),3}.coefs ... 
                    .* gain_chan(refs)'/gain_chan(imegsens(k)); 
            else
                % PB with virtual channel
                [refs] = (CoefInfo{imegsens(k),grad_order_no(imegsens(k))}.sensor_list);
                %KND changed a transposition before "/"   
                Gcoef(k,refs-min(irefsens)+1) = CoefInfo{imegsens(k),grad_order_no(imegsens(k))}.coefs ... 
                    .* gain_chan(refs)/gain_chan(imegsens(k)); 
            end
            
        end
        
        Channel(imegsens(1)).Gcoef = Gcoef;
    end
    Time = linspace(-GenRes4.gSetUp.preTrigPts/GenRes4.gSetUp.sample_rate,GenRes4.gSetUp.epoch_time/GenRes4.gSetUp.no_trials-GenRes4.gSetUp.preTrigPts/GenRes4.gSetUp.sample_rate,GenRes4.gSetUp.no_samples);
    
    save_sensor_locs(Channel)
    
    if VERBOSE
        disp(['Sensor locations can be visualized with the MRI Tool by loading the file: sensor_result.mat'])
    end
    drawnow
    
    fclose('all');
    
    % Create the BrainStorm res4 file for subsequent fast access to the data file
    no_channels = length(Channel);
    gain_chan(ieegsens)=1./gain_chan(ieegsens);
    save(res4_mat,'gSetUp','meg4file','ieegsens','irefsens', 'iothersens', 'imegsens','Time','no_channels','gain_chan','channel_name','Channel','grad_order_no','filter','RunTitle');
    
    if READRES == 2
        READRES = 0; %read the res4.mat file just created and reads the data by block.
        if nargin == 2 % Read the whole thing
            CHANNELS = [imegsens,ieegsens];
            TIME = Time;
            NO_TRIALS = 1:gSetUp.no_trials;
        end
        %         [F,Channel,imegsens,ieegsens,iothersens,irefsens,grad_order_no,no_trials,filter,Time, RunTitle] = ds2brainstorm(ds_directory,VERBOSE,READRES,CHANNELS,TIME, NO_TRIALS);    
        %         
        %         return
    end
    
    
else % READRES == 0
    load(res4_mat);
    
end


%--------------------------- Readind DATA FILE ------------------------------

if VERBOSE
    fprintf('\n--------------------------- Reading Data -----------------------------------------\n')
end

if nargin <= 2 %| (nargin > 2 & READRES == 0) % Reads the whole block of data
    
    no_trials = gSetUp.no_trials;
    
    [meg,message] = fopen(meg4file,'rb','s'); % Big-endian byte ordering
    if meg < 0
        errordlg(message)
        return
    end
    
    F = cell(gSetUp.no_trials,1); % allocate space for the data array % ASSUME SINGLE TRIAL FOR THE MOMENT - ie enough memory space
    header = char(fread(meg,8,'char')');
    
    nref=length(irefsens);
    
    for trial = 1:gSetUp.no_trials
        
        if VERBOSE
            fprintf('Reading Trial %d/%d\n',trial,gSetUp.no_trials);
        end
        
        F{trial} = zeros(gSetUp.no_channels,gSetUp.no_samples);
        F{trial} = fread(meg,[gSetUp.no_samples gSetUp.no_channels],'int32')';
        
        if VERBOSE
            fprintf('-> Done %d/%d\n',trial,gSetUp.no_trials)
        end
        % IMPORTANT NOTICE : Applying Gradient Correction
        % Data are saved in a given nth-order gradient correction
        % Applying gradient correction si only needed for forward model computation
        % or if it is desired to reverse to lower-order gradient correction (see importdata.m for instance).
        
        % Apply channel gains
        % F{trial}(ieegsens,:) = diag( gain_chan(ieegsens))*F{trial}(ieegsens,:) ; %To get Microvolts
        F{trial}(ieegsens,:) = diag(1./gain_chan(ieegsens))*F{trial}(ieegsens,:) ; %To get Microvolts->already inverted when saved _res4.mat
        F{trial}(imegsens,:) = diag(1./gain_chan(imegsens))*F{trial}(imegsens,:)  ;
        F{trial}(irefsens,:) = diag(1./gain_chan(irefsens))*F{trial}(irefsens,:) ;
        F{trial}(iothersens,:) = diag(1./gain_chan(iothersens))*F{trial}(iothersens,:) ;
        
    end
    
    fclose('all');
    
    %------------------------------------------------------------------------------------------------------------------------------------
    
else % Reads sub-block of data
    
    %ds2brainstorm(ds_directory,VERBOSE,READRES,CHANNELS,TIME, NO_TRIALS);
    if nargin <= 3 % CHANNELS not defined
        CHANNELS=[1:gSetUp.no_channels];
    end
    if nargin <= 4 % TIME not defined
        TIME=[-gSetUp.preTrigPts*1/gSetUp.sample_rate (gSetUp.no_samples-gSetUp.preTrigPts)*1/gSetUp.sample_rate];
    end
    if nargin <= 5 % NO_TRIALS not defined
        no_trials = [1:gSetUp.no_trials];
    else
        no_trials = [NO_TRIALS];
    end
    
    fclose('all');
    [meg,message] = fopen(meg4file,'rb','s'); % Big-endian byte ordering
    if meg < 0
        errordlg(message)
        return
    end
    
    % no_samples = round((TIME(end)-TIME(1))*gSetUp.sample_rate) +1; % Number of time samples in a trial
    
    F = cell(length(no_trials),1); % allocate space for the data array % ASSUME SINGLE TRIAL FOR THE MOMENT - ie enough memory space
    % Adjust time range to the closest time samples;
        
        if isempty(TIME)
        return
    end
    %     [m,t1] = min(abs(TIME(1)-Time));  
    %     [m,t2] = min(abs(TIME(end)-Time));  
    %  
    %     TIME(1) = Time(t1);
    %     TIME(end) = Time(t2);
    %     
    header = char(fread(meg,8,'char')');
    
    implicit.sample_rate = 1/(Time(2) - Time(1)); % i.e. the one used in the data file given the time begin_time end period.
    % Time = (Time(1):1/implicit.sample_rate:Time(end));
    t_in = round((TIME(1)-Time(1))*implicit.sample_rate) +1; % Sample time offset since the beginning of the trial: beginning of the time window TIME
    %t_out = round((TIME(end)-Time(1))*implicit.sample_rate)+1; % Sample time offset since the beginning of the trial: end of the time window TIME
    
    no_samples = round((TIME(end)-TIME(1))*implicit.sample_rate)+1; % Number of time samples to extract
    t_out = t_in + no_samples - 1;
    
    %no_samples = t_out-t_in+1;
    
    
    diff_trials = diff(no_trials)-1; % Number of trials between each selected trials (useful when skipping a few trials)
    
    ByteSizeOfTrial= no_channels*gSetUp.no_samples*4; % Byte size of a single trial of data (Int32 coding) 
    
    samples_skip = gSetUp.no_samples-no_samples; %Number of time samples to skip per channel
    
    LastChannelSkip = (no_channels - max(CHANNELS))*gSetUp.no_samples*4; % Skip data from last channels
    
    channels = [min(CHANNELS):max(CHANNELS)]; % Block of channels to extract.
    
    FirstChannelSkip = (min(CHANNELS)-1)*gSetUp.no_samples*4; % Skip data from first channels
    no_channels = length(channels);    
    
    itrial = 0;
    
    for trial = no_trials
        itrial = itrial+1;
        if VERBOSE
            fprintf('Reading Trial %d / %d\n',itrial,length(no_trials));
        end
        
        F{itrial} = zeros(no_channels,no_samples);
        
        if trial == no_trials(1) % Read first trial
            fseek(meg,(trial-1)*ByteSizeOfTrial + FirstChannelSkip + (t_in-1)*4 ,0);
        else % just shift from the size of a trial
            fseek(meg,LastChannelSkip + diff_trials(itrial-1)*ByteSizeOfTrial + FirstChannelSkip  ,0);
        end
        
        F{itrial} = fread(meg,[no_samples no_channels],[num2str(no_samples),'*int32=>int32'], samples_skip*4)';
        F{itrial} = F{itrial}(CHANNELS-min(CHANNELS)+1,:);
        
        % IMPORTANT NOTICE : Applying Gradient Correction
        % Data are saved in a given nth-order gradient correction
        % Applying gradient correction is only needed for forward model computation
        % or if it is desired to reverse to lower-order gradient correction (see importdata.m for instance).
        
        % Apply channel gains
        F{itrial} = diag(1./gain_chan(CHANNELS))*double(F{itrial});
        
        
        if VERBOSE
            fprintf('-> Done %d/%d\n',itrial,length(no_trials))
        end
        
    end
    
    fclose('all');
    
    %Time = TIME(1):1/gSetUp.sample_rate:TIME(end);
    
end
cd(current_dir)


function PrintCoilPos(channel_file, CoilRec_ext,nCoils) ; 

% Subroutine to DS2BRAINSTORM 
% Formatted output of channel locations in a file (channel_file is the pointer to this file)
% as defined in theCoilRec_ext structure, according to the number of coils nCoils for every gradiometer

for coil=1:nCoils
    fprintf(channel_file,'Coil %d:', coil);
    fprintf(channel_file,' pX %g,', CoilRec_ext(coil).position.x);
    fprintf(channel_file,' pY %g,', CoilRec_ext(coil).position.y);
    fprintf(channel_file,' pZ %g ', CoilRec_ext(coil).position.z);
    fprintf(channel_file,'-');
    fprintf(channel_file,' oX %g,', CoilRec_ext(coil).orient.x);
    fprintf(channel_file,' oY %g,', CoilRec_ext(coil).orient.y);
    fprintf(channel_file,' oZ %g ', CoilRec_ext(coil).orient.z);
    fprintf(channel_file,'-');
    fprintf(channel_file,' turns %d,', CoilRec_ext(coil).numturns);
    fprintf(channel_file,' area %g', CoilRec_ext(coil).area);
    
    if coil < nCoils
        fprintf(channel_file,' --- ');
    end
    
    fprintf(channel_file,'\n');
end

return

function  save_sensor_locs(Channel)
% Save Channel location in a pseudo-result file for visualization in the MRITool

nchan = length(Channel);
meg = good_channel(Channel,ones(nchan,1),'MEG');
eeg = good_channel(Channel,ones(nchan,1),'EEG');

nchan= length([meg,eeg]);
SourceLoc = cell(1,nchan);

i = 0;
for k = [meg,eeg]
    i = i+1;
    SourceLoc{i} = Channel(k).Loc(:,1);
    SourceOrder(i) = -1;
    Comment = 'Sensor Locations';
end
DataFlag = 'Sensors';
save sensor_result SourceLoc SourceOrder DataFlag Comment

return
