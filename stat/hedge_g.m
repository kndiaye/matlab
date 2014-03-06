function [g_star,g,v_star]=hedge_g(X1,X2)
% Computes effect size g, as suggested by Larry Hedges in 1981.
% [g_star,g]=functionhedge_g(X1,X2)
%

X1=X1(:);
X2=X2(:);

m1=mean(X1);
m2=mean(X2);

n1=size(X1,1);
n2=size(X2,1);

v1=var(X1);
v2=var(X2);

%s Hedge's pooled variance
% note the -2 in the denominator
a=n1+n2-2;
v_star = ((n1-1)*v1 + (n2-1)*v2)/a;

g = (m1 - m2)/sqrt(v_star);

if 0
    J = gamma(a/2)/(sqrt(a/2)*gamma((a-1)/2));
else
    % approximate
    J = 1 - 3/(a-1);   
end

g_star=J*g;
