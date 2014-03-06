% Transpose, Flip, etc so that Left is on Left 
% and all the rest is okay
% TessFile='D:\ndiaye\data\subjects\MNI_4_Yann\MNI_brain_NoCollosum_12000V_tess.mat';
% fv=tess2patch(TessFile);
% v=(fv.vertices*diag([1 -1 -1])+repmat([-90e-3 217e-3-126e-3 181e-3-72e-3], size(fv.vertices,1),1))*diag([-1 1 1])*1000;
% view_cortex(fv.faces, v)
% image_spm(y,vol); view(2); hold on
% h=findTessellationHandles
% set(h, 'visible', 'off')

TessFile='D:\ndiaye\data\subjects\MNI_4_Yann\MNI_brain_NoCollosum_12000V_tess_corrected.mat';
fv=tess2patch(TessFile);


AtlasMRI='d:/ndiaye/data/subjects/colin27/brodmann.img';
AtlasMRI='d:/ndiaye/data/subjects/colin27/aal.img';

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
    
    try
       [ign,labels,ign]=textread(strrep(y.fname,'img', 'txt'), '%f%s%f');
    catch
        labels=cellstr(num2str([1:max(ref)]'));
    end
    
end
if not(exist('xyz2'))
    DECIMATION=1;   
    xyz2=xyz(1:DECIMATION:end,:);
    ref2=ref(1:DECIMATION:end);
    % in MNI
    xyz2=[xyz2 ones(size(xyz2,1),1)]*y.mat';
    xyz2=xyz2(:,1:3);
end
