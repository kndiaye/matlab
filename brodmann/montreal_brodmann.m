mypath

addpath(fullfile(HOMEDIR, 'mtoolbox/brainstorm/Toolbox'))
addpath(fullfile(HOMEDIR, 'mtoolbox/spm2'))
addpath(fullfile(MATLABDIR))
addpath(fullfile(MATLABDIR, 'ctf2tal'))
addpath(fullfile(MATLABDIR, 'stormvisa'))
addpath(fullfile(MATLABDIR, 'brodmann'))


load(fullfile(HOMEDIR, 'data/subjects/montreal_subject/montreal_4layer_tess'))
fv.vertices=Vertices{4}';
fv.vertconn=VertConn{4};
clear Vertices;
fv.faces=Faces{4};
clear Faces;
clear VertConn
clear tess2mri_interp
try
    load(fullfile(USBDIR, 'data/subjects/montreal_subject/TalairachMRIscs.mat'), 'TAL')
    S(1)=load(fullfile(HOMEDIR, 'data/subjects/montreal_subject/montreal_subjectimage.mat'), 'SCS')
    S(2).SCS=S(1).SCS(1);
    S(3)=load(fullfile(HOMEDIR, 'mtoolbox/brainstorm/Phantom/montreal_subject/montreal_subjectimage_info.mat'), 'SCS')
    S(4).SCS=S(3).SCS(1);
    
catch
end
% fv2.vertices=scs2mri(S(2),fv.vertices'*1000)'-repmat([92 128 74],[10001,1]);
fv2.faces=fv.faces;
fv2.vertconn=fv.vertconn;

fv2.vertices=scs2mri(S(end),fv.vertices'*1000);
[ignore,fv2.vertices]=mri2scs(TAL,fv2.vertices);
fv2.vertices=fv2.vertices';
v2=fv2.vertices;

disp('Lecture des fichiers Analyze')
apc=[0 0 0; 0 -23 0; 0 0 50];
verttal = ctf2tal(v2, [], 'ACPCIH_ctf', [apc], 'brainvert', v2);

figure(1)
clf
view_cortex(fv2.faces,v2/1000,'FaceColor','none', 'EdgeColor', 'k' , 'FaceAlpha', .5)
hold on
view_cortex(fv2.faces,verttal, 'FaceColor','none', 'EdgeColor', 'r')
view_cortex(fv2.faces,mni2tal(v2)/1000, 'FaceColor','none', 'EdgeColor', 'g')
legend({'orig','tal', 'mni2tal'},0)

view(90,0)
rotate3d
drawnow



if not(exist('xyz2'))
    DECIMATION=1000
%    y=spm_vol(fullfile(HOMEDIR, 'data', 'subjects', 'colin27','aal.img'))    
    y=spm_vol(fullfile(HOMEDIR, 'data', 'subjects', 'colin27','brodmann.img'))    
    v=spm_read_vols(y);
    % Undo L-R flipping 
    if spm_flip_analyze_images
        y.mat(1:5:11)=y.private.hdr.dime.pixdim(2:4);
        y.mat(1,4)=-y.mat(1,4);
    end
    ref=v(v>0);
    try
       [ign,labels,ign]=textread(strrep(y.fname,'img', 'txt'), '%f%s%f');
    catch
        labels=cellstr(num2str([1:max(ref)]'));
    end
    % in MRI
    [xyz(:,1),xyz(:,2),xyz(:,3)]=ind2sub(size(v), find(v>0));
    xyz2=xyz(1:DECIMATION:end,:);
    ref2=ref(1:DECIMATION:end);
    % in MNI
    xyz2=[xyz2 ones(size(xyz2,1),1)]*y.mat';
    xyz2=xyz2(:,1:3);
    
    % I dunno why but brodmann from MRIcro is not centered?!?
    % xyz2=xyz2-repmat([-3 10 -10], [size(xyz2,1) 1]);
    v2=fv2.vertices+repmat([0 10 -8],10001,1);
end
plot3d([xyz2]/1000)

% r=labelize(v2, xyz2, ref2, 'TimeBar', 'on');

return
labelviewer(struct('vertices', v2, 'faces', fv.faces), r, xyz2, ref2, labels)


r=ref2(closest(v2,xyz2));

if 0
    load(fullfile(HOMEDIR, 'matlab/ctf2tal/TTareas.mat'));
    xyz=xyz(1:10:end,:);
    ref=ref(1:10:end);
    ref=double(ref);
    xyz=ctf2tal(xyz, [], 'brainvert', xyz, 'CA', [0 0 0], 'CP', [0 -23 0], 'IH' ,[0 0 50]);
    r=labelize(verttal, xyz2, ref, 'TimeBar', 'on');
    talairach.vertices=verttal;
    talairach.faces=fv.faces;
end

return

save(fullfile(SCOUTDIR,date,[date '_brodmann.mat']), 'r','talairach', 'xyz', 'ref', 'labels' )

disp('Sauvegarde dans un fichier CorticalScout')

scoutfile=dir(fullfile(RESDIR,date, [date '*CorticalScout_2.mat']));
scouts=load(fullfile(RESDIR,date, scoutfile.name));

BA=strmatch('Brodmann', labels);

SIDES=['R', 'L'];
for side=0:1
for i=1:length(BA)
 vba=find(r==BA(i) & left==side);
 scouts.CorticalScouts.CorticalMarkersLabels{i+42*side}=[labels{BA(i)} '-' SIDES(side+1)];
 if not(isempty(vba))
 scouts.CorticalScouts.CorticalSpots(i+42*side)=vba(1);
 scouts.CorticalScouts.CorticalMarkers(i+42*side,:) = v_ctf(vba(1),:);
else
 scouts.CorticalScouts.CorticalSpots(i+42*side)=NaN;
 scouts.CorticalScouts.CorticalMarkers(i+42*side,:) = NaN;
end
 scouts.CorticalScouts.CorticalProbePatches{i+42*side}=vba;
 scouts.CorticalScouts.CorticalProbeDepth(i+42*side)=0;
 scouts.CorticalScouts.CorticalProbePatchesXYZ{i+42*side}=v_ctf(scouts.CorticalScouts.CorticalProbePatches{i},:)';
end
end
bascoutfile=strrep(scoutfile.name, '_2.mat', '_BA.mat')
     CorticalScouts=scouts.CorticalScouts;
     ResultFile=scouts.ResultFile;
     ActiveTess=scouts.ActiveTess;
     save(fullfile(SCOUTDIR,date,bascoutfile), 'ResultFile','ActiveTess','CorticalScouts')

return



cmap=hsv(69);
hf=figure;
p=patch('vertices', fv.vertices, 'faces',fv.faces, ...
	'CData', r, 'CDataMapping', 'direct', ... 	
	'EdgeColor', 'none', 'FaceColor', 'flat');
colormap(cmap)
h=colorbar;
axis image
light('position' , [-1 1 0])
light('position' , [ 0 0 1])
light('position' , [ 1 -1 -1])
light('position' , [ 1 1 0])
l=findobj(hf, 'type', 'light');
set(l, 'color', .8*ones(1,3))
set(h, 'YDir', 'reverse');
set(h, 'position', [0.8314    0.1100    0.02    0.8150])
view(3)
rotate3d
lighting gouraud

return
