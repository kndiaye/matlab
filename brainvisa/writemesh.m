function [] = writemesh(filemesh, vertices, faces, normals, indirect_referential)
% creation de fichier .mesh
% writemesh(filemesh, vertices, faces, normals)
  
  
  % Check faces
  nv = size(vertices,1);
  if size(vertices,2)  ~= 3
      error('Vertices should be a N-by-3 matrix')
  end
  nt = size(vertices,3); %Time steps

  % Check faces
  nf = size(faces,1);
  if size(faces,2)  ~= 3
      error('Faces should be a N-by-3 matrix')
  end
  if  max(faces(:))>(nv-1)      
    error(['In AIMS mesh format, vertices indices start at 0 in' ...
	     ' the ''Faces'' array'])
  end
  if (min(faces(:)) == 1 && max(faces(:)) == nv)
    warning(['In AIMS mesh format, vertices indices start at 0 in' ...
	     ' the ''Faces'' array'])    
  end

  if nargin < 4
    nn=0;
    %    normals=normalsvertices(vertices, faces);
    %    nn=size(normals, 1);
  else
    nn=size(normals, 1);
  end
  
  % By default, we are working in the AIMS referential, which is indirect.
  if nargin<5
      indirect_referential = 1;
  end

  if indirect_referential
      faces=fliplr(faces);
  end
  
  [ext,ext]=fileparts(filemesh);
  
  fid = fopen(filemesh ,'w') ;

  fprintf(fid, 'ascii\n');
  fprintf(fid, 'VOID\n');
  fprintf(fid, '%d\n',size(vertices,2));
  fprintf(fid, '%d\n',nt);
  
  for t=1:nt
    % Instant in time (an integer !)
    fprintf(fid, '%d\n',t-1);  
    
    % VERTICES
    fprintf(fid, '%d\n',nv);
    for i = 1:nv
      fprintf(fid, '(%1.4g,%1.4g,%1.4g)\n',vertices(i,1:3,t));
    end
    
    % NORMALS
    fprintf(fid, '%d\n',nn);
    for i = 1:nn
      fprintf(fid, '(%1.4g,%1.4g,%1.4g)\n',normals(i,1:3,t));
    end
    
    % The following line HAS TO be here !!!
    % There is no texture
    fprintf(fid, '0\n\n');
    
    % FACES
    fprintf(fid, '%d\n',nf);
    for i = 1:nf
      fprintf(fid, '(%d,%d,%d)\n',faces(i,1:3,t));
    end
  end
  fclose(fid);
  
