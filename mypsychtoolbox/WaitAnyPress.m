function [rt, k, t0, t] = WaitAnyPress(keys, timeout, newOnly)
% WaitAnyPress - Wait for a button or a key press
%
%   [rt, k, t0, t] = WaitAnyPress(keys, timeout, newOnly)
%
%INPUTS:
%   keys: code of keys to listen to. Keyboard keys are mapped on 8:256.
%         By default, mouse clicks (which are mapped on 1=Left, 2=Right,
%         3=??, 4=Middle, 5=Backward, 6=Forward) are not listened. Parallel
%         port is read with ReadParPort(), if available. Bits are assigned
%         to the keycodes [257:264] so that:
%               1 (bit0) = 257 (left LENA-button)
%               2 (bit1) = 258 (middle LENA-button)
%               4 (bit2) = 259 (right LENA-button)
%                   ... 
%               128 (bit7) = 264
%   timeout: Duration of the timeout in seconds.
%   newOnly: Only detect new keypress (not keys that were already pressed from
%            the onset), default: true
%OUPUTS:
%   rt: reaction time (NaN if no key was pressed before timeout)
%   k : array with 1's for the button/key which have been pressed
%   t0: start time of the wait
%   t : real time of the press, so that rt = t - t0
%
%See also: WaitAnyRelease, ReadParPort

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2009 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2009-03-13 Creation
% KND  2009-03-30 Test OpenParPort to set default keys
% KND  2010-11-18 Keys that are pressed on call may now be discarded
% ----------------------------- Script History ---------------------------------

t0=GetSecs;
t=0;
rt=nan;
if nargin<3
    % wait for a new press (not one that was already down)
    newOnly = 1;
end
if nargin<2
    timeout = Inf;
end
btnCode = 256+[1:8];
if nargin<1
    keys=[];
end
if isempty(keys)
    % Not accepting mouse buttons (from 1 to 7)
    keys = [ 8:256 ];
    global PAR_PORT
    if ~isempty(PAR_PORT)
        keys = [ keys btnCode ];
    end    
end
if any(keys<8)
    checkMouse = 1;
else
    checkMouse = 0;
end
if any(keys>256)
    checkParPort = 1;
else
    checkParPort = 0;
end
if any(keys<1)
    error('Can''t map keys below 1');
end
k=zeros(1,max(keys));
k_new = [];
k1=k;
while ~any(k(keys)) && ((t-t0) < timeout)
    [keyIsDown,t,k] = KbCheck;
    if checkParPort
        [btnState] = ReadParPort(0);
        k(btnCode) = 0;
        k(btnCode(logical(bitget(btnState,1:8)))) = 1;
    end
    if checkMouse
        [mouseState,mouseState,mouseState] = GetMouse;
        k(mouseState) = 0;
        k(1:3) = mouseState;
    end
    if  newOnly
        % Keys that were down from the start, will not trigger a response
        if isempty(k_new);k_new=k;end
        k1=k;
        k(k==k_new)=0;
        % Listen to them however if they have been released in the meantime
        k_new(k1<k_new)=0;
    end
end
if any(k(keys))
    rt = t-t0;
end