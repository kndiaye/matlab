%SENSORNAMES - Retrieves the name of the sensors in the data
%   [] = sensornames(dh)
%
%   Example
%       >> sensornames
%
%   See also:

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2010
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2010-04-22 Creation
%
% ----------------------------- Script History ---------------------------------
function s = sensornames(dh)
s = {dh.supersensor.name};
end