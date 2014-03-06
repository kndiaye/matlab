function varargout = vline(x,varargin)
%VLINE - Create a vertical line on a plot
%   [h] = vline(x)
%   Adds as many vertical lines on the current plot as there are values in  x.
%
%   See also: line, hline

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2006 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2006-02-02 Creation
% KND  2009-10-22 Corrected bug with single argument for linestyle
% ----------------------------- Script History ---------------------------------

%y=max(abs(get(gca, 'Ylim')))*[-1 1];
%y=*10;
y=get(gca, 'Ylim');
if isequal(get(gca, 'Yscale'),'log')
    % not a perfect trick to deal with log scales... 
    yt = get(gca,'Ytick');    
    y = [yt(1).^2/yt(2) y(2)];
end
x=x(:);
x=[x*ones(1,2)]';
y=repmat(y,size(x,2),1)';

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
LineStyles={'-', ':', '--', '-.'};
if nargin>3
    if isempty(strmatch('linestyle', lower(varargin(cellfun('isclass', varargin, 'char'))))) && ...
            isempty(intersect(LineStyles,lower(varargin(cellfun('isclass', varargin, 'char')))))
        for i=1:length(h);
            set(h(i), 'LineStyle', LineStyles{mod(ceil(i/size(get(gca, 'ColorOrder'),1))-1,4)+1});
        end
    end
end
if nargout==0
    return
end
varargout={h};
