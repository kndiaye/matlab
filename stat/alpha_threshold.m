function [pv_alpha]=alpha_threshold(alphas,pThresholds,pv)
% alpha_threshold - recompute the p-values to a given alpha
%
%   [pv_alpha] = alpha_threshold(alphas,pThresholds,pv);
%
pv_alpha=ones(size(pv));
for i=length(alphas):-1:1
    idx=find(pv<=pThresholds(i));    
    pv_alpha(idx)=alphas(i);
end
return
