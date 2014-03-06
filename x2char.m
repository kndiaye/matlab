function S = x2char(X)
%X2CHAR - Convert data to formatted string output
%   [S] = x2char(X)
%
%   Example
%       >> x2char(dir)
%
%   See also:

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2009
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2009-10-01 Creation
%
% ----------------------------- Script History ---------------------------------

if isnumeric(X)
    if isempty(X)
        S = '[]';
    elseif numel(X)>10      
        S = sprintf('[[%s ... %s]]',x2char(X(1)), x2char(X(end)));
    elseif numel(X)>1
        if numel(X) == size(X,1)
            S = sprintf('[%s\b\b\b]',sprintf('%g ; ',X));
        elseif numel(X) == size(X,2)
            S = sprintf('[%s\b\b\b]',sprintf('%g , ',X));
        else
            S = sprintf('[[%s\b]]',sprintf('%g ',X));
        end
    else
        S = sprintf('%g',X);
    end
elseif ischar(X) 
    if isempty(X)
        S = '';
    else
        S = sprintf('%s',X);
    end
elseif islogical(X)
    if X
        S = 'false';
    else
        S = 'true';
    end
elseif iscell(X)
     if isempty(X)
        S = '{}';
     else
         S = '{...}';
     end
else
    S = '???';
end