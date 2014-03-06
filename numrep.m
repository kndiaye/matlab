function Y = numrep(X,varargin)
%numrep() - Replace numerical value with another
%   [Y] = numrep(X,p,q) replaces p's in X with q's
%   Works with p=NaN (as well as p=+Inf, and p=-Inf)
%   p may be an array so that all of these values will be replaced by q
%	[Y] = numrep(X,[p1 p2],q1 , p3,q3) works also
%
%   See also: strrep

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2005
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% ----------------------------- Script History ---------------------------------
% KND   2005-12-12 Creation
% KND   2006-10-23 Added possibility to replace multiple p values at once
% KND   2009-10-22 Logical array are converted to double if needed (+warning)
% ----------------------------- Script History ---------------------------------

Y=X;
p=varargin(1:2:end);
q=varargin(2:2:end);
for i=1:length(p)
    while ~isempty(p{i})
        if isnan(p{i}(1))
            Y(isnan(X))=q{i};
        else
            try
            Y(X==p{i}(1))=q{i};
            catch ME
                if isequal(ME.identifier, 'MATLAB:nologicalnan')
                	warning('numrep:NAnintoLogical','numrep:Logical array is converted to double to incoporate NaN''s.');
                    Y=double(Y);
                    Y(X==p{i}(1))=q{i};
                else
                    rethrow(ME)
                end
            end
        end
        p{i}(1)=[];
    end
end