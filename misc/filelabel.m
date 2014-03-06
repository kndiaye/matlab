function filelabel;
% This program labels a figure with the name of the m.file
% which produced the plot as well as the date and time it 
% was created.
%
% To use this function, insert the command 'filelabel' after your plot command.
% The function operates only on the active figure, so if you have more than
% one figure, you will need to insert this command for each figure.

[st,I]=dbstack; % accesses the stack of called functions
filestring=st(2).name; % the first m file is this one - labelfig.
% the second item in the stack would refer to the function
% that called this program

[pathstr,name,ext,versn] = fileparts(filestring);% allows elimination of the path
% string, since this is assumed to be either extraneous or transient information.
% If the full path name is desired, then the first 'tit' line should be commented out
% and the second one used.

tit=[name,ext,'   ',datestr(now)];
%tit=[filestring,'   ',datestr(now)];


set(gca,'position',[0.1300    0.200    0.775    0.7250]);
% the set command raises the bottom of the axes to allow for labeling

text(.5,-.2,tit,'interpreter','none','units','normalized','VerticalAlignment','top',...
    'HorizontalAlignment','center','clipping','off');






