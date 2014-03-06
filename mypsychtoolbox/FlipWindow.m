function [VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos] = FlipWindow(windowPtr,when,dontclear,dontsync,multiflip)
%FLIPWINDOW - Oneliner for Screen('Flip',...)
%   [VBLT, OnsetTime, FlipT, Missed Beampos] =
%       FlipWindow flips the last window
%   	FlipWindow(windowPtr)
%
%   Example
%       >> FlipWindow
%
%   See also: Screen('Flip?')

% Author: K. N'Diaye (kndiaye01<at>gmail.com)
% Copyright (C) 2011
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2011-02-15 Creation
%
% ----------------------------- Script History ---------------------------------

if nargin<1
    windowPtr=[];
end
if isempty(windowPtr)
    windowPtr = Screen('Windows');
    windowPtr = windowPtr(end);
end
if isempty(windowPtr)
    warning('FlipWindow:NoWindow', 'No window found');
    return
end
% when,dontclear,dontsync,multiflip)
switch nargin
    case {0 1}
        [VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos] = Screen('Flip',windowPtr);
    case 2
        [VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos] = Screen('Flip',windowPtr,when);
    case 3
        [VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos] = Screen('Flip',windowPtr,when,dontclear);
    case 4
        [VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos] = Screen('Flip',windowPtr,when,dontclear,dontsync);
    case 5
        [VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos] = Screen('Flip',windowPtr,when,dontclear,dontsync,multiflip);
end