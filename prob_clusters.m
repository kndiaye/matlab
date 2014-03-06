function [Xclu,aXclu,mXclu,mSclu] = prob_clusters(X,S,vc,VERBOSE)
%PROB_CLUSTERS - Compute probability of getting a given cluster from data
%   [clu,aclu,mclu] = prob_clusters(X,S,vc) 
%       Estimates the mass statistics, i.e. computes the
%       probability of clusters at least as 'heavy' as those found in the  
%       [N-by-1] vector X in the [P-by-N] distribution S where each line
%       is an observation/permutation of N data point.
%       'heavier' is to be understand as 'of a greater mass'
%   Outputs:
%       clu: clusters found in X
%       aclu: alpha level probability of each cluster according to
%             cluster distribution extracted from S 
%       mclu: mass of each cluster
% 
%   [...] = prob_clusters(X,S)
%   [...] = prob_clusters(X,S,1)
%           When vc=1 or not given, assumes continuity between data point.
%           This is the case when X's 2nd dimension is time.
%
%   Example
%       >> [pv,T,P,PS] = permttest(X1,X2)
%       Performs permutation test on data X1 and X2
%       >> [c,pc]=prob_clusters(T>quantile(PS,.95),PS,[])
%       Computes the probability of each cluster made of data point showing
%       a significant difference between X1 and X2 samples.
%
%   See also: permttest_clusters, clustering

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2006 
% This program isfree software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2006-01-05 Creation
% KND  2007-04-16 Added some comments
% ----------------------------- Script History ---------------------------------

% Variables:
%   X: data to test
%   S: [P-by-size(X)] dataset of observations
%   Xclu: clusters of data in X
%   mXclu: mass of each X cluster
%   mSclu: [P-by-size(X,2:end)] maximal mass in each observation
X=X(:);
if size(S,2)~=size(X,1)
    error('X and S sizes don''t match');
end
Xclu={};
mXclu=[];
if nargin<3
    vc=[];
end
if iscell(vc)
    warning(sprintf('%s\n%s', '''vc'' is provided as a vertices_connectivity cell list.' , ... 
        'It will be converted to an adjacency matrix for faster computation.'));
    vc=vertconn2adjacency(vc);
    fprintf('Adjacency matrix computed\n');
end
if nargin<4
    VERBOSE=1;
end

%Clusters in the original data
Xclu=clustering(X,vc);
for i=1:length(Xclu);
    mXclu(i,:)=sum(X(Xclu{i}));
end 
aXclu=ones(size(mXclu));
if isempty(mXclu) & nargout < 4
    % If no cluster in test data X and user doesn't want mSclu, skip the rest
    return
end
%Sort clusters accordig to their mass
[mXclu,i]=sort(mXclu);
mXclu=flipud(mXclu);
i=flipud(i);
Xclu=Xclu(i);

if VERBOSE
    try
        htimer = timebar('Probing Clusters','Progress...');
    catch
        warning('Function timebar.m missing. waitbar.m is used instead')
        htimer = waitbar(0,'Probing Clusters');    end
else
    htimer = NaN;
end
sX=size(X);
NP=size(S,1);
mSclu=zeros([NP,sX(2:end)]);
for p=1:NP
    % Find clusters in each permutation/observation, p, of test data S
    Sclu=clustering(S(p,:)~=0,vc);
    for i=1:length(Sclu);
        % Update distribution of clusters
        mSclu(p,:)=max(mSclu(p,:),sum(S(p,Sclu{i}),2));
    end
    if VERBOSE, if ishandle(htimer),try,if isequal(get(htimer, 'tag'), 'timebar'), timebar(htimer,p/NP),else,waitbar(p/NP,htimer);end;catch,end,end,end
end
if VERBOSE, if ishandle(htimer),try,close(htimer),end,end, drawnow, end

% Compute probability according to the observed distribution
for i=1:length(Xclu)
    aXclu(i)=(sum(repmat(mXclu(i,:),NP,1)<=mSclu)+1)/(NP+1);
end    

return