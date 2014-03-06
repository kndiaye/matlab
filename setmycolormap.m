function [varargout]=setmycolormap(seuil,varargin)

m=mycolormap(seuil, varargin{:});
colormap(m);
material dull;
%h=light;
%set(h, 'position', [0 -1 0])
%set(h, 'color', [0.5 .5 0.5])
%h=light;
%set(h, 'position', [0 1 0])
%set(h, 'color', [0.5 .5 0.5])
% caxis([-mean(abs(caxis)) mean(abs(caxis))])

colorbar
set(gcf, 'Color', [1 1 1 ])
rotate3d on
if nargout > 0
varargout=m;
end
