function [vertex,faces,normals,vertex_number,faces_number]= readmeshes(meshfiles)
% readmeshes - read many meshes and concatenate them in a single mesh

vertex=[];
faces=[];
normals=[];
vertex_number=0;
faces_number=0;

for i=1:length(meshfiles)
  [v,f,n,vn,fn]=readmesh(meshfiles{i});  
  vertex=[vertex; v];
  faces=[faces; f+vertex_number];
  normals=[normals; n];
  vertex_number=vertex_number+vn;
  faces_number=faces_number+fn;
end
  
