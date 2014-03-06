% view3d() - a simple 3D viewer
% Use:
%  >> view3d(FV)
%  >> view(vertices, faces)
% FV might be a structure with fields .vertices and .faces
% 
% Setting options:
%  >> view3d(FV, options)
%  >> view(vertices, faces, options)
% e.g.:
%  >> view(vertices, faces, 'FaceColorCData', rand(length(vertices),1))
function [ p ] = view3d(v,f, varargin)
if isfield(v, 'vertices')
    for i=1:length(v)        

        view3d(v(i).vertices, v(i).faces, f, varargin{:})
        hold on
        zoom(1/1.1)
        delete(findobj(gca, 'type', 'light'))
        delete(findobj(gca, 'type', 'light'))
    end 
    axis image
    if length(findobj(gca, 'type', 'light')) == 0
       light('Position',[-1 -1 1],'Style','infinite'); 
       light('Position',[1 1 0],'Style','infinite'); 
   end
else    
    
    if isempty(varargin)
        options={'FaceColor' , [0.7 .65 .65]};
    else
        options=varargin;
    end
    
    p=patch('Vertices', v, 'Faces', f,'EdgeColor','none','FaceLighting','phong','FaceAlpha','interp', options{:}); 
    set(p,'DiffuseStrength',.6,'SpecularStrength',0,'AmbientStrength',.4,'SpecularExponent',5)
    view(3); 
    grid on; 
    lighting phong; 
    alpha(1); 
    axis on; 
    axis image;
    if length(findobj(gca, 'type', 'light')) == 0
    light('Position',[-1 -1 1],'Style','infinite'); 
    light('Position',[1 1 0],'Style','infinite'); 
    end
    zoom(1.1);
end