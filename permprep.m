% function prep=permprep(X,Y,paired,tails)
for i=1:10000
    n=subarray(randperm(30),1:15);
    y(i)=mean(z{1}(n));
    n=subarray(randperm(30),1:15);
    y(i)=y(i)-mean(z{2}(n));
end

% doesn't work


% % 
% % Z=sum(Y(1:ceil(N(1)/2),:),1)./ceil(N(1)/2)-sum(Y(N(1)+(1:ceil(N(2)/2)),:),1)./ceil(N(2)/2);
% % if i==0
% 
% Randomization methods avoid assumptions of normality, are useful for
% small-n experiments, and are robust against heteroscedasticity. To employ
% them:
% 
%     * Bootstrap populations for the experimental and control samples
%     independently, generating subsamples of half the size of the original
%     samples, using software such as Resampling Stats©(Bruce, 2003). This
%     half-sizing provides the sqrt(2) increase in the standard
%     deviation intrinsic to calculation of prep.
%     * Generate an empirical sampling distribution of the difference of
%     the means of the subsamples, or of the mean of the differences for a
%     matched-sample design.
%     * The proportion of the means that are positive gives prep.
% 
% This robust approach does not take into account ??2, and so is accurate
% only for exact replications.