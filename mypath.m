function [HOMEDIR]=mypath()
% MYPATH - Retrieves home directory on the current OS
HOMEDIR='';
lcd=cd;
if ispc
    [s,m]=system('echo %USERPROFILE%\My Documents & cd "%USERPROFILE%\My Documents"');
    if s
        [s,m]=system('echo %USERPROFILE%\Mes Documents & cd "%USERPROFILE%\Mes Documents"');
    end
    if s
        [s,m]=system([ ...
            'echo "%TEMP%" & regedit /E "%TEMP%\homepath.txt" ' ...
            '"HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\" & '...
            'type "%TEMP%\homepath.txt"|find "Personal"']);
        if ~s
            m=m(findstr(lower(deblank(m)), '"personal"="') + 12:end-2);
            warning('MYPATH:HomepathFromRegistry','No "My Documents" in the user folder. Use Registry table value.');
        end
    else
        m=deblank(m);
    end
    if ~s
        lcd=cd;
        cd(m);
        m=cd;
    end
elseif isunix
    % [s,m]=system('cd ~');
    %     [p,n]=fileparts(cd);
    %     if isequal('matlab', lower(n))
    %         cd(p);
    %     end
    try
        s=0;
        cd('~');
        m=cd;
    catch
        s=1;
    end
end
cd(lcd);
if s
    error('Unable to find your home folder on this OS:\n%s',m);
else
    HOMEDIR=m;
end

return


% Set PATH variables: HOMEDIR & USBDIR
%   [HOMEDIR,USBDIR]=mypath()

HOMEDIR='';
LACIE='';
WENDY='';
MAMMAMIA='';
USBDIR=NaN;

if nargin>0
    if isunix
        testloc={'/mnt'}
    elseif ispc
        testloc=[ { 'F:' 'G:' 'H:'} cellstr([char(65:90)' repmat(':', 26,1)])' ];
    end
    switch upper(NAME)
        case 'WENDY'
            testname='wendy.txt';
        case 'LACIE'
            testname='lacie.txt';
    end
    for i=1:length(testloc)
        if  exist(fullfile(testloc{i}, testname), 'file')
            HOMEDIR=testloc{i};
            return
        end
    end
    return
end

if isunix
    if  exist('/home/ndiayek')
        HOMEDIR='/home/ndiayek';
    elseif exist('/pclxserver2/home/ndiaye')
        HOMEDIR='/pclxserver2/home/ndiaye';
    end

elseif ispc
    if exist('f:\matlab') && (exist('g:\lacie.txt') || exist('g:\wendy.txt'))
        % USB key is F:
        USBDIR='f:\';
    elseif exist('g:\matlab') && (exist('g:\lacie.txt') || exist('g:\wendy.txt') || exist('g:\mammamia.txt'))
        % USB key is G:
        USBDIR='g:\';
    elseif exist('h:\matlab') && (exist('h:\lacie.txt') || exist('h:\wendy.txt'))
        % USB key is H:
        USBDIR='h:\';
        %     elseif exist('d:\matlab') && (exist('g:\lacie.txt') || exist('g:\wendy.txt'))
        %         % USB key is D:
        %         USBDIR='d:\';
    end

    % if D: is a CD drive, hangs the execution !!!
    %     if exist('d:\ndiaye\')
    %         HOMEDIR='d:\ndiaye\';
    %     elseif exist('d:\ndiayek\')
    %         HOMEDIR='d:\ndiayek\';
    %     elseif exist('e:\ndiaye\')
    %         HOMEDIR='e:\ndiaye\';
    %     elseif exist('g:\ndiayek\')
    %         HOMEDIR='g:\ndiayek\';
    %     end
end

if nargout==0
    assignin('caller', 'HOMEDIR', HOMEDIR)
    assignin('caller', 'USBDIR', USBDIR)
end
