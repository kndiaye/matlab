function S = fileparts2(fname,arg, mode)
%FILEPARTS2 - One line description goes here.
%   [S] = fileparts2(FILE,ARG) returns a specific part of a filename
%       ARG can be specified as text or as a numerical value:
%           'path' [0] (default) 
%           'name' [1]
%           'ext' [0.1]
%           'name.ext' [1.1] 
%           'shortname' [2]
%           'path\name' [3]
%           'root' [-Inf] 
%       if ARG is a negative integer, retrieves the n-th folder up.
%   [S] = fileparts2(FILE,ARG,MODE) 
%       if MODE is:
%           'none', retrieves path as given in the FILE argument
%           'absolute' converts output to an absolute path
%           'relative' force output to be a relative path
%           
%   Example
%       >> fileparts2('d:\tmp\test.ext','name') returns 'test'
%       >> fileparts2('d:\tmp\test.ext','root') returns 'd:'
%       >> fileparts2('d:\tmp\test.ext','root') returns 'd:'
%
%   See also: fileparts

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2008
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2008-09-18 Creation
%
% ----------------------------- Script History ---------------------------------
[p,n,e]=fileparts(fname);
if nargin==1
    S = p;
    return;
end
switch arg
    case {'path' 0}
        S = p;
    case {'root' -Inf}
        S = regexp(p, [filesep '.*\'], 'split');
        i=find(~cellfun('isempty',S)); 
        S = [repmat(filesep,1,i(1)-1) S{i(1)} filesep];
    case {'shortname' 2}
        if ispc
            % shortname for windows 95, XP, Vista, etc.
            if not(exist(fname,'file'))
                error('File not found: %s', fname)
            end
            [ok,w]=system(sprintf('dir "%s" /x/a-d/-c',fname));
            if ok
                error(w);
            end
            w=strread(w, '%s', 'delimiter',char(10));
            w=strread(w{6}, '%s');
            S = w{4};
        else
            warning('Shortname is irrelevant in non-Windows OS.');
            S = [n e];
        end
    case {'name',1}
        S = n;
    case {'ext' .1}
        S = e;
    case {'path\name' 3}
        S= fullfile(p,n);
    case {'name.ext' 1.1}
        S = [n e];
end