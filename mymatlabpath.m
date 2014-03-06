function [MYMATLABDIR]=MYMATLABPATH()
% MYMATLABPATH - Retrieves the matlab working directory
MYMATLABDIR = fileparts(mfilename('fullpath'));
