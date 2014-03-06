function y = findinstruct(x,S,fun,varargin)
%FINDINSTRUCT - Finds a value in the fields (and subfields) of a structure
%   [y] = findinstruct(x,S)
%       Searches in structure S any field equal to x and outputs a cell
%       array of subscripted references to the matching elements
%
%   [y] = findinstruct(x,S,fun)
%       Allows user to specify his/her own function to be tested using
%       input x and S content. E.g. 'strmatch(x,S)'
%
%   Example
%       >> a.b=1;a.c='toto';
%       >> findinstruct(1,a)
%       >> findinstruct('tot',a,'strmatch(x,S)')
%
%   See also: subsref

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2006
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2006-12-06 Creation
%
% ----------------------------- Script History ---------------------------------
if nargin<3 || isempty(fun)
    fun='isequal(x,S)';
end
y=[];
if isstruct(S)
    f=fieldnames(S);
    for j=1:numel(S)
        for i=1:length(f)
            s=struct('type', '.', 'subs', f{i});
            z=findinstruct(x,subsref(S(j),s),fun,varargin{:});
            if ~isempty(z)
                if numel(S)>1
                    s=[struct('type', '()', 'subs', {{j}}) s];
                end
                for k=1:length(z)
                    y{end+1}=[s z{k}];
                end
            end
        end
    end
else
    try
        if eval(fun)
            y={[]};
        end
    end
end


