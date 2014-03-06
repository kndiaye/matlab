function [t,m] = ptx2events(input)
%PTS2EVENTS - One line description goes here.
%   [] = ptx2events(input)
%
%   Example
%       >> ptx2events
%
%   See also: eeglab

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2009
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2009-04-24 Creation
%
% ----------------------------- Script History ---------------------------------


[onsets,names,trials,durations,offsets] = read_ptx(input);
e = create_events(onsets,names,trials,durations,offsets);



