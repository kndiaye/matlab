function [eeg] =read_eph(ephfile)
% read_eph() - Reads EPH file (Cartool)

eeg.Filename = ephfile;
[eeg.NumElectrodes eeg.NumTimeFrames eeg.SamplingFrequency]=textread(ephfile,'%d %d %d',1);
eeg.data=textread(ephfile,'%f',eeg.NumElectrodes*eeg.NumTimeFrames , 'headerlines',1);
eeg.data=reshape(eeg.data,[eeg.NumElectrodes eeg.NumTimeFrames]);
