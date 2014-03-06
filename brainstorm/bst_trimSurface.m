function []=bst_trimSurface(h,xyz)
if (nargin<2)
    xyz=h;
    h=findTessellationHandles
end
    
iSurf=1;
TessInfo(iSurf)=get(h);
TessInfo(iSurf).trimXYZ=[xyz(1) xyz(2) xyz(3)];
TessInfo(iSurf).alpha=.5;
vertices = get(h,'vertices');
FaceVertexAlphaData =  get(h,'FaceVertexAlphaData');

if isempty(FaceVertexAlphaData)
    FaceVertexAlphaData = TessInfo(iSurf).alpha*ones(size(vertices,1),1);    
end


iNoModif = [];
for iCoord = 1:3
    vertx = vertices(:,iCoord)'; 
    vertx = vertx-mean(vertx);
    vertx = vertx/max(abs(vertx));
    if TessInfo(iSurf).trimXYZ(iCoord) > 0
        iNoModif = [iNoModif,find(vertx < TessInfo(iSurf).trimXYZ(iCoord))];
    elseif TessInfo(iSurf).trimXYZ(iCoord) < 0
        iNoModif = [iNoModif,find(vertx > TessInfo(iSurf).trimXYZ(iCoord))];
    else
        %doNothing
    end
    
end

if isempty(iNoModif)
    set(h,'alphadatamapping','scaled','FaceVertexAlphaData',TessInfo(iSurf).alpha*ones(size(vertices,1),1),'FaceAlpha',TessInfo(iSurf).alpha,...
        'backfacelighting','lit')
else
    FaceVertexAlphaData(unique(iNoModif)) = TessInfo(iSurf).alpha;
    FaceVertexAlphaData(setdiff(1:end,iNoModif)) = 0;
    set(h,'alphadatamapping','none','FaceVertexAlphaData',FaceVertexAlphaData,'FaceAlpha','interp','backfacelighting','unlit')
end