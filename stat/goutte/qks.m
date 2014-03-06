function P = qks(M, tol)
%QKS    Kolmogorov-Smirnov probability.
%       QKS(x) computes the function that enters into the calculation
%       of the significance level in a Kolmogorov-Smirnov test.
%                      +oo
%                     .-- [    k-1         2  2  ]
%          Q  (x) = 2  >  [ (-1)   exp(-2.x .k ) ]
%           KS        '-- [                      ]
%                      k=1
%       Ref.: Numerical Recipes, 2nd ed. pp.623-628
%       QKS(M) calculates QKS(x) for each x in M.
%       QKS(M, TOL) uses TOL as the precision required for the convergence.
%       The default value is MATLAB's eps (1e-8).
%
%       See also: KSTEST, QKS2.
if (nargin < 1 | nargin > 2)
   error('QKS: requires one or two arguments.') ;
end

if (nargin == 1)
   tol = eps ;
else
   if (tol <= 0)
      error('QKS: precision must be strictly positive.') ;
   end
end

[nl, nc] = size(M) ;
if ((nl * nc) <= 0)
   error('QKS: first argument is empty or has wrong dimensions.') ;
end

n = nl * nc ;
X = reshape(M, n, 1) ;
P = ones(n, 1) ;

for i = find(X ~= 0)'
   coeff = 2 ;
   alpha = -2 * X(i, 1) * X(i, 1) ;
   sss   = 0 ;
   k     = 1 ;
   ui    = coeff * exp(alpha) ;
   while (( abs(ui) > tol * sss ) & ( k < 100 ))
      sss = sss + ui ;
      k = k + 1 ;
      coeff = - coeff ;
      ui = coeff * exp(alpha * k * k) ;
   end
   if (k == 100)
% Ca n'a pas converge
      P(i,1) = 1 ;
   else
% Ca a converge : on arrondit a epsilon pres.
      P(i,1) = round((sss + ui) / tol) * tol ;
   end
end

P = reshape(P, nl, nc) ;
