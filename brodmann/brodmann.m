mypath

addpath(fullfile(HOMEDIR, 'mtoolbox/brainstorm/Toolbox'))
addpath(fullfile(HOMEDIR, 'matlab/'))
addpath(fullfile(HOMEDIR, 'matlab/ctf2tal/'))
addpath(fullfile(HOMEDIR, 'matlab/stormvisa'))
addpath(fullfile(HOMEDIR, 'matlab/brodmann'))

IRMDIR='/pclxserver2/home/datalinks/DAV/brainvisa/div'
TESSDIR='/pclxserver2/home/datalinks/DAV/brainvisa/div'
SCOUTDIR=fullfile(HOMEDIR, 'tmp')

sujet='div07'
segdir='tri'
date=sujet
RESDIR=SCOUTDIR;


IRMdim=readdim(fullfile(IRMDIR,sujet,'anatomy', [sujet '.dim']));
a=readAPCmm(fullfile(IRMDIR,sujet,'anatomy', [sujet '.APC']), IRMdim.voxelsize(1:3))
tessfile=dir(fullfile(TESSDIR,sujet, segdir, [sujet '*_tess.mat']));
tess=load(fullfile(TESSDIR,sujet, segdir, tessfile.name));
fv.vertices=tess.Vertices{end}';
fv.faces=tess.Faces{end};
v1=readtri(fullfile(TESSDIR,sujet, segdir, [sujet '_Lhemi.tri']));
v2=readtri(fullfile(TESSDIR,sujet, segdir, [sujet '_Lhemi-CTF.tri']));
v2=v2/1000;

if not(exist('left'))
% look for Left sided vertices
left=zeros(size(fv.vertices,1),1);
nverts=size(fv.vertices,1);
h=timebar('Finding side of scouts', 'Left or Right?')
for i=1:nverts
timebar(h, i/nverts)
d=sum((repmat(fv.vertices(i,:), size(v2,1),1)-v2).^2,2);
 x=find(d==0);
if not(isempty(x))
 left(i)=1;
end
end
close(h)
end

disp('Calcul des régions de Brodmann dans Talairach')

m2=[v1 ones(size(v1,1),1)]\v2;

%id est: 
% v_ctf=[fv.vertices ones(size(fv.vertices,1),1)]*m2;

v_ctf=fv.vertices;
apc=[a*1000 ones(3,1)]*m2;
verttal = ctf2tal(v_ctf, [], 'ACPCIH_ctf', apc, 'brainvert', v_ctf);
load(fullfile(HOMEDIR, 'matlab/ctf2tal/TTareas.mat'));
xyz=xyz(1:10:end,:);
ref=ref(1:10:end);
ref=double(ref);
xyz=ctf2tal(xyz, [], 'brainvert', xyz, 'CA', [0 0 0], 'CP', [0 -23 0], 'IH' ,[0 0 50]);
r=labelize(verttal, xyz, ref, 'TimeBar', 'on');

talairach.vertices=verttal;
talairch.faces=fv.faces;

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

     labelviewer(struct('vertices', verttal, 'faces', fv.faces), r, xyz, ref, labels)
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
