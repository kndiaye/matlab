function [h] = atlasviewer(xyz, ref, labels)
% ATLASVIEWER - Display labelled regions in 3 plans for a brain atlas
% [] = atlasviewer(AtlasXYZ, AtlasREF, AtlasLabels)
% 
% - TemplateXYZ: [Na x 3] Atlas Coordinates of the Na vertices
% - TemplateREF: [Na x 1] Atlas Label ID
% - Labels: Cell of strings
%


figure
clf

ax(1).h=subplot(2,2,1);
ax(1).name='coronal';
view(0,0); % Left on left
hold on


ax(2).h=subplot(2,2,2);
ax(2).name='sagittal';
view(-90,0); % anterior on left
hold on

ax(3).h=subplot(2,2,3);
ax(3).name='axial';
view(0,90); % anterior on top
hold on


ax(4).h=subplot(2,2,4);

set([ax(:).h], 'units', 'normalized');

nl=length(labels);
hbar = timebar('Labeling clusters','Progress')

v=find(ref==0);
axes(ax(3).h)
if ~isempty(v)
    hp(1,3)=plot3d(xyz(v,:), '.', 'Marker', '.', 'MarkerSize', 1);
else
    hp(1,3)=plot3d([0 0 0], '.', 'Marker', '.', 'MarkerSize', 1);
    set(hp(1,3), 'Visible', 'Off');
end
for i=2:nl+1  
  v=find(ref==i-1);
  if ~isempty(v)
      axes(ax(3).h)
      hp(i,3)=plot3d(xyz(v,:), '.', 'Marker', '.', 'MarkerSize', 1);    
  end
  timebar(hbar,(i)/(nl))  
end
v=find(not(ismember(ref,0:nl)));
axes(ax(3).h)
if ~isempty(v)    
    hp(end+1,3)=plot3d(xyz(v,:), '.', 'Marker', '.', 'MarkerSize', 1);
else
    hp(end+1,3)=plot3d([0 0 0], '.', 'Marker', '.', 'MarkerSize', 1);
    set(hp(end,3), 'Visible', 'Off');
end
close(hbar);
hp(hp(:,3)>0,1)=copyobj(hp(hp(:,3)>0,3),ax(1).h);
hp(hp(:,3)>0,2)=copyobj(hp(hp(:,3)>0,3),ax(2).h);
for j=1:3
  axes(ax(j).h)
  axis image
end

u.hp=hp;
set(gcf, 'UserData', u);

callback=[ 'u=get(gcbf, ''UserData'');'...
	   'set([u.hp(u.hp>0)], ''MarkerSize'', 1, ''Color'', ''b'');' ...
	   'set([u.hp(get(gcbo,''value''),:)],''MarkerSize'',5, ''Color'', ''r''); ' ...
	   'clear u;'];

hui=uicontrol('Style', 'listbox',  'Tag', 'Labels', ...
	      'String', [ {'Not Labeled'} ; labels ; {'Missing labels'}], ...
	      'callback', callback);
set(hui, 'units', 'normalized')
set(hui, 'Max', 2, 'Min', 0)
set(hui, 'position', get(ax(4).h, 'Position'));

axes(ax(4).h)
set(ax(4).h, 'Units', 'centimeters')
ht=title(sprintf('%d labeled regions', nl));
set(ht, 'Units', 'centimeters')
p=get(ht, 'Extent')+get(ax(4).h, 'Position').*[ 1 1 0 0]
htui=uicontrol('Style', 'text', 'Units', 'centimeters', 'position', p, 'String', get(ht, 'String'));
set(htui, 'units', 'normalized')
delete(ax(4).h)





