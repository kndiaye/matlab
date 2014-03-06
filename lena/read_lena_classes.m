function cls = read_lena_class(classfile)
%READ_LENA_CLASS - One line description goes here.
%   [cls] = read_lena_class(classfile)
%   [cls] = read_lena_class(lenafolder)
%
%   Example
%       >> read_lena_class
%
%   See also: 

% Author: K. N'Diaye (kndiaye01<at>gmail.com)
% Copyright (C) 2011 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2011-06-08 Creation
%                   
% ----------------------------- Script History ---------------------------------
cls=repmat(struct('name',[],'trials',[]),0);
if nargin < 1,help(mfilename);return;end;
if exist(classfile,'dir')
    classfile = fullfile(classfile,'data.class');
end
if ~exist(classfile,'file') 
    error('read_lena_class:BadLenaFolder','File not found: %s',classfile)
end
e = read_lena_events(classfile);
[names i,j] =unique({e.name});
n=numel(names);
cls=repmat(cls,1,n);
for i=1:n
    cls(i).name = names{i};
    cls(i).trials = [e(j==i).trial];
end
