function h = hot2(m,pR,pY)
%HOT2    Alternative Black-red-yellow-white color map.
%   HOT2(M,R,Y) returns an M-by-3 matrix containing a "hot" colormap in
%   which the proportion of red is set by R (default: 0.5)
%   and that of yellow by Y (default: 0.25).
%   HOT2, by itself, is the same length as the current colormap.
%
%   For example, to reset the colormap of the current figure:
%
%             colormap(hot2)
%
%   See also HSV, GRAY, PINK, COOL, BONE, COPPER, FLAG, 
%   COLORMAP, RGBPLOT.

%   K.N'Diaye 
%   C. Moler, 8-17-88, 5-11-91, 8-19-92.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.7 $  $Date: 2002/04/08 22:00:14 $

if nargin < 1, m = size(get(gcf,'colormap'),1); end
if nargin < 2, pR = .5; end
if nargin < 3, pY = .1; end

n1 = fix(pR*m);
n3 = fix(pY*m);
n2 = m-n1-n3;

r = [(1:n1)'/n1; ones(n2+n3,1)];
g = [zeros(n1,1); (1:n2)'/n2; ones(n3,1)];
b = [zeros(n1+n2,1); (1:m-n1-n2)'/(n3)];

h = [r g b];