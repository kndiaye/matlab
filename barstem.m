function h = barstem(x,y,z,bw)
%BARSTEM - 3D bar version of stem3
%   [] = barstem(x,y,z,barwidth)
%
%   Example
%       >> h=barstem(rand(15,1), rand(1,15), randn(1,15));
%       >> shading interp; set(h, 'CData', get(h, 'ZData'),'EdgeColor', 'k')
%   See also:

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2009
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2009-03-23 Creation
%
% ----------------------------- Script History ---------------------------------
[n] = numel(y);


if numel(x) ~= numel(y) 
    if numel(x)==1 || numel(y)==1
        x = x(:,ones(1,numel(y)));
        y = y(:,ones(1,numel(x)));
    end
end

% Remove y values to 0 where y is NaN;
k = find(isnan(y));
if ~isempty(k), y(k) = 0; end

x=x(:)';
y=y(:)';
z=z(:)';

if nargin<4
    bw = [ min(diff(sort(x))) min(diff(sort(y))) ];
    bw = triu(sqrt((meshgrid(x)-meshgrid(x)').^2 + (meshgrid(y)-meshgrid(y)').^2 ),1);
    bw(bw==0)=Inf;
    bw=min(min(bw))*sqrt(1/2)/2;
    %bw = bw*.95;

end

if numel(bw)==1
    bw=[bw bw];
end

zz = zeros(6*4,n);
yy = zz;
xx = zz;

zz([6 7 10 11],:) = repmat(z, 4,1);
xx = kron(ones(6,1), kron([x-bw(1) ; x+bw(1) ], [1;1])); 
yy = kron([y-bw(2) ; y+bw(2) ; y-bw(2)],ones(8,1));  
i = [1 4 13 16 17 20 21 22 23 24 ];
zz(i,:) = nan;
yy(i,:) = nan;
xx(i,:) = nan;

cc = repmat(z,24,1);


zz = reshape(zz, 4, [])';
yy = reshape(yy, 4, [])';
xx = reshape(xx, 4, [])';

cc = reshape(cc, 4, [])';


edgec = get(gcf,'defaultaxesxcolor');
facec = 'flat';
h=[];
h = [surf(...
    'xdata',xx,...
    'ydata',yy, ...
    'zdata',zz,...
    'CData',cc,...
    'FaceColor',facec,...
    'EdgeColor',edgec,...
    'tag',mfilename)];