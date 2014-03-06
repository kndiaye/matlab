function  B = field2struct(A,label,target)
%FIELD2STRUCT - Export values from a field as a fields of a new struct
%   [B] = field2struct(A,label,target) uses field named label in structure
%           A to create a new structure B whose fieldnames are the
%           'A.label' values and values are the corresponding 'A.target'
%
%
%   Example
%       >> field2struct
%
%   See also:

% Author: K. N'Diaye (kndiaye01<at>gmail.com)
% Copyright (C) 2011
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2011-06-08 Creation
%
% ----------------------------- Script History ---------------------------------
B = [];
for i=1:numel(A)
    if isfield(B,getfield(A(i),label))
        warning('field2struct:DuplicatedLabel',sprintf('Duplicated label: %s', getfield(A(i),label)));
    end
    try
        B=setfield(B,getfield(A(i),label), getfield(A(i),target));
    catch ME
        switch (ME(end).identifier)
            case 'MATLAB:AddField:InvalidFieldName'
                warning('field2struct:InvalidFieldName','%s is not a valid field name. It will be discarded', getfield(A(i),label))
            otherwise
                rethrow(ME)
        end
    end
end