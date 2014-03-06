function []=mkdirr(p)
% mkdirr - recursive mkdir
% 
%Native MKDIR waits a relative path:
%   >> mkdir('/usr/bin/newpath1/newpath2')
%will therefore create a usr/bin/newpath1... 
%in the CURRENT directory whereas our
%   >> mkdirr('/usr/bin/newpath1/newpath2')
%will make newpath1 and newpath2 in /usr/bin
i=0;
while not(exist(p, 'dir'))
    i=i+1;
    [p,np{i},e]=fileparts(p);
    np{i}=[np{i},e];
    if isempty(np{i})
        break
    end
end
lcd=pwd;
if isempty(p)
    p='.';
end
for j=i:-1:1
    cd(p)
    mkdir(np{j});
    p=fullfile(p,np{j});
end
cd(lcd)