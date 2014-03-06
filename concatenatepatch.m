function NFV = concatenatepatch(FV1,varargin)
%CONCATENATEPATCH - Concatenate FV patch structures
%   [NFV] = concatenatepatch(FV1,FV2,FV3,...)
%       will concatenate FV's .vertices fields and re-index .faces ones
%       Additional field will be concatenated also (if possible)
%   See also: patch

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2005 
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% ----------------------------- Script History ---------------------------------
% KND  2005-12-11 Creation
%                   
% ----------------------------- Script History ---------------------------------

NFV=FV1;
fn=fieldnames(NFV);
nfn=length(fn);
for i=2:nargin
    nv=size(NFV.vertices,1);
    NFV.vertices=[NFV.vertices; getfield(varargin{i-1}, 'vertices')];
    NFV.faces=[NFV.faces; getfield(varargin{i-1}, 'faces')+nv];    
    for j=1:nfn
    try
        NFV=setfield(NFV, fn{j}, [ getfield(NFV, fn{j}) ; getfield(varargin{i-1}, fn{j}) ]);
    catch
        warning(sprintf('Can''t concatenate field: %s', fn{j}));
    end
    end
    
end