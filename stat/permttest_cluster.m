function [clusters,pvclusters,pv,S,T,P,PS,S_sort]=permttest_cluster(X1,X2,dimP,dimM,vc,threshold,st,NP,TimeBar,tails)
%permttest_cluster - Cluster-level permutation test 
%   [clusters,pvclusters] = permttest_cluster(X1,X2,dimP,dimM,vcM,NP,threshold,TimeBar,tails,st)
%       Performs two-pass permutation test for cluster-level inference
%       On the firts pass, an uncorrected permutation test is performed on
%       data. From this, the cluster-level assessment is performed using
%       connectivity information provided.
%       The choice of the cluster statistics 'mass'
%   MANDATORY INPUTS:
%       X1,X2: data (see permttest)
%   OPTIONAL INPUTS:
%       dimP: permuted dimension (default: see permttest)
%       dimM: dimension used for clustering (typically: vertices or time)
%       vc: connectivity (if vc==1, assumed continuous, eg. time)
%       threshold: primary threshold on uncorrected alpha significance
%                  default: 0.05
%       st: choice of the statistics: 'mass' (default) or 'size'. 
%       NP: number of permutations (default:see permttest)
%       TimeBar: display TimeBar (default:see permttest)
%       tails: 1 or 2-tail testing (default: 2)
%   OUTPUTS:
%       clusters: cell array of clusters
%       pvcluster: p-value as approximated by permutations
%
%   Example
%       >> [c,pc]=permttest_cluster(x1,x2,1
%
%   See also: 

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2006 
% This program isfree software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2006-01-05 Creation
%                   
% ----------------------------- Script History ---------------------------------

if ndims(X1)>2
    error('Cannot deal with multiple dimensions')
end

if ~exist('dimP','var')
    dimP=[];    
end
if ~isempty(dimP) & ~isequal(abs(dimP),1)
    error('Data matrices X1 and X2 should be: [Subjects]x[Vertices]x[Time Samples]')
end
if ~exist('vc','var')
    vc=[];
end
if ~isempty('vc')
    vc=1;
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
    st='mass';
end
if ~exist('NP','var')
    NP=[];
end
if ~exist('TimeBar','var')
    TimeBar=0;
end
if ~exist('tails','var')
    tails=2;
end
[pv,T,P,PS] = permttest(X1,X2,dimP,0,NP,TimeBar,tails); 
T_thd=quantile(PS,1-threshold);
NP=size(PS,1);
if tails==2
    TT=abs(T);
end
switch(st)
    case 'mass'
        [clusters,pclusters]=prob_clusters(TT.*(TT>=shiftdim(T_thd)),PS.*(PS>=repmat(T_thd,NP,1)),vc);
    case 'size'
        [clusters,pclusters]=prob_clusters(TT>=shiftdim(T_thd),PS>=repmat(T_thd,NP,1),vc);
end
pvclusters=1-pclusters; % this is now a p-value...

return


%====================================================================
%% OLD STUFF (now use prob_clusters)
%
%



clear P;
sX=size(pv);
NP=size(PS,1);
T_thd=quantile(PS,1-threshold);
T_thd=reshape(T_thd, sX);
PS=reshape(PS, [NP sX 1]);
PS=permute(PS, [1 dimM setdiff(2:length(sX), dimM)]);
sX=size(PS);
S=ones(NP,1);
for i=1:NP
    if isempty(vcM)
        s=piecemeal(shiftdim(PS(i,:,:),1)>=T_thd(:,:));
        if isempty(s)
            s=0;
        else
            s=max(s);
        end
        S(i)=s;
    else        
    clusters=tex_clusters(abs(T)>=T_thd,vcM)
    for i=1:length(clusters{1});
        sz(i)=length(clusters{1}{i});
    end    
    end
end
if isempty(vcM)
    [sz,samples]=piecemeal(abs(T)>=T_thd);
    for i=1:length(sz);
        clusters{i}=samples(i)+[1:sz(i)]-1;
    end
else
    clusters=tex_clusters(abs(T)>=T_thd,vcM)
    for i=1:length(clusters{1});
        sz(i)=length(clusters{1}{i});
    end    
end

if isempty(sz)
    clusters={};
    pclusters=[];
    return
end

[sz,i]=sort(sz);
sz=flipud(sz);
i=flipud(i);
clusters=clusters(i);
for i=1:length(sz)
    pclusters(i)=(sum(S>=sz(i))+1)/(NP+1);
end    

%====================================================================
%% OLD STUFF
%
%


for k=1:blk:NV
	kk=[k:min(k+blk-1,NV)];
	clear pv_tmp T_tmp P PS
    tic
	
    toc    
	
	if k==1
        % Those allocations cannot be done earlier as we don't know NP
		NP=size(PS,1);
		S=ones(NP,1);
		T=zeros(szX(2:end));
		pv=zeros(szX(2:end));        
    end
    % Minimal p-value across channels, time etc for each perm(but not
    % across perms)
    S = min([S pvalue_fast(PS(:,:))]')';
	T(kk,:)=T_tmp;
	pv(kk,:)=pv_tmp;
end

S_sort = sort(S);
alphas =          find(diff(S_sort)~=0)/length(S_sort);
pThresholds=S_sort(find(diff(S_sort)~=0));
if nargout>3
    pv_alpha=alpha_threshold(alphas,pThresholds,pv);
end    
return

function [pA] = pvalue_fast( A )
% calculate p-values of a matrix A
% p-values are calculated column-wise
A=A(:,:);
pA=zeros(size(A));
[Y,I] = sort(-A);
n=size(A,1);
%fast calculation of p values ignoring common elements
for i=1:size(A,2)
    pA(I(:,i),i) = 1:n;
end
pA=pA./n;
return


%==========================================================================
%%OLDER STUFF...



S = ones(M,1); %initialize with worst case
T_orig_pvalue = zeros(size(T_orig));
for k = 1:K %for all channels/sources    
    MF = []; %MF holds all data from same channel k (MxF matrix)
    for m = 1:M %for all permutations
        MF = [MF; T{m}(k,:)];
    end
    %convert MF into p-values
    MFpvalue = pvalue_fast(MF')';
    %Update S statistic, S = minmin_kf T_kf
    %we find minimum component for each channel k each time, iterate for K channels
    S = min([S MFpvalue]')';
end

S_sort = sort(S);

bst_message_window('Convert Perm statistics into P-values -> Done')
delete(hwait)

%This is not completely correct
%The empirical distribution of S_sort is discrete and the left
%tail is not clearly defined
%Instead of 5% threshold, you may achieve 7.6% or something like that

% p_steps = find(diff(S_sort)~=0)/length(S_sort);
% true_pvalue = S_sort(length(S_sort)*closest(pthres,S_sort));

%Sth = S_sort(length(S_sort)*0.05)

%Significant values:
%T_orig_pvalue > Sth
return




