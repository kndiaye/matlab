function [] = ctf2cartool(ctf)
%CTF2CARTOOL - Converts CTF M/EEG data to .ep text file and .xyz channel file
%   [] = ctf2cartool(input)
%
%   Example
%       >> ctf=ctf_read_meg4('folder.ds',[],'meg');
%       >> ctf2cartool(ctf)
%
%   See also:

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2007
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2007-01-30 Creation
%
% ----------------------------- Script History ---------------------------------

fid = fopen([ctf.folder(1:end-3) '.ep'],'wt');
for t=1:size(ctf.data,1);
    for i=1:size(ctf.data,2);
        fprintf(fid,'%g ',ctf.data(t,i));
    end
    fprintf(fid,'\n');
end
fclose(fid);

nsens=length(ctf.sensor.label);

fid = fopen([ctf.folder(1:end-3) '_channels.xyz'],'wt');
fprintf(fid,'%d 1', nsens);
for i=1:nsens
    fprintf(fid,'%g %g %g ',ctf.sensor.location(:,i));
    fprintf(fid,'%s\n',ctf.sensor.label{i});
end
fclose(fid);