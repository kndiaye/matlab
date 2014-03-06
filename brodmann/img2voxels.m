function [xyz,ref]=img2voxels(y,thd)
if ischar(y)
    y=spm_vol(y);
end
if nargin<2
    thd=0;
end
vol=spm_read_vols(y);
% Undo L-R flipping
if spm_flip_analyze_images
    y.mat(1:5:11)=y.private.hdr.dime.pixdim(2:4);
    y.mat(1,4)=-y.mat(1,4);
end
ref=vol(vol>0);
[xyz(:,1),xyz(:,2),xyz(:,3)]=ind2sub(size(vol), find(vol>0));
xyz=[xyz ones(size(xyz,1),1)]*y.mat';
xyz=xyz(:,1:3);
