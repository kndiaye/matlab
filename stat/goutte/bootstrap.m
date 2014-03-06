function [biais, variance, fboot] = bootstrap(f, X, B, P1, P2, P3)
%BOOTSTRAP Bootstrap estimates of bias and variance.
%
%       [BIAS VAR Fboot] = BOOTSTRAP('f', X, B) gives the following elements
%       calculated by the bootstrap method using B replications:
%         - bias of f(X),
%         - variance of f(X),
%         - corrected f(X).
%       The data in X must be organised in rows (see function CORRCOEF)
%       The bias formula is the standard one (not .632).
%
%       [BIAS VAR Fboot] = BOOTSTRAP('f', X, B, opt1, opt2, opt3) allows to
%       pass up to 3 additional arguments to 'f'.
%
%       BOOTSTRAP needs the AVEVAR function.
%       (c) 1997, C. Goutte. 
% See also: JACKKNIFE.

if (nargin < 3) | (nargin > 6)
  error('BOOTSTRAP: wrong number of arguments.') ;
end

[N P] = size(X) ;
if (N < 2)
  error('BOOTSTRAP: not enough samples.')
end
evalstr = [f, '(X_i'] ;
for i = 1:(nargin - 3)
  evalstr = [evalstr, ',P', int2str(i)] ;
end
evalstr = [evalstr, ')'] ;

f_i = zeros(B,1) ;
X_i = X ;
fhat = eval(evalstr) ;

for i = 1:B
  idx_i = ceil(rand(1,N)*N) ;
%  disp(idx_i)
  X_i = X(idx_i, :) ;
  f_i(i) = eval(evalstr) ;
end
[fboot, variance] = avevar(f_i) ;
biais = (fboot - fhat) ;
fboot = 2 * fhat - fboot ;

% (c) 16/05/97, CG.
