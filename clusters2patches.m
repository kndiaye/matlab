function [fv,vclusters]=clusters2patches(vclusters, faces, vertices,verbose)
% clusters2patches - computes patches of clusters
%
% [p,clusters]=clusters2patches(clusters, faces, vertices,verbose)
%
% INPUTS:
%   clusters: cell list of vertex indices
%   faces: from a FV structure, see PATCH
%   vertices: idem.
%   verbose: optional, default=1
%
% OUPUTS:
%   p: Nx1 array of FV structures
%   clusters: newly assignated vertices in each clusters.
%             Indeed, as some faces may lie on the border of two (or even
%             three) clusters, the new patches may overlap. Therefore some
%             faces and vertices are duplicated between patches and we keep
%             track of these "extended" clusters in this output

% KND : 2005-07-01 : Initial release. Some vectorization should be possible
if nargin<3
    verbose=0;
end

nclu=length(vclusters);
if verbose
    h=waitbar(0,'Clusters of patches');
end
for i=1:nclu
    fv(i).faces=[];    
    for j=1:size(faces,1)
        if length(intersect(faces(j,:),vclusters{i}))>1
            fv(i).faces=[fv(i).faces; 0 0 0];
            for k=1:3
                if ~ismember(faces(j,k),vclusters{i})
                    vclusters{i}=[vclusters{i} faces(j,k)];                                        
                end
                fv(i).faces(end,k)=find(faces(j,k)==vclusters{i});                
            end
        end
    end
    fv(i).vertices=vertices(vclusters{i},:);  
    if verbose
        waitbar(i/nclu,h);    
    end    
end

% Post process faces to remove duplicated faces
% f=unique(cat(1,fv(:).faces), 'rows');
% [f,f]=setdiff(cat(1,fv(:).faces),f, 'rows');

if verbose
    close(h)
end