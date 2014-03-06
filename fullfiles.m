function [f]=fullfiles(varargin)
%fullfiles - Build full filenames from parts (allow multiple path/basename/ext).
%   fullfiles(D1, D2, ... , FILES) with D1 being { D1a D1b ...} idem for D2 and FILES 
%   will (recursively) produce a cell array of full filenames 
%   { D1a/D2a/FILE1 ; D1a/D2a/FILE2 ; D1a/D2b/FILE1 ; D1a/D2b/FILE2 ; ... } 
%   
% See: fullfile()


% THE FOLLOWING OPTION DOES NOT WORK YET !

%   fullfiles(D1, D2, ... , FILES, [n1 n2]) will match the n1-th and n2-th
%   arguments on a 1-by-1 basis so that:
%       >> fullfiles({'a' 'b'}, 'c', {'e' 'f'}, [1 3])
%           'a/c/e'
%           'b/c/f'
%   instead of:
%           'a/c/e'
%           'a/c/f'
%           'b/c/e'
%           'b/c/f' 

if nargin<2
    f=varargin{1};
    if ischar(f)
        f={f};
    end
    return
end

d=varargin{1};
g=fullfiles(varargin{2:end});
f=[];
if ischar(d)
    d={d};
end    
for i=1:length(d)
    for j=1:length(g);
        f=[ f; {fullfile(d{i}, g{j})}]; 
    end
end