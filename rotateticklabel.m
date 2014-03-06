function th=rotateticklabel(h,rot,demo)
%ROTATETICKLABEL rotates tick labels
%   TH=ROTATETICKLABEL(H,ROT) is the calling form where H is a handle to
%   the axis that contains the XTickLabels that are to be rotated. ROT is
%   an optional parameter that specifies the angle of rotation. The default
%   angle is 90. TH is a handle to the text objects created. For long
%   strings such as those produced by datetick, you may have to adjust the
%   position of the axes so the labels don't get cut off.
%
%   Of course, GCA can be substituted for H if desired.
%
%   TH=ROTATETICKLABEL([],[],'demo') shows a demo figure.
%
%   Known deficiencies: if tick labels are raised to a power, the power
%   will be lost after rotation.
%
%   See also datetick.

%   Written Oct 14, 2005 by Andy Bliss
%   Copyright 2005 by Andy Bliss

%DEMO:
if nargin==3 
    if ~isempty(h) || ~isempty(rot)
        error('Do you want a demo or not?!')
    end
    x=[now-.7 now-.3 now];
    y=[20 35 15];
    figure
    plot(x,y,'.-')
    datetick('x',0,'keepticks')
    h=gca;
    set(h,'position',[0.13 0.35 0.775 0.55])
    rot=90;
end

%set the default rotation if user doesn't specify
if nargin==1
    if ishandle(h)
        rot=60
    else
        rot=h;
        h=gca;
    end
end
%set the default rotation if user doesn't specify
if nargin==0
    rot=90;
    h=gca;
end

%make sure the rotation is in the range 0:360 (brute force method)
rot=mod(rot,360);
% while rot>360
%     rot=rot-360;
% end
% while rot<0
%     rot=rot+360;
% end

%tries to find previously rotated labels
th=findobj(h, 'tag', mfilename);
%get current tick labels
a=get(h,'XTickLabel');
%erase current tick labels from figure
set(h,'XTickLabel',[]);
%get tick label positions
b=get(h,'XTick');
c=get(h,'YTick');
if isempty(th) || numel(th) ~= length(b)
    delete(th);
    %make new tick labels
    th=text(b,repmat(c(1)-.1*(c(2)-c(1)),length(b),1),a,'tag',mfilename);
end
if rot<180
    set(th, 'HorizontalAlignment','right');
else
    set(th, 'HorizontalAlignment','left');
end
for i=1:length(th)
    set(th(i),'position', get(th(i), 'position').*[0 0 1] + [b(i) c(1)-.1*(c(2)-c(1)) 0],'rotation',rot);
end