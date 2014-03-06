function GUI = regcheck(GUI);
%REGCHECK - Check the regularization tag
% function GUI = regcheck(GUI);
% The following three structure fields are optional for regularization purposes.
%  They may be null or missing to represent unused. If multiple fields are given, 
%  then precedence is given in the order given below.
%  .Condition, condition number to use in truncation, e.g. 100
%  .Energy, fractional energy to use in truncation, e.g. .95
%  .Column_norm, condition number to use in Tikhonov regularization, e.g. 100
%  If all are null, no regularization is performed in the RAP-MUSIC loops.
% Returns the same structure, but with all regularization conditions set to exist
%  and the field GUI.REG set to the correct field string, such that
%  getfield(GUI,GUI.REG) returns the parameter associated with the string.

%<autobegin> ---------------------- 26-May-2004 11:34:14 -----------------------
% --------- Automatically Generated Comments Block Using AUTO_COMMENTS ---------
%
% CATEGORY: Inverse Modeling
%
% At Check-in: $Author: Mosher $  $Revision: 12 $  $Date: 5/26/04 10:02a $
%
% This software is part of BrainStorm Toolbox Version 2.0 (Alpha) 24-May-2004
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
% Copyright (c) 2004 BrainStorm by the University of Southern California
% This software distributed  under the terms of the GNU General Public License
% as published by the Free Software Foundation. Further details on the GPL
% license can be found at http://www.gnu.org/copyleft/gpl.html .
% 
% FOR RESEARCH PURPOSES ONLY. THE SOFTWARE IS PROVIDED "AS IS," AND THE
% UNIVERSITY OF SOUTHERN CALIFORNIA AND ITS COLLABORATORS DO NOT MAKE ANY
% WARRANTY, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO WARRANTIES OF
% MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, NOR DO THEY ASSUME ANY
% LIABILITY OR RESPONSIBILITY FOR THE USE OF THIS SOFTWARE.
%<autoend> ------------------------ 26-May-2004 11:34:14 -----------------------


% $Date: 5/26/04 10:02a $ $Revision: 12 $

% Establish the regularization
if(~isfield(GUI,'Condition')),
  GUI.Condition = [];
end
if(~isfield(GUI,'Energy'))
  GUI.Energy = [];
end
if(~isfield(GUI,'Column_norm'))
  GUI.Column_norm = 0; % by default, don't column normalize
end
if(~isfield(GUI,'Tikhonov')),
  GUI.Tikhonov = [];
end

% Now set the regularization switch
if(~isempty(GUI.Condition)),
  GUI = setfield(GUI,'REG','Condition');
elseif(~isempty(GUI.Energy)),
  GUI = setfield(GUI,'REG','Energy');
elseif(~isempty(GUI.Tikhonov)),
  GUI = setfield(GUI,'REG','Tikhonov');
else
  GUI = setfield(GUI,'REG','None');
end

return
