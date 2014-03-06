function [] = event2mrkfile(mrkfile,event,srate,pnts)
%EVENT2MRKFILE - Writes EEGLAB events to .MRK marker (Cartool)
%   [] = event2mrkfile(event,srate)
%
%   Example
%       >> event2mrkfile
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
% KND  2007-04-04 Creation
%                   
% ----------------------------- Script History ---------------------------------

fid=fopen(mrkfile, 'wt');
fprintf(fid,'TL02\n')
for i=1:length(event)
    fprintf(fid,'\t%d\t\t', round(event(i).latency));
    fprintf(fid,'%d\t\t', round(event(i).latency+event(i).duration));
    fprintf(fid,'"%02d"\n', event(i).type);
end
fclose(fid)