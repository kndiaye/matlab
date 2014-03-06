function [hp]=img_slice(hdr,pos,v)
%IMG_SLICE - display a MRI slice
%
%   [hp]=img_slice(hdr,pos,v)
%   hdr: SPM Analyze header (or filename)
%   pos: position of the slice in mm.
%        To slice along one direction, put the other dimensions to NaN.
%        E.g. [NaN NaN 0] will display a Z=0 slice
%              Default, Z=0 if = in the cube, otherwise in the middle
%   v: SPM Analyze volume of data (if empty, read the hdr.fname)
%
%   [hp]=img_slice(hdr,pos,['calculation'],...) does a calculation on the data
%   before plotting 3D data are in X. 
%   Ex: img_slice(hdr,'X=X(:)-min(X(:))',...)
%   Note: Data are reshaped to their original size if vectorized. 
%
%   Example
%       >> img_slice
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
% KND  2009-07-03 Creation
%                   
% ----------------------------- Script History ---------------------------------
if nargin<1
    hdr=[];
end
if nargin<3
    v=[];
end
if isempty(hdr) && isempty(v)
    hdr = fullfile(spm('dir'), 'canonical','single_subj_T1.nii');
    if ~exist(hdr,'file')
        hdr = fullfile(spm('dir'), 'canonical','single_subj_T1.img');
    end
    if ~exist(hdr,'file')
        hdr = fullfile(spm('dir'), 'canonical','single_subj_T1.mnc');
    end
end
if ischar(hdr)
    if exist(hdr,'file')
        hdr=spm_vol(hdr);
    else
        error('File doesn''t exist: %s',y)
    end
end
if nargin<2
    pos=[];
end
if ischar(v)
    calc=v;
    v=[];
else
    calc=[];
end
if size(calc, 1)>1
    error('Calculation should be a 1-line text');
end
if isempty(v)
    v=spm_read_vols(hdr);
end
if nargin<4
    thd=0;
end
if nargin<5
    dynamic=0;
end

xyz=[[eye(3) ; diag(hdr.dim(1:3))]-1 ones(6,1)]*hdr.mat';
xyz=[diag(xyz(1:3,1:3)) diag(xyz(4:6,1:3))];
dims=hdr.dim(1:3);
XYZ=[xyz dims(:)];
if isempty(pos)
    if XYZ(3,1)<0 & XYZ(3,2)>0
        pos=[NaN NaN 0];
    else
        pos=[NaN NaN (XYZ(3,2)-XYZ(3,1))/2];
    end
end
if numel(pos) ~= 3
    error('Position of the slices should be given in XYZ 3-coordinate vector');
end
pos = pos(:);

if isempty(get(0, 'CurrentFigure')) | isempty(get(gcf, 'CurrentAxes'))
    NewAxes=1;
else
    NewAxes=0;
end
holdstate=ishold;
if ~isempty(calc)
    [v]=calculation(v,calc);           
end

bbox = [XYZ(:,1:2)]';

hp=[];
for slicing = find(~isnan(pos(:)'));
    p=zeros([1 3]);
    p(slicing)=pos(slicing);
    if  not((XYZ(slicing,1)<=p(slicing) & p(slicing)<=XYZ(slicing,2)) | (XYZ(slicing,2)<=p(slicing) & p(slicing)<=XYZ(slicing,1)))
        Slice out of bound!
        letter = 'XYZ';
        warning('Slice at %s=%g is out of bounds [%g %g]!', letter(slicing), p(slicing), XYZ(slicing,1),XYZ(slicing,2));
    else

        % Position of the slice in the voxel cube
        vpos=diag(diag(p(:)-hdr.mat(1:3,4))*inv(hdr.mat(1:3,1:3))');

        vpos=round(vpos);
        switch slicing
            case 1
                img=v(vpos(1),:,:);
            case 2
                img=v(:,vpos(2),:);
            case 3
                img=v(:,:,vpos(3));
        end
        xyz=XYZ;
        xyz(slicing,:)=[p(slicing) p(slicing) 1];

        [X,Y,Z]=ndgrid(...
            linspace(xyz(1,1),xyz(1,2),xyz(1,3)),...
            linspace(xyz(2,1),xyz(2,2),xyz(2,3)),...
            linspace(xyz(3,1),xyz(3,2),xyz(3,3)));
        X=squeeze(X);
        Y=squeeze(Y);
        Z=squeeze(Z);
        img=squeeze(img);

        hp=[hp surf(X,Y,Z,img)];
        set(hp(end), 'AlphaData', double(img>thd))
        hold on

        l = [bbox].*[logical(p);logical(p)] + ones(2,1)*(pos'.*(~p))

        line(l(:,1),l(:,2),l(:,3))
        if 1%dynamic
            setappdata(hp(end),'data', v);
            setappdata(hp(end),'XYZ', XYZ);
            setappdata(hp(end),'pos', pos);
        end
    end
end
if ~isempty(hp)
    set(hp, 'edgecolor', 'none')
    %set(hp, 'FaceAlpha', 'interp')
    set(hp, 'FaceAlpha', 1)
    axis image
    if NewAxes
        view(60,30)
    end
    if ~holdstate
        hold('off')
    end
end


function [v]=calculation(v,calc)
% Process this independently of the main workspace
X=v;
try
    [t,X]=evalc(calc);
catch
    evalc(calc);
end
v=reshape(X,size(v));