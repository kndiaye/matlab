function  S = sprintf2cell(F,varargin)
%SPRINTF2CELL - sprintf to separate cells
%   [] = sprintf2cell(input)
%
%   Example
%       >> sprintf2cell
%
%   See also:

% Author: K. N'Diaye (kndiaye01<at>gmail.com)
% Copyright (C) 2010
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2010-10-05 Creation
%
% ----------------------------- Script History ---------------------------------

S = {sprintf(F)};
if nargin>1
    sz = cellfun('prodofsize',varargin);
    u = unique(sz(sz~= 1));
    if numel(u) > 1
        error('arguments should be of the same size')
    end
    for i=1:u
        A = {};
        for j = 1:(nargin-1)
            if iscell(varargin{j})
            end
            if sz(j)==1
                A{end+1} = varargin{j};
            else
                A{end+1} = varargin{j}(i);
            end
        end        
        S{i,1} = sprintf(F,A{:});
    end
end