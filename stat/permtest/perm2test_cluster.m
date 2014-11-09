function [clusters,pvclusters,pv,S,P,PS]=perm2test_cluster(X1,X2,testname,vc,threshold,dims,NP,tails,st,TimeBar,varargin)
%perm2test_cluster - Cluster-level permutation test for 2-sample statistic 
%   [clusters,pvclusters,pv,S] = perm2test_cluster(X1,X2,testname,vc,threshold,dims,st,NP,TimeBar,tails,testoptions)
%       Performs two-pass permutation test for cluster-level inference
%       On the firts pass, an uncorrected permutation test is performed on
%       data. From this, the cluster-level significance level is assessed
%       using connectivity information provided.
%
%   MANDATORY INPUTS:
%       X1,X2: 2D-data [Subjects x Measures] or [Measures x Subjects] (see permtest)
%       testname: Name of the test used at the first level 
%                 'ttest'|'diff'|'pseudottest'|'mann-whitney'|'wilcoxon' 
%   OPTIONAL INPUTS:
%       dimP: permuted dimension (default: 1. see permtest)
%       vc: connectivity (if vc==1, assumed continuous, eg. time)
%       threshold: primary threshold on uncorrected alpha significance
%                  default: 0.05
%       st: choice of the statistics: 
%               - 'probmass' (default): probability mass  
%               - { 'area' AREA} : area of the cluster. AREA should be a
%                 vector of areas associated to each vertices
%               - 'size': number of vertices 
%       NP: number of permutations (default:see permtest)
%       TimeBar: display TimeBar (default:see permtest)
%       tails: 1 or 2-tail testing (default: 2)
%       testoptions: parameters used by the chosen test 
%                    (e.g. smoothing kernel for pseudottest)
%   OUTPUTS:
%       clusters: cell array of clusters
%       pvcluster: p-value as approximated by permutations on clusters
%       pv: uncorrected p-values at each measure point
%       S: observed statistics in the data
%
%   Example
%       >> [c,pc]=permtest_cluster(x1,x2,'peusodttest',1,mni.vertconn,...
%                                  0.05,'pmass',9999,1,mni.smooth.W) 
%
%   See also: permtest, permtest_norm

% Author: Th K&K Team. (kndiaye01<at>yahoo.fr & jerbi<at>chups.jussieu.fr)
% Copyright (C) 2006 
% This program isfree software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% K&K   2006-01-05 Creation
% KND   2006-02-01 'area' option
% ----------------------------- Script History ---------------------------------

if ndims(squeeze(X1))>2
    error('Cannot deal with multiple dimensions')
end

if ~exist('dimP','var')
    dimP=[];    
end
if ~exist('vc','var')
    vc=[];
end
if ~isequal(vc,1) && (~iscell(vc) || size(vc,1)~=size(vc,1)) && ~isempty(vc)
    error('Connectivity Information provided through ''vc'' is of wrong type');
end
if ~exist('dimM','var')
    if iscell(vc)
        dimM=find(size(X1)==length(vc));
    else
        [ignore,dimM]=max(size(X1));
    end
    fprintf('Clustering on dimension: %d\n', dimM);
end
if ~exist('threshold','var')
    threshold=0.05;
end
if ~exist('st','var')
    st='pmass';
end
if ~exist('NP','var')
    NP=[];
end
if ~exist('TimeBar','var')
    TimeBar=1;
end
if ~exist('tails','var')
    tails=2;
end
if ~ismember(st{1}, { 'probmass' 'area' 'size' })
    error('Wrong cluster-level statistic!')
end
 

[pv,S,NP,P,PS] = perm2test(X1,X2,testname,dimP,0,NP,TimeBar,tails,varargin{:}); 
if nargout<5
    clear P;
end
PS=squeeze(PS);
pv=squeeze(pv);
T_thd=quantile(PS,1-threshold);
if tails==2
    TT=abs(S);
else
    TT=S;
end

if ischar(st)    
    st={st};
end

switch(st{1})
    case 'probmass'
        [clusters,pvclusters]=prob_clusters(TT(:).*(TT(:)>=T_thd(:)),PS.*(PS>=repmat(T_thd(:)',NP,1)),vc,TimeBar);
    case 'area'
        [clusters,pvclusters]=prob_clusters(st{2}(:).*(TT(:)>=T_thd(:)),repmat(st{2}(:)',NP,1).*(PS>=repmat(T_thd(:)',NP,1)),vc,TimeBar);
    case 'size'
        [clusters,pvclusters]=prob_clusters(TT(:)>=T_thd(:),PS>=repmat(T_thd(:)',NP,1),vc,TimeBar);    
end
return
%[FaceNormal, FaceArea, FaceCenter, VertexNormal, VertexArea, SuspectFace, NumFacesEachVertex, Duplicated_Faces, Not_Twice_Faces] = tessellation_stats(
