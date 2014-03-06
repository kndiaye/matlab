function [Y,I] = maxabs(X,varargin)
%MAXABS - Signed maximum of absolute value
%   [Y,I] = maxabs(X,varargin)
%
%   Example
%       >> maxabs([-3 2 1]) ouputs: -3
%
%   See also: max, max2

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2006
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2006-02-26 Creation
%
% ----------------------------- Script History ---------------------------------

[Y,I]=max(abs(X),varargin{:});
[Z,J]=max(X,varargin{:});
if ~isequal(size(Y),size(X))
    Y(I~=J)=-Y(I~=J);
else
    Y=X;
end
