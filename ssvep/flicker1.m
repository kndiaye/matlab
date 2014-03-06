% rotating hemifield flickering checkerboard
rcycles = 8; % number of white/black circle pairs
tcycles = 24; % number of white/black angular segment pairs (integer)
flicker_freq = 4; % full cycle flicker frequency (Hz)
flick_dur = 1/flicker_freq/2;
period = 30; % rotation period (sec)
[w, rect] = SCREEN('OpenWindow', 0, 128);
HideCursor
xc = rect(3)/2;
yc = rect(4)/2;
% make stimulus
hi_index=255;
lo_index=0;
bg_index =128;
xysize = rect(4);
s = xysize/sqrt(2); % size used for mask
xylim = 2*pi*rcycles;
[x,y] = meshgrid(-xylim:2*xylim/(xysize-1):xylim, - ...
xylim:2*xylim/(xysize-1):xylim);
at = atan2(y,x);
checks = ((1+sign(sin(at*tcycles)+eps) .* ...
sign(sin(sqrt(x.^2+y.^2))))/2) * (hi_index-lo_index) + lo_index;
circle = x.^2 + y.^2 <= xylim^2;
checks = circle .* checks + bg_index * ~circle;
t(1) = SCREEN('MakeTexture', w, checks);
t(2) = SCREEN('MakeTexture', w, hi_index - checks); % reversed contrast
flick = 1;
flick_time = 0;
start_time = GetSecs;
while (1) % animation loop
thetime = GetSecs - start_time; % time (sec) since loop started
if thetime > flick_time % time to reverse contrast?
flick_time = flick_time + flick_dur; % set next flicker time
flick = 3 - flick;
end
SCREEN('DrawTexture', w, t(flick));
% draw mask
theta = 2*pi * mod(thetime, period)/period;
st = sin(theta);
ct = cos(theta);
xy = s * [-st,-ct; -st-ct,st-ct; st-ct,st+ct; st,ct] + ...
ones(4,1) * [xc yc];
SCREEN('FillPoly', w, bg_index, xy);
SCREEN('Flip', w);
if KbCheck
break % exit loop upon key press
end
end
ShowCursor
SCREEN('Close',w);