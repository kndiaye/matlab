function []=trimsurface(varargin)
% trimsurface - trim (or crop) a surface along a plane
%   trimsurface(handle,xyz) trims surface along coordinates
%   trimsurface(xyz) trim current surface 
%   if xyz(i) == NaN, no trimming is done along dimension i
%   trimsurface(h, xyz, dxyz) trim in direction dxyz 
%   if dxyz(i)>0, hide what is BELOW xyz(i)
%   if dxyz(i)<0, hide what is ABOVE xyz(i)
%   if dxyz(i)=0, depends whether xyz(i)<0 or >O (BrainStorm behavior)
%
% KND : 2005-09-18 : Created based on code from tessellation_manager

h=[];
xyz=[];
dxyz=[];

if nargin>1
    idxargin=1;
    if length(varargin{1})==1 & ishandle(varargin{1}) 
        h=varargin{1};        
        idxargin=idxargin+1;    
    end    
    if idxargin<=nargin
        xyz=varargin{idxargin}; 
        idxargin=idxargin+1;    
    end
    if idxargin<=nargin
        dxyz=varargin{idxargin}; 
        idxargin=idxargin+1;    
    end    
end

if isempty(h)
    try
        h=findTessellationHandles;
    catch;
    end;
end

if isempty(xyz)
    xyz = [NaN NaN NaN]; % Normalized euclidian coordinate threshold along which we want to trim out the surface view
end
if isempty(dxyz)
    dxyz = [0 0 0]; % Trimming direction
end

if ishandle(h)
    vertices = get(h,'vertices');
    FaceVertexAlphaData =  get(h,'FaceVertexAlphaData');
    alpha=get(h,'FaceAlpha');
    if isreal(alpha)
        alpha=max(alpha);
        alpha=min(alpha,1);
        alpha=max(alpha,0);
    else
        alpha=1;   
    end
    if isempty(FaceVertexAlphaData)
        FaceVertexAlphaData = ones(size(vertices,1),1);    
    end
    iNoModif = [];
    for iCoord = 1:3
        vertx = vertices(:,iCoord)'; 
%         vertx = vertx-mean(vertx);
%         vertx = vertx/max(abs(vertx));
        if isnan(xyz(iCoord))
            % do nothing
        elseif dxyz(iCoord)==0 % native Brainstorm behavior
            if xyz(iCoord) > 0            
                iNoModif = [iNoModif,find(vertx < xyz(iCoord) )];
            elseif xyz(iCoord) < 0
                iNoModif = [iNoModif,find(vertx > xyz(iCoord) )];    
            else
                %do nothing
            end
        else
            if dxyz(iCoord)>0
                iNoModif = [iNoModif,find(vertx > xyz(iCoord) )];
            else
                iNoModif = [iNoModif,find(vertx < xyz(iCoord) )];                
            end
        end
        
    end
              
    if isempty(iNoModif)
        set(h,'alphadatamapping','scaled',...
            'FaceVertexAlphaData',alpha*ones(size(vertices,1),1),....
            'FaceAlpha',alpha,...
            'backfacelighting','lit')
    else
        
        FaceVertexAlphaData(unique(iNoModif)) = alpha;
        FaceVertexAlphaData(setdiff(1:end,iNoModif)) = 0;
        set(h,'alphadatamapping','none',...
            'FaceVertexAlphaData',FaceVertexAlphaData,...
            'FaceAlpha','interp',...
            'backfacelighting','unlit')
    end
    
    
end
