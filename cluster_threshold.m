function  [Y,clusters] = cluster_threshold(X,thd,vc,dim,verbose)
%CLUSTER_THRESHOLD - Keep only data which are clustered
%   [Y] = cluster_threshold(X,thd,vc/adj,dim,verbose)
%       Finds clusters along dimension dim in matrix X whose mass/area is
%       bigger than (or equal to) thd:
%               for each cluster clu{i}=[ ... ],  sum(X([clu{i}])) >= thd;
%       Adjacency/connectivity must be specified in vc 
%           * use vc=1 for continous data (e.g. time samples)
%           * use a conectivity matrix or cell array of neighbors otherwise
%       By default [dim] is the first non singleton dimension of X
%   Outputs Y (of the same size as X) such that Y=X where the clusters
%   match the criterion, Y=0 elsewhere.
%
%   See also: CLUSTERING

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2006 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2006-02-18 Creation
%                   
% ----------------------------- Script History ---------------------------------

if nargin<4
    [dim,dim]=min(find(size(X)>1));
    if isempty(dim)
        dim=1;
    end
end
if nargin<5
    verbose=1;
end

sX=size(X);
ndX=ndims(X);
Y=permute(X, [dim setdiff(1:ndX,dim)]);
if iscell(vc)
    warning(sprintf('%s\n%s', '''vc'' is provided as a vertices_connectivity cell list.' , ...
        'It will be converted to an adjacency matrix for faster computation.'));
    vc=vertconn2adjacency(vc);
    fprintf('Adjacency matrix now computed\n');
end
    
if verbose
    htime=timebar('Finding clusters');    
end
niter=(prod(sX)/sX(dim));
for i=1:niter
    [clu,sclu]=clustering(Y(:,i),vc);
    y=Y(:,i);    
    Y(:,i)=0;
    Y([clu{sclu>=thd}],i)=y([clu{sclu>=thd}],1);
    if verbose
        try,timebar(htime,i/niter);end
    end
    if nargout>1
        clusters{i} = clu(sclu>=thd);
    end
        
end
if verbose
    try;close(htime);end
end
Y=ipermute(Y, [dim setdiff(1:ndX,dim)]);