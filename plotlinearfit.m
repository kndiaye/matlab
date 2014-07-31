function [h,slope,offset,R2,SCE,P,T] = plotlinearfit(Y,X,varargin)
%PLOTLINEARFIT - One line description goes here.
%   [h,slope,offset,R2,SCE,P,T] = plotlinearfit(Y,X)
%   [h,info] = plotlinearfit(Y,X)
%
%   Example
%       >> plotlinearfit(Y,X)
%
%   See also:

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2008
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2008-07-01 Creation
%
% ----------------------------- Script History ---------------------------------

if nargin<1
    error('No data!')
end
if numel(Y)==prod(size(Y))
    Y=Y(:);
    if nargin>=2
        X=X(:);
    end
end

switch nargin
    case 0
        error('No input!')
    case 1
        [slope,offset,R2,SCE,P,T] = linearfit(Y);
        X=1:size(Y,1);
    otherwise
        [slope,offset,R2,SCE,P,T] = linearfit(Y,X);
end
% [s,o,r2,sce,p]=linearfit(roi.allcons,roi.allregressors);
%     text(median(roi.allregressors), quantile(roi.allcons,.90), {'Correlation: '  sprintf('r2 = %g\np = %g', r2,p)})
%     xlabel(xSPM.SPM.xX.name(find(xSPM.SPM.xCon(Icc).c)))
%     ylabel(xSPM.SPM.xY.VY(1).descrip)
if size(X,2) == 1    
    h=plot(X, Y,'.', varargin{:});
elseif size(X,2) == 2
    for i=1:size(Y,2)
        h(i)=stem(X(:,1),X(:,2),Y(:,i),'.', varargin{:});
        %        h(i)=stem(X(:,1),X(:,2),Y(:,i), 'x',varargin{:});
    end
else
end
hold on;
h=h(:);
set(h, 'linestyle', 'none')
[xx]=axis;
for i=1:size(Y,2)
    h(i,2)=plot(xx(1:2)', xx(1:2)'*slope(i)+(xx(1:2)'.*0+1)*offset(i), ...
        '--', 'Color', get(h(i), 'Color'), 'Marker', 'none');
    hold on
end
set(h(P<.05,2),'LineStyle', '-');
hold off
if nargout==0
    set(h(P>0.05,2),'LineStyle',':');
    fprintf('Slope....: %s\n',sprintf('% 5.2g\t',slope));
    fprintf('Offset...: %s\n',sprintf('% 5.2g\t',offset));
    fprintf('r2.......: %s ; r = %s\n',sprintf('% 5.2g\t',R2),sprintf('% 5.2g\t',sqrt(R2)));
    fprintf('p-value..: %s\n',sprintf('% 5.2g\t',P));
    fprintf('SCE......: %s\n',sprintf('% 5.2g\t',SCE));
    fprintf('T........: %s\n',sprintf('% 5.2g\t',T));
end
if nargout == 2
    slope=struct('slope',slope,'offset',offset,'r2',R2,'sce',SCE,'p',P,'t',T);
end

