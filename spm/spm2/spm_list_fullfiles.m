function [Files]= spm_list_fullfiles(Dirs,Filter)
% spm_list_fullfiles() - List full files (including path)
% FORMAT [Files] = spm_list_fullfiles(Dirs [,Filter])
% Dirs   - directories to list (possibly more than one).
%          Default: current directory ('.')
% Filter - e.g. '*.img' (default)
% Files  - full filenames including paths
% Dirs   - directories
%_______________________________________________________________________
%
% See also: spm_list_files.m
%_______________________________________________________________________
% @(#)spm_list_fullfiles.m	1.0 Karim N'Diaye 06/12/07
if nargin<2
    Filter='*.img';
    if nargin<1
        Dirs={cd};        
    end
end
if ischar(Dirs)
    Dirs=cellstr(Dirs);
end
Files=[];
for i=1:length(Dirs)
    d=cd;
    cd(Dirs{i})
    Dirs{i}=cd;
    cd(d);
    [f,d] = spm_list_files(Dirs{i},Filter);
    f=[repmat([Dirs{i}, filesep], size(f,1), 1) f];
    Files=[Files; f];
end

