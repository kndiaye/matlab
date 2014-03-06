function t = sprintf2(varargin)
%SPRINTF2 - Intelligent sprintf
%   S = sprintf2(A) tries to guess what would be the best format for A
%
%   S = sprintf2(FORMAT, A, ...) behaves like the native SPRINTF
%
%   Example
%       >> sprintf2(pi)
%
%   See also: sprintf, fprintf

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2010
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2010-04-01 Creation
%
% ----------------------------- Script History ---------------------------------

if nargin>1
    s= sprintf(varargin{:});
    return
end
y=varargin{1};
t='';
if isempty(y)   
    return
end
 brakets = '[]';
if numel(y)>1 & ~ischar(y)
    t = [brakets(1)];
    if isvector(y) && numel(y)<100 || (iscell(y) && size(y,1)<100)
        if size(y,1)==1
           sep = ',';
        elseif iscell(y)
            sep = sprintf('\t');
        else
            sep = ';';
        end
        if iscell(y)
            y=transpose(y);
        end
        for i=1:numel(y)
            if i>1
                t = [t sep];
            end
            if iscell(y)
                yy=y{i};
                if mod(i+1,size(y,1))==0
                    t=[t sprintf('\n')];
                end
            else
                yy= y(i);
            end
            t = [t sprintf2(yy)];
        end
    else
        t = [ t '...' ];
    end
    t = [t brakets(end)];
    return
end


if isnumeric(y)
    t = sprintf('%g',y);
elseif ischar(y)
    t = sprintf('%s',y);
elseif islogical(y)
    if y
        t = sprintf('true');
    else
        t = sprintf('false');
    end    
elseif iscell(y)
    brakets ='{}';
    t = [ brakets(1) sprintf2(y{1}) brakets(end) ];
elseif isa(y,'function_handle')
     t = char(y);
else
    t = sprintf('%s','???');
end