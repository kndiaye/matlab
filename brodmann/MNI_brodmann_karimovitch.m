% Transpose, Flip, etc so that Left is on Left 
% and all the rest is okay
% TessFile='D:\ndiaye\data\subjects\MNI_4_Yann\MNI_brain_NoCollosum_12000V_tess.mat';
% fv=tess2patch(TessFile);
% v=(fv.vertices*diag([1 -1 -1])+repmat([-90e-3 217e-3-126e-3 181e-3-72e-3], size(fv.vertices,1),1))*diag([-1 1 1])*1000;
% view_cortex(fv.faces, v)
% image_spm(y,vol); view(2); hold on
% h=findTessellationHandles
% set(h, 'visible', 'off')


clear
spm_defaults

switch(1)
    case 1
        TessFile='D:\ndiaye\data\subjects\MNI_4_Yann\MNI_brain_NoCollosum_12000V_tess_corrected.mat';
        fv=tess2patch(TessFile);
        % Note that the right hemi at the occipital pole viewed from above goes towards the left         
    case 2
        % TessFile='D:\ndiaye\data\subjects\MNI_4_Yann\MNI_brain_tess.mat';
        
        fv=tess2patch(TessFile);
        % In MNI coordinates:
        fv.vertices=(fv.vertices*diag([1 -1 -1])+repmat([-90e-3 217e-3-126e-3 181e-3-72e-3], size(fv.vertices,1),1))*diag([-1 1 1])*1000;
    case 3
        TessFile=uigetpathfile
        fv=tess2patch(TessFile);
        % In MNI coordinates:
        fv.vertices=(fv.vertices*diag([1 -1 -1])+repmat([-90e-3 217e-3-126e-3 181e-3-72e-3], size(fv.vertices,1),1))*diag([-1 1 1])*1000;
end

AtlasMRI='d:/ndiaye/data/subjects/colin27/brodmann.img';
%AtlasMRI='d:/ndiaye/data/subjects/colin27/aal.img';
ColinMRI='d:/ndiaye/data/subjects/colin27/colin.img';

% Note: the right occipital pole of the single subject MNI (colin27) goes a
% little on the left side
if not(exist('xyz'))
%    y=spm_vol(fullfile(HOMEDIR, 'data', 'subjects', 'colin27','aal.img'))    
    y=spm_vol(AtlasMRI)  
    vol=spm_read_vols(y);
    % Undo L-R flipping 
    if spm_flip_analyze_images
        y.mat(1:5:11)=y.private.hdr.dime.pixdim(2:4);
        y.mat(1,4)=-y.mat(1,4);
    end

    ref=vol(vol>0);
    [xyz(:,1),xyz(:,2),xyz(:,3)]=ind2sub(size(vol), find(vol>0));
    % MRI to MNI coord.
    xyz=[xyz ones(size(xyz,1),1)];
    xyz=xyz*y.mat';    
    xyz=xyz(:,1:3);
    
    try
       [ign,labels,ign]=textread(strrep(y.fname,'img', 'txt'), '%f%s%f');
    catch
        labels=cellstr(num2str([1:max(ref)]'));
    end
    
    % Import 
    yc=spm_vol(ColinMRI);
    if spm_flip_analyze_images
        yc.mat(1,:)=-yc.mat(1,:);
    end
    volc=spm_read_vols(yc);

end

if 0
    if not(exist('xyz2'))
        DECIMATION=1;
        xyz2=xyz(1:DECIMATION:end,:);
        ref2=ref(1:DECIMATION:end);
    end
end


figure(1);
clf
z=40; dz=2; 
k=fv.vertices(:,3)<z+dz & fv.vertices(:,3)>z-dz;
p=plot3d(fv.vertices(k,:) ,'.');
view(2);hold on;
% set(hp, 'FaceAlpha', 'interp');set(hp, 'FaceVertexAlphaData', k+(1-k)*0);
n=100;
colormap([ subarray(colorcube(n), randperm(n)) ; gray(100)]); 
colorbar
hc=img_slice(yc,volc./max(volc(:))*100+n+1, [NaN NaN z]);
set(hc, 'CDataMapping', 'direct', 'FaceAlpha', 1)
hi=img_slice(y,[], [NaN NaN z]);
set(hi, 'CDataMapping', 'direct', 'AlphaData', logical(get(hi, 'CData'))*.51)

return

if 0 
    % Make AAL for all vertices
    fv.r=ref(nearest(fv.vertices, xyz));
elseif BRODMANN
    % Brodmann only for cerebral matter
    r=zeros(size(fv.vertices,1), 1)
    k=load(TessFile, 'Lhemi', 'Rhemi', 'Cerebellum')
    r([ k.Rhemi ; k.Lhemi])=ref(nearest(fv.vertices([ k.Rhemi ; k.Lhemi]), xyz));
end
    


return

% =========================================================================
% =========================================================================
% =========================================================================

mypath 
addpath(fullfile(HOMEDIR, 'mtoolbox/brainstorm/Toolbox'))
addpath(fullfile(HOMEDIR, 'mtoolbox/spm2'))
addpath((MATLABDIR))
addpath(fullfile(MATLABDIR, 'ctf2tal'))
addpath(fullfile(MATLABDIR, 'stormvisa'))
addpath(fullfile(MATLABDIR, 'brodmann'))

AtlasMRI='d:/ndiaye/data/subjects/colin27/brodmann.img';
AtlasMRI='d:/ndiaye/data/subjects/colin27/aal.img';

MNISubjectImage=fullfile(USBDIR,'/mtoolbox/brainstorm/MNItemplate','MNI_subjectimage.mat')
tessfile=fullfile(USBDIR,'/mtoolbox/brainstorm/MNItemplate','MNI_braincereb_small_tess_CTF.mat')

% Note: the right occipital pole of the single subject MNI (colin27) goes a
% little on the left side
if not(exist('xyz'))
%    y=spm_vol(fullfile(HOMEDIR, 'data', 'subjects', 'colin27','aal.img'))    
    y=spm_vol(AtlasMRI)  
    vol=spm_read_vols(y);
    % Undo L-R flipping 
    if spm_flip_analyze_images
        y.mat(1:5:11)=y.private.hdr.dime.pixdim(2:4);
        y.mat(1,4)=-y.mat(1,4);
    end
    ref=vol(vol>0);
    try
       [ign,labels,ign]=textread(strrep(y.fname,'img', 'txt'), '%f%s%f');
    catch
        labels=cellstr(num2str([1:max(ref)]'));
    end
    % in MRI
    [xyz(:,1),xyz(:,2),xyz(:,3)]=ind2sub(size(vol), find(vol>0));
end
if not(exist('xyz2'))
    DECIMATION=1;   
    xyz2=xyz(1:DECIMATION:end,:);
    ref2=ref(1:DECIMATION:end);
    % in MNI
    xyz2=[xyz2 ones(size(xyz2,1),1)]*y.mat';
    xyz2=xyz2(:,1:3);
end

return

s=load(MNISubjectImage, 'talCS', 'SCS')
fv=tess2patch(tessfile);

v=scs2tal(s.talCS.scsCubeFiducial/1000, s.talCS.cortexTess, fv.vertices', 'mnicereb');

return

view_cortex(fv.faces, v*1000)
r=ref2(closest(v'*1000, xyz2)); % labelize(v'*1000, xyz2,ref2, 'Timebar', 'on')
labelviewer(fv, r, xyz2, ref2, labels)

