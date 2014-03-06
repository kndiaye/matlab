function t = cell2str(c,sep,s)
%CELL2STR - Convert a cell array into text (i.e. string array)
%   [S] = cell2str(C)
%
%   Example
%       >> celldisp2
%
%   See also: celldisp

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

%error(nargchk(1,2,nargin,'struct'));
if ~iscell(c),
    error('MATLAB:celldisp:notCellArray', 'Must be a cell array.');
end
if nargin<2, sep = {'-' '|' }; end
if nargin<3, s = inputname(1); end
if isempty(s), s = 'ans'; end

for i=1:numel(c),
    if iscell(c{i}) && ~isempty(c{i}),
        t=sprintf( '%s\n%s\n%s',s,repmat(sep{1}, [1 size(s,2)]), cell2str(c{i},sep,[s subs(i,size(c))]));
    else
        t=sprintf('%s%s =\n',s,subs(i,size(c)));

        if ~isempty(c{i}),
            t=sprintf('%s%s',t,);
        else
            if iscell(c{i})
                disp('     {}')
            elseif ischar(c{i})
                disp('     ''''')
            elseif isnumeric(c{i})
                disp('     []')
            else
                [m,n] = size(c{i});
                disp(sprintf('%0.f-by-%0.f %s',m,n,class(c{i})))
            end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s = subs(i,siz)
%SUBS Display subscripts

if length(siz)==2 && any(any(siz==1))
    v = cell(1,1);
else
    v = cell(size(siz));
end
[v{1:end}] = ind2sub(siz,i);

s = ['{' int2str(v{1})];
for i=2:length(v),
    s = [s ',' int2str(v{i})];
end
s = [s '}'];