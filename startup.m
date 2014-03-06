DoMatlabUpdate = false;
disp('Hi Karim,')
[hostname,hostname]=system('hostname');
switch upper(deblank(hostname))
    case 'D5BDS81J'
        disp('Welcome on FREDERIC''s PC!')
    case 'IMAGERIE2-PV'
        disp('Welcome on STEPHANIE''s PC!')
        DoMatlabUpdate = 0;
    case 'MONTBLANC'
        disp('Welcome on the MONTBLANC Linux Blast @ LabNIC!')
    case 'KARIMND'
        
        disp('Welcome on the LENA138/Windows station!')
        homedir = 'E:/ndiaye/home';                
    otherwise
        if ~isempty(strfind(lower(hostname), 'chups.jussieu.fr'))
            disp('Welcome at the COGIMAGE Lab!')
            lcd=cd;cd('~');homedir=cd;cd(lcd);
            switch strrep(hostname, '.chups.jussieu.fr', '')
                case 'lena138.lena'
                    disp('Welcome on the COGIMAGE Lena138 station!')
                    %lcd=cd;cd('~');homedir=cd;cd(lcd);
            end
        end
end
disp(' ')

[HOMEDIR]=mypath

if not(exist(HOMEDIR, 'dir'))
    warning(sprintf(['Directory %s does not exist!\n' ...
        'HOMEDIR variable unset'], HOMEDIR))
    clear HOMEDIR
else
    disp(sprintf('HOMEDIR variable set to: %s', HOMEDIR))
    %    addpath(fullfile(HOMEDIR, 'mtoolbox', 'lib'));
    addpath(fullfile(HOMEDIR, 'matlab'));
    %cd(fullfile(HOMEDIR, 'matlab'))
end


[USBDIR]=usbpath;


if isempty(USBDIR) || any(isnan(USBDIR))
    warning(sprintf(['No USB key found.\n' ...
        'USBDIR variable unset']))
    clear USBDIR
elseif not(exist(USBDIR, 'dir'))
    warning(sprintf(['Directory %s does not exist!\n' ...
        'USBDIR variable unset'], USBDIR))
    clear USBDIR
else
    disp(sprintf('USB key is: %s', USBDIR))
    %    addpath(fullfile(USBDIR, 'mtoolbox', 'lib'));
    addpath(fullfile(USBDIR, 'matlab'));
    if DoMatlabUpdate
        if exist('C:\Program Files\WinMerge')
            if exist(HOMEDIR,'dir') && exist(USBDIR,'dir')
                system(['"C:\Program Files\WinMerge\WinMerge.exe" /r /e /f "*.m" /x ' fullfile(HOMEDIR, 'matlab') ' ' fullfile(USBDIR, 'matlab')])
            end
        end
    end
end

% try
%     addpath 'C:\Program Files\MATLAB704\toolbox\matlab\datafun\'
% end

% cd(fullfile(HOMEDIR, 'matlab'))

if ~exist('DoMatlabUpdate','var')
    DoMatlabUpdate = 1;
end

% SVN update
switch upper(deblank(hostname))
    case 'D5BDS81J'
        disp('SVU update...')
        !svn update
        !svn commit --message "Automatic update by startup.m"
    case 'IMAGERIE2-PV'
        disp('Welcome on STEPHANIE''s PC!')        
    case 'MONTBLANC'
         disp('Welcome on the MONTBLANC Linux Blast!')
    case 'LENA138.LENA.CHUPS.JUSSIEU.FR'
         disp('SVN update...')
        !svn update ~/matlab
        !svn commit ~/matlab --message "Automatic update by startup.m"
    case 'KARIMND'        
         disp('SVN update...')
        !svn update .
        !svn commit . --message "Automatic update by startup.m"        
end

if DoMatlabUpdate
    try
        matlabupdate
    catch
        warning('Couldn''t update your MATLAB scripts & functions...')
    end
end
DoMatlabUpdate = 0;

if exist('G:/mtoolbox/javaclasses')
    javaaddpath G:/mtoolbox/javaclasses
end
if exist('g:\mtoolbox\Psychtoolbox\PsychJava')
    javaaddpath g:\mtoolbox\Psychtoolbox\PsychJava
end
if exist('F:/mtoolbox/javaclasses')
    javaaddpath F:/mtoolbox/javaclasses
end

% warning('off','MATLAB:dispatcher:nameConflict')

disp(' ');
disp(' ');

