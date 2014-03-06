function [VecInd,minn]  = findclosest2(VecGuess, VecRef, mode)
% FINDCLOSEST: Find entries of closest elements between two vectors.
%
% USAGE:  VecInd  = findclosest(VecGuess, VecRef);
% USAGE:  VecInd  = findclosest(VecGuess, VecRef, mode);
%
% DESCRIPTION:
%     VecGuess is a vector for which one wants to find the closest entries in vector VecRef
%     VecInd is the vector of indices pointing at the entries in
%     vector VecRef that are the closest to VecWin
%     VecInd is of the same length as VecGuess
%     'mode' is a string specifying how the search is made:
%       - 'closest': find the closest value (above or below)
%       - 'above': find the closest value above the VecGuess
%       - 'below': 
%     In other words, VecRef(VecInd(i)) is the element of VecRef closest to VecGuess(j)
%     VecRef and VecGuess do not need to be the same length

% @=============================================================================
% This software is part of The Brainstorm Toolbox
% http://neuroimage.usc.edu/brainstorm
% 
% Copyright (c)2010 Brainstorm by the University of Southern California
% This software is distributed under the terms of the GNU General Public License
% as published by the Free Software Foundation. Further details on the GPL
% license can be found at http://www.gnu.org/copyleft/gpl.html.
% 
% FOR RESEARCH PURPOSES ONLY. THE SOFTWARE IS PROVIDED "AS IS," AND THE
% UNIVERSITY OF SOUTHERN CALIFORNIA AND ITS COLLABORATORS DO NOT MAKE ANY
% WARRANTY, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO WARRANTIES OF
% MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, NOR DO THEY ASSUME ANY
% LIABILITY OR RESPONSIBILITY FOR THE USE OF THIS SOFTWARE.
%
% For more information type "brainstorm licence" at command prompt.
% =============================================================================@
%
% Authors: ?
% ----------------------------- Script History ---------------------------------
%
% ------------------------------------------------------------------------------

if isvector(VecRef)
  if size(VecRef,1) == 1
    VecRef = VecRef';
  end
end
if nargin<3
    mode='closest';
end
tmp = repmat(VecRef,1,length(VecGuess));
switch(mode)
 case 'closest'
   [minn VecInd] = min(abs(repmat(VecGuess(:)',length(VecRef),1) - tmp));
 case 'above'
   [minn VecInd] = min(abs(repmat(VecGuess(:)',length(VecRef),1) - tmp));
 case 'below'
   [minn VecInd] = min(abs(repmat(VecGuess(:)',length(VecRef),1) - tmp));
end  
VecInd = reshape(VecInd, size(VecGuess));
minn = reshape(minn, size(VecGuess));