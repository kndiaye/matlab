function [normals]=normalsvertices(vertices, faces)
% Normals at the vertices od the (triangular) faces defined by vertices and faces

h=patch('vertices',vertices, 'faces', faces);
normals=get(h, 'VertexNormals');
delete(h);
%normals=normals./repmat(rownorm(normals),1,3);
%inout=-sign(sum(vertices .* normals ,2));
%normals=repmat(inout, 1,3).*normals;
return

