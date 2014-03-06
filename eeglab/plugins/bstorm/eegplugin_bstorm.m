function eegplugin_bstorm( fig, try_strings, catch_strings);
% Plugs in the BStorm importation 
% K. N'Diaye, 2005/02/07
if ~exist('pop_readbstorm')
	try 
		p = which('eeglab');
		p=fileparts(p);
		p=fileparts(p);
		p=fileparts(p);
		p=fullfile(p, 'matlab', 'eeglab', 'plugins', 'bstorm')
		addpath(p)
	catch
	end
    p = which('eegplugin_bstorm');
    p = p(1:findstr(p,'eegplugin_bstorm.m')-1);
    addpath([ p 'bstorm' ] );
end;

e_try = 'try, if exist(''h'') == 1, clear h; disp(''EEGLAB note: variable h cleared''); end;';
e_catch = 'catch, errordlg2(lasterr, ''EEGLAB error''); LASTCOM= ''''; clear EEGTMP; end;';
nocheck           = e_try;
e_catch = 'catch, errordlg2(lasterr, ''EEGLAB error''); LASTCOM= ''''; clear EEGTMP; end;';
storenewcall = '[ALLEEG EEG CURRENTSET LASTCOM] = pop_newset(ALLEEG, EEG, CURRENTSET); h(LASTCOM);';
e_newnonempty   = [e_catch 'h(LASTCOM, EEG); if ~isempty(LASTCOM) & ~isempty(EEGTMP), EEG = EEGTMP;' storenewcall 'disp(''Done.''); end;  clear EEGTMP; eeglab(''redraw'');'];

filemenu = findobj(fig, 'label', 'File');
neuromenu = findobj(filemenu, 'tag', 'import data');
uimenu(neuromenu, 'Tag', 'bstormCmd', 'Label', 'From BrainStorm DS folder', 'CallBack', [ nocheck '[EEGTMP LASTCOM]= pop_readbstorm;' e_newnonempty ],  'Separator', 'on'); 
