function  varargout = spm_check_realign(SPM)
%SPM_CHECK_REALIGN - One line description goes here.
%   [] = spm_check_realign(SPM)
%
%   Example
%       >> spm_check_realign
%
%   See also:

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2008
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2008-10-13 Creation
%
% ----------------------------- Script History ---------------------------------

if nargin<1
    SPM=uigetpathfile('rp*.txt');
end
if ischar(SPM)
    if exist(SPM,'file')
        SPM=load(SPM);
    elseif exist(SPM,'dir')
        SPM=load(fullfile(SPM, 'SPM.mat'));
    else
        error('Unknown file/directory: %s', SPM);
    end
end
if isstruct(SPM)
    if isfield(SPM,'SPM')
        SPM=SPM.SPM;
    end
    lcd=pwd;
    try;cd(SPM.swd);end
    [p,f,e]=fileparts(SPM.xY.VY(1).fname);
    try
        P=load(fullfile(p, 'rp_f_0001.txt'));
    catch
        try
            P=load(fullfile(fileparts(p), 'rp_f_0001.txt'));
        catch
            error('Can''t find rp_*.txt');
        end
    end
elseif size(SPM,2)==6
    P=SPM;
else
    error('Wrong type of data')
end
[ax]=plot_parameters2(P);
if nargout>0
    varargout={P,ax};
end

% Adapted from spm_realign.m/plot_parameters (SPM2) 
%_______________________________________________________________________
function ax=plot_parameters2(Params)
if iscell(Params)
    Params = cat(1,Params{:});
end
if length(Params)<2, return; end;

% 
% 	for i=1:numel(P),
% 		Params(i,:) = spm_imatrix(P(i).mat/P(1).mat);
% 	end

% display results
% translation and rotation over time series
%-------------------------------------------------------------------
% spm_figure('Clear','Graphics');
fg=gcf;
set(fg,'Name','Image realignment');
%ax=axes('Position',[0.1 0.65 0.8 0.2])%,'Parent',fg,'Visible','off');
% set(get(ax,'Title'),'String','Image realignment (check)','FontSize',16,'FontWeight','Bold','Visible','on');
%x     =  0.1;
%y     =  0.9;
% for i = 1:min([numel(P) 12])
%     text(x,y,[sprintf('%-4.0f',i) ],'FontSize',10,'Interpreter','none','Parent',ax);
%     y = y - 0.08;
% end
% if numel(P) > 12
%     text(x,y,'................ etc','FontSize',10,'Parent',ax); end

ax(1)=subplot(2,1,1,'Parent',fg,'XGrid','on','YGrid','on');
hp=plot(Params(:,1:3),'Parent',ax(1));
s = {'x translation' 'y translation' 'z translation'};
%text([2 2 2], Params(2, 1:3), s, 'Fontsize',10,'Parent',ax)
set(get(ax(1),'Title'),'String','translation','FontSize',16,'FontWeight','Bold');
%set(get(ax,'Xlabel'),'String','image');
set(get(ax(1),'Ylabel'),'String','mm');
legend(hp, s, 0)

%ax=axes('Position',[0.1 0.05 0.8 0.2],'Parent',fg,'XGrid','on','YGrid','on');
ax(2)=subplot(2,1,2,'Parent',fg,'XGrid','on','YGrid','on');
hp=plot(Params(:,4:6)*180/pi,'Parent',ax(2));
s = {'pitch';'roll ';'yaw  '};
%text([2 2 2], Params(2, 4:6)*180/pi, s, 'Fontsize',10,'Parent',ax)
set(get(ax(2),'Title'),'String','rotation','FontSize',16,'FontWeight','Bold');
set(get(ax(2),'Xlabel'),'String','image');
set(get(ax(2),'Ylabel'),'String','degrees');
legend(hp, s, 0)
return;
%_______________________________________________________________________
