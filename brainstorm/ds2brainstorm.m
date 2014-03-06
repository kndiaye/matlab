function [F,Channel,imegsens,ieegsens,iothersens,irefsens,grad_order_no,no_trials,filter,Time,RunTitle] = ds2brainstorm(ds_directory,VERBOSE,READRES,CHANNELS, TIME, NO_TRIALS, DCOffset);
%DS2BRAINSTORM Convert a DS CTF dataset into BrainStorm format
% function [F,Channel,imegsens,ieegsens,iothersens,irefsens,grad_order_no,no_trials,filter,Time,RunTitle] = ds2brainstorm(ds_directory,VERBOSE,READRES,CHANNELS,TIME, NO_TRIALS, DCOffset);
% [F,Channel,imegsens,ieegsens,iothersens,irefsens,grad_order_no,no_trials,filter,Time, RunTitle] 
%                      ... = ds2brainstorm(ds_directory,VERBOSE,READRES,CHANNELS,TIME, NO_TRIALS, DCOffset);
% Reads CTF Systems Inc. Data and Resource file formats (4.1 MEG Data Format)
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
% READRES = 0: Do not read the original .res4 file assuming it has been read previously. 
%              Read  _res4.mat instead. If _res4.mat does not exist, automatic switch to READRES = 1.   
% READRES = 1: Read the original .res4 file and writes out a file called **_res4.mat in the .ds folder, 
%              which is a shortened version of the CTF resources file .res4.
%              MEG/EEG data are also read from the .meg4 file ONLY IF other input arguments are specified 
% READRES = 2: Same as READRES = 1, without the long reading of coefficient information
%              but reads ONLY a short version of data information and returns them in F as a structure.
%              MEG/EEG data are nor read from the .meg4 file.
%              This is useful for display in importdata_gui for instance.
% READRES = 3: Do not read .meg4 file (useful when data need to be kept in native file format when importing into BrainStorm)
%              F is then a string indicating the name of the corresponding .ds folder.
%
%
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
% DCOffset: A flag indicating whether DC offset needs to be removed from every MEG channel.
% Acceptable values:
%                   0 - DC offset is not removed from MEG channels (DEFAULT)
%                   1 - DC offset is removed from MEG channels based on the entire trial length 
%                   2 - DC offset is removed from MEG channels based on pretigger time period 
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
% F - Data Matrix: One sensor per row; one time sample per column / alternatively a structure containing all data information
%    (resources contained in .res4 file).
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

%<autobegin> ---------------------- 15-Dec-2003 16:09:01 -----------------------
% --------- Automatically Generated Comments Block Using AUTO_COMMENTS ---------
%
% CATEGORY: Data Processing
%
% Alphabetical list of external functions (non-Matlab):
%   toolbox\bst_message_window.m
%   toolbox\findclosest.m
%   toolbox\good_channel.m
%
% Subfunctions in this file, in order of occurrence in file:
%   PrintCoilPos(channel_file, CoilRec_ext,nCoils) ;
%   save_sensor_locs(Channel,SensorLocFile)
%
% At Check-in: $Author: Mosher $  $Revision: 23 $  $Date: 12/15/03 2:48p $
%
% Overall BrainStorm authors are:
% ** Dr. John C. Mosher,  Los Alamos National Laboratory
% ** Dr. Sylvain Baillet, CNRS Cognitive Neuroscience & Brain Imaging Laboratory
%
% Copyright (c) 2003 BrainStorm MMIII by the University of Southern California
% Principal Investigator:
% ** Professor Richard M. Leahy, USC Signal & Image Processing Institute
%
% Source code may not be distributed in original or altered form.
% For license and copyright notices, type 'bst_splashscreen' in Matlab,
%   or see BrainStorm website at http://neuroimage.usc.edu,
%   or email Professor Richard M. Leahy at leahy@sipi.usc.edu
%   for further information and permissions.
%<autoend> ------------------------ 15-Dec-2003 16:09:01 -----------------------


% /---Script Authors-------------------------------------\
% |                                                      |
% |  *** Sylvain Baillet, Ph.D.                          |
% |  Cognitive Neuroscience & Brain Imaging Laboratory   |
% |  CNRS UPR640 - LENA                                  | 
% |  Hopital de la Salpetriere, Paris, France            |
% |  sylvain.baillet@chups.jussieu.fr                    |
% |                                                      |
% |  *** John C. Mosher, Ph.D.                           |
% |  Design Technology Group                             |
% |  Los Alamos National Laboratory                      |
% |  Los Alamos, New Mexico, USA                         |
% |  mosher@lanl.gov                                     |
% |                                                      |
% |  -> with contributions from                          |
% |       Line Garnero, Ph.D. and Antoine Ducorps, Ph.D. |
% |       MEG Center &                                   |
% |       Cognitive Neuroscience                         | 
% |       & Brain Imaging Laboratory - CNRS              |
% |       La Salpetriere Hospital, Paris - France        |
% \------------------------------------------------------/

% Script History ----------------------------------------------------------------------------------------
%
% 11/28/00 - SB   : Updated to read the 3rd-order gradient information
% 03/09/01 - SB   : Data block extraction
% 15/11/01 - SB   : Extraction of the ADC Input channels in iothersens, combined with the STIM channel
% 19/11/01 - SB   : Save iothersens indices in the _res4.mat file
% JCM 06-Jun-2002 : made waitbar update less often, autocomments
% SB 26-Jul-2002  : Added the READRES = 2 condition to read basic file information for display importdata_gui.
% ..............    Removed creation of channel_file.txt. 
% SB 27-Jul-2002  : Minor alterations in the READRES conditions - see help header. 
% SB 28-Jul-2002  : When CHANNELS is emptu, all channels, including reference channels are read.
% ..............    Changed name of sensor location result file (for visualization in MRITool or 3DViewer)
% SB 10-Sep-2002  : Minor layout editing.
% SB 07-Nov-2002  : Display all progress information into bst_message_window
% SB 15-Nov-2002  : EEG channel .loc field is now only 3x1 (was 3x2, second column filled with zeros).
%                   Added DCOffset input argurment to remove DC Offset from MEG channels.
% SB 20-Nov-2002  : Assign "MEG REF" type to MEG reference channels for fast retrieval with GOOD_CHANNEL
%                   Removed .Gcoef and .i*sens fields form Channel structure.
% SB 23-Dec-2002  : Time now returns only the time window on which data has been extracted (not the whole original time span of data) 
% SB 21-Jan-2003  : Fixed 1-sample bug for total Time length
% SB 23-Jan-2003  : Added READRES = 3 option.
% SB 06-Feb-2003  : Fixed bug when accessing data with multiple trials specificied in NO_TRIALS
%                   From the second NO_TRIALS entry on, data was always read from beguinning of trial 
%                   not from the first entry specified in TIME. 
% JCM 10-Dec-2003 : Added additional blank SensorNames to account for type "17" in the 275 channel arrays. Moved around
%                   redundant definitions of SensorNames. Thanks to Fred Carver NIMH for finding this.
% JCM 11-Dec-2003 : Updating SensorNames based on email from CTF,
% plus correcting 0 indexing scheme
% KND 01-Jun-2004 : Added a quick & dirty test for virtual MEG channels
% KND 02-Jun-2004 : Modified Check input arguments, so that 4 arguments is ok [173-183]
%                   Bug: TIME was defined as a 1xN array (=Time) instead of a [BeginLatency EndLatency]
% --------------------------------------------------------------------------------------------------------

% Check input arguments

if nargin == 2
   READRES = 1;
   DCOffset = 0;
elseif nargin==5 % No Marker file and marker range are defined
   MARKER_FILE = 0;
   MARKER_RANGE = [];
   DCOffset = 0;
% KND:
elseif nargin==4
  % if READRES ~= 1 | READRES ~= 2
  %   READRES = 2; % Read data information only.
  % end
  MARKER_FILE = 0;
  MARKER_RANGE = [];
  TIME = [];
  NO_TRIALS = [];   
  DCOffset = 0;  
% -- KND
elseif nargin==3
   % Read only file information.
   % Check that READRES has acceptable values - if not, the whole file could be read
   % which could end-up in loading very large files into Matlab format 
   % and cause memory crash.
   if READRES ~= 1 | READRES ~= 2
      READRES = 2; % Read data information only.
   end
   MARKER_FILE = 0;
   MARKER_RANGE = [];
   CHANNELS = [];
   TIME = [];
   NO_TRIALS = [];   
   DCOffset = 0;
end


% SensorNames ={'Ref Magnetometer','Ref Gradiometer' ,''  , '' , '' ,'MEG Sensor','' , '', '','EEG Sensor','ADC Input','Stimulation input',''}; % CHEAT - added the 13th '' ofor testing purposes
% 10 December 2003 Fred Carver at NIMH found that 275 channel arrays had a type 17. Added extra blanks to account for.
% 11 December 2003, based on email directly from Dough McKenzie at CTF:
% Comments on types, email of 10 December 2003:
%The new types are
%
%   SAM Sensor       -- Synthetic electrode channel from SAM
%   Virtual Channel  -- Linear combination of sensor channels
%   System Clock     -- 32 bit counter incremented at 12,000
%                       ticks per second for Omega 2000 system
%                       ( new systems like NIMH )
%                       and incremented at 12,500 ticks per
%                       second for older systems.
%
%   Video Time       -- A 32 bit encoded value that can be recorded from
%                       a SONY Video time output from a video player or 
%                       recorder
%
%                       The format is 'hhmmssff'  where each byte contains
%                            hh    hours in decimal ( 0--
%                            mm    minutes          ( 0 ~ 59 )
%                            ss    seconds          ( 0 ~ 59 )
%                            ff    frames           ( 0 ~ 29 )
%
%   ADC Input Voltage -- Used if the ADC channels are measuring
%                        voltage. == 11 if measuring current
%
%NOTE: There will be some additional channels types defined
%      mid next year.
SensorNames ={...
      'Ref Magnetometer',... % Sensor Type Index of 0
      'Ref Gradiometer' ,... % Index of 1
      ''  ,...               % 2
      '' ,...                % 3
      '' ,...                % 4
      'MEG Sensor',...       % 5
      '' ,...                % 6
      '',...                 % 7
      '',...                 % 8
      'EEG Sensor',...       % 9
      'ADC Input Current',...% 10 ADC Input Current (Amps)
      'Stimulation input',...% 11
      'Video Time',...       % 12
      '',...                 % 13
      '',...                 % 14
      'SAM Sensor',...       % 15
      'Virtual Channel',...  % 16
      'System Clock',...     % 17 System Time Ref
      'ADC Input Voltage',...% 18 ADC Input Voltage (Volts)
   };


%% Checking files
cd(ds_directory)
[path,rootname] = fileparts(ds_directory);
meg4file = [rootname,'.meg4'];
rec4file = [rootname,'.res4'];
if isdir('BrainStorm') % Was a BrainStorm directory created in .ds folder ? Yes if ds2brainstorm called from importdata
   res4_mat = fullfile('BrainStorm',[rootname,'_res4.mat']);
else
   res4_mat = [rootname,'_res4.mat'];
end

if ~exist(rec4file,'file') | ~exist(meg4file,'file') 
   errordlg([rec4file ' or ' meg4file ' missing'])
   return
end

% If .mat version of the .res4 does not exist while we supposed it did - read it.
if ~exist(res4_mat,'file') & READRES == 0  
   % Force reading of original .res4 
   READRES = 1;
end

if VERBOSE
   bst_message_window(['Working in...',ds_directory ])
end


%*********************************************    

if READRES > 0 % Read the .res4 file     
   
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
      bst_message_window({...
            sprintf('ds2brainstorm -> %s file format',char(header))...
         })
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
   gSetUp.no_trials_bst_message_windowlay = (fread(rec,1,'int16')');
   fseek(rec,ceil(ftell(rec)/4)*4,-1);
   gSetUp.save_trials = (fread(rec,1,'int32')');
   gSetUp.primaryTrigger = char(fread(rec,1,'uchar')');
   gSetUp.secondaryTrigger = char(fread(rec,MAX_AVERAGE_BINS,'uchar')');
   gSetUp.triggerPolarityMask = char(fread(rec,1,'uchar')');
   
   gSetUp.trigger_mode = (fread(rec,1,'int16')');
   fseek(rec,ceil(ftell(rec)/4)*4,-1);
   gSetUp.accept_reject_Flag = (fread(rec,1,'int32')');
   gSetUp.run_time_bst_message_windowlay = (fread(rec,1,'int16')');
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
   tmp = fread(rec,60,'char')';
   tmp(tmp<0) = 0; % prevent out of range character conversion warning
   nfSetUp.nf_sensorFileName = tmp; clear tmp
   
   fseek(rec,ceil(ftell(rec)/4)*4,-1);
   nfSetUp.rdlen = fread(rec,1,'int32')';
   
   GenRes4.gSetUp = gSetUp;
   GenRes4.nfSetUp = nfSetUp;
   
   
   % Time span of data record
   Time =  linspace(-GenRes4.gSetUp.preTrigPts/GenRes4.gSetUp.sample_rate,...
      GenRes4.gSetUp.epoch_time/GenRes4.gSetUp.no_trials-(GenRes4.gSetUp.preTrigPts+1)/GenRes4.gSetUp.sample_rate,...
      GenRes4.gSetUp.no_samples);
   %     
   %----------------------------------------------------------------------------------------
   
   if VERBOSE
      ON_OFF = {'Off','On'};
      bst_message_window({...
            sprintf('ds2brainstorm -> Header information'),...
            sprintf('                 Collected %s starting at %s', GenRes4.data_date, GenRes4.data_time),...
            sprintf('                 Run Name: %s', nfSetUp.nf_run_name),...
            sprintf('                 Run Title: %s', nfSetUp.nf_run_title),...
            sprintf('                 Col Desc: %s', nfSetUp.nf_collect_descriptor),...
            sprintf('                 Run Desc: %s', GenRes4.dataDescription),...
            sprintf('                 Operator: %s', nfSetUp.nf_operator),...
            sprintf('                 Subject : %s', nfSetUp.nf_subject_id),...
            sprintf('                 Channels: %d',gSetUp.no_channels),...
            sprintf('                 Samples : %d per trial', gSetUp.no_samples),...
            sprintf('                 Rate    : %g samples/sec', gSetUp.sample_rate),...
            sprintf('                 Trials  : %d (average of %d)', gSetUp.no_trials, GenRes4.no_trials_avgd),...
            sprintf('                 Duration: %g seconds/trial', gSetUp.epoch_time/gSetUp.no_trials),...
            sprintf('                 Pre-trig: %g samples', gSetUp.preTrigPts),...
            sprintf('                 Sensor file name : %s', nfSetUp.nf_sensorFileName),...
            sprintf('                 Head zeroing: %s', ON_OFF{gSetUp.zero_Head_Flag+1}),...
            sprintf('_________________')...
         })
   end
   
   
   %-------------------------------------------------------------------------------
   
   %----------------------------------READ FILTERS---------------------------------
   
   fseek(rec,1844,-1);
   
   % Run Description
   rundescript = char(fread(rec,nfSetUp.rdlen,'char'));
   if VERBOSE
      bst_message_window({...
            sprintf('ds2brainstorm -> Run Description: %s', rundescript )...
         })  
   end
   
   classType = {'CLASSERROR','BUTTERWORTH'};
   filtType = {'TYPERROR','LOWPASS','HIGHPASS','NOTCH'};
   
   
   % Number of filters
   no_filters = fread(rec,1,'int16');
   if VERBOSE
      bst_message_window({...
            'ds2brainstorm -> Filter information',...
            sprintf('Number of filters: %d', no_filters)...
         })
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
         bst_message_window({...
               sprintf('  Filter - %d',fi),...
               sprintf('         -> Frequency: %g Hz',filter(fi).freq),...
               sprintf('         -> Class: %s',filter(fi).fClass),...
               sprintf('         -> Type: %s',filter(fi).fType),...
               sprintf('         -> Number of parameters: %d',filter(fi).numParam)...
            })
         
         if ~isempty(filter(fi).params)
            bst_message_window({...
                  sprintf('         -> Parameter Value(s): %g',filter(fi).params)...
               })
         end
      end 
      
      bst_message_window({...
            sprintf('ds2brainstorm -> Reading Filter Information - DONE'),...
            sprintf('ds2brainstorm -> Reading Channel Information. . .')...
         })
   end
   
   % Channel Names
   for chan = 1:gSetUp.no_channels 
      channel_name{chan} = fread(rec,32,'char')'; 
      tmp = channel_name{chan};
      tmp(tmp>127) = 0; 
      tmp(tmp<0) = 0;
      channel_name{chan} = strtok(tmp,char(0));
      ChannelName{chan} = char(strtok(channel_name{chan},'-'));
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
      bst_message_window({...
            'ds2brainstorm -> Reading Channel Information - DONE',...
            'ds2brainstorm -> Converting Channel Information. . .'...
         })
      
   end
   
   nchan= length(channel_name); % Number of channels
   
   % Explode data according to channel type
   imegsens = find([SensorRes.sensorTypeIndex] == 5); % Indices of MEG sensors
   ieegsens = find([SensorRes.sensorTypeIndex] == 9); % Indices of EEG sensors
   iothersens = [find([SensorRes.sensorTypeIndex] == 11),find([SensorRes.sensorTypeIndex] == 10)]; % Indices of OTHER sensors ('Stimulation input' and 'ADC')
   irefsens = find([SensorRes.sensorTypeIndex] == 0); % Reference Channels
   irefsens = [irefsens,find([SensorRes.sensorTypeIndex] == 1)]; % Reference Channels
   
   if READRES == 2 % Enough data information - send it out of here
      % Initialize output arguments 
      [F,Channel,grad_order_no,no_trials,Time, RunTitle] = deal([]);
      F = GenRes4;
      F.filter = filter;
      F.imegsens = imegsens;
      F.ieegsens = ieegsens;
      F.irefsens = irefsens;
      F.iothersens = iothersens;
      F.ChannelNames = char(ChannelName);
      F.grad_order_no = [SensorRes(:).grad_order_no];        
      F.nchan = length([imegsens,ieegsens,irefsens,iothersens]);
      F.Time = Time;
      return
   end
   
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
   
   [Channel(1:nchan)] = deal(struct('Loc',[],'Orient',[],'Comment',[],'Weight',[],'Type',[],'Name',''));
   
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
         
         Channel(chan).Comment = ''; % SB 20-Nov-2002
         Channel(chan).Name = [SensorNames{SensorRes(chan).sensorTypeIndex+1},' ',int2str(chan)];% SB 20-Nov-2002
         Channel(chan).Type = 'MEG REF'; % SB 20-Nov-2002
         
         % Channel(chan).Type = SensorNames{SensorRes(chan).sensorTypeIndex+1} ;
         %             if isempty(deblank(Channel(chan).Type))
         %                 Channel(chan).Type = 'MEG REF';
         %             end
         
         chanmeg = [chanmeg,chan];
         refID(iref) = chan; 
         Channel(chan).Weight = [1 -1] ;  
         
       case 5 % MEG
	% KND:
	% Quick & dirty test for possible Virtual MEG channel
	% To detect Virtual ones, we could also use 
	% Head Coil Position = (0,0,0)
	%   ie. SensorRes(chanNumber).HdcoilTbl(1).position.x=0
	%       SensorRes(chanNumber).HdcoilTbl(1).position.y=0
	%       SensorRes(chanNumber).HdcoilTbl(1).position.z=0

	if SensorRes(chan).coilTbl(1).area > 0
	  % Not a virtual one... I guess !
	  % -- KND
					      
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
         
         Channel(chan).Comment = ' ';%[SensorNames{SensorRes(chan).sensorTypeIndex+1},' ',int2str(chan)];
         Channel(chan).Type = 'MEG';%SensorNames{SensorRes(chan).sensorTypeIndex+1} ;
         
         chanmeg = [chanmeg,chan];
         megID(imeg) = chan; 
         Channel(chan).Weight = [1 -1] ;  
         Channel(chan).Name = ChannelName{chan}; %char(strtok(channel_name{chan},'-'));
	else                  
	  %KND : 
	  % Virtual Channel Specifications	  
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
	% -- KND
      case 9 % EEG
         ieeg = ieeg + 1;
         MAX_COILS = 1; % Take only into account the first sensor location for EEG (second pseudo-coil location is [0 0 0] as writtent in .ds files)
         tmp = [SensorRes(chan).HdcoilTbl(:).position]; 
         tmpx  = [tmp(1:MAX_COILS).x]/100;% In meters
         tmpy  = [tmp(1:MAX_COILS).y]/100;
         tmpz  = [tmp(1:MAX_COILS).z]/100;
         
         Channel(chan).Loc = ...
            [tmpx;tmpy;tmpz];
         
         Channel(chan).Orient = [];
         
         Channel(chan).Type = 'EEG';%SensorNames{SensorRes(chan).sensorTypeIndex+1} ;
         Channel(chan).Comment = ' ';%[SensorNames{SensorRes(chan).sensorTypeIndex+1},' ',int2str(chan)];
         Channel(chan).Weight = [];   
         Channel(chan).Name = ChannelName{chan}; %char(strtok(channel_name{chan},'-'));%int2str(ieeg) ;  
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
	% KND:
	% for MicroMed EEG dataHandled... 	
	% iother2 = iother2+1; 
	 iother = iother+1;
	% -- KND 
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
   
   if VERBOSE
      bst_message_window('ds2brainstorm -> Converting Channel Information  - DONE')
   end
   %-------------------------------------------------------------------------------
   
   
   %----------------------------------READ Coefficients---------------------------------
   
   % Number of coefficient records
   nrec = fread(rec,1,'int16');
   
   channel_name = cellstr(char(channel_name{:}));
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
      
      cchannel = strmatch( deblank(SensorCoefResRec(k).sensorName),channel_name);
      CoefType = find(hex2dec(hexadef)==(SensorCoefResRec(k).coefType));
      
      if CoefType > 0
         
         CoefInfo{cchannel,CoefType-1}.num_of_coefs =  SensorCoefResRec(k).CoefResRec.num_of_coefs;
         
         for i=1:CoefInfo{cchannel,CoefType-1}.num_of_coefs 
            CoefInfo{cchannel,CoefType-1}.sensor_list(i) = irefsens(strmatch(strtok(SensorCoefResRec(k).CoefResRec.sensor_list(i,:),char(0)),channel_name(irefsens)));   
            CoefInfo{cchannel,CoefType-1}.coefs(i) = SensorCoefResRec(k).CoefResRec.coefs_list(i);
         end
      end  
      if VERBOSE
         if(~rem(k,floor(nrec/10))), % only occasionally
            waitbar(k/nrec);
         end
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
      bst_message_window({...
            'ds2brainstorm -> Coefficient Information',...
            sprintf('                 Number of coefficient records = %d ', nrec)...
         })
      
      %         [coef_file, message] = fopen('coef_file.txt','wt+');
      %         
      %         if coef_file < 0
      %             errordlg(message)
      %             return
      %         end
      %         
      %         fprintf(coef_file,'Number of coefficient records = %d \n', nrec);
      %         
      %         for k = 1:nrec
      %             coefType = dec2hex(SensorCoefResRec(k).coefType);
      %             coefType = strdef{hex2dec(hexadef)==hex2dec(coefType)};
      %             
      %             fprintf(coef_file,'Channel %s type %s, ',SensorCoefResRec(k).sensorName, coefType);
      %             
      %             num_of_coefs = SensorCoefResRec(k).CoefResRec.num_of_coefs;
      %             fprintf(coef_file,'number = %d:\n', num_of_coefs);
      %             if 0
      %                 for j=1:num_of_coefs
      %                     fprintf(coef_file,' %s ', SensorCoefResRec(k).CoefResRec.sensor_list{j});
      %                     fprintf(coef_file,' %g ',SensorCoefResRec(k).CoefResRec.coefs_list(j));
      %                 end
      %                 fprintf(coef_file,'\n');
      %             end
      %         end
      %         
      %         bst_message_window({...
      %                 sprintf('ds2brainstorm -> Coefficient Information saved in coef_file.txt'),...        
      %                 sprintf('ds2brainstorm -> Reading Coefficient Information - DONE'),...
      %                 ' '...
      %             })
      bst_message_window({...
            sprintf('ds2brainstorm -> Reading Coefficient Information - DONE'),...
            ' '...
         })
   end
   
   
   % Calculus of the matrix for nth-order gradient correction
   % Coefficients for unused reference channels are weigthed by zeros in
   % the correction matrix.
   Gcoef = zeros(length(imegsens),length(min(irefsens):max(irefsens)));
   grad_order_no = [SensorRes(:).grad_order_no];        
   for k = 1:length(imegsens)
      
      % Reference coils for channel k
      if grad_order_no(imegsens(k)) == 0
         %Data is saved as RAW
         %Save 3rd order gradient sensor-list for subsequent correction if requested later by the user
         [refs] = (CoefInfo{imegsens(k),3}.sensor_list);
         Gcoef(k,refs-min(irefsens)+1) = CoefInfo{imegsens(k),3}.coefs ... 
            .* gain_chan(refs)'/gain_chan(imegsens(k)); 
      else
         [refs] = (CoefInfo{imegsens(k),grad_order_no(imegsens(k))}.sensor_list);
         Gcoef(k,refs-min(irefsens)+1) = CoefInfo{imegsens(k),grad_order_no(imegsens(k))}.coefs ... 
            .* gain_chan(refs)'/gain_chan(imegsens(k)); 
      end
      
   end
   
  if ~isempty(imegsens)
      Channel(imegsens(1)).Comment = Gcoef;
  end
   %     Channel(imegsens(1)).imegsens = imegsens;
   %     Channel(imegsens(1)).ieegsens = imegsens;
   %     Channel(imegsens(1)).irefsens = irefsens;
   %     Channel(imegsens(1)).RefChannel = Channel; % Store MEG reference information for future call to MEG forward routines and proper processing of gradient correction
   
   SensorLocFile = strrep(ds_directory,[fileparts(ds_directory),filesep],'');
   SensorLocFile = strrep(SensorLocFile,'.ds','_SensorLoc_Results.mat');
   save_sensor_locs(Channel,SensorLocFile)
   
   if VERBOSE
      bst_message_window('wrap',...
         sprintf('ds2brainstorm -> Sensor locations can be visualized with the MRI Tool by loading the file: %s',SensorLocFile)...
         )
   end
   
   fclose('all');
   
   % Create the BrainStorm res4 file for subsequent fast access to the data file
   no_channels = length(Channel);
   gain_chan(ieegsens)=1./gain_chan(ieegsens);
   no_trials = [1:gSetUp.no_trials];
   
   save(res4_mat,'gSetUp','meg4file','ieegsens','irefsens', 'iothersens', 'imegsens','Time','no_channels','gain_chan','channel_name','Channel','grad_order_no','filter','RunTitle','no_trials');
   
   if READRES == 1
      READRES = 0; %read the res4.mat file just created and read the data by block.
      if nargin == 2 % Stop there
         return
         %CHANNELS = 1:length(Channel); % With all available channels...
         %TIME = Time; % whole time duration...
         %NO_TRIALS = 1:gSetUp.no_trials; % All trials
      elseif nargin > 2
         % Fill empty arguments
         if isempty(CHANNELS)
            CHANNELS = 1:length(Channel); % Read all available channels
         end
         if isempty(TIME)
            % KND: 
	    % Bug in the following line?
	    % TIME = Time; % Read entire trial duration 
	    TIME=[Time(1) Time(end)];
	    % -- KND
	    
         end
         if isempty(NO_TRIALS)
            NO_TRIALS = 1:gSetUp.no_trials; % Read all trials
         end
      end
   end
   
else % READRES == 0
   if VERBOSE
      bst_message_window({...
            sprintf('ds2brainstorm -> Loading resources : %s',res4_mat),...
         })
   end
   load(res4_mat);
   
   % KND:
   if isempty(TIME)
     TIME = [Time(1) Time(end)]; % Read entire trial duration 
     if VERBOSE              
        bst_message_window({...
            sprintf('ds2brainstorm -> Whole trial will be read: Time window: %f %f', TIME(1),TIME(2))...
         })
     end
   end
   % -- KND
end


%--------------------------- Readind DATA FILE ------------------------------

if VERBOSE
   bst_message_window({...
         sprintf('ds2brainstorm -> Reading Data')...
      })
end

if nargin == 2 & READRES ~= 3 % Read entire block of data
   
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
         bst_message_window({...
               sprintf('ds2brainstorm -> Trial %d/%d',trial,gSetUp.no_trials)...
            })
      end
      
      F{trial} = zeros(gSetUp.no_channels,gSetUp.no_samples);
      F{trial} = fread(meg,[gSetUp.no_samples gSetUp.no_channels],'int32')';
      
      if VERBOSE
         bst_message_window({...
               sprintf('ds2brainstorm -> Done')...
            })
      end
      % IMPORTANT NOTICE : Applying Gradient Correction
      % Data are saved in a given nth-order gradient correction
      % Applying gradient correction si only needed for forward model computation
      % or if it is desired to reverse to lower-order gradient correction (see importdata.m for instance).
      
      % Apply channel gains
      F{trial}(ieegsens,:) = diag(1./gain_chan(ieegsens))*F{trial}(ieegsens,:) ; %To get Microvolts->already inverted when saved _res4.mat
      F{trial}(imegsens,:) = diag(1./gain_chan(imegsens))*F{trial}(imegsens,:)  ;
      
      % Removing DC Offset
      switch(DCOffset)
      case {1,2}
         if VERBOSE
            bst_message_window({...
                  'ds2brainstorm -> Removing DC offset'...
               })
         end
         
         if DCOffset == 1 % Based on entire trial length
            F{trial}(imegsens,:) = F{trial}(imegsens,:) - repmat(mean(F{trial}(imegsens,:)')',1,size(F{trial},2));
            F{trial}(irefsens,:) = F{trial}(irefsens,:) - repmat(mean(F{trial}(irefsens,:)')',1,size(F{trial},2));    
         else % Based on pretrigger
            TimeNeg = TIME(TIME<0); % Find pretrigger time points
            if ~isempty(TimeNeg)
               F{trial}(imegsens,:) = F{trial}(imegsens,:) - repmat(mean(F{trial}(imegsens,TimeNeg)')',1,size(F{trial},2));
               F{trial}(irefsens,:) = F{trial}(irefsens,:) - repmat(mean(F{trial}(irefsens,TimeNeg)')',1,size(F{trial},2));
            else
               % Do nothing
            end
         end
         
         if VERBOSE
            bst_message_window({...
                  'ds2brainstorm -> Removing DC offset - DONE'...
               })
         end
         
      otherwise
         % Do nothing
      end
      
      F{trial}(irefsens,:) = diag(1./gain_chan(irefsens))*F{trial}(irefsens,:) ;
      F{trial}(iothersens,:) = diag(1./gain_chan(iothersens))*F{trial}(iothersens,:) ;
      
   end
   
   fclose('all');
   
   %------------------------------------------------------------------------------------------------------------------------------------
   
else % Reads sub-block of data
   
   
   if READRES == 3
      
      F = ds_directory;
      
      if isempty(NO_TRIALS) % argument NO_TRIALS not defined
         no_trials = [1:gSetUp.no_trials];
      else
         no_trials = [NO_TRIALS];
      end
      
   else
      
      %ds2brainstorm(ds_directory,VERBOSE,READRES,CHANNELS,TIME, NO_TRIALS);
      if isempty(NO_TRIALS) % argument NO_TRIALS not defined
         no_trials = [1:gSetUp.no_trials];
      else
         no_trials = [NO_TRIALS];
      end
      
      if isempty(CHANNELS)
         CHANNELS = [1:length(Channel)];
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
      
      header = char(fread(meg,8,'char')');
      implicit.sample_rate = 1/(Time(2) - Time(1)); % i.e. the one used in the data file given the time begin_time end period.
      %     t_in = round((TIME(1)-Time(1))*implicit.sample_rate) +1; % Sample time offset since the beginning of the trial: beginning of the time window TIME
      %     
      %     no_samples = round((TIME(end)-TIME(1))*implicit.sample_rate)+1; % Number of time samples to extract
      %     t_out = t_in + no_samples - 1;
      
      tmp = findclosest([TIME],Time');
      t_in = tmp(1);
      t_out = tmp(2);
      no_samples = length(t_in:t_out);
      
      try 
         Time = Time(t_in:t_out); % SB 23-Dec-2002
      catch 
         error(...
            sprintf('Data time ranges from %3.1f to %3.2f ms. Please adjust time extraction window',Time(1),Time(end)));
      end
      
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
            bst_message_window({...
                  sprintf('ds2brainstorm -> Trial %d / %d',itrial,length(no_trials))...
               })
         end
         
         F{itrial} = zeros(no_channels,no_samples);
         
         if trial == no_trials(1) % Read first trial
            fseek(meg,(trial-1)*ByteSizeOfTrial + FirstChannelSkip + (t_in-1)*4 ,0);
         else % just shift from the size of a trial
            fseek(meg,LastChannelSkip + diff_trials(itrial-1)*ByteSizeOfTrial + FirstChannelSkip + (t_in-1)*4 ,0);
         end
         
         F{itrial} = fread(meg,[no_samples no_channels],[num2str(no_samples),'*int32=>int32'], samples_skip*4)';
         F{itrial} = F{itrial}(CHANNELS-min(CHANNELS)+1,:);
         
         % IMPORTANT NOTICE : Applying Gradient Correction
         % Data are saved in a given nth-order gradient correction
         % Applying gradient correction is only needed for forward model computation
         % or if it is desired to reverse to lower-order gradient correction (see importdata.m for instance).
         
         % Apply channel gains
         F{itrial} = diag(1./gain_chan(CHANNELS))*double(F{itrial});
         
         % Removing DC Offset
         if isempty(DCOffset)
            DCOffset = 0;
         end
         switch(DCOffset)
         case {1,2}
            if VERBOSE
               bst_message_window({...
                     'ds2brainstorm -> Removing DC offset'...
                  })
            end
            
            if DCOffset == 1 % Based on entire trial length
               F{itrial}(imegsens,:) = F{itrial}(imegsens,:) - repmat(mean(F{itrial}(imegsens,:)')',1,size(F{itrial},2));
               F{itrial}(irefsens,:) = F{itrial}(irefsens,:) - repmat(mean(F{itrial}(irefsens,:)')',1,size(F{itrial},2));
            else % Based on pretrigger
               TimeNeg = intersect(find(Time(t_in:t_out) >= TIME(1)),find(Time(t_in:t_out)<0)); % Find pretrigger time points
               if ~isempty(TimeNeg)
                  F{itrial}(imegsens,:) = F{itrial}(imegsens,:) - repmat(mean(F{itrial}(imegsens,TimeNeg)')',1,size(F{itrial},2));
                  F{itrial}(irefsens,:) = F{itrial}(irefsens,:) - repmat(mean(F{itrial}(irefsens,TimeNeg)')',1,size(F{itrial},2));
               else
                  % Do nothing
               end
            end
            
            if VERBOSE
               bst_message_window({...
                     'ds2brainstorm -> Removing DC offset - DONE'...
                  })
            end
            
         otherwise
            % Do nothing
         end
         
         
         if VERBOSE
            bst_message_window({...
                  sprintf('ds2brainstorm -> Done')...
               })
         end
         
      end
      
      fclose('all');
   end
   
end


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

function  save_sensor_locs(Channel,SensorLocFile)
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
if isdir('BrainStorm')
   save(fullfile('BrainStorm',SensorLocFile),'SourceLoc','SourceOrder','DataFlag','Comment')
else
   save sensor_result SourceLoc SourceOrder DataFlag Comment
end

return
