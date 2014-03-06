function h = windfind(name);
%WINDFIND - Find or create a particular window using it's NAME property
% function h = windfind(name);
% find the first window whos 'Name' is name.
% If no such window exists, create it.  
% h is the handle of the window returned.

%<autobegin> ---------------------- 27-Jun-2005 10:46:04 -----------------------
% ------ Automatically Generated Comments Block Using AUTO_COMMENTS_PRE7 -------
%
% CATEGORY: Utility - General
%
% At Check-in: $Author: Mosher $  $Revision: 16 $  $Date: 6/27/05 9:00a $
%
% This software is part of BrainStorm Toolbox Version 27-June-2005  
% 
% Principal Investigators and Developers:
% ** Richard M. Leahy, PhD, Signal & Image Processing Institute,
%    University of Southern California, Los Angeles, CA
% ** John C. Mosher, PhD, Biophysics Group,
%    Los Alamos National Laboratory, Los Alamos, NM
% ** Sylvain Baillet, PhD, Cognitive Neuroscience & Brain Imaging Laboratory,
%    CNRS, Hopital de la Salpetriere, Paris, France
% 
% See BrainStorm website at http://neuroimage.usc.edu for further information.
% 
% Copyright (c) 2005 BrainStorm by the University of Southern California
% This software distributed  under the terms of the GNU General Public License
% as published by the Free Software Foundation. Further details on the GPL
% license can be found at http://www.gnu.org/copyleft/gpl.html .
% 
% FOR RESEARCH PURPOSES ONLY. THE SOFTWARE IS PROVIDED "AS IS," AND THE
% UNIVERSITY OF SOUTHERN CALIFORNIA AND ITS COLLABORATORS DO NOT MAKE ANY
% WARRANTY, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO WARRANTIES OF
% MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, NOR DO THEY ASSUME ANY
% LIABILITY OR RESPONSIBILITY FOR THE USE OF THIS SOFTWARE.
%<autoend> ------------------------ 27-Jun-2005 10:46:04 -----------------------

% ----------------------------- Script History ---------------------------------
% Author 1994 John C. Mosher
% 3/3/94 Author
% 19-May-2004 JCM Comments Cleaning
% ----------------------------- Script History ---------------------------------

if(~isstr(name)),
  error('WINDFIND: input argument must be string');
end

hw = get(0,'children');		% all open windows
hw = sort(hw);			% in increasing window order

for i = 1:length(hw),
  s = get(hw(i),'Name');
  if(strcmp(deblank(s),deblank(name))),
    h = hw(i);
    return;
  end
end

% we exited out without a match, make the window
h = figure;
set(h,'Name',name);
return

