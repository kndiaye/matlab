function  h = nappe(data)
%NAPPE - One line description goes here.
%   [] = nappe(input)
%
%   Example
%       >> nappe
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
% KND  2011-05-23 Creation
%                   
% ----------------------------- Script History ---------------------------------
s=size(data);
if sum(s>1)==2
    data=squeeze(data);
end
    h = pcolor(data);
set(h, 'EdgeColor', 'none');

% time,1:12,nd2array(normalize(mean(data(ok,:,:,:)),'baseline',4,128:256),4)')
