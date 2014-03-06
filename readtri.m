function [vertices, faces, normals]=readtri(filetri)
  % Reads a TRI file
  %   [vertices, faces, normals]=readtri(filetri)
  fid = fopen(filetri,'r');
  if fid < 0, error(['Cannot open file ', TRIFILES{k}]), return, end
  nverts = abs(str2num(fgetl(fid))); % Number of Vertices
  vertices = fscanf(fid,'%f',[6 nverts])';
  if size(vertices, 2) > 3
    normals = vertices(:,4:6);
  end
  vertices = vertices(:,1:3);

  fgetl(fid);  
  nfaces = str2num(fgetl(fid)); % Number of faces
  nfaces = abs(nfaces(1));
  faces = fscanf(fid,'%f',[3 nfaces])'+1;