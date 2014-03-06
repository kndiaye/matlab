function [hp]=image_spm(y,v,pos)
% image_spm - display a MRI slice
%   [hp]=image_spm(hdr,vol,pos)
%   hdr: SPM Analyze header
%   vol: SPM Analyze volume
%   pos: position of the slice in mm. 
%        To slice along one direction, put the other dimension to NaN. 
%        E.g. [NaN NaN 0] will display a Z=0 slice (default)
%        

if nargin<3
    pos=[0 0 0];
end

slicing=find(~isnan(pos));
if length(slicing)~=1
    slicing=3;
end

xyz=[[eye(3) ; diag(y.dim(1:3))]-1 ones(6,1)]*y.mat';
xyz=[diag(xyz(1:3,1:3)) diag(xyz(4:6,1:3))];
dims=y.dim(1:3);
xyz=[xyz dims(:)];

% Position of the slice in the voxel cube
vpos=diag(diag(pos(:)-y.mat(1:3,4))*inv(y.mat(1:3,1:3))');

switch slicing
    case 1
        img=v(vpos(1),:,:);
    case 2
        img=v(:,vpos(2),:);
    case 3
        img=v(:,:,vpos(3));
end
xyz(slicing,:)=[pos(slicing) pos(slicing) 1];

[X,Y,Z]=ndgrid(...
    linspace(xyz(1,1),xyz(1,2),xyz(1,3)),...
    linspace(xyz(2,1),xyz(2,2),xyz(2,3)),...
    linspace(xyz(3,1),xyz(3,2),xyz(3,3)));
X=squeeze(X);
Y=squeeze(Y);
Z=squeeze(Z);
img=squeeze(img);
if isempty(get(0, 'CurrentFigure')) | isempty(get(gcf, 'CurrentAxes'))
    NewAxes=1;
else
    NewAxes=0;
end
hp=surf(X,Y,Z,img)
set(hp, 'edgecolor', 'none')
set(hp, 'AlphaData', double(img>0))
set(hp, 'FaceAlpha', 'interp')
axis image
if NewAxes
    view(60,30)
end

