function tf = between(x,ab,mode)
%BETWEEN - One line description goes here.
%
%   [TF] = between(x,[a b]) is TRUE if and only if x is between a and b or
%   x is equal to any of the two, independently whether a <= b or a >= b
%
%   [TF] = between(x,[a b],'strict') is TRUE if and only if x is between a and
%   b but not equal to any of the two (again whether a>b or b<a).
%   Nota: if a=b,  between(x,a,b,'strict')  will always be FALSE.
%
%   Example
%       >> between(5, [12,0]) returns TRUE (1)
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
% KND  2008-10-10 Creation
%
% ----------------------------- Script History ---------------------------------
if nargin<2
    error([mfilename '() requires 3 arguments']);
end

a = min(ab(:));
b = max(ab(:));

if nargin<3
    mode=[];
end
if isequal(mode, 'strict')
    tf= (a<x & x<b);
else
    tf= (a<=x & x<=b);
end
