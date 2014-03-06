function [pval, f, df_b, df_w] = anova (y, g)
% ANOVA One-way analysis of variance (ANOVA)
% Performs a one-way analysis of variance (ANOVA).  The goal is to test
% whether the population means of data taken from k different groups
% are all equal.
%
% anova (y, g) provides all data in a single vector y;  g is the vector
% of corresponding group labels (e.g., numbers from 1 to k). This is
% the general form which does not impose any restriction on the number
% of data in each group or the group labels (other than that they must
% be scalars).
%
% anova (y), where y is a matrix, treats each column as a group. This
% form is only appropriate for balanced ANOVA where the numbers of
% samples from each group are all equal.
%
% Under the null of constant means, the statistic f follows an F
% distribution with df_b and df_w degrees of freedom.  pval is the
% p-value (1 minus the CDF of this distribution at f) of the test.
%
% If no output argument is given, the standard one-way ANOVA table is
% printed.


if ((nargin < 1) | (nargin > 2))
    error('USE anova (y [, g])');
    return
elseif (nargin == 1)
    if ndims(y)==1
        error('anova:  for anova (y), y must be a matrix');
        return
    end
    [group_count, k] = size(y);
    n = group_count * k;
    group_mean = mean(y);
else
    if ~isvector(y) % ndims(y) ~= 1
        error('anova:  for anova(y, g), y must be a vector');
    end
    n = length(y);
    if  (~isvector(g) | (length(g) ~= n)) % (ndims(g) ~= 1 | (length(g) ~= n))
        error(['anova:  for anova (y, g), g must be a vector of the same length y']);
    end
    group_label = sort(unique(g));
    
    if (length(group_label) == 1)
        error('anova:  there should be at least 2 groups');
        return
    end
    for i = 1:length(group_label);
        v = y(find(g == group_label(i)));
        group_count(i) = length(v);
        if i>1
            if group_count(i) ~= group_count(i-1) 
                error('anova:  all groups should have the same number of observations');
            end
        end
        group_mean(i) = mean(v);
    end    
end
% moyenne de l'échantillon
total_mean = mean(group_mean);  % OK car tous les grp ont meme nb d'obs 
%total_mean = sum(group_count.*group_mean)/sum(group_count); 

%Variance Expliquée par la partition (inter-groupe)
SSB = sum(group_count .*(group_mean - total_mean) .^ 2);
%VARIANCE TOTALE:
SST = sum((reshape(y, n, 1) - total_mean).^2); 
% Variance résiduelle (intra groupe)
SSW = SST - SSB;
%Deg de lib inter, intra
df_b = k - 1;
df_w = n - k;
%Var inter, intra
v_b = SSB / df_b;
v_w = SSW / df_w;

f = v_b / v_w;

pval = 1 - cdf('f', f, df_b, df_w);

if (nargout == 0)
    %% This eventually needs to be done more cleanly ...
    disp(sprintf('\n'));
    disp(sprintf('One-way ANOVA Table:\n'));
    disp(sprintf('\n'));
    disp(sprintf('Means:'));
    disp(sprintf('Group %d: %3.4f (std:%3.4f)\n', [[1:k]; group_mean; std(y)]));
    disp(sprintf('Difference of group %d with grandmean: %3.4f\n', [[1:k]; mean(group_mean)-group_mean]));
    disp(sprintf('Source of Variation   Sum of Squares    df  Empirical Var\n'));
    disp(sprintf('*********************************************************\n'));
    disp(sprintf('Between Groups       %15.4f  %4d  %13.4f\n', SSB, df_b, v_b));
    disp(sprintf('Within Groups        %15.4f  %4d  %13.4f\n', SSW, df_w, v_w));
    disp(sprintf('---------------------------------------------------------\n'));
    disp(sprintf('Total                %15.4f  %4d\n', SST, n - 1));
    disp(sprintf('\n'));
    disp(sprintf('Test Statistic F(%d,%d)=%15.4f\n', df_b,df_w,f));    
    disp(sprintf('p-value               p=%15.4f\n', pval));
    disp(sprintf('\n'));
end  


