function logtxt = spm_config_realign_log(prog,val,options)
% spm_config_realign(prog,val) - Generates log for spm_realign
%   [logtxt] = spm_config_realign(prog,val)
%    logtxt is a cell array of string
%   Example
%       >> spm_log2html
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
% KND  2008-10-17 Creation
%
% ----------------------------- Script History ---------------------------------

% TODO :
%   [logtxt] = spm_config_realign(job)
%   [logtxt] = spm_config_realign(jobs)

prog_infos=functions(prog)
jobname=sprintf('%s/', prog_infos.parentage{end:-1:1});
jobname(end)=[];
logtxt={};
logtxt{end+1}=['SPM logging for: ' jobname];
htmlfile = fullfile(fileparts(getfield(spm_vol(val.data{1}{1}),'fname')),'log',['log_' datestr(now,30)],[jobname '.html']);
logtxt{end+1}=['Into: '];
logtxt{end+1}={'file' htmlfile};
htmldir = fileparts(htmlfile);
if not(exist(htmldir, 'dir'))
    logtxt{end+1}=['Creating new directory: ' ];
    logtxt{end+1}={'folder', htmldir};
    mkdir(htmldir)
end
try
    switch jobname
    case 'spm_config_realign/estimate'
        mfile = which('spm_realign');
        if ~isequal(textread(mfile,'%s',4,'headerlines',82,'delimiter',' '),...
                {'%', '$Id:', 'spm_realign.m', '433'}') % The native version at the time
            logtxt{end+1}=sprintf('The spm_realign.m (%s) has changed! Default flags may also have changed.', mfile);
            warning(logtxt(1));
        end
        disp('REALIGNING IS COOL!')
        def_flags = struct('quality',1,'fwhm',5,'sep',4,'interp',2,'wrap',[0 0 0],'rtm',0,'PW','','graphics',1,'lkp',1:6);
        flags =mergestructs(def_flags,val.eoptions);
        if flags.graphics
            opts = {fullfile(htmldir,'realign_estimate.png'),'-noui','-painters','-dpng'};
            fg = spm_figure('FindWin','Graphics');
            logtxt{end+1} = {'Plot of the Movement Parameters'};
            print(fg,opts{:});
            logtxt{end+1} = {'picture',opts{1}};
            
        else
            logtxt{end+1}='Graphics must be generated for logging. Sorry...';

            % rp_file = [spm_str_manip(prepend(getfield(spm_vol(val.data{1}{1}),'fname'),'rp_'),'s') '.txt'];
            % P=textread(rp_file);
            % plot_parameters(P)
        end
    case 'spm_config_realign/reslice';
        % to do
    case 'spm_config_realign/estwrite_fun';
        % to do
    otherwise
        logtxt{end+1}=['Unknown function to log: ' jobname];
end
catch
    logtxt{end+1}=['Error while logging! ' lasterr];
end
spm_log2html(htmlfile,logtxt)
return


% spm_realign
%_______________________________________________________________________
function PO = prepend(PI,pre)
[pth,nm,xt,vr] = fileparts(deblank(PI));
PO             = fullfile(pth,[pre nm xt vr]);
return;


%_______________________________________________________________________
function plot_parameters(P)
fg=spm_figure('FindWin','Graphics');
if ~isempty(fg),
    P = cat(1,P{:});
    if length(P)<2, return; end;
    Params = zeros(numel(P),12);
    for i=1:numel(P),
        Params(i,:) = spm_imatrix(P(i).mat/P(1).mat);
    end

    % display results
    % translation and rotation over time series
    %-------------------------------------------------------------------
    spm_figure('Clear','Graphics');
    ax=axes('Position',[0.1 0.65 0.8 0.2],'Parent',fg,'Visible','off');
    set(get(ax,'Title'),'String','Image realignment','FontSize',16,'FontWeight','Bold','Visible','on');
    x     =  0.1;
    y     =  0.9;
    for i = 1:min([numel(P) 12])
        text(x,y,[sprintf('%-4.0f',i) P(i).fname],'FontSize',10,'Interpreter','none','Parent',ax);
        y = y - 0.08;
    end
    if numel(P) > 12
        text(x,y,'................ etc','FontSize',10,'Parent',ax); end

    ax=axes('Position',[0.1 0.35 0.8 0.2],'Parent',fg,'XGrid','on','YGrid','on');
    plot(Params(:,1:3),'Parent',ax)
    s = ['x translation';'y translation';'z translation'];
    %text([2 2 2], Params(2, 1:3), s, 'Fontsize',10,'Parent',ax)
    legend(ax, s, 0)
    set(get(ax,'Title'),'String','translation','FontSize',16,'FontWeight','Bold');
    set(get(ax,'Xlabel'),'String','image');
    set(get(ax,'Ylabel'),'String','mm');


    ax=axes('Position',[0.1 0.05 0.8 0.2],'Parent',fg,'XGrid','on','YGrid','on');
    plot(Params(:,4:6)*180/pi,'Parent',ax)
    s = ['pitch';'roll ';'yaw  '];
    %text([2 2 2], Params(2, 4:6)*180/pi, s, 'Fontsize',10,'Parent',ax)
    legend(ax, s, 0)
    set(get(ax,'Title'),'String','rotation','FontSize',16,'FontWeight','Bold');
    set(get(ax,'Xlabel'),'String','image');
    set(get(ax,'Ylabel'),'String','degrees');

    % print realigment parameters
    spm_print
end
%_______________________________________________________________________




%------------------------------------------------------------------------
function estimate(varargin)
job           = varargin{1};
P             = {};
for i=1:length(job.data),
    P{i}  = strvcat(job.data{i});
end;
flags.quality = job.eoptions.quality;
flags.fwhm    = job.eoptions.fwhm;
flags.sep     = job.eoptions.sep;
flags.rtm     = job.eoptions.rtm;
flags.PW      = strvcat(job.eoptions.weight);
flags.interp  = job.eoptions.interp;
flags.wrap    = job.eoptions.wrap;
spm_realign(P,flags);
return;
%------------------------------------------------------------------------

%------------------------------------------------------------------------
function reslice(varargin)
job          = varargin{1};
P            = strvcat(job.data);
flags.mask   = job.roptions.mask;
flags.mean   = job.roptions.which(2);
flags.interp = job.roptions.interp;
flags.which  = job.roptions.which(1);
flags.wrap   = job.roptions.wrap;
spm_reslice(P,flags);
return;
%------------------------------------------------------------------------

%------------------------------------------------------------------------
function estwrite_fun(varargin)
job           = varargin{1};
P             = {};
for i=1:length(job.data),
    P{i} = strvcat(job.data{i});
end;
flags.quality = job.eoptions.quality;
flags.fwhm    = job.eoptions.fwhm;
flags.sep     = job.eoptions.sep;
flags.rtm     = job.eoptions.rtm;
flags.PW      = strvcat(job.eoptions.weight);
flags.interp  = job.eoptions.interp;
flags.wrap    = job.eoptions.wrap;
spm_realign(P,flags);

P            = strvcat(P);
flags.mask   = job.roptions.mask;
flags.mean   = job.roptions.which(2);
flags.interp = job.roptions.interp;
flags.which  = job.roptions.which(1);
flags.wrap   = job.roptions.wrap;
spm_reslice(P,flags);
return;

%------------------------------------------------------------------------

%------------------------------------------------------------------------
function vf = vfiles_reslice(job)
P = job.data;
if numel(P)>0 && iscell(P{1}),
    P = cat(1,P{:});
end;

switch job.roptions.which(1),
    case 0,
        vf = {};
    case 1,
        vf = cell(numel(P)-1,1);
        for i=1:length(vf),
            [pth,nam,ext,num] = spm_fileparts(P{i+1});
            vf{i} = fullfile(pth,['r', nam, ext, num]);
        end;
    otherwise,
        vf = cell(numel(P),1);
        for i=1:length(vf),
            [pth,nam,ext,num] = spm_fileparts(P{i});
            vf{i} = fullfile(pth,['r', nam, ext, num]);
        end;
end;
if job.roptions.which(2),
    [pth,nam,ext,num] = spm_fileparts(P{1});
    vf = {vf{:}, fullfile(pth,['mean', nam, ext, num])};
end;
