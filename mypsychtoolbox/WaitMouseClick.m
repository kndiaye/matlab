function [button,t] = WaitMouseClick(timeout,whichButtons, whichMarkers)

if nargin < 1 || isempty(timeout)
    timeout = 10;
end
if nargin < 2 || isempty(whichButtons)
    whichButtons = (1:3);
end
if nargin < 3
    whichMarkers = [];
end
if ~isempty(whichMarkers)
    wm = whichMarkers;
    try % Quick and dirty test to see if buttons & markers match
        wm=whichButtons;
        wm=whichMarkers;
    catch
        error('Markers and Buttons do not match');
    end
end
% whichButtons = swap(whichButtons, 2, 3);

t0 = GetSecs();
while true
    if GetSecs() - t0 > timeout
        t = [];
        button = [];
        break
    end
    [xMouse, yMouse, mouseButtons] = GetMouse();
    if any(mouseButtons(whichButtons))
        t = GetSecs();
        i = find(mouseButtons(whichButtons), 1);
        button = whichButtons(i);
        % button = swap(whichButtons(i), 2, 3);
        if ~isempty(whichMarkers)
            WriteMarker(whichMarkers(i));
        end
        while true
            [xMouse, yMouse, mouseButtons] = GetMouse();
            if ~any(mouseButtons(whichButtons)) && GetSecs() - t > 10e-3
                break
            end
        end
        break
    end
end
