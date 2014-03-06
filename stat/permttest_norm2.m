function [alphas,pThresholds,pv,pv_alpha,T,P,PS,S_sort]=permttest_norm2(X1,X2,dimP,NP,TimeBar,tails)
% Normalized permutation Two-sided permutation pseudo T-test (with memory optimization)
%   [alphas,pThresholds,pv] = permttest_norm2(X1,X2,dimP,dimM,NP,TimeBar,tails)
%   [alphas,pThresholds,pv,pv_alpha] = permttest_norm2(...)
%   [alphas,pThresholds,pv,T,P,PS,S_sort] = permttest_norm2(...)
% 
% dimP=1;
% NP=100;
% TimeBar=0;
% tails=2;
% X1=rand(15,10,12);X2=cumsum(repmat(randn(1,10), [15,1,12]),2)+rand(15,10,12);
if ~exist('dimP','var')
    dimP=[];
end
if ~isempty(dimP) & ~isequal(abs(dimP),1)
    error('Data matrices X1 and X2 should be: [Subjects]x[Vertices]x[Time Samples]')
end
if ~exist('NP','var')
    NP=+inf;
end
if ~exist('TimeBar','var')
    TimeBar=0;
end
if ~exist('tails','var')
    tails=2;
end
% try
%     MEMSPACE=feature('dumpmem'); % largest contiguous block in memory
%     MEMSPACE=MEMSPACE/8; % doubles are 8 bytes
%     MEMSPACE=MEMSPACE/4; % we want to use only a 1/4 of it
% catch
%     MEMSPACE=8e6;
% end
% 
szX=[size(X1) 1];
NV=size(X1,2);
blk=500;

for k=1:blk:NV
	kk=[k:min(k+blk-1,NV)];
	clear pv_tmp T_tmp P PS
    tic
	[pv_tmp,T_tmp,P,PS] = permttest(X1(:,kk,:),X2(:,kk,:),dimP,0,NP,TimeBar,tails); % KJ customized.....
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



%% OLDIES =========================================



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




