function FV = patchify(S,varargin)
%PATCHIFY  - Remove subfields from a struct to make it a FV patch
%   FV = patchify(S) remove fields from S other than .vertices and .faces
%   If needed, those fields will be lower-cased.
%   See also: patch

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2005 
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% ----------------------------- Script History ---------------------------------
% KND  2005-12-08 Creation
%                   
% ----------------------------- Script History ---------------------------------
FV=struct('vertices', [], 'faces', []);
if isfield(S,'vertices')    
    FV=setfield(FV,'vertices',getfield(S, 'vertices'));
elseif isfield(S,'Vertices')    
    FV=setfield(FV,'vertices',getfield(S, 'Vertices'));
end
if isfield(S,'faces')    
    FV=setfield(FV,'faces',getfield(S, 'faces'));
elseif isfield(S,'Faces')    
    FV=setfield(FV,'faces',getfield(S, 'Faces'));
end
if isfield(S,'facevertexcdata')
    FV=setfield(FV,'facevertexcdata',getfield(S, 'facevertexcdata'));
elseif isfield(S,'FaceVertexCData')    
    FV=setfield(FV,'facevertexcdata',getfield(S, 'FaceVertexCData'));
end
    