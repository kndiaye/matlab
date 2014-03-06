function [alphas,thresholds,pv,T,P,PS,S_sort]=permttest_norm(X1,X2,dimP,dimM,NP,TimeBar,tails)
% Normalized permutation Two-sided permutation pseudo T-test
%   [alphas,thresholds,pv] = permttest_norm(X1,X2,dimP,dimM,NP,TimeBar,tails)
% 
% dimP=1;
% NP=100;
% TimeBar=0;
% tails=2;
% X1=rand(15,10,12);X2=cumsum(repmat(randn(1,10), [15,1,12]),2)+rand(15,10,12);

% actual code
[pv,T,P,PS] = permttest(X1,X2,dimP,0,+inf); % KJ customized.....
NP=size(PS,1);
S=ones(NP,1);

for k=1:size(T,2)
    MFpvalue=pvalue_fast(squeeze(PS(:,k,:))')';
    S = min([S MFpvalue]')';
end

S_sort = sort(S);
alphas =          find(diff(S_sort)~=0)/length(S_sort);
thresholds=S_sort(find(diff(S_sort)~=0));

% Sth = S_sort(length(S_sort)*closest(pthres,S_sort));

return





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


function [pA] = pvalue_fast( A )
%calculate p-values of a matrix A
%p-values are calculated row-wise

[Y,I] = sort(-A,2);

%fast calculation of p values ignoring common elements
for i=1:size(A,1)
    if(rem(i,250)==0)
        disp([num2str(i) ' out of ' num2str(size(A,1))]);
        pack
    end
    pA(i,I(i,:)) = 1:size(A,2);
end
pA=pA/size(A,2);


