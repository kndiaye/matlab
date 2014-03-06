function [D]=subdir(DN)
% subdir() - Process DIR command across subdirectories
%   [output] = subdir(directory_name)
if nargin==0
    DN=pwd;
end
[p0,n,e]=fileparts(DN);
if isempty(p0)
    p0=pwd;
end
p=strread(genpath(p0), '%s', 'delimiter', ';');
D=[];
for i=1:length(p)
    f=dir(fullfile(p{i}, [n e]));
    for j=1:length(f);
       f(j).name=fullfile(p{i}, f(j).name);
   end
   D=[D; f];
end
if nargout==0
    if ~isempty(p0)
        cd(p0)
    end    
    D=strvcat({D.name});
end
            