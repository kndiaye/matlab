function fv = bst_surf2fv(s)
%BST_SURF2FV - One line description goes here.
%   [fv] = bst_surf2fv(s)
% will remove extra fields of s to keep only the "Vertices" and "Faces" ones
% Note: Upper case/lower case discrepancies are ignored.
%
%   Example
%       >> bst_surf2fv
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
for f={'faces', 'vertices'}
    if isfield(s, f{1})    
        fv=setfield(fv, f{1}, getfield(s, f{1}));
    elseif isfield(s, lower(f{1}))    
        fv=setfield(fv, f{1}, getfield(s, lower(f{1})));
    elseif isfield(s,  [upper(f{1}(1)) upper(f{1}(2:end))])
        fv=setfield(fv, f{1}, getfield(s, [upper(f{1}(1)) upper(f{1}(2:end))]));
    else
        warning(sprintf('No field %f in the structure', f{1}))
    end
end