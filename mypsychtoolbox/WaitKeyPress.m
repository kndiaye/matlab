function [key, t, i] = WaitKeyPress(whichKeys, whichMarkers, timeout)
% WaitKeyPress - Wait for a key press from user and send marker(s)
%   [key, t, i] = WaitKeyPress(whichKeys, whichMarkers, timeout) waits for a
%   keypress from user and returns the key code and the time of it
%
%INPUTS:
%   whichKeys: list of key codes/names. [] (default) listens to any key
%   
if nargin < 3
    timeout = 10;
end
if nargin < 2
    whichMarkers = [];
end
if nargin < 1
    whichKeys = {};
end

if isempty(whichKeys)
    whichKeyCodes = 1:256;
elseif iscell(whichKeys)
    whichKeyCodes = KbName(whichKeys);
end
i = [];
t = [];
key = [];
t0 = GetSecs();
while (GetSecs() - t0) <= timeout
    [isKeyDown, keyTime, keyCode] = KbCheck();
    if any(keyCode(whichKeyCodes))
        t = keyTime;
        i = find(keyCode(whichKeyCodes), 1);
        key = KbName(whichKeyCodes(i));
        if ~isempty(whichMarkers)
            WriteMarker(whichMarkers(i));
        end
        FlushEvents('keyDown');
%         while true
%             [isKeyDown, keyTime, keyCode] = KbCheck();
%             if ~any(keyCode(whichKeyCodes)) && GetSecs() - t > 10e-3
%                 break
%             end
%         end
        break
    end
end

end
