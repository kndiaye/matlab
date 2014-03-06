function []=matlabupdate(mpath)
% matlabupdate() - Add matlab functions in the path to attempt forward compatibility
%
%   matlabupdate(mpath) add the subdirectories found in the specified path
%       If a directory matches a date pattern (e.g., 2007-12-31), then it
%       is included only if the running version of matlab is older.
%       All other subdirectories will be unconditionally added
%
%   default: mpath = folder of 'matlabupdate.m'/matlabupdate', 
%              e.g., g:\ndiayek\matlab\matlabupdate
%
if nargin<1
    mpath=mfilename('fullpath');
end
dat=0;
try
    dat=datenum(version('-date'));
end
f=dir(mpath);
f([f.isdir]==0)=[];
f(strmatch('.', {f.name}, 'exact'))=[];
f(strmatch('..', {f.name}, 'exact'))=[];
f(strmatch('.svn', {f.name}, 'exact'))=[];

for dats={f.name}
    t=1; %unconditionnlly add "non-calendar" directories
    try
        t = datenum(dats{1},'yyyy-mm-dd') >= dat;
    end
    if t
        fprintf('Adding to the path: %s\n', fullfile(mpath, dats{1}))
        addpath(fullfile(mpath, dats{1}))
    end
end

