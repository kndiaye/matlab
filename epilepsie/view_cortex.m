function [h,g]=view(faces,vertices, data)
% function [h,g]=view(faces,vertices, data)

if nargin==1
    data=faces;
    global faces
    global vertices    
end
    

if(size(vertices,2) > 3), % assume transposed
  vertices = vertices';  % if the assumption is wrong, will crash below anyway
end

% if(~exist('cdata','var')),
%  cdata = rownorm(vertices);
% end

% h = windfind(figname);
% figure(h)
% windclf
% h=figure
cla
h = patch('faces',faces,'vertices',vertices,...
  'facevertexcdata',data(:),'facecolor','interp','edgecolor','none');


hl(1) = camlight(-20,30);
hl(2) = camlight(20,30);
hl(3) = camlight(-20,-30);
for i = 1:length(hl),
  set(hl(i),'color',[.8 1 1]/length(hl)/1.2); % mute the intensity of the lights
end
g=light;
set(g, 'position', [0  -1 0])
g=light;
set(g, 'position', [0  1 0])

% h=view_surface('',faces, vertices, data);


view(2)
axis image
axis off
rotate3d
view([0 0])


lighting phong
material dull
colormap(hot(256))
setmycolormap(50)

set(h, 'Userdata', {'Cortex'})
