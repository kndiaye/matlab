function [a] = absolutepath(r,p,c)
%ABSOLUTEPATH()  -  Returns the absolute path
%
%   a = absolutepath(r,p) returns a char array a giving absolute path of r
%   (relatively to path p, if not given relatively to current path )
%
%   a = absolutepath(r,p,c) indicates the computer type to work in
%   c can be 'PCWIN'|'GLNX86' (see: computer). Default is to use current
%   environment.
%   If [c] == 1, absolutepath will try to move in the resulting path [a] so
%   as to clean of any relative (e.g., '..') and symbolic links in [a]
if  nargin < 3
    c = computer;
end
if  nargin < 2
    p = cd;
end
a=p;
if nargin<1
    return
end

if ispc
    % Windows is not case-sensitive!
    p=lower(p);
    r=lower(r);
end
if isabsolute(r,c)
    %     if nargin < 2
    warning('Input path is already an absolute path: %s', r)
    %     else
    %         error('Cannot set r relatively to path p for it is already an absolute path: %s', r)
    %     end
    a = r;
else
    if isequal(c, 'PCWIN') || (isequal(c,1) && ispc)
        filesep = '\';
        if length(r)>1 && isequal(r(1), filesep)
            % In windows '\bla' is ambiguous about the drive
            if isequal(p(2), ':')
                p=p(1:2);
            else isequal(p(1:2), [filesep filesep])
                p=[ filesep filesep strtok(p, filesep)];
            end
        end
    else
    a=fullfile(p,r);
end

if isequal(c,1)
    lcd=cd;
    cd(a);
    a=cd;
    cd(lcd);
end

return

function tf = isabsolute(p,c)
% Test if path p is an absolute path in the current environment
tf = true;
if isequal(c,1)
    c = computer;
end
switch c
    case 'GLNX86'
        filesep = '/';
        if ~isempty(p) && ( isequal(p(1), filesep) || isequal(p(1), '~'))
            % In Unix /bla is absolute as well as '~/bla'
            % (whereas in Windows \bla doesn't specify the drive)
            return;
        end
    case 'PCWIN'
        filesep = '\';
        if  length(p)>1 &&  ...
                ( isequal(p(1:2),[ filesep filesep ]) || ...
                isequal(p(1:2),[   ':' filesep   ]) )
            %  C:\bla\... or \\network\... schemes in windows
            return;
        end
end
tf=false;
return


if ispc
    if length(p)>0 && isequal(p(1), filesep)
        p = strtok(cd, filesep);
    end
end



if ispc
    if length(p)>1 && isequal(p(2), ':')

    elseif length(p)>1 && isequal(p(2), filesep)
        % network location

    end

end

% Predefine return string:
abs_path = '';

% Make sure strings end by a filesep character:
if  length(act_path) == 0   |   ~isequal(act_path(end),filesep)
    act_path = [act_path filesep];
end
if  length(rel_path) == 0   |   ~isequal(rel_path(end),filesep)
    rel_path = [rel_path filesep];
end

% Convert to all lowercase:
[act_path] = fileparts( lower(act_path) );
[rel_path] = fileparts( lower(rel_path) );

% Create a cell-array containing the directory levels:
act_path_cell = pathparts(act_path);
rel_path_cell = pathparts(rel_path);
abs_path_cell = act_path_cell;

% Combine both paths level by level:
while  length(rel_path_cell) > 0
    if  isequal( rel_path_cell{1} , '.' )
        rel_path_cell(  1) = [];
    elseif  isequal( rel_path_cell{1} , '..' )
        abs_path_cell(end) = [];
        rel_path_cell(  1) = [];
    else
        abs_path_cell{end+1} = rel_path_cell{1};
        rel_path_cell(1)     = [];
    end
end

% Put cell array into string:
for  i = 1 : length(abs_path_cell)
    abs_path = [abs_path abs_path_cell{i} filesep];
end

return

% -------------------------------------------------

function  path_cell = pathparts(path_str)

path_str = [filesep path_str filesep];
path_cell = {};

sep_pos = findstr( path_str, filesep );
for i = 1 : length(sep_pos)-1
    path_cell{i} = path_str( sep_pos(i)+1 : sep_pos(i+1)-1 );
end

return