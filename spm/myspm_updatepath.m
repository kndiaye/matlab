function Q = myspm_updatepath(P,varargin)
%MYSPM_UPDATEPATH - Update SPM path/working directory.
%   [Q] = myspm_updatepath(P)
%   [SPM] = myspm_updatepath(spmfilename)
%   [Q] = myspm_updatepath(P,nwd)
%   [SPM] = myspm_updatepath(spmfilename,nwd,save?)
%
%   Example
%       >> myspm_updatepath
%
%   See also: spm_vol

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2009
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2009-07-22 Creation
%
% ----------------------------- Script History ---------------------------------

spmfilename=[];
imgfilename=[];
persistent pwd
persistent nwd
Q=P;
if nargin>1
    nwd=varargin{2};
    if ~exist(nwd, 'dir')
        warning('myspm_updatepath:NotADirectory','Updated directory doesn''t exist: %s',nwd);
    end
end
if nargin<3
    dosave=NaN;
else
    dosave=varargin{3};
end

if iscell(P)
    Q=cell(size(P));
    for i=1:numel(P)
        Q{i}=myspm_updatepath(P{i},varargin{:});
        return
    end
end
   
if isstruct(P)
    SPM=P;
    clear P;
    swd = SPM.swd;
elseif ischar(P)
    try
        % test if it's an SPM file
        clear SPM
        load(P)
        swd = SPM.swd;
        spmfilename = P;
        clear P;
    catch ME
        [swd,imgfilename,imgfileext] = fileparts(P);
    end
else
    error('Wrong input P must be an image/SPM filename or a SPM struct.')
end 
if isempty(pwd) || ~strmatch(pwd,swd,'exact')
    if ~isempty(spmfilename)
    pwd=fileparts(spmfilename);
    end
    nwd=uigetdir(pwd,sprintf('Pick a new SPM folder instead of:\n%s',swd));
   if isequal(nwd,0)
        return
    end
end
fprintf(1,'Updating former path: %s\ninto: %s\n', pwd,nwd);
pwd=swd;
if exist('SPM', 'var')
    SPM.swd=nwd;
    if dosave && ~isempty(spmfilename)
        save(spmfilename, '-APPEND', 'SPM');
    end
    Q=SPM;
end
if ~isempty(imgfilename)
    Q=fullfile(nwd,[imgfilename,imgfileext]);
end
return
