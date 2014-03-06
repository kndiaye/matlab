function [K,XYZvox,rXYZmm] = myspm_get_data_xyz(V,XYZmm,approx)
%MYSPM_GET_DATA_XYZ - gets data from image files at locations given in mm
% FORMAT [K,XYZvox,rXYZmm] = myspm_get_data(V,XYZmm,approx);
%
%INPUTS
%   V: (cell) array of M filenames or volume structures  from sspm_vol
%   XYZmm: 3-by-N voxels locations to read in millimeters
%   approx: Approximation mode. if approx==NaN (default) returns NaN for
%           voxels out of the image else approximates see spm_sample_vol()
%
%OUPUTS
%   K: M-by-N values read in the files
%   XYZvox: 3-by-M-by-N matrix of voxels locations read in voxel space
%   rXYZmm: 3-by-M-by-N matrix of actual coordinates of the voxels read
%
%   Example
%       >> spm_get_data_xyz(P,[45 -50 +50]) retrieves voxel intensity in
%       the VMPFC of the MNI template...
%
%   See also: spm_get_data

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2008
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2008-10-22 Creation
%
% ----------------------------- Script History ---------------------------------
if isstruct(V)
% output of a dir
    if isfield(V,'name')
        V={V.name};
    end
end

if ~isstruct(V)
    V = spm_vol(V);
    try
        V = cat(2,V{:});
    end
end

if nargin<3
    approx=NaN;
end
if isempty(approx)
    approx=NaN;
end
if numel(approx)==1
    approx(1:length(V))=approx;
end
if nargin<2
    XYZmm = 'all';
end
if ~ischar(XYZmm)
    if ~isequal(size(XYZmm,1),3)
        error('XYZ input should be 3-by-N')
    end
    % number of voxels to retrieve
    %---------------------------------------------------------------
    n=size(XYZmm,2);
    % preallocate outputs
    %---------------------------------------------------------------
    K     = zeros(  length(V),n);
    XYZvox= zeros(3,length(V),n);   
    % expand approximation mode to match size of inputs
    %---------------------------------------------------------------
    if prod(size(approx))==1
        approx=repmat(approx,length(V),1);
    end
    xyz  = [XYZmm; ones(1,n)];
    xyz(isinf(xyz)) = 1e10*sign(xyz(isinf(xyz)));
else
    switch (XYZmm)
        case 'all'
            
        case 'roi'
            % To do: retrieve a region from a given atlas:
            % aal:sup front gyrus:Right;
            % brodmannn:4:Left etc.
    end
end
for i = 1:length(V)
    if exist('xyz', 'var')
        % trick from spm_XYZreg
        vox = round(inv(V(i).mat)*xyz);
        j = all(vox(1:3,:)<=repmat(V(i).dim(1:3)',1,n)) & all(vox(1:3,:)>zeros(3,n));
    elseif i==1
        % retrieve all voxels
        h=spm_vol(V(i));
        [vox(1,:),vox(2,:),vox(3,:)] = ind2sub(h.dim, 1:prod(h.dim));        
        j=logical(ones(size(vox(1,:))));
        n=length(j);
        % preallocate outputs
        %---------------------------------------------------------------
        K     = zeros(  length(V),n);
        XYZvox= zeros(3,length(V),n);
    end
    if any(j)
        %-Load mask image within current mask & update mask
        %-------------------------------------------------------
        K(i,j) = spm_sample_vol(V(i),vox(1,j),vox(2,j),vox(3,j),0);
    end
    if isnan(approx(i))
        K(i,~j)=NaN;
    else
        K(i,~j) = spm_sample_vol(V(i),vox(1,~j),vox(2,~j),vox(3,~j),approx(i));
    end
    XYZvox(1:3,i,1:n) = vox(1:3,:);
    if nargout > 2
        if i==1
            % pre-allocation might be useless if later on, a V(i) volume is
            % bigger than the first one and all voxels are retrieved)
            rXYZmm= zeros(3,length(V),n);
        end
        if ~exist('xyz', 'var')
            rXYZmm(1:4,i,:) = NaN;
            rXYZmm(1:4,i,1:n)=V(i).mat*[vox(:,:) ; ones(1,n)];
            rXYZmm(4,:) = NaN;  
        else           
            rXYZmm(1:3,i,1:n) = V(i).mat(1:3,:)*xyz;
        end
    end
end
