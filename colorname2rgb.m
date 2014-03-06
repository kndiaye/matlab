function  y = colorname2rgb(x)
%COLORNAME2RGB - Converts colornames to
%   [] = colorname(x)
%
%   Example
%       >> colorname('r')
%           [ 1 0 0 ]
%   See also:

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2007
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2007-10-02 Creation
%
% ----------------------------- Script History ---------------------------------
if isnumeric(x)
    y=x;
    return;
end
if iscell(x)
    y=cell(size(x));
    for i=1:numel(x)
        y{i}=colorname2rgb(x{i});
    end
    return
end
if ischar(x)
    if size(x,1) >1
        y=NaN*zeros(size(x,1),3);
        for i=1:size(x,1)
            y(i,:)=colorname2rgb(x(i,:));
        end
    else
        switch lower(x)
            case { 'k' 'black'}
                y=[0 0 0];
            case { 'w' 'white'}
                y=[1 1 1];
            case { 'r' 'red'}
                y=[1 0 0];
            case { 'g' 'green'}
                y=[0 1 0];
            case { 'b' 'blue'}
                y=[0 0 1];
            case { 'y' 'yellow'}
                y=[1 1 0];
            case { 'c' 'cyan'}
                y=[0 1 1];
            case { 'm' 'magenta'}
                y=[1 0 1];

            otherwise
                y=str2num(x)
        end
    end
end
if isempty(y)
    y=NaN;
end
