function [filenames, pathname] = uigetfiles(varargin)
% This is a Java interfaced version of UIGETFILES, that brings multiple file
% open dialog box. 
%
% [filenames, pathname] = uigetfiles; displays a dialog box file browser
% from which the user can select multiple files.  The selected files are
% returned to FILENAMES as an arrayed strings. The directory containing
% these files is returned to PATHNAME as a string. 
%
% A successful return occurs only if the files exist.  If the user selects
% a  file that does not exist, an error message is displayed to the command
% line.  If the Cancel button is selected, zero is assigned to FILENAMES
% and current directory is assigned to PATHNAME. 
%
% Allows the same syntax for file filter as Matlab (R13) function UIGETFILE :
%   uigetfiles(filterspec, title)
% filterspec should be a N-by-2 cell array of strings.
% See: UIGETFILE
%
% This program has an equivalent function to that of a C version of
% "uigetfiles.dll" downloadable from www.mathworks.com under support, file
% exchange (ID: 331). 
%
% It should work for matlab with Java 1.3.1 or newer.
%
% Modified by KND, 2005-11-08, kndiaye01<at>yahoo.fr
%
% Shanrong Zhang
% Department of Radiology
% University of Texas Southwestern Medical Center
% 02/09/2004
%
% email: shanrong.zhang@utsouthwestern.edu

% mainFrame = com.mathworks.ide.desktop.MLDesktop.getMLDesktop.getMainFrame;
filechooser = javax.swing.JFileChooser(pwd);
filechooser.setMultiSelectionEnabled(true);
filechooser.setFileSelectionMode(filechooser.FILES_ONLY);
if nargin>0
    filechooser.setAcceptAllFileFilterUsed(false); 
    filter=varargin{1};
    for i=1:size(filter, 1)
        % Parse string sith multiple '*.ext' 
        ext=strread(filter{i}, '%s', 'delimiter', ';');
        for j=1:length(ext)
            if size(filter,2)>1
                flt=javaObject('MatlabR13FileFilter', ext{j}, filter{i,2});
            else
                flt=javaObject('MatlabR13FileFilter', ext{j});
            end
            filechooser.addChoosableFileFilter(flt);
        end
    end
end
if nargin>1
    filechooser.setDialogTitle(varargin{2})
end
% The following does NOT work. I dunno why...
% if nargin>2
%     if ~iscell(varargin{3})
%         varargin{3}={varargin{3}};
%     end
%     selfiles=javaArray('java.io.File',length(varargin{3})   );    
%     for i=1:length(varargin{3})
%         selfiles(i)=java.io.File(varargin{3}{i})
%     end    
%     filechooser.setSelectedFiles(selfiles)
% end
if nargin>2
    error('uiGetFiles cannot deal with pre-selected files')
end

selectionStatus = filechooser.showOpenDialog(com.mathworks.mwswing.MJFrame); 

if selectionStatus == filechooser.APPROVE_OPTION
    pathname = [char(filechooser.getCurrentDirectory.getPath), ...
                java.io.File.separatorChar];
    selectedfiles = filechooser.getSelectedFiles;
    for k = 1:1:size(selectedfiles)
        filenames(k) = selectedfiles(k).getName;
    end
    filenames = char(filenames);  
else
    pathname = pwd;
    filenames = 0;
end

% End of code