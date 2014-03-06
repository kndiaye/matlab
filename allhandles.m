function  [H,exclude] = allhandles(A,varargin)
%ALLHANDLES - Handles of existing objects only
%   [H] = allhandles(A)
%       Returns in vector H only handles to existing objects from A
%
%   [H,exclude] = allhandles(A, 'Property', Value, ...)
%       Retrieves only those handles whose Property/ies match the Value(s)

%   Example
%       >> allhandles(0:10)
%       >> allhandles(findobj(0), 'type', 'line')
%
%   See also: ishandle, nonzeros

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2009
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2009-10-22 Creation
%
% ----------------------------- Script History ---------------------------------

% to  do: varargin : only handles matching some criterion.
% eg. (tag, 'something') or ('visible', 'on')

H=A(ishandle(A));
exclude = [];
if nargin>1
    exclude=zeros(size(H));
    for i=1:numel(H)
        for j=1:2:(nargin-1)
            try
                if ~isequal(get(H(i),varargin{j}), varargin{j+1})
                    exclude(i) = j;
                    break
                end
            catch
                exclude(i)=-1;
            end
        end
    end
    H=H(~exclude);
end