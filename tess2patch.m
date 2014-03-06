function [fv]=tess2patch(tess)
% tess2patch - convert Brainstorm tessellation to FV structure
% [fv]=tess2patch(tess)
% [fv]=tess2patch('xxx_tess.mat')
% NB: On FV structures, see REDUCEPATCH
if nargin<1
  [f,p]=uigetfile;
  if isempty(f)
    return
  end
  tess=fullfile(p,f)
end

if ischar(tess)
  if exist(tess, 'file') | exist([tess '.mat'], 'file')
    tess=load(tess, 'Faces', 'Vertices');
  end
end

for i=1:length(tess.Faces)
  fv(i).faces=tess.Faces{i};
  fv(i).vertices=tess.Vertices{i}';  
end
