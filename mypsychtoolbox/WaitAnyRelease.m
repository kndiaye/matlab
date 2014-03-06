function [rt, k, t0, t] = WaitAnyRelease(keys, timeout)
% WaitAnyRelease - Wait for the next button or key to be released
%   Keyboard keys are mapped on 8:256. 
%   LENA-Buttons are read using ReadParPort and mapped on codes:
%       257 (for 1, left)
%       258 (for 2, middle)
%       259 (for 4, right)
%   By default, mouse clicks (which are mapped on 1=Left, 2=Right, 3=??,
%   4=Middle, 5=Backward, 6=Forward) are not listened to.
%
%    [rt, k, t0, t] = WaitAnyRelease(keys, timeout)
%
%OUPUTS:
%   rt: reaction time (NaN if no key was released before timeout)
%   k : array with 1 for the button/key which have been released
%   t0: onset time
%   t : real time of the release, so that rt = t - t0
%
%See also: WaitAnyPress, ReadParPort

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2009
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2009-03-23 Creation
%
% ----------------------------- Script History ---------------------------------
if nargin<2
    timeout = Inf;
end
btnCode = 256+[1:3];
if nargin<1
    keys=[];
end
if isempty(keys)
    % By default doesn't listen to mouse buttons (from 1 to 7)
    keys = [ 8:256 btnCode ];
end
if any(keys>256)
    checkButtons = 1;
else
    checkButtons = 0;
end
% At onset, check state of buttons and keys
rt=nan;
t=0;
[keyIsDown,t0,k1] = KbCheck;
if checkButtons
    btnPress=0;
    [btnPress] = ReadParPort(0);
    k1(btnCode) = 0;
    k1(btnCode(logical(bitget(btnPress,1:3)))) = 1;
end
k=zeros(1,max(keys));
while ~any(k(keys)) && ((t-t0) < timeout)
    k0 = k1;
    [keyIsDown,t,k1] = KbCheck;
    if checkButtons
        [btnState] = ReadParPort(0);
        k1(btnCode) = 0;
        k1(btnCode(logical(bitget(btnState,1:3)))) = 1;
    end   
    k = k0 & ~logical(k1);
end
if any(k(keys))
    rt = t-t0;
end
