function [c,rt,events,onset_time]=ConfidenceDisc(frame,nlevels,timelimit,keylist,markers,FOV)
% ConfidenceScale - disc for confidence rating
%	[c,rt]=ConfidenceDisc(frame,nlevels,timelimit)
%   
%   markers.onset
%   markers.keys
c=NaN;
rt=NaN;
events=[];            
if nargin<1
    DEBUG=1;
else
    DEBUG=0;
end
if ~exist('keylist','var')
    keylist={};
end
sendMarkers = 0;
if nargin>4
    sendMarkers = 1;    
end

%% Behaviour & visual aspect of the disc
%
% Shape parameters
% They are all relative top the field of view (fov) which is itself based
% on the frame/window size :
disc.diameter = .25;   % height of the disc
disc.contour=1/60;   % pen width (relatively to frame size)

% NaN = starts at a random position;
disc.startlevel = NaN;

% Number of consecutive key press to go to fast mode
nkey = 10;
repetitiontime = 0.05; % minimum time between consecutive keypresses
keytimebreak = 0.3;

% To validate, SS press
% Esc = 27 or SPACE = 32 or RETURN = 13
if isempty(keylist)
    keylist = { 
        [ KbName('LeftArrow')  KbName('LeftAlt')  KbName('LeftControl')  74 257]
        [ KbName('RightArrow') KbName('RightAlt') KbName('RightControl') 75 258] 
        [ KbName('Return') KbName('Space') 259 ] 
        [ KbName('Escape') ] };
end

listenParPort = 0;
if any([keylist{:}]>256) 
    if exist('ReadParPort')==2
        listenParPort = 1;
    else
        error('Listening to Parallel port requires readParPort() function');
    end
end

if listenParPort || sendMarkers
    OpenParPort(1);
end

keys.less = keylist{1};
keys.more = keylist{2};
keys.ok = keylist{3};
keys.quit = keylist{4};
keys.resp = [ keys.less keys.more keys.ok keys.quit];

%% Processing of inputs
if nargin<1
    frame =[];
end
WindowWasOpen = 0;
if isempty(frame)
    clc
    Screen('Preference', 'SkipSyncTests', 1);
    frame = OpenDisplay([800,600], [140 140 140]);
    WindowWasOpen = 1;
end
w = frame.ptr;

black = BlackIndex(w);
white = WhiteIndex(w);
red = [white(1) black(1) black(1)]/3;
blue = [black(1) black(1) white(1)]./3;
grey = white/3;
if isfield(frame, 'color')
    disc.bgcolor = frame.color;
else
    disc.bgcolor = black;
end
disc.fgcolor = 2*grey;
disc.bordercolor = grey;
disc.textcolor = white*.75;

% "Field of View"
if nargin<6
    fov = min(frame.size);
else
    fov = FOV;
end

if nargin<2
    nlevels=[]; % = 8 including zero!
end
if isempty(nlevels)
    nlevels=7; % = 8 including zero!
end
if isnan(disc.startlevel)
    c=1+floor(rand*(nlevels-1));
elseif disc.startlevel<1
    c=round(disc.startlevel*nlevels);
else
    c=disc.startlevel;
end
small_inc=1;
big_inc = max(small_inc,nlevels/25);

if nargin<3
    timelimit = Inf;
end
if nargin<4
    labels={'Totalement incertain' 'Sûr et certain' };
end


%% Drawing of the disc
rect = fov*disc.diameter*[1 1];
pos  = RectAlign(rect,frame.size, 'c');
penwidth = fov*disc.contour*disc.diameter;
Screen('FrameArc', w, disc.bordercolor, pos, 0, 360, penwidth)

% Remainder
pos2 = pos + penwidth*[1 1 -1 -1]/2;
Screen('FillArc',  w, disc.bgcolor, pos2, 360*(1-(nlevels-c)/nlevels), 360);
% Lines
pos3 = [ (pos(3)-pos(1))/2 , (pos(3)-pos(1))/2 ];
radius = pos3-penwidth/2;
pos3 = pos3 + pos(1:2);
angle = c/nlevels*2*pi;
Screen('DrawLine',  w, disc.bordercolor, pos3(1),pos3(2),pos3(1),pos3(2)-radius(2), penwidth);
Screen('DrawLine',  w, disc.bordercolor, pos3(1),pos3(2), ...
    pos3(1)+radius(1)*(sin(c/nlevels*2*pi)), ...
    pos3(2)-radius(2)*(cos(c/nlevels*2*pi)), ...
    penwidth);

% Filling
Screen('FillArc',  w, disc.fgcolor, pos2, 0, 360*(c)/nlevels);
%% User interaction
try
    ListenChar(2);
end;

% Flip screen to show initial position
if exist('c:/documents and Settings/knierim/')
    onset_time=Screen('Flip', w, 0);
else
    onset_time=Screen('Flip', w, 0,1);
end
if sendMarkers
    WriteParPort(markers.onset);
end

% onset_time will be used to re-compute the response time according to the onset
% time of the display
secs(1:2) = onset_time;
rt=NaN;
btnPress = 0;

% Log info regarding state of the confidence disc at onset
events(1).c=c;
events(1).dir=nan;
events(1).k=[];
events(1).press_time=secs(1);
fprintf('c = %d ',c);

while true
    % Is response time over?
    if (secs(2)-onset_time) > timelimit
        fprintf(' >< time over.\n');
        c=NaN;
        break
    end    
    % Reads buttons from parallel port
    if listenParPort
        [btnPress] = ReadParPort(0);   
    end
    [keyIsDown, secs(2), keyCode] = KbCheck;
    keyCode=logical([keyCode bitget(btnPress,1:3)]);
    if any(keyCode(keys.resp));
        inc=0;
        dir=0;
        % Subject pressed Escape (or the like)
        if any(keyCode(keys.quit))
            rt=NaN;
            c=NaN;
            break
        elseif any(keyCode(keys.ok))
            % Subject has validated his/her response
            if sendMarkers
                WriteParPort([c,markers.keys(keyCode),markers.onset]);                
                WaitSecs(0.0078);
            end
             % log events
            events(end+1).c=c;
            events(end).press_time=secs(2);
            events(end).dir=nan;            
            events(end).k=find(keyCode);
            fprintf(' = %d ; RT=%0.3fs\n',c,secs(2)-onset_time)
            break
        elseif any(keyCode(keys.more))
            dir=+1;
        elseif any(keyCode(keys.less))
            dir=-1;
        end
        if (secs(2)-secs(1)) > repetitiontime
            if sendMarkers
                WriteParPort(markers.keys(keyCode));
                WaitSecs(0.0078);
                WriteParPort(markers.onset);
            end
            % Separated clicks
            inc=small_inc;     
            % Update confidence value
            c=c+dir*inc;
            c=max(c,0);
            c=min(c,nlevels);
            % log events
            events(end+1).c=c;
            events(end).press_time=secs(2);
            events(end).dir=dir;
            events(end).k=find(keyCode);
            %             fprintf('RT=%0.3fs [key=%s] %d -> c=%d\n',secs(2)-rt,...
            %                 sprintf('%d ',events(end).k),events(end).dir,c)
            if dir>0
                fprintf('%s', '+');
            elseif dir<0
                fprintf('%s', '-');
            end
            %fprintf('%d', c);
            %d'> c=%d\n',secs(2)-onset_time,...
            %                 sprintf('%d ',events(end).k),events(end).dir,c)
        end
        secs(1)=secs(2);

        % Update the display
        % secs(1:nkey-1) = secs(2:nkey);
        Screen('FillArc', w, disc.bgcolor, pos2, 360*(1-(nlevels-c)/nlevels), 360);
        Screen('DrawLine',  w, disc.bordercolor, pos3(1),pos3(2),pos3(1),pos3(2)-radius(2), penwidth);
        Screen('DrawLine',  w, disc.bordercolor, pos3(1),pos3(2), ...
            pos3(1)+radius(1)*(sin(c/nlevels*2*pi)), ...
            pos3(2)-radius(2)*(cos(c/nlevels*2*pi)), ...
            penwidth);
        Screen('FillArc', w, disc.fgcolor, pos2, 0, 360*(c)/nlevels);
        if exist('c:/documents and Settings/knierim/')
            secs(2)=Screen('Flip', w, 0);
        else
            secs(2)=Screen('Flip', w, 0,1);
        end

    end
end

try
    ListenChar(0);
end;
if WindowWasOpen
    Screen('Close', w);
    if doSendMarkers 
        WriteParPort(0);
    end
end
rt=secs(end)-onset_time;

