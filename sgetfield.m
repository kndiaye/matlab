function [f,sz] = sgetfield(s,varargin)
%SGETFIELD -  Get structure field and subfield contents.
%   F = SGETFIELD(S,'field.subfield') returns the contents of the specified
%   field and subfield.  This is equivalent to the comamnd:
%       F = S(1).field.subfield
%   S must be a 1-by-1 structure.
%
% See also: SSTRUCTS, SSETFIELD, SFIELDNAMES

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2009 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2009-03-12 Also process struct arrays
%                   
% ----------------------------- Script History ---------------------------------

% Check for sufficient inputs
if (isempty(varargin))
    error('MATLAB:sgetfield:InsufficientInputs',...
        'Not enough input arguments.')
end

sz = size(s)

% The most common case
strField = varargin{1};
if (length(varargin)==1 && ischar(strField))
    [strField, subField]=strtok(strField, '.');        
    f = [s.(deblank(strField))]; % deblank field name
    if numel(f)==numel(s)
        f=reshape(f,size(s));
    end
    if isempty(subField)
        return
    end
    % recursive call to process subfields
    f = sgetfield(f,subField);
    if numel(f)==numel(s)
        f=reshape(f,size(s));
    else
        warning('MATLAB:sgetfield:EmptySubields','Incomplete array of (sub)fields, some are empty')
    end
end

return


f = s;
for i = 1:length(varargin)
    index = varargin{i};
    if (isa(index, 'cell'))
        f = f(index{:});
    elseif ischar(index)

        % Return the first element, if a comma separated list is generated
        try
            f = f.(deblank(index)); % deblank field name
        catch
            tmp = cell(1,length(f));
            [tmp{:}] = deal(f.(deblank(index)));
            f = tmp{1};
        end
    else
        error('MATLAB:getfield:InvalidType', 'Inputs must be either cell arrays or strings.');
    end
end

