if 0
  a=readAPCmm('../../brainvisa/div/div11/anatomy/div11.APC')
  [m,m2]=readMRItoCTF([ '../../brainvisa/div/div11/tri/'...
		    'div11_MD_CTF.txt'])
  [fv.vertices, fv.faces]=readmeshes({'../../brainvisa/div/div11/tri/div11_Lhemi.mesh' '../../brainvisa/div/div11/tri/div11_Rhemi.mesh'});
  fv.faces=fv.faces+1;
  fv=reducepatch(fv,50000);
  faces=fv.faces;
  v_ctf=[fv.vertices ones(size(fv.vertices,1),1)]*m2;
  apc=[a ones(3,1)]*m2;
  vertices = ctf2tal(v_ctf, [], 'ACPCIH_ctf', apc, 'brainvert', v_ctf);
  save ../../data/s11cortex_tal.mat faces vertices
  
  load ../../data/talairach/TTareas.mat
  cmap= hsv(66); %[repmat(.6, 3,3) ; hsv(47-3) ; repmat(.6,69-47,3)];
  kcmap=0.3;

xyz=xyz(1:10:end,:);
ref=ref(1:10:end);
ref=double(ref);

% Bizarrely, this vertices are not exactly shaped to the talairach
% box... We deform them slightly
xyz=ctf2tal(xyz, [], 'brainvert', xyz, 'CA', [0 0 0], 'CP', [0 -23 0], 'IH' ,[0 0 50]);

r=zeros(length(vertices),1)*NaN;
k=r;

end

figure
p=patch('vertices', vertices, 'faces',faces, ...
	'CData', r, 'CDataMapping', 'direct', ... 	
	'EdgeColor', 'none', 'FaceColor', 'flat');
axis image
set(p, 'SpecularExponent', 2)
set(p, 'SpecularStrength', .3)


light('position' , [-1 1 0])
light('position' , [ 0 0 1])
light('position' , [ 1 -1 -1])
light('position' , [ 1 1 0])
l=findobj(gcf, 'type', 'light');
set(l, 'color', .8*ones(1,3))

lighting gouraud
colormap(cmap)
h=colorbar
set(h, 'YDir', 'reverse');
set(h, 'position', [0.8314    0.1100    0.02    0.8150])
view(3)
rotate3d

if all(isnan(r)) %not(exist('k')) & not(exist('r'))
  r=labelize(vertices, xyz, ref, 'TimeBar', 'on');
  
% $$$   h=timebar('Labelling vertices...', 'TTGyri');
% $$$   for i=1:length(vertices)
% $$$     d=sqrt(sum(power(xyz-repmat(vertices(i,:),size(xyz,1),1),2),2));     
% $$$     
% $$$     % local "smoothing" 
% $$$     % r(i)=imax(hist(ref(d<5e-3), .5:length(labels)));        
% $$$     
% $$$     k(i)=imax(-d);
% $$$     r(i)=ref(k(i));    
% $$$     timebar(h, i/length(vertices),1);
% $$$     %set(p, 'FaceVertexCData',r); drawnow;
% $$$   end
% $$$   close(h)
end


% jj=hsv;jj=jj(randperm(64),:);colormap(jj)

hold on
for i=1:length(labels)
  pp(i)=plot3d(xyz(ref==i,:),'w.', 'markerSize', 2);
end
set(pp, 'visible', 'off');

if not(exist('cmap'))
  cmap=hsv(69);
end


hui=findobj(gcf,'Tag', 'Labels')
if isempty(hui)    
  callback=['set(pp, ''visible'', ''off'');' ...
	    'i=get(hui,''value'');set(pp(i),''visible'',''on''); ' ...
	    'c=cmap*kcmap; c(i,:)=cmap(i,:); colormap([c]);' ...
	    'roi=find(r==i);'];
  hui=uicontrol('Style', 'listbox',  'Tag', 'Labels', ...
	    'callback', callback);
  eval(callback);
  set(hui, 'units', 'normalized')
  set(hui, 'Max', 2, 'Min', 0)
  set(hui, 'position', [0.8414    0.1100    .15    .8150])
  set(hui, 'String', labels)
end
rotate3d

