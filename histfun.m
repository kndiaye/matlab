function [Z,C,B] = histfun(X,Y,E,fun)
%HISTFUN - Apply a function to each class of a histogram
%   [Z,C] = histfun(X,Y,E,fun)
%
%   Example
%       >> x = randn(100,1);
%       >> y = x.^2
%       >> histfun(x,y,10,'mean')
%
%   See also: histc, cellfun, histk()

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2009
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2009-02-10 Creation
%
% ----------------------------- Script History ---------------------------------

if nargin<4
    fun = @mean;
end
if isempty(Y)
    Y=X;
end
if isempty(E)
    E=10;
end

if numel(E)==1
    [C] = bins(X,E-1);
    C = [-Inf C Inf];
    [N,B] = histc(X,C);
else
    C=E;
    [N,B] = histc(X,[E]);
end
for i=1:(length(C)-1)
    if any(B==i)
        Z(i)=feval(fun, Y(B==i));
    else
        Z(i)=NaN;
    end
end
return

function n=count(x)
n=length(x);    

function [b]=bins(y,n)
% Compute n bins from data 
%
miny = min(y(~isnan(y)));
maxy = max(y(~isnan(y)));
if (isempty(miny))
    % In acase all nan...
    miny = NaN;
    maxy = NaN;
end
if miny == maxy,
    miny = miny - floor(n/2) - 0.5;
    maxy = maxy + ceil(n/2) - 0.5;
end
bw = (maxy - miny) ./ n;
b = miny + bw/2 + bw*(0:n-1) ;