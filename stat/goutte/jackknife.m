function [biais, variance, fjack] = jackknife(f, X, P1, P2, P3)
%JACKKNIFE Jackknife estimates of bias and variance.
%
%       [BIAS VAR Fjack] = JACKKNIFE('f', X) gives the following elements
%       calculated by the jackknife method:
%         - bias of f(X),
%         - variance of f(X),
%         - corrected f(X).
%       The data in X must be organised in rows (see function CORRCOEF)
%
%       [BIAS VAR Fjack] = JACKKNIFE('f', X, opt1, opt2, opt3) allows to
%       pass up to 3 additional arguments to 'f'.
%
%       JACKKNIFE needs the AVEVAR function.
%       (c) 1997, C. Goutte. 
% See also: BOOTSTRAP.

if (nargin < 2) | (nargin > 5)
  error('JACKKNIFE: wrong number of arguments.') ;
end

[N P] = size(X) ;
if (N < 2)
  error('JACKNIFE: not enough samples.')
end
evalstr = [f, '(X_i'] ;
for i = 1:(nargin - 2)
  evalstr = [evalstr, ',P', int2str(i)] ;
end
evalstr = [evalstr, ')'] ;

f_i = zeros(N,1) ;
X_i = X ;
fhat = eval(evalstr) ;

for i = 1:N
  idx_i = [1:(i-1), (i+1):N] ;
  X_i = X(idx_i, :) ;
  f_i(i) = eval(evalstr) ;
end
[fbar, variance] = avevar(f_i) ;
variance = (N - 1) * (N - 1) * variance / N ;
biais = (N - 1) * (fbar - fhat) ;
fjack = N * fhat - (N - 1) * fbar ;

% (c) 16/05/97, CG.