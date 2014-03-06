function varargout = bst_safeCall( varargin )
% BST_SAFECALL: Call any function with an error catching.

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
% Authors: Francois Tadel, 2008
% ----------------------------- Script History ---------------------------------
% FT  24-Jun-2008  Creation
% ------------------------------------------------------------------------------

try
    if (nargout)
        [varargout{1:nargout}] = feval(varargin{:});
    else
        feval(varargin{:});
    end
catch
    bst_error();
    if (nargout > 0)
        varargout(1:nargout) = cell(1, nargout);
    end
end

end






