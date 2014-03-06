function h = structcomparator(A,B,varargin)
%STRUCTCOMPARATOR - One line description goes here.
%   [] = structcomparator(input)
%
%   Example
%       >> structcomparator
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
% KND  2009-07-28 Creation
%                   
% ----------------------------- Script History ---------------------------------
F=structdiff(A,B,varargin{:});
for i=1:size(F,1)
    a=[];
    b=[];
    if ~isempty(F{i,1})
        a=getfield2(A,F{i,1});
        fprintf('%s',F{i,1})
    end
    fprintf(' | ');
    if ~isempty(F{i,2})
        b=getfield2(B,F{i,2});
        fprintf('%s',F{i,2})
    end
    fprintf('\n')
    if isstruct(a) | isstruct(b)
        disp(a)
        disp(b)
    elseif isequal(size(a,1),size(b,1))
        if isnumeric(a) & isnumeric(b)
            fmt='%g ';
        elseif ischar(a) & ischar(b)
            fmt='%s ';
        else
            fmt='...';
        end
        for i_row=1:size(a,1)
            ta=sprintf(fmt, a(i_row,:));
            tb=sprintf(fmt, b(i_row,:));
            fprintf('%s | %s\n', ta, tb);
        end
    else
        disp(a)
        disp(b)
    end
    fprintf('\n');
end