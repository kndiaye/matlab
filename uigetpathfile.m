function [ff]=uigetpathfile(varargin)
[f,p]=uigetfile(varargin{:});
if isequal(f,0) | isequal(p,0)
    ff=0;
    return
end
ff=fullfile(p,f);
if length(dbstack)==1 % (evalin('caller','mfilename'))
    disp(ff)
end