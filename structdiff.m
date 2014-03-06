function [varargout] = structdiff(X,Y,recursive,output)
%STRUCTDIFF - Compare structures and output differences
%   [C] = structdiff(X,Y) list the fields that differ in a N-by-2 cell
%   array. Fileds that are in X but not in Y appear only in the first
%   column; fields of Y absent in X appear in the 2nd column; and fields
%   that differ between X and Y appear in both columns
%
%   Example
%       >> structdiff(get(figure('name','a')),get(figure('name','b')))
%
%   [C] = structdiff(X,Y,r)
%       if r== 0 (default) not recursive
%       if r==Inf  -> recursive
%       if r==N -> max depth of recursion
%
%   See also: getfield2

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2008
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2008-07-17 Creation
% KND  2008-10-28 Changed format of output
%
% ----------------------------- Script History ---------------------------------
if nargin<3
    recursive=0;
end
if ~iscell(recursive)
    recursive={recursive ''};
    %Internally, the 'recursive' argument is embedded in a cell, so as to
    %pass the prefix (i.e. the "super.field") as the second element of it.
end
if length(X)>1 | length(Y)>1
    error('Cannot deal with struct arrays')
end

x=fieldnames(X);
y=fieldnames(Y);
C=setdiff(x,y);
C=C(:);
n=length(C);
for i=1:n
    C{i,1}=[recursive{2} C{i,1}];
    C{i,2}=[];
end
A=setdiff(y,x);
for i=1:length(A)
    C{n+i,1}=[];
    C{n+i,2}=[recursive{2} A{i}];
end
clear A
%common fields
f=intersect(x,y);
for i=1:length(f)
    x=getfield(X,f{i});
    y=getfield(Y,f{i});
    if recursive{1} && isstruct(x) && isstruct(y)
        recursive{1} = recursive{1} - 1;
        if  length(x)== 1 && length(y)==1
            C=[C; structdiff(x,y,{1 [recursive{2}  f{i} '.']})];
        elseif length(x)~= length(y)
            C=[C; [recursive{2} f{i}]];
        elseif ~isequalwithequalnans(x,y)
            for j=1:length(x)
                if ~isequal(x(j),y(j))
                    C=[C; structdiff(x(j),y(j),{recursive{1} ,[recursive{2} f{i} sprintf('(%d)', j) '.']})];
                end
            end
        end
    else
        if ~isequalwithequalnans(x,y)
            C=[C; {[recursive{2} f{i}] [recursive{2} f{i}]}];
        end
    end
end
if nargin>3
    for i=1:size(C,1)
        a=[];
        b=[];
        if ~isempty(C{i,1})
            a=getfield2(X,C{i,1});
            fprintf('%s',C{i,1})
        end
        fprintf(' | ');
        if ~isempty(C{i,2})
            b=getfield2(Y,C{i,2});
            fprintf('%s',C{i,2})
        end
        fprintf('\n')
        if isstruct(a) | isstruct(b)
            disp(a)
            disp(b)
        elseif isequal(size(a,1),size(b,1))
            if isnumeric(a) & isnumeric(b) %& numel(a)<100 & numel(b)<100
                fmt='%g ';
            elseif ischar(a) & ischar(b)
                fmt='%s ';
            elseif ischar(a) & ischar(b)

            else
                a=' ';b=' ';
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
end

if nargout>1
    varargout = {C};
else
    n=size(C,1);
    D=cell(n,3);
    disp(C)
    for j=1:n
        D(j,1) = unique(C(j,~cellfun('isempty', C(j,:)))');
        if ~isempty(C{j,1})
            getfield(X, D{j,1})
            D{j,2} = getfield(X, D{j,1});
        end
        if ~isempty(C{j,2})
            D{j,3} = getfield(Y, D{j,1});
        end
    end
    varargout = {D};
end
