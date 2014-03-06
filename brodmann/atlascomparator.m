function []=atlascomparator(atlas1,atlas2, loc)
% atlascomparator - compare two atlases
% atlascomparator(atlas1,atlas2) display for each atlas1 region, the
%      overlapping regions from atlas2. 
% atlascomparator(atlas1,atlas2, loc) LOC is the mapping of atlas1 onto atlas2

if nargin<3
    [tf,loc]=ismember(atlas1.xyz,atlas2.xyz,'rows');
end


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

nl=length(atlas1.labels);
nl2=length(atlas2.labels);

% hbar = timebar('Labeling clusters','Progress')

if 0
% Not lableled
axes(ax(1).h)
v=find(atlas1.ref==0);
if ~isempty(v)
    hp{1}(1,1)=plot3d(atlas1.xyz(v,:), '.', 'Marker', '.', 'MarkerSize', 1);
    hp{1}(1,2)=copyobj(hp{1}(:,1),ax(2).h);
    hp{1}(1,3)=copyobj(hp{1}(:,1),ax(3).h);
    
else
    hp{1}=[];
end
end

disp('Displaying Clusters')
fprintf(sprintf('%02d/%02d',0,nl))
for i=1:nl  
    v=find(atlas1.ref==i);
    if ~isempty(v)
        l=loc(v);
        lu=unique(atlas2.ref(l(l>0)));
        nlu=length(lu);
        colors=hsv(nlu);
        hp{i+1}=zeros(nlu,3);
        areas{i+1}=zeros(nlu,1);
        axes(ax(1).h)
        
        if any(l==0)
            colors=hsv(nlu+1);
            hp{i+1}=zeros(nlu+1,3);           
            hp{i+1}(nlu+1)=plot3d(atlas1.xyz(v(l==0),:), '.', 'Marker', '.', 'MarkerSize', 1, 'Color', colors(nlu+1,:));
            areas{i+1}=zeros(nlu,1);
            areas{i+1}(nlu+1)=nl2+1;
        end
        for j=1:nlu
            hp{i+1}(j)=plot3d(atlas1.xyz(v(atlas2.ref(l(l>0))==lu(j)),:), '.', 'Marker', '.', 'MarkerSize', 1, 'Color', colors(j,:));    
            areas{i+1}(j)=lu(j);
        end
        
        hp{i+1}(:,2)=copyobj(hp{i+1}(:,1),ax(2).h);
        hp{i+1}(:,3)=copyobj(hp{i+1}(:,1),ax(3).h);
    end
    
    % timebar(hbar,(i)/(nl))  
    fprintf(sprintf('\b\b\b\b\b%02d/%02d', i,nl))
end
disp('... done')
if 0
    v=find(not(ismember(ref,0:nl)));
    if ~isempty(v)
        hp(end+1,3)=plot3d(xyz(v,:), '.', 'Marker', '.', 'MarkerSize', 1);
    else
        hp(end+1,3)=plot3d([0 0 0], '.', 'Marker', '.', 'MarkerSize', 1);
        set(hp(end,3), 'Visible', 'Off');
    end
end
% close(hbar);

for j=1:3
    axes(ax(j).h)
    axis image
end

u.labels2=[ atlas2.labels(:) ; {'Not in Atlas2'}];
u.areas=areas;

u.hp=hp;
set(gcf, 'UserData', u);

callback=[ 'u=get(gcbf, ''UserData'');' ...
        'set(cat(1,u.hp{:}), ''MarkerSize'', 1, ''Color'', ''k'');' ...
        'u.iref=get(gcbo,''value'');'...
        'set([u.hp{u.iref}(:)], ''MarkerSize'', 5);' ...
        'u.colors=hsv(size(u.hp{u.iref},1));'...
        'for i=1:size(u.hp{u.iref},1);'...
        'set(u.hp{u.iref}(i,:), ''Color'', u.colors(i,:));'...
        'end;'...
        'u.hleg=legend(u.hp{u.iref}(:,3), strrep(u.labels2(u.areas{u.iref}), ''_'', ''\_''),0);'...
        'set(u.hleg, ''Position'', get(u.hleg, ''Position'').*[0 0 1 1] + [ .4 .45 0 0]);'...
        'clear u;'];

hui=uicontrol('Style', 'listbox',  'Tag', 'Labels', ...
    'String', [ {'Not Labeled'} ; atlas1.labels ; {'Missing labels'}], ...
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
