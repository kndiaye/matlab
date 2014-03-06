function [sig,alpha]=alpha_significance(alpha,pv,alphas,pThresholds) 
% [sig,alpha]=alpha_significance(alpha,pv,alphas, pThresholds) 
%
% This function finds the significant value according to a given alpha with
% FWER specified by alphas and their corresponding thresholds 
%
%   Ex:
%       >> [alphas,pThresholds,pv]=permttest_norm2(X1,X2);
%       >> [sig,alpha]=alpha_significance(0.05,pv,alphas,pThresholds);
%   
%   In this example, you compare X1 and X2, sig will have 1 at any position
%   where significativity is below 0.05 

i=max(find(alphas<alpha));
thres=pThresholds(i);
sig=zeros(size(pv));
sig(pv<thres)=1;
sig=logical(sig);
