function [patchhandle, template] = labelviewer(fv, r, xyz, ref, labels, varargin)
% LABELVIEWER - Display labels on a cortex
% [] = labelviewer(Brain, CData, TemplateXYZ, TemplateREF, Labels, [ColorMap])
% 
% - Brain: a .vertices and .faces structure
% - CData: already computed labels on the brain mesh
% - TemplateXYZ: [Na x 3] Atlas Coordinates of the Na vertices
% - TemplateREF: [Na x 1] Atlas Label ID
% - Labels: Cell of strings
% - ColorMap=[Nlabels x 3] colormap (default: hsv)
%
% Ouputs:
% - [none] : GUI version


if nargin > 5 
    cmap=varargin{1};
else
    cmap=hsv(length(labels));
end

kcmap=.4;
r=double(r);
hf=figure;
axes
set(gca, 'color', 'k');
p=patch('vertices', fv.vertices, 'faces',fv.faces, ...
    'CData', r, 'CDataMapping', 'direct', ... 	
    'EdgeColor', 'none', 'FaceColor', 'flat');
lighting gouraud
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

hold on
if not(isempty(xyz)) & not(isempty(ref))
    for i=1:length(labels)
        if any(ref==i)
        pp(i)=plot3d(xyz(ref==i,:),'o', 'markerSize', 2, 'color', 1-cmap(i,:));
    else
        pp(i)=plot3d([0 0 0],'Marker', 'none', 'markerSize', 2, 'color', 1-cmap(i,:));
    end
    end
    set(pp, 'visible', 'off');    
else
    pp=[];
end
u.pp=pp;
u.r=r;
u.cmap=cmap;
u.kcmap=kcmap;
u.ref=ref;
u.roi=[];
set(hf, 'UserData', u);
callback=[ 'u=get(gcbf, ''UserData'');'...
        'set(u.pp, ''visible'', ''off'');' ...
        'i=get(gcbo,''value'');set(u.pp(i),''visible'',''on''); ' ...
        'c=u.cmap*u.kcmap; c(i,:)=u.cmap(i,:); colormap([c]);' ...
        'u.roi=find(ismember(u.r,i));' ...
        'set(gcbf, ''UserData'', u);'];
hui=uicontrol('Style', 'listbox',  'Tag', 'Labels', ...
    'String', labels , ...
    'callback', callback);
set(hui, 'units', 'normalized')
set(hui, 'Max', 2, 'Min', 0)
set(hui, 'position', [0.8414    0.1100    .15    .8150])

eval(strrep(strrep(callback, 'gcbf', 'hf'), 'gcbo', 'hui'));
rotate3d

