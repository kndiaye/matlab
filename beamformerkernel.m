function  = beamformerkernel(input,varargin)
%BEAMFORMERKERNEL - One line description goes here.
%   [] = beamformerkernel(input)
%
%   Example
%       >> beamformerkernel
%
%   See also: 

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2006 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2006-02-04 Creation
%                   
% ----------------------------- Script History ---------------------------------


    bst_message_window('Calculating the spatial filter. . .');
    spatialFilter = Kernel'*Cm_inv;
    ImagingKernel= (spatialFilter) ./ repmat(source_power_inv', 1,size(spatialFilter,2));
