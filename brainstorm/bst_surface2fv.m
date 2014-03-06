function fv = bst_surface2fv(s)
%BST_SURFACE2FV - One line description goes here.
%   [fv] = bst_surface2fv(s)
% will remove extra fields of s to keep only the "Vertices" and "Faces" ones
% Note: Upper case/lower case discrepancies are ignored.
%
%   Example
%       >> bst_surface2fv
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
% KND  2009-09-18 Creation
%
% ----------------------------- Script History ---------------------------------

fv=[];
FIELDS={'faces', 'vertices'};
for iField=1:2
    f=FIELDS{iField};
    if ~isfield(s, f)
        f = [upper(f(1)) f(2:end)];
        if ~isfield(s,f)
            f=NaN;
        end
    end
    if isnan(f)
        warning(sprintf('No field %s in the structure', f))
    else
        fv=setfield(fv,FIELDS{iField}, getfield(s,f));
        if iField==2
           if size(fv.vertices,2) ~= 3 &&  size(fv.vertices,1) == 3 
               fv.vertices=fv.vertices';
           end
        end
    end    
end