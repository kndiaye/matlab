function [s] = struct2tab(x,varargin)
% struct2tab -  Print fields of structure into a text table
%   [s] = struct2tab(x)
%   [s] = struct2tab(x,  'headers', ['no']|'yes'|'only')

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2009
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2009-03-12 Creation
%
% ----------------------------- Script History ---------------------------------


% Not implemented yet:
%   [s] = struct2tab(x, 'format', ['%30.5']|'no'|'only')

options = parser(varargin{:});

headers=options.headers;
superfield=options.superfield;

if headers == 1
    s=[struct2tab(x,options,'headers','only');struct2tab(x,options,'headers','no')];
    return
end

s=[];
fn = fieldnames(x);
for f=fn(:)'
    if ~headers
        if numel(x)>1
            for i=1:numel(x)
                s=[s;struct2tab(x(i), varargin{:})];
            end
            return
        end
    end
    y=getfield(x(1), f{1});
    if iscell(y)        
        y=y{1}
    end
    if isstruct(y)
        if headers
            if ~isempty(superfield)
                superfield = [superfield '.' ];
            end
            t=struct2tab(y,'headers',[superfield f{1}]);
        else
            t=struct2tab(y,'headers','no');
        end
        s=[repmat(s,size(t,1)) t];
    else
        if headers
            y = [f{1}];
            if ~isempty(superfield)
                y = [superfield '.' y];
            end
            y=y(max(1,end-29):end);
        end
        if isempty(y)
            t = sprintf('%30.5f',0);
            t = strrep(t, '0', ' ');
            t = strrep(t, '.', ' ');
        elseif isnumeric(y)
            if numel(y)>1
                %t=[];
                %for i=1:numel(y)
                %t = [t;sprintf('%30.5f',y(i));];
                %end
                t = sprintf('%30s','...');
            elseif fix(y)==y
                t = sprintf('%30d',y);
            else
                t = sprintf('%30.5f',y);
            end
        elseif ischar(y)
            t = sprintf('% 30s',y);
        elseif islogical(y)
            if y
                t = sprintf('% 30s','0');
            else
                t = sprintf('% 30s','1');
            end
        else
            t = sprintf('% 30s','N/A');
        end


        %         s_fill = repmat(' ', max(0,size(t,1)-size(s,1)), size(s,2));
        %         % Keeps tabs in filling
        %         s_fill(:,all(s==9))=9;
        %         t_fill = repmat(' ', max(0,size(s,1)-size(t,1)), size(t,2))
        s_fill = '';
        t_fill = '';
        s=[[s; s_fill] [t; t_fill]];
        s = [s repmat(sprintf('\t'), size(s,1),1)] ;
    end
end


function options = parser(varargin)
% Parse options

% default values
options.headers = 1;
options.superfield = [];
options.fieldwidth = 30;
options.fieldformat.char = [];
options.fieldformat.logical = [];
options.fieldformat.numeric = [];
options.arrays = '...';
if nargin==0
    return
end
if isstruct(varargin{1})
    options = mergestruct(options,varargin{1});
    varargin(1)=[];
end
na=length(varargin);
if mod(na,2)
    error('Options must be specified in pairs: ''option'', value');
end
na=na/2;
for i=1:na
    va=varargin{2*i};
    switch lower(varargin{2*i-1})
        case 'headers'
            if isequal(va,'yes')
                options.headers = 1;
            elseif isequal(va,'only')
                options.headers = 2;
            elseif isequal(va,'no')
                options.headers = 0;
                options.superfield = [];
            else
                options.headers = 2;
                options.superfield = va;
            end
        case 'superfield'
            options.superfield=va;
    end
end


function s3 = mergestruct(s1,s2)
s3=s1;
f=fieldnames(s2);
for i=1:length(f)
    s3=setfield(s3, f{i}, getfield(s2,f{i}));
end
