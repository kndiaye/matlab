function X = loadfield(filename,fieldname)
%LOADFIELD - Load a given variable from a .mat file
%   [X] = loadfield(filename,fieldname)
%
%   Example
%       >> a=loadfield('test.mat', 'a')
%
%   See also: load, getfield

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2006 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2006-01-11 Creation
%                   
% ----------------------------- Script History ---------------------------------

if nargin<2
    error('No field/vraible given!')
end
X=getfield(load(filename, fieldname), fieldname);