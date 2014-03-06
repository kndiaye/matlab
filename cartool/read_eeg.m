%struct  TSefHeader{    
%       int   Version;                       // magic number filled with the wide char 'SE01'
%       int   NumElectrodes;                 // total number of electrodes
%       int   NumAuxElectrodes;              //  out of which are auxiliaries    
%       int   NumTimeFrames;                 // time length
%       float SamplingFrequency;             // frequency in Hertz
%       short Year;                          // Date of the recording
%       short Month;                         // (set to 00-00-0000 if unknown)
%       short Day;
%       short Hour;                          // Time of the recording
%       short Minute;                        // (set to 00:00:00:0000 if unknown)
%       short Second;
%       short Millisecond;
%   };
% 
% Variable part of the header:
% The names of the channels, as a matrix of  NumElectrodes x 8 chars.
%typedef char        TSefChannelName[8];  // 1 electrode name
% 
% To allow an easy calculation of the data origin, be aware that names are
% always stored on 8 bytes, even if the string length is smaller than that.
% In this case, the remaining part is padded with bytes set to 0, f.ex. two
% consecutive names:
%
% binary values            70 112 122 00 00 00 00 00 65 70 55 00 00 00 00 00 ...
% string equivalence       F  P   z   \0             A  F  7  \0
% 
% Data part:
% Starting at file position:
% sizeof ( TSefHeader ) + 8 * NumElectrodes
% data are stored as a float (Little Endian convention - PC) matrix written row by row:
% float data [ NumTimeFrames ][ NumElectrodes ];

frewind(fid)

eeg.Version             = fread(fid,1,'int')
eeg.NumElectrodes       = fread(fid,1,'int')
eeg.NumAuxElectrodes    = fread(fid,1,'int')
eeg.NumTimeFrames       = fread(fid,1,'int');
eeg.SamplingFrequency   = fread(fid,1,'float');
eeg.Year=fread(fid,1,'short');
eeg.Month               = fread(fid,1,'short');
eeg.Day                 = fread(fid,1,'short');
eeg.Hour                = fread(fid,1,'short');
eeg.Minute              = fread(fid,1,'short');
eeg.Second              = fread(fid,1,'short');
eeg.Millisecond         = fread(fid,1,'short');
