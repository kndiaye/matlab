function [normals, centroid]=normalsOutVertices(vertices, faces)
% [normals, centroid]=normalsOutVertices(vertices, faces)
% Normals going out of the patch, at each vertex
%  
  
  normals=normalsvertices(vertices, faces);
   

% is the orientation of the triangle in or out?
inout = sign(sum(vertices .* normals ,2));
%  Make the normals out going
normals=normals.*repmat(inout,1,3);
return

%v=vertices(faces,:);
%v=reshape(v, [size(faces, 1) 3 3]);
%v1=squeeze(v(:,1,:));
%v2=squeeze(v(:,2,:));
%v3=squeeze(v(:,3,:));

% Position of the barycentre of each triangle
% centroid = squeeze(mean(v,2));

% The normals to the surface of the triangle
% normals=cross(v2-v1, v3-v1,2);
%surfaces = rownorm(normals)/2; % area of each triangle


if 0
figure(1)
clf
plot3(vertices(faces(1,[1 2 3 1]),1),vertices(faces(1,[1 2 3 1]),2), vertices(faces(1,[1 2 3 1]),3))
hold on
v=[centroid(1,:) ; centroid(1,:)];
plot3(v(:,1), v(:,2), v(:,3), 'rx')
v=[centroid(1,:) ; centroid(1,:) + normals(1,:)];
plot3(v(:,1), v(:,2), v(:,3), 'g')
grid on
axis equal
end