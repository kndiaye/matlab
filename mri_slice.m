function [hp,y,v]=mri_slice(varargin)
% mri_slice - display a MRI slice
%   [hp]=mri_slice(mri,pos)
%   [hp]=mri_slice(hdr,vol,pos)
%INPUTS:
%   mri: BrainStorm Subject Image filename/data or Analyze file/header
%   pos: position of the slice in mm.
%        To slice along one direction, put the other dimension to NaN.
%        E.g. [NaN NaN 0] will display a Z=0 slice (default)
%

ninputs=nargin;
y=[];
if ischar(varargin{1})
    read=0;
    try;y=load(varargin{1});read=1;catch;end        
    if ~read;try,y=spm_vol(varargin{1}); if spm_flip_analyze_images, y.mat(1,:)=-y.mat(1,:);end;read=1;catch,end;end
    if ~read
        error(sprintf('I don''t know how to handle file: %s', varargin{1}));
    end
else
    y=varargin{1};
end
switch nargin
    case 1
        v=[];
        pos=[];
    case 2
        if numel(varargin{2})==3
            pos=varargin{2};
            v=[];
        else
            v=varargin{2};
            pos=[];
        end
    case 3
        v=varargin{2};
        pos=varargin{3};
end
if isempty(v)
    if isfield(y,'fname')
        v=spm_read_vols(y);
    else
        v=y.Cube;        
    end
end
y.dim=size(v);
if isfield(y,'Cube')
    y=rmfield(y,'Cube');
end
if ~isfield(y, 'mat')
    % y.mat=[diag(y.Voxsize) -ones(3,1); 0 0 0 1];    
    if isempty(pos)
        pos=ceil(y.dim'/2);
    end
end
if isfield(y, 'SCS')
    xyz=[[eye(3) ; diag(y.dim(1:3))]-1 ones(6,1)]*y.mat';
    xyz=[diag(xyz(1:3,1:3)) diag(xyz(4:6,1:3))];
else
    xyz=[[eye(3) ; diag(y.dim(1:3))]-1 ones(6,1)]*y.mat';
    xyz=[diag(xyz(1:3,1:3)) diag(xyz(4:6,1:3))];
    dims=y.dim(1:3);
    xyz=[xyz dims(:)];

    if isempty(pos)
        pos=[0 0 0];
    end
    if nargin<4
        thd=0;
    end

    slicing=find(~isnan(pos));
    if length(slicing)~=1
        slicing=3;
    end

    % Position of the slice in the voxel cube
    vpos=diag(diag(pos(:)-y.mat(1:3,4))*inv(y.mat(1:3,1:3))');
    vpos=round(vpos);
    switch slicing
        case 1
            img=v(vpos(1),:,:);
        case 2
            img=v(:,vpos(2),:);
        case 3
            img=v(:,:,vpos(3));
    end
    xyz(slicing,:)=[pos(slicing) pos(slicing) 1];
end

[X,Y,Z]=ndgrid(...
    linspace(xyz(1,1),xyz(1,2),xyz(1,3)),...
    linspace(xyz(2,1),xyz(2,2),xyz(2,3)),...
    linspace(xyz(3,1),xyz(3,2),xyz(3,3)));
X=squeeze(X);
Y=squeeze(Y);
Z=squeeze(Z);
img=squeeze(img);
img=double(img);
if isempty(get(0, 'CurrentFigure')) | isempty(get(gcf, 'CurrentAxes'))
    NewAxes=1;
else    
    NewAxes=0;
end
hp=surf(X,Y,Z,img);
set(hp, 'edgecolor', 'none')
set(hp, 'FaceAlpha', 'interp')
set(hp, 'AlphaData', double(img>thd))
axis image
if NewAxes
    colormap(bone)
    if slicing==3
        view(2)
    else
    view(60,30)
    end
end

