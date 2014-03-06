function [d,h,sigma_d,r2]=cohen_d(X1,X2,variant,parameters)
% cohen_d() - Computes Cohen's d' effect size and variants
% [d]=cohen_d(X1,X2)
% [d]=cohen_d(X1,X2,variant) with 'variant' being:
%       'none' (default)
%       'winsor'
% [d,h]=cohen_d(...) also compute Hedge's corrected d
% [d,h,sigma_d]=cohen_d(...) outputs sigma_d the S.D. of d so that 
%               Conf. Interval for d = d +/- 1.96*sigma_d
%
% [d,h,sigma_d,r2]=cohen_d(...) outputs r2 the percent variance explained

if nargin<3
    options =[];
end

m2=0;
n2=0;
v2=0;
if nargin>1
    if isvector(X1) & isvector(X2)
        X2=X2(:);
        X1=X1(:);
    end
    m2=mean(X2);
    n2=size(X2,1);
    v2=var(X2);
elseif isvector(X1)
    X1=X(:);
end

if nargin>2
    switch lower(variant)
    case 'none'
    case {'winsor', 'winsorized', 'trimmed'}
        
end
end

m1=mean(X1);
n1=size(X1,1);
v1=var(X1);

n = n1+n2;
pooled_v = ((n1-1)*v1 + (n2-1)*v2)./(n-2);

d = (m1 - m2)./sqrt(pooled_v);

% Hedges and Olkin's correction for small samples
% Hedges, L. and Olkin, I. (1985) 
% Statistical Methods for Meta-Analysis.
% New York: Academic Press.
h = d*(1-3/(4*n-9));
sigma_d = sqrt(n/n1/n2 + d.^2/2/n);
r2 = d.^2./(d.^2+4);
