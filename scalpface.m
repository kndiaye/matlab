function [face_t]=scalpface(scalp)
% Convert scalp (a patch structure) to head.mat to be used in EEGLAB
% cf. headplot() 

if 0 %s4head
    %Vertices in the face
    face_v=find(scalp.vertices(:,3)<-.01 & scalp.vertices(:,1)>.025 );
    % remove also the basal part
    x1=-0.0960;   
    y1=0.0533;
    x2=0.0264;
    y2=-0.0308;
    face_v=[face_v ; find(scalp.vertices(:,3) <= (y2-y1)/(x2-x1)*(scalp.vertices(:,1)-x1)+y1)];
    % Which triangles encompass these vertices
    face_t=[];
    for v=face_v'
        face_t=[face_t; find(scalp.faces(:,1)==v | scalp.faces(:,2)==v |scalp.faces(:,3)==v  )];
    end
    face_t=unique(scalp.faces(face_t,:), 'rows');
    %[ign,face_t]=intersect(scalp.faces(:),face_v);
    %[face_t, ign]=ind2sub([length(scalp.faces), 3] , face_t);
    %face_t=scalp.faces(face_t,:);
    scalp_t=setdiff(scalp.faces, face_t, 'rows');
end

% -------------------------
%     Head1 or nicehead
% -------------------------
 nv=size(scalp.vertices,1);
% Distance au centre 1
d1=sqrt(sum((scalp.vertices(:,[1 3])-repmat([70  230],nv,1)).^2, 2));
% Distance au centre 2
d2=sqrt(sum((scalp.vertices(:,[1 3])-repmat([105 -75],nv,1)).^2, 2));
scalp_v=find((d1 < 265 & d2 > 95 & scalp.vertices(:,[3])> -30));

% nicehead:
% scalp_v=find((d1 < 255 & d2 > 95 & scalp.vertices(:,[3])> -30) | (scalp.vertices(:,[3]) > -30 & scalp.vertices(:,[2]) < -69));

scalp_t=find(ismember(scalp.faces(:,1), scalp_v) | ismember(scalp.faces(:,2), scalp_v) | ismember(scalp.faces(:,3), scalp_v));
scalp_t=scalp.faces(scalp_t,:);

% For NiceHead, add the following line:
% scalp_t=scalp_t([1:629 632:end],:);

face_t=setdiff(scalp.faces, scalp_t, 'rows');


POS=scalp.vertices;
TRI1=scalp_t;
index1=unique(scalp_t(:));
TRI2=face_t;
HeadCenter=[0 0 0];
save head1.mat POS TRI1 TRI2 HeadCenter index1

return
% in mhead.mat 
% POS       2678x3                    64272  double array   : vertices
% TRI1      2697x3                    64728  double array   : scalp
% TRI2      2305x3                    55320  double array   : face
% center       1x3                       24  double array   : center shouldn't it be HeadCenter ?
% index1    1612x1                    12896  double array   : vertices of the scalp


