

error('read_events is deprecated, use: read_lena_events()')

% function [e,txt] = read_event(eventfile)
% if nargin < 1,help(mfilename);return;end;
% e = struct(...
%     'trial',[],...
%     'time', [],...
%     'name', [],...
%     'duration', [],...
%     'offset',   []);
% fprintf('Reading File: %s\n', eventfile)
% txt=textread(eventfile,'%s','delimiter','\n','whitespace','');
% NL = length(txt);
% i=1;
% % TRIAL	TIME	NAME	DURATION	OFFSET
% while(i<=NL && (txt{i}(1) == '#'))
%     i=i+1;
% end
% n=0;
% while i<=NL
%     n=n+1;
%     try
%         [e(n).trial,e(n).time,e(n).name,e(n).duration,e(n).offset]=strread(txt{i}, '%d%f%s%f%f');
%     catch
%         [e(n).trial,e(n).time,e(n).name]=strread(txt{i}, '%d%f%s');
%     end
%     e(n).trial=e(n).trial+1;
%     e(n).name = e(n).name{1};
%     i=i+1;
% end
