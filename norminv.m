function z = norminv(p,mu,sigma)
%NORMINV - Inverse Normal Law
%   [z] = norminv(p,mu,sigma)
%
%   Example
%       >> norminv()
%
%   See also: 

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2006 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2006-06-01 Creation
% 
% ----------------------------- Script History ---------------------------------
if nargin < 3
    sigma = 1; 
    if nargin < 2
        mu = 0;
    end
end
z=-sqrt(2)*sigma.*erfcinv(2*p) + mu;
%z=-sqrt(2)*erfcinv(2*p);
