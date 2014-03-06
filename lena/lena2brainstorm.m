function [Channel,Time,F,h] = lena2brainstorm(lenafile,varargin)
%LENA2BRAINSTORM - Reads LENA file into brainstorm data format
%   [Channel,Time,F,header] = lena2brainstorm(lenafile)
%
%   Example
%       >> lena2brainstorm
%
%   See also: 

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2010 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2010-04-02 Creation
%                   
% ----------------------------- Script History ---------------------------------

%% Reads .lena file/folder
warning off
if nargout < 3
    % No need to read the full data info
    [h] = read_lena(lenafile,varargin{:});
else
    [h,F] = read_lena(lenafile,varargin{:});
end
warning on
%% Brainstorm's Channel structure
Channel = [];
if nargout < 2
    return
end
%% Time array
Time = [0:(str2num(h.description.time_range.time_samples)-1)]./...
    str2num(h.description.time_range.sample_rate) - ...
    str2num(h.description.time_range.pre_trigger);
if nargout < 3
    return
end
%% Process data into F
canonical_dimensions = {'sensor_range' 'time_range' 'datablock_range' };
data_dimensions = fieldnames(h.description);
[ign,candim] = intersect(canonical_dimensions(:), data_dimensions);
icandim(candim)=1:numel(candim);
F = permute(F, icandim);
