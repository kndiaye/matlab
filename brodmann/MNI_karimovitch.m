 
addpath(fullfile(HOMEDIR, 'mtoolbox/brainstorm/Toolbox'))
addpath(fullfile(HOMEDIR, 'mtoolbox/spm2'))
addpath((MATLABDIR))
addpath(fullfile(MATLABDIR, 'ctf2tal'))
addpath(fullfile(MATLABDIR, 'stormvisa'))
addpath(fullfile(MATLABDIR, 'brodmann'))

if not(exist('xyz2'))
    DECIMATION=1000
%    y=spm_vol(fullfile(HOMEDIR, 'data', 'subjects', 'colin27','aal.img'))    
    y=spm_vol('brodmann.img')  
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
end


s=load('MNI_subjectimage.mat', 'talCS', 'SCS')
tessfile='MNI_braincereb_small_tess_CTF.mat'
fv=tess2patch(tessfile);
v=scs2tal(s.talCS.scsCubeFiducial/1000, s.talCS.cortexTess, fv.vertices', 'mnicereb');
view_cortex(fv.faces, v*1000)
r=labelize(v'*1000, xyz2,ref2, 'Timebar', 'on')
labelviewer(fv, r, xyz2, ref2, labels)

