function [c,rt,pos]=ConfidenceScale2_mod(frame,nlevels,labels)
% ConfidenceScale - Scale for confidence rating
if nargin<1
    DEBUG=1;
else
    DEBUG=0;
end

%% Behaviour & visual aspect of the scale
%
% Shape parameters
% They are all relative top the field of view (fov) which is itself based
% on the frame/window size :
scale.orientation = 90;  % vertical = 0 ; horizontal = 90
scale.excentricity = .5;  % position of the scale on screen
scale.length =  .3;   % length of the scale
scale.shape = .25;    % width-to-length ratio
scale.contour=1/60;   % pen width (relatively to frame size)
scale.ticks = 1;      % display ticks on the scale

% NaN = starts at a random position; 0.5 = starts at the middle position;
scale.startlevel = 0.75;

% Number of consecutive key press to go to fast mode
nkey = 10;
sluggish = 0.1; % minimum time between consecutive keypresses
keytimebreak = 0.3;
% To validate, SS press
% Esc = 27 or SPACE = 32 or RETURN = 13
OkKey = [32 13];
EscKey = 27;

%% Processing of inputs
if nargin<1
    frame =[];
end
WindowWasOpen = 0;
if isempty(frame)
    clc
    Screen('Preference', 'SkipSyncTests', 1);
    frame = OpenDisplay([800,600], [0]);
    frame.window = frame;
    WindowWasOpen = 1;
end
if ~isfield(frame, 'rect')
    frame.rect= Screen('Rect', frame.ptr);    
    frame.size = frame.rect(3:4);
end
w = frame.ptr;

black = BlackIndex(w);
white = WhiteIndex(w);
red = [white(1) black(1) black(1)]/3;
blue = [black(1) black(1) white(1)]./[3 3 1];
grey = white/3;

scale.bgcolor = black;
scale.fgcolor = blue;
scale.bordercolor = grey;
scale.textcolor = white*.75;

% "Field of View"
fov = min(frame.size);

if nargin<2
    nlevels=20;
end
if isnan(scale.startlevel)
    c=floor(rand*(nlevels+1));
elseif scale.startlevel<1
    c=round(scale.startlevel*nlevels);
else
    c=scale.startlevel;
end
small_inc=1;
big_inc = max(small_inc,nlevels/25);

if nargin<3
   labels={' ' ' ' };
%   labels={'Totalement incertain','Sur de son choix'};
end

%% Drawing of the scale
scale.orientation

rect = fov*scale.length*[scale.shape 1];
pos  = RectAlign(rect,frame.size, 'c');
% Bottom label
DrawText(w,labels{1}, [mean(pos([1 3])) ...
    frame.size(2)*(1-(1-scale.length)/4)], scale.textcolor);
DrawText(w,labels{2}, [mean(pos([1 3])) ...
    frame.size(2)*((1-scale.length)/4)], scale.textcolor)

penwidth = fov*scale.contour;
Screen('FrameRect',w,scale.bordercolor,pos, penwidth);

% Upper Black rectangle
pos2 = pos + penwidth/2*[1 1 -1 -1];
pos2 = pos2([1 2 3 2]) + [0 0 0 +1]*(nlevels-c)/(nlevels)*(pos2(4)-pos2(2));
Screen('FillRect',w,scale.bgcolor,pos2);

% Lower Filling Rectangle
pos2 = pos + penwidth/2*[1 1 -1 -1];
pos2 = pos2([1 2 3 4]) + [0 +1 0 0]*(nlevels-c)/(nlevels)*(pos2(4)-pos2(2));
Screen('FillRect',w,scale.fgcolor,pos2);

Screen('Flip', w, 0, 0);



%% User interaction

ListenChar(2);
[keyIsDown,rt]=KbCheck;
secs(1:nkey) = rt;
prevc=c;
while true
    [secs(nkey), keyCode] = KbWait;
    if any(keyCode(EscKey))        
        rt=NaN;
        c=NaN;
        break
    end
    if any(keyCode(OkKey))
        break
    end
    inc=0;

    if (secs(nkey)-secs(nkey-1)) > sluggish
        % slow mode
        secs(1:nkey)=secs(nkey);
        inc=small_inc;
    elseif all(diff(secs)>0)
        if all(diff(secs) < sluggish)
            % fast mode
            inc=big_inc;
        else
            % wait that nkey have been sampled
            inc=0;
        end
    end
    % change cursor only once we are in slow or fast mode
    if keyCode(38)
        c=min(c+inc,nlevels);
    elseif keyCode(40)
        c=max(c-inc,0);
    end
    secs(1:nkey-1) = secs(2:nkey);

    %border
    penwidth = fov*scale.contour;
    Screen('FrameRect',w,scale.bordercolor,pos, penwidth);

    % Upper Black rectangle
    pos2 = pos + penwidth/2*[1 1 -1 -1];
    pos2 = pos2([1 2 3 2]) + [0 0 0 +1]*(nlevels-c)/(nlevels)*(pos2(4)-pos2(2));
    Screen('FillRect',w,scale.bgcolor,pos2);

    % Lower Filling Rectangle
    pos2 = pos + penwidth/2*[1 1 -1 -1];
    pos2 = pos2([1 2 3 4]) + [0 +1 0 0]*(nlevels-c)/(nlevels)*(pos2(4)-pos2(2));
    Screen('FillRect',w,scale.fgcolor,pos2);

    
    DrawText(w,sprintf('%2.0f%', 100*prevc/nlevels), [mean(pos([1 3])) ...
    frame.size(2)*((1.5-scale.length)/4)], scale.bgcolor);
    DrawText(w,sprintf('%2.0f%', 100*c/nlevels), [mean(pos([1 3])) ...
    frame.size(2)*((1.5-scale.length)/4)], 200);
    prevc=c;
    Screen('Flip', w, 0, 0);

    
end
try
ListenChar(0);
end;
if WindowWasOpen
    Screen('Close', w);
end
rt=secs(nkey)-rt;

