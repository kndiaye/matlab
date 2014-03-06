function [curvature_sigmoid,curvature]=curvature_cortex(arg1,arg2,arg3,arg4)
%CURVATURE_CORTEX - calculates cortex curvature
% function [curvature_sigmoid,curvature]=curvature_cortex(arg1,arg2,arg3,arg4)
%
% function [curvature_sigmoid,curvature]=curvature_cortex(FV,VertConn,sigmoid_const,show_sigmoid)
% FV is the Faces/Vertices structure used to calculate curvature
% VertConn is the vertices connectivity of FV
% sigmoid_const is the sigmoid coefficient (small values give smooth transition of convex to concave areas
% and vice versa). Use close to zero for linear transition.
% show_sigmoid chooses whether to show the sigmoid (1) or not (0)
%
% curvature returned is the surface curvature
% curvature_sigmoid returned is the curvature weighted by a sigmoid
%
% function [curvature_sigmoid]=curvature_cortex(curvature,sigmoid_const,show_sigmoid)
% Used to change the transition of positive and negative curvatures
%
% Remarks: Curvature_cortex uses an approximation of mean curvature. It calculates the mean angle between
% the surface normal of a vertex and the edges formed by the vertex and the neighbouring ones.
%
% See also VERTICES_CONNECTIVITY

%<autobegin> ---------------------- 26-May-2004 11:29:55 -----------------------
% --------- Automatically Generated Comments Block Using AUTO_COMMENTS ---------
%
% CATEGORY: Visualization
%
% Alphabetical list of external functions (non-Matlab):
%   toolbox\colnorm.m
%
% At Check-in: $Author: Mosher $  $Revision: 8 $  $Date: 5/26/04 9:59a $
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
%<autoend> ------------------------ 26-May-2004 11:29:55 -----------------------

% Author: Dimitrios Pantazis, Ph.D.

% ----------------------------- Script History ---------------------------------
% DP 05-May-2002  Creation
% JCM 19-May-2004 Commenting
% ----------------------------- Script History ---------------------------------


%choose whether to display bars
if(~exist('VERBOSE','var')),
   VERBOSE = 1; % default non-silent running of waitbars
end

narg = nargin;
if narg==4
    %assign inputs
    FV=arg1;
    VertConn=arg2;
    sigmoid_const=arg3;
    show_sigmoid=arg4;

    %ititialization
    nVertices=size(FV.vertices,1);
    
    %calculate normals and curvature of FV
    hf=figure('Visible','off');
    hp=patch('faces',FV.faces, 'vertices', FV.vertices);
    normals=get(hp,'VertexNormals');
    close(hf);
    %Make the normals unit norm
    [nrm,normalsnrm]=colnorm(normals');
    
    if(VERBOSE)
        hwait = waitbar(0,sprintf('Calculating curvature...'));
        drawnow %flush the display
        step=round(nVertices/10);
    end
    %compute average angle on each vertex
    curvature=zeros(nVertices,1);
    curvature_sigmoid=zeros(nVertices,1);
    for i=1:nVertices %for all vertices
        if(VERBOSE)
            if(~rem(i,step)) % ten updates
                waitbar(i/nVertices,hwait,sprintf('Calculating curvature...'));
                drawnow %flush the display         
            end
        end
        nNeighbours=length(VertConn{i}); %number of neighbours
        edgevector=FV.vertices(VertConn{i},:)-repmat(FV.vertices(i,:),nNeighbours,1); %vectors joining vertex with neighbours
        [nrm,edgevector]=colnorm(edgevector');
        curvature(i)=mean(acos(normalsnrm(:,i)'*edgevector))-pi/2;
        curvature_sigmoid(i)= 1./(1+exp(-curvature(i).*sigmoid_const))-0.5;
    end
    close(hwait);
end

if narg==3
    %assign inputs
    curvature=arg1;
    sigmoid_const=arg2;
    show_sigmoid=arg3;
    
    curvature_sigmoid=zeros(length(curvature),1);
    for i=1:length(curvature)
        curvature_sigmoid(i)= 1./(1+exp(-curvature(i).*sigmoid_const))-0.5;
    end
end

if(exist('show_sigmoid'))
    if(show_sigmoid)
        x=-pi/2:0.01:pi/2;
        y=1./(1+exp(-x*sigmoid_const))-0.5;
        figure;
        plot(x,y)
        grid on;
        title('Transition between negative and positive curvature');
    end
end
