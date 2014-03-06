function []= savefields(matfile,X,overwrite,varargin)
% savefields - save the fields of a struct as separate variables in a MAT file
%
% savefields(matfile,X)
%
% X is a struct, e.g. with fields a,b,c
%  >> savefields('test.mat',X)
% Creates a .mat file with each field a, b or c saved as a separate
% variable (whereas the native SAVE() would save the whole struct):
%  >> X=load('test.mat', 'a')
% 
%   savefields(matfile,X,overwrite)
%   if overwrite=1: overwrite the whole file
%   if overwrite=0: append the data to file
%
%   savefields(matfile,X,overwrite,'field1','field2')
%       Save only those fields
%


if nargin<3
    overwrite=0;
end

if isstruct(matfile)
    tmp=matfile;
    matfile=X;
    X=tmp;
    clear tmp;
end
[p,f, e]=fileparts(matfile);
if isempty(e) || isequal('.', e)
    e='.mat';
end
matfile=fullfile(p, [f e]);
if ischar(X)
    X=evalin('caller',X);
end
if nargin>3
    fn=varargin;
else
    fn=fieldnames(X);
end
for i=1:length(fn);
    eval(sprintf('%s=X.%s;', fn{i}, fn{i}));
end
if ~exist(matfile, 'file') | isequal(overwrite,1) || isequal(overwrite, '-APPEND')
    save(matfile,fn{:})
elseif isequal(overwrite,0)
    save(matfile,  '-APPEND' ,fn{:})
else
    error('File (%s) exists but I don''t know what to do with it',matfile);    
end

