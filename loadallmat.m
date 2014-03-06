function [varargout]=loadallmat(directory)
%loadallmat - load all MAT files from a directory
% 
if nargin<1
  directory=pwd;
end

f=dir(fullfile(directory,'*.mat'));
for i=1:length(f)
  [ignore,vname]=fileparts(f(i).name);
  disp(sprintf('Loading %s...', vname));
  eval(sprintf('vars.%s=load(''%s'');',vname,fullfile(directory,f(i).name)));
end
if nargout==1    
    varargout={vars};    
else
  vnames=fieldnames(vars);
  
  for i=1:length(vnames)
    assignin('base', vnames{i}, getfield(vars, vnames{i}));
  end
end
