function [varargout] = DrawText(wPtr,txt,alignment,fgcol,bgcol)
%DRAWTEXT - One line description goes here.
%   [newXY] = DrawText(wPtr, text [,alignment ,fgColor ,bgColor])
%       Easy way to control position of the text on screen 
%       
%    alignment may be any of: 'l' (left), 'c' (horizontally centered),
%       'r' (right), 't' (top), 'm' (vertically middle), 'b' (bottom)
%       Any single letter can be used multiple times to: 'llc' position
%       the text quite on the left (66% of the half-width), whereas 'rccc'
%       puts it almost in the center (25% of the half-width off to the
%       right).
%       Alignment can also be specified as 2*1 or 4*1 numerical vector
%
%   Example
%       >> DrawText(w,'bla bla', 'ct') positions the text 'bla bla' at the
%               (c)entered at the (t)op
%
%       >> DrawText(w,'bla bla', 'ct') positions the text 'bla bla' at the
%               (c)entered at the (t)op
%
%   Based on: Screen('Drawtext?')
%   See also: DrawFormattedtext

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2009
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2009-02-02 Creation
%
% ----------------------------- Script History ---------------------------------

if nargin < 1
    error('DrawText: window handle missing!');
end

if nargin < 2 || isempty(txt)
    % Empty text string -> Nothing to do.
    return;
end
if isempty(wPtr)
    clc
    frame = OpenDisplay;
    wPtr=frame.ptr;
end
if nargin<3
    alignment='';
end
if nargin<4
    fgcol=[255];
end
if nargin<5
    bgcol=[];
end

% [x,x,x]=intersect(alignment,'lcr');
% if length(x)>1
%     error('Wrong horizontal alignment!');
% end
% [y,y,y]=intersect(alignment,'tmb');
% if length(y)>1
%     error('Wrong vertical alignment!');
% end

if ischar(txt)
    txt={txt};
end
wh =[];
for i=1:numel(txt)
    if isempty(txt{i})
        wh = [wh; Screen('TextBounds', wPtr, ' ')];
        wh(end,3)=0;
    else
        wh = [wh; Screen('TextBounds', wPtr, txt{i})];
    end
end
wh=wh(:,3:4)-wh(:,1:2);
%wh(:,1) = max(wh(:,1));
%wh(:,2)= cumsum(wh(:,2));

xy=zeros(size(wh,1),2);
if isnumeric(alignment)
    if numel(alignment) == 2
        x0=alignment(1);
        y0=alignment(2);
        x=0.*x0;
        y=0.*y0;
        x(x0==-1)=+1;
        x(x0==+1)=-1;
        y(y0==-1)=+1;
        y(y0==+1)=-1;

    elseif numel(alignment) == 4
        x0=alignment(1);
        y0=alignment(2);
        x=alignment(3);
        y=alignment(4);
    else
        error('Wrong numeric alignment')
    end
else
    x0=0;
    y0=0;
    alignment=lower(alignment);
    if isequal(alignment, 'center')
        alignment='c';
    end
    if isequal(alignment, 'right')
        alignment='r';
        x=-1;
    end
    if isequal(alignment, 'left')
        alignment='l';
        x=+1;
    end
    if isequal(alignment, 'top')
        alignment='t';
        y=+1;
    end
    if isequal(alignment, 'middle')
        alignment='m';
    end
    if isequal(alignment, 'bottom')
        alignment='b';
        y=-1;
    end

    [z,z]=ismember(alignment,'lcrtmb');
    if any(z==0)
        error('Wrong alignment parameter!');
    end
   if any(z<=3)
        x0=mean(z(z<=3),2)-2;
    else
        x0=NaN;
    end
    x0(isnan(x0))=0;
    if any(z>=4)
        y0=mean(z(z>=4),2)-5;
    else
        y0=NaN;
    end
    y0(isnan(y0))=0;
    x=0.*x0;
    y=0.*y0;
    x(x0==-1)=+1;
    x(x0==+1)=-1;
    y(y0==-1)=+1;
    y(y0==+1)=-1;
end

%scr = Screen('Resolution',wPtr);
r = [Screen('Rect', wPtr)];
scr.width  = r(3)-r(1);
scr.height = r(4)-r(2);

if abs(x0)<=1
    x0=(1+x0)*scr.width/2;
end
if abs(y0)<=1
    y0=(1+y0)*scr.height/2;
end

if x>1
    xy(:,1) = x0 + x;
else
    xy(:,1) = x0 + (x-1).*wh(:,1)/2;
end
if y>1
    xy(:,2) = y0 + y;
else
    xy(:,2) = y0 + (y-1).*sum(wh(:,2))/2+cumsum([0;wh(1:end-1,2)]);
end
for i=1:numel(txt)
    if isempty(txt{i})
        xy2(i,1)=xy(i,1);
        xy2(i,2)=xy(i,2);
    else
        [xy2(i,1) xy2(i,2)]=Screen('DrawText',wPtr,txt{i},xy(i,1),xy(i,2),fgcol,bgcol);
    end
end
varargout={};
if nargout>0
    varargout={xy2,xy,wh};
end
return
