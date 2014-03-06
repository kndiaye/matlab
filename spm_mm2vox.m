function M = spm_mm2vox(V,XYZmm,dim)
%SPM_MM2VOX - Retrieve coordinates in voxels from millimeters
%   [M] = spm_mm2vox(V,XYZmm,dim)
%
%   Example
%       >> spm_mm2vox
%
%   See also: 

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2008 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2008-06-12 Creation
%                   
% ----------------------------- Script History ---------------------------------
if nargin<3
    dim=find(size(XYZmm) == 3);    
    if length(dim)~=1
        error('XYZmm must be a 3 by N matrix')        
    end
end
if ischar(V)
    if exist(V,'file')
        V=spm_vol(V);
    end
end
if isstruct(V)
    if isfield(V, 'mat')
        V=V.mat;
    end
    if isfield(V, 'MAT')
        V=V.MAT;
    end  
end
MAT=V;

s = size(XYZmm);
if s(dim) ~= 3
    error('The %d-th dimension of XYZmm should be 3', dim)
end

XYZmm = nd2array(XYZmm,dim);
XYZmm = [XYZmm ; ones(1, size(XYZmm,2))];

M = inv(MAT)*XYZmm;
M = M(1:3,:);
M = nd2array(M,-dim,s);
