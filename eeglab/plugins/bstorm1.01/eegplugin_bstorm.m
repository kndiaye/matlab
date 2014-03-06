% eegplugin_bstorm() - EEGLAB plugin for importing data from BrainStorm toolbox
%
% Usage:
%   >> eegplugin_bstorm(fig, try_strings, catch_strings);
%
% Inputs:
%   fig            - [integer] EEGLAB figure
%   try_strings    - [struct] "try" strings for menu callbacks.
%   catch_strings  - [struct] "catch" strings for menu callbacks. 
%
% Create a plugin:
%   For more information on how to create an EEGLAB plugin see the
%   help message of eegplugin_besa() or visit http://www.sccn.ucsd.edu/eeglab/contrib.html
%
% Author: Karim N'Diaye, CNRS-UPR640, 01 Feb 2005
%
% See also: eeglab(), readbstorm()

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) 2003 Arnaud Delorme, Salk Institute, arno@salk.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function eegplugin_bstorm( fig, try_strings, catch_strings);

if nargin < 3
    error('eegplugin_bstorm requires 3 arguments');
end;

% add bstrom folder to path
% -------------------------
if ~exist('pop_bstorm')
    p = which('eegplugin_bstorm');
    p = p(1:findstr(p,'eegplugin_bstorm.m')-1);
    addpath([ p ] );
end;

% find import data menu
% ---------------------
filemenu = findobj(fig, 'label', 'File');
neuromenu = findobj(filemenu, 'tag', 'import data');

% e_try = 'try, if exist(''h'') == 1, clear h; disp(''EEGLAB note: variable h cleared''); end;';
% e_catch = 'catch, errordlg2(lasterr, ''EEGLAB error''); LASTCOM= ''''; clear EEGTMP; end;';
% nocheck           = e_try;
% e_catch = 'catch, errordlg2(lasterr, ''EEGLAB error''); LASTCOM= ''''; clear EEGTMP; end;';
% storenewcall = '[ALLEEG EEG CURRENTSET LASTCOM] = pop_newset(ALLEEG, EEG, CURRENTSET); h(LASTCOM);';
% e_newnonempty   = [e_catch 'h(LASTCOM, EEG); if ~isempty(LASTCOM) & ~isempty(EEGTMP), EEG = EEGTMP;' storenewcall 'disp(''Done.''); end;  clear EEGTMP; eeglab(''redraw'');'];
% uimenu(neuromenu, 'Tag', 'bstormCmd', 'Label', 'From BrainStorm DS folder', 'CallBack', [ nocheck '[EEGTMP LASTCOM]= pop_readbstorm;' e_newnonempty ],  'Separator', 'on'); 

% menu callbacks
% --------------
combio = [ try_strings.no_check '[EEG LASTCOM] = pop_readbstorm;' catch_strings.new_and_hist ]; 
uimenu(neuromenu, 'Tag', 'bstormCmd', 'Label', 'From BrainStorm DS folder', 'CallBack', combio,  'Separator', 'on'); 

return