function [fv2]=subpatch(fv,idx)
% subpatch - Sub part of a patch struct
% [fv2]=subpatch(fv,idx) where idx are the indices of the subpatch
fv2.vertices=fv.vertices(idx,:);
fv2.faces=[];
for i=1:size(fv.faces,1)
    if all(ismember(fv.faces(i,:), idx))
        fv2.faces=[fv2.faces; find(fv.faces(i,1)==idx) find(fv.faces(i,2)==idx) find(fv.faces(i,3)==idx) ];        
    end
end
