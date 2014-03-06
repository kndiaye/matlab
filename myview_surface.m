function [hf,hs,hl] = view_surface(figname,faces,verts,cdata);
% VIEW_SURFACE Convenient function to consistently plot surfaces
% function [hf,hs,hl] = view_surface(figname,faces,verts,cdata);
% figname is the name of the figure window
% faces is the triangle listing
% verts are the corresponding vertices
% cdata is the colordata to use.  If not given, uses norms of verts

% John C. Mosher, Ph.D.  See Copyright.m for information
% $Revision: 1 $ $Date: 1/24/01 5:50p $
% ---> Karim NDIAYEs version <----

if(size(verts,2) > 3), % assume transposed
  verts = verts';  % if the assumption is wrong, will crash below anyway
end

if(~exist('cdata','var')),
  cdata = rownorm(verts);
end

cla
hs = patch('faces',faces,'vertices',verts,...
  'facevertexcdata',cdata(:),'facecolor','interp','edgecolor','none');
view(2)
axis image
axis off
lighting phong



material dull;
lighting phong
set(gcf, 'Color', [1 1 1 ])
rotate3d on

hl(1) = camlight(-20,30);
hl(2) = camlight(20,30);
hl(3) = camlight(-20,-30);
%for i = 1:length(hl),
%  set(hl(i),'color',[.8 1 1]/length(hl)/1.2); % mute the intensity of the lights
%end

if(nargout>0),
  hf = h;  % only if the user has output argument
end

return
