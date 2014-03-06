mypath
addpath(fullfile(HOMEDIR, 'mtoolbox/brainstorm/Toolbox'))
addpath(fullfile(HOMEDIR, 'mtoolbox/spm2'))
addpath((MATLABDIR))
addpath(fullfile(MATLABDIR, 'ctf2tal'))
addpath(fullfile(MATLABDIR, 'stormvisa'))
addpath(fullfile(MATLABDIR, 'brodmann'))


try
    load(fullfile(USBDIR, 'data/subjects/montreal_subject/TalairachMRIscs.mat'), 'TAL')
    S(1)=load(fullfile(HOMEDIR, 'data/subjects/montreal_subject/montreal_subjectimage.mat'), 'SCS')
    S(2).SCS=S(1).SCS(1);
    S(3)=load(fullfile(HOMEDIR, 'mtoolbox/brainstorm/Phantom/montreal_subject/montreal_subjectimage_info.mat'), 'SCS')
    S(4).SCS=S(3).SCS(1);    
catch
end


if not(exist('xyz2'))
    DECIMATION=1000
%    y=spm_vol(fullfile(HOMEDIR, 'data', 'subjects', 'colin27','aal.img'))    
    y=spm_vol(fullfile(HOMEDIR, 'data', 'subjects', 'colin27','brodmann.img'))    
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
    xyz2=xyz(1:DECIMATION:end,:);
    ref2=ref(1:DECIMATION:end);
    % in MNI
    xyz2=[xyz2 ones(size(xyz2,1),1)]*y.mat';
    xyz2=xyz2(:,1:3);
    
        % I dunno why but brodmann from MRIcro is not centered?!?
    % xyz2=xyz2-repmat([-3 10 -10], [size(xyz2,1) 1]);
    v2=fv2.vertices+repmat([0 10 -8],10001,1);

end

% 
% tessfile='d:\ndiaye\data\subjects\MNI\MNI_LhemiMNI_Rhemi_10000V_tess.mat'
% fv=tess2patch(tessfile);
% % in mm:
% fv.vertices=fv.vertices*1000;
% % Re-center 
% % Z-flip:
% fv.vertices(:,3)=-fv.vertices(:,3);
% % Y (antero-post) flip
% fv.vertices(:,2)=-fv.vertices(:,2);
% fv.vertices=fv.vertices+repmat(y.mat(1:3,4)', [size(fv.vertices,1),1]);
% delete(findTessellationHandles);view_cortex(fv);pause

s=load('MNI_subjectimage.mat', 'talCS', 'SCS')
tessfile='MNI_braincereb_small_tess_CTF.mat'
fv=tess2patch(tessfile);
v=scs2tal(s.talCS.scsCubeFiducial/1000, s.talCS.cortexTess, fv.vertices', 'mnicereb');
view_cortex(fv.faces, v*1000)

return

fv2.faces=fv.faces;
% fv2.vertconn=fv.vertconn;
fv2.vertices=scs2mri(S(end),fv.vertices'*1000);
[ignore,fv2.vertices]=mri2scs(TAL,fv2.vertices);
fv2.vertices=fv2.vertices';
v2=fv2.vertices;

disp('Lecture des fichiers Analyze')
apc=[0 0 0; 0 -23 0; 0 0 50];
verttal = ctf2tal(v2, [], 'ACPCIH_ctf', [apc], 'brainvert', v2);
