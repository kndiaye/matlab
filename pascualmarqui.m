function L = loreta_laplacian(varargin)
%loreta_laplacian - Laplacian operator for a mesh according to Pascual-Marqui
%   [L] = loreta_laplacian(D)
%   Computes LORETA's laplacian L for a distance matrix (D) of a mesh
%
%   [L] = loreta_laplacian(vertices,faces)
%   Computes laplacian L for a mesh defined by its vertices and faces 
%
%   [L] = loreta_laplacian(vertices,vertconn)
%   Computes laplacian L for a mesh where vertex connectivity cell list has
%   already been computed using: vertices_connectivity
%   
%   See also: bst_laplacian, mesh_laplacian

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2006 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2006-02-03 Creation (thanks to Jean Daunizeau scripts)
%                   
% ----------------------------- Script History ---------------------------------
if nargin>1
    if ~iscell(varargin{2})
        vertices_distances
    else
        D=vertices_distances(vararagin{1},vararagin{2},1);
    end
else
    D=varargin{1};
end
L=-bst_smooth_fun([],D,1,0,'1./r');
nv=size(L,1);
L(1:(nv+1):end)=0;
L(1:(nv+1):end)=-mean(sum(L,2));

return

