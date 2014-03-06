function [TF,index] = isfield2(s,varargin)
%ISFIELD2 - Advanced ISFIELD, to test if a field is in structure array
%   [TF] = isfield2(S,F)  returns true if the string F is the name of a
%          field or a subfield in the structure array S.
%
%   Example
%       >> isfield2(
%
%   See also: getfield2

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2009
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2009-03-31 Creation
%
% ----------------------------- Script History ---------------------------------

if (isempty(varargin))
    error('MATLAB:GETFIELD:DeprecatedFunction:InsufficientInputs','Not enough input arguments.')
end
TF=0;
% The most common case
index = varargin{1};
if (length(varargin)==1 && isstr(index))
    if any(index=='.')
        [f1,f2]=strtok(index,'.');
        if ~isfield(s, deblank(f1))
            return
        end
        TF=isfield2([s.(deblank(f1))],f2(2:end));
    else
        TF = isfield(s, deblank(index));
        return
    end
end

return
