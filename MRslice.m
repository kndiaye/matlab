function [hp]=MRslice(Cube,pos,SCS)
% image_spm - display a MRI slice
%   [hp]=image_spm(hdr,vol,pos)
%   hdr: SPM Analyze header
%   vol: SPM Analyze volume
%   pos: position of the slice in mm. 
%        To slice along one direction, put the other dimension to NaN. 
%        E.g. [NaN NaN 0] will display a Z=0 slice (default)
%        


if nargin<1
    error('MR image needed')
end
if ischar(Cube)
    
end

    
    
    
if nargin<3
    pos=mean(szCube);
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

end


% Axial View --------------------------------
if get(mriHandles.axial3D,'value')
    
    X = linspace(0,MRI.FOV(1),size(MRI.Cube,1));
    Y = linspace(0,MRI.FOV(2),size(MRI.Cube,2));
    Z = mriCoord(3)*ones(length(X), length(Y));
    hhh = surf(X,Y,Z);
    set(hhh,'visible','off')
    %set(hhh,'visible','on','Cdata',double(MRI.Cube(:,:,newIndices(3)))','edgecolor','none')
    %hold on
    x = get(hhh,'xdata');
    y = get(hhh,'ydata');
    X = repmat(x,length(y),1);
    Y = repmat(y',1,length(x));
    x = X(:); y = Y(:); z = Z(:);
    
    [transf,scsCoord] = mri2scs(MRI,[x,y,z]');
    scsCoord = scsCoord/1000;
    
    X = (reshape(scsCoord(1,:),size(MRI.Cube,1),size(MRI.Cube,2)));
    Y = (reshape(scsCoord(2,:),size(MRI.Cube,1),size(MRI.Cube,2)));
    Z = (reshape(scsCoord(3,:),size(MRI.Cube,1),size(MRI.Cube,2)));
    %                 figure, hold on 
    hhh = surf(X,Y,Z); 
    set(hhh,'visible','off')
    
    if isempty(mriImages.Axial) % Fisrt time 3D visualization of MR slices was called
        figure(h3D), hold on
        mriImages.Axial = surf(X,Y,Z);
        %setappdata(h3D,'mriImages',mriImages)
    else
        mriImages = getappdata(h3D,'mriImages');    
    end
    
    CData = double(MRI.Cube(:,:,newIndices(3)))';
    CData = CData/max(CData(:));
    CData(CData < (min(CData(:))+1*std(CData(:)))) = NaN;
    set(mriImages.Axial,'Xdata',X,'Ydata',Y,'ZData',Z,'Cdata',CData,'edgecolor','none','facelighting','none')
    
else
    if ~isempty(mriImages.Axial) % Remove from visualization
        delete(mriImages.Axial)
        mriImages.Axial = [];
    end
end

% Sagittal View --------------------------------
if get(mriHandles.sagittal3D,'value')
    
    Y = linspace(0,MRI.FOV(2),size(MRI.Cube,2));
    Z = linspace(0,MRI.FOV(3),size(MRI.Cube,3));
    X = mriCoord(1)*ones(length(Y), length(Z));
    
    hhh = surf(Y,Z,X);
    set(hhh,'visible','off')
    %set(hhh,'visible','on','Cdata',double(MRI.Cube(:,:,newIndices(3)))','edgecolor','none')
    %hold on
    y = get(hhh,'xdata');
    z = get(hhh,'ydata');
    Y = repmat(y,length(z),1);
    Z = repmat(z',1,length(y));
    x = X(:); y = Y(:); z = Z(:);
    
    [transf,scsCoord] = mri2scs(MRI,[x,y,z]');
    scsCoord = scsCoord/1000;
    
    X = (reshape(scsCoord(1,:),size(MRI.Cube,2),size(MRI.Cube,3)));
    Y = (reshape(scsCoord(2,:),size(MRI.Cube,2),size(MRI.Cube,3)));
    Z = (reshape(scsCoord(3,:),size(MRI.Cube,2),size(MRI.Cube,3)));
    %                 figure, hold on 
    hhh = surf(X,Y,Z); 
    set(hhh,'visible','off')
    
    if isempty(mriImages.Sagittal) % Fisrt time 3D visualization of MR slices was called
        figure(h3D), hold on
        mriImages.Sagittal = surf(X,Y,Z);
        %setappdata(h3D,'mriImages',mriImages)
    else
        mriImages = getappdata(h3D,'mriImages');    
    end
    CData = double(squeeze(MRI.Cube(newIndices(1),:,:)))';
    CData = CData/max(CData(:));
    CData(CData < (min(CData(:))+1*std(CData(:)))) = NaN;
    set(mriImages.Sagittal,'Xdata',X,'Ydata',Y,'ZData',Z,'Cdata',CData,'edgecolor','none','facelighting','none')
    
else
    if ~isempty(mriImages.Sagittal) % Remove from visualization
        delete(mriImages.Sagittal)
        mriImages.Sagittal = [];
    end
end


% Coronal View --------------------------------
if get(mriHandles.coronal3D,'value')
    
    X = linspace(0,MRI.FOV(1),size(MRI.Cube,1));
    Z = linspace(0,MRI.FOV(3),size(MRI.Cube,3));
    Y = mriCoord(2)*ones(length(X), length(Z));
    
    hhh = surf(X,Z,Y);
    set(hhh,'visible','off')
    %set(hhh,'visible','on','Cdata',double(MRI.Cube(:,:,newIndices(3)))','edgecolor','none')
    %hold on
    x = get(hhh,'xdata');
    z = get(hhh,'ydata');
    X = repmat(x,length(z),1);
    Z = repmat(z',1,length(x));
    x = X(:); y = Y(:); z = Z(:);
    
    [transf,scsCoord] = mri2scs(MRI,[x,y,z]');
    scsCoord = scsCoord/1000;
    
    X = (reshape(scsCoord(1,:),size(MRI.Cube,2),size(MRI.Cube,3)));
    Y = (reshape(scsCoord(2,:),size(MRI.Cube,2),size(MRI.Cube,3)));
    Z = (reshape(scsCoord(3,:),size(MRI.Cube,2),size(MRI.Cube,3)));
    %                 figure, hold on 
    hhh = surf(X,Y,Z); 
    set(hhh,'visible','off')
    
    if isempty(mriImages.Coronal) % Fisrt time 3D visualization of MR slices was called
        figure(h3D), hold on
        mriImages.Coronal = surf(X,Y,Z);
        %setappdata(h3D,'mriImages',mriImages)
    else
        mriImages = getappdata(h3D,'mriImages');    
    end
    
    CData = double(squeeze(MRI.Cube(:,newIndices(2),:)))';
    CData = CData/max(CData(:));
    CData(CData < (min(CData(:))+1*std(CData(:)))) = NaN;
    set(mriImages.Coronal,'Xdata',X,'Ydata',Y,'ZData',Z,'Cdata',CData,'edgecolor','none','facelighting','none')
    
    
else
    if ~isempty(mriImages.Coronal) % Remove from visualization
        delete(mriImages.Coronal)
        mriImages.Coronal = [];
    end
end 
set(h3D, 'colormap',bone(ngray))
