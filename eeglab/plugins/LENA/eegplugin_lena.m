function eegplugin_lena( fig, try_strings, catch_strings);
% Plugs in the LENA format importation 
% K. N'Diaye, 2009/04/05
if ~exist('pop_readlena', 'file') 
    addpath(fileparts(mfilename('fullpath')));
end
if ~exist('fastReadLENAHeadBin', 'file') 
    addpath(fullfile(fileparts(mfilename('fullpath')),'ReadWriteLena'))
	addpath(fullfile(fileparts(mfilename('fullpath')),'ReadWriteLena', 'Input'))
	addpath(fullfile(fileparts(mfilename('fullpath')),'ReadWriteLena', 'Output'))
	addpath(fullfile(fileparts(mfilename('fullpath')),'ReadWriteLena', '@xmltree'))
end;

% e_try = 'try, if exist(''h'') == 1, clear h; disp(''EEGLAB note: variable h cleared''); end;';
% e_catch = 'catch, errordlg2(lasterr, ''EEGLAB error''); LASTCOM= ''''; clear EEGTMP; end;';
% nocheck           = e_try;
% e_catch = 'catch, errordlg2(lasterr, ''EEGLAB error''); LASTCOM= ''''; clear EEGTMP; end;';
% storenewcall = '[ALLEEG EEG CURRENTSET LASTCOM] = pop_newset(ALLEEG, EEG, CURRENTSET); h(LASTCOM);';
% e_newnonempty   = [e_catch 'eeg_h(EEG,LASTCOM); ...
%     if ~isempty(LASTCOM) & ~isempty(EEGTMP), ...
%         EEG = EEGTMP;' storenewcall 'disp(''Done.''); ...
%     end;  clear EEGTMP; eeglab(''redraw'');'];

nocheck =[];
e_newnonempty = 'EEG = EEGTMP; eeglab(''redraw'');' ;   

filemenu = findobj(0, 'label', 'File');
if isempty(filemenu)
    error('No EEGLAB window found: try starting EEGLAB first');
end
neuromenu = findobj(filemenu, 'tag', 'import data');
uimenu(neuromenu, 'Tag', 'lenaCmd', 'Label', 'From LENA format', 'CallBack', ...
    [ nocheck '[EEGTMP LASTCOM]= pop_readlena;' e_newnonempty ],  'Separator', 'on'); 
