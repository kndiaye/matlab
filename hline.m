function varargout = hline(y,varargin)
%HLINE - Create a horizontal line on a plot
%   [h] = hline(y)
%   Adds as many horizontal lines on the current plot as there are values in y.
%
%   See also: line, vline

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2006
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2006-02-02 Creation
%
% ----------------------------- Script History ---------------------------------

%x=max(abs(get(gca, 'Xlim')))*[-1 1];
%x=x*10;
x=get(gca, 'Xlim');
y=y(:);
y=[y*ones(1,2)]';
x=repmat(x,size(y,2),1)';

holdstate=ishold;
hold on;
if nargin>1 && ischar(varargin{1}) && mod(nargin-1,2)==1 
    opt=[];
    c = ismember(varargin{1}, 'bgrcmykw');
    m = ismember(varargin{1}, '.ox+*sdv^<>ph');
    if any(c)
        opt=[{'Color', varargin{1}(c)} opt];
    end
    if any(m)
        opt=[{'Marker', varargin{1}(m)} opt];
    end
    if any(~c & ~m)
        opt=[{'LineStyle', varargin{1}(~c & ~m)} opt];
    end
    varargin(1)=[];
    varargin = [opt varargin];
end
h=line(x,y,varargin{:});
if ~holdstate
    hold off;
end
if nargin==1
    LineStyles={'-', ':', '--', '-.'};
    for i=1:length(h);
        set(h(i), 'LineStyle', LineStyles{ceil(i/size(get(gca, 'ColorOrder'),1))});
    end
end
if nargout==0
    return
end
varargout={h};
