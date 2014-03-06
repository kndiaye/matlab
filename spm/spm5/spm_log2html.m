function  htmlfile = spm_log2html(prog, val, options)
%SPM_LOG2HTML - Log report on SPM processing to HTML file
%   [] = spm_log2html(prog, val, options) print log to the html file named in output
%
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

% I guess there exists an xml -> html thingy I could use somewhere...

prog_infos=functions(prog)
% jobname=sprintf('%s:', prog_infos.parentage{end:-1:1});
% jobname(end)=[];
jobname=sprintf('%s', prog_infos.parentage{1});
logtxt={};
logtxt{end+1}=['SPM logging for: ' jobname];
htmlfile = fullfile(fileparts(getfield(spm_vol(val.data{1}{1}),'fname')),'log',[jobname '.html']);
logtxt{end+1}=['Into: '];
logtxt{end+1}={'file' htmlfile};
htmldir = fileparts(htmlfile);
% if exist(htmldir, 'dir')
%     if length(dir(htmldir)) > 2
%         htmldir_old=fullfile(fileparts(htmldir), ['log_' datestr(now,30)]);
%         movefile(htmldir,-)
%         logtxt{end+1}=['Renaming older directory: ' ];
%         logtxt{end+1}={'folder', htmldir_old};
%         mkdir(htmldir)
%     end
% end
if not(exist(htmldir, 'dir'))
    logtxt{end+1}=['Creating new directory: ' ];
    logtxt{end+1}={'folder', htmldir};
    mkdir(htmldir)
end

switch jobname
    case 'estimate'
        logtxt=log_realign(val,htmldir,logtxt);
    case 'reslice';
        % to do
    case 'estwrite_fun';
        % to do
    otherwise
        logtxt{end+1}=['Unknown function to log: ' jobname];
end
log2html(htmlfile,logtxt)
return

function [spname]=shortpathname(pname)
% shortens file names
spname=[pname(1:10) '...' pname(end-15:end)];

function [hpname]=htmlpathname(pname)
% Replace filesep in file path with slashes (/) for HTML compatibility
hpname = strrep(pname,filesep,'/');

function []=log2html(htmlfile, log)
% print out to html file
save(fullfile(fileparts(htmlfile),'spm_log2html.mat'),'log');
fid=fopen(htmlfile,'wt');
html_header(fid);
fprintf(fid,'<p>');
for i=1:length(log);
    if ischar(log{i})
        if i>1
            fprintf(fid, '</p>\n<p>');
        end
        fprintf(fid, '%s', log{i});
    else
        switch log{i}{1}
            case 'picture'
                fprintf(fid, '<a href="%s"><img src="%s" height="50%%"></a>',htmlpathname(log{i}{2}),htmlpathname(log{i}{2}),shortpathname(log{i}{2}));
            case {'folder' 'file'}
                fprintf(fid, '<a href="%s">%s</a>',htmlpathname(log{i}{2}),shortpathname(log{i}{2}));
        end
    end
end
fprintf(fid,'Done.</p>\n</body></html>\n');
if fid > 2
    fclose(fid);   
    try
        browser = '"C:\Documents and Settings\ndiayek\Local Settings\Application Data\Google\Chrome\Application\chrome.exe"'
        system([browser ' "' htmlfile '"']);
    catch
        browser = '"C:\program Files\Mozilla Firefox\firefox.exe" ';         
    end;
end
return

function [logtxt]=html_header(fid)
fprintf(fid,'<html>\n');
fprintf(fid,'<body>\n');
fprintf(fid,'<p>Processing steps: <ol>');
fprintf(fid,'<li><a href="realign.html">realign</a>');
fprintf(fid,'<li><a href="segment.html">segment</a>');
fprintf(fid,'<li><a href="normalize.html">normalize</a>');
fprintf(fid,'<li><a href="smooth.html">smooth</a>');
fprintf(fid,'<li><a href="design.html">design</a>');
fprintf(fid,'</ol></p>');



function [logtxt]=html_footer(htmlfile, logtxt)



function [logtxt] = log_design(val,htmldir,logtxt)
% Log of DESIGN results


function [logtxt] = log_realign(val,htmldir,logtxt)
% Log of REALIGN results
mfile = which('spm_realign');
if ~isequal(textread(mfile,'%s',4,'headerlines',82,'delimiter',' '),...
        {'%', '$Id:', 'spm_realign.m', '433'}') % The native version at the time
    logtxt{end+1}=sprintf('The spm_realign.m (%s) has changed! Default flags may also have changed.', mfile);
    warning(logtxt(1));
end
def_flags = struct('quality',1,'fwhm',5,'sep',4,'interp',2,'wrap',[0 0 0],'rtm',0,'PW','','graphics',1,'lkp',1:6);
flags =mergestructs(def_flags,val.eoptions);
if flags.graphics
    opts = {fullfile(htmldir,'realign_estimate.png'),'-noui','-painters','-dpng'};
    fg = spm_figure('FindWin','Graphics');
    logtxt{end+1} = {'Plot of the Movement Parameters'};
    % export figure in image file
    print(fg,opts{:});
    logtxt{end+1} = {'picture','realign_estimate.png'};
else
    logtxt{end+1}='Graphics must be generated for logging. Sorry...';
    % rp_file = [spm_str_manip(prepend(getfield(spm_vol(val.data{1}{1}),'fname'),'rp_'),'s') '.txt'];
    % P=textread(rp_file);
    % plot_parameters(P)
end
return


function [logtxt] = log_smooth(val,htmldir,logtxt)
% Log of SMOOTH results
mfile = which('spm_smooth');
logtxt(end+1)='todo';
return
