function [fclusters]=clusters2faces(vclusters, faces,verbose)
% clusters2faces - find faces encompassed in each cluster
%
% [fclusters]=clusters2faces(vclusters, faces,verbose)
% Retrieve faces fully included in each cluster

% KND : 2005-07-01 : Initial release. Some vectorization should be possible
if nargin<3
    verbose=0;
end

nclu=length(vclusters);
if verbose
    h=waitbar(0,'Clusters of faces ');
end
for i=1:nclu
    fclusters{i}=[];
    for j=1:size(faces,1)
        if length(intersect(faces(j,:),vclusters{i}))==3
            fclusters{i}=[fclusters{i} j];
        end        
    end 
    if verbose
        waitbar(i/nclu,h);    
    end
end
if verbose
    close(h)
end