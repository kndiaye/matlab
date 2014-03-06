function docinfo;
% Adds a user defined field to a figure that contains
% a text transcript of the m-file that called this command.
% The text will be stored when the figure is stored as a fig file
% and can be recovered using the 'recallfigmfile' command.
%
% To use this function, insert the command 'docinfo' after your plot command.
% The function operates only on the active figure, so if you have more than
% one figure, you will need to insert this command for each one.

[st,I]=dbstack; % accesses the stack of called functions

filestring=st(2).name; 
% docinfo is first on the stack, so the second file is required.

[pathstr,name,ext,versn] = fileparts(filestring);
% identifies the mfile

mfiletext=textread([name,ext],'%s','delimiter','\r');
%reads the mfile as a text structure.

atext=char(mfiletext);%convert to a string

set(gcf,'userdata',atext);%stores as a property of the figure

