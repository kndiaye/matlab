function [p, d] = kstest2(v1, v2)
%ktest2() - Kolmogorov-Smirnov test of two arrays.
%       KSTEST2(V1, V2) gives the significance level of V1 and V2 being
%       sampled from the same distribution.
%       [PROB, D] = KSTEST2(V1, V2) returns :
%         PROB : the probability of the KS statistics to be greater
%                than observed on V1 and V2,
%         D    : the observed KS statistics.
%       where V1 and V2 are the locations of the samples.
%
%       When PROB is close to 0, the samples are probably from different
%       distributions.
%
%       To test a sample V against a distribution, produce a *big* sample VS
%       from this distribution, and test KTEST(V, VS).
%
%       See also: QKS.

if (nargin ~= 2)
   error('KSTEST: requires 2 samples.') ;
end

[nl1 nc1] = size(v1) ;
if ((nl1 *nc1 <= 0) | (min([nl1 nc1]) ~= 1))
   error('KSTEST: first argument is empty or has wrong dimensions.') ;
end
[nl2 nc2] = size(v2) ;
if ((nl2 *nc2 <= 0) | (min([nl2 nc2]) ~= 1))
   error('KSTEST: second argument is empty or has wrong dimensions.') ;
end

n1 = nl1 * nc1 ;
d1 = reshape(v1, n1, 1) ;
n2 = nl2 * nc2 ;
d2 = reshape(v2, n2, 1) ;
%[d1 d2 ]'
h = zeros(1, n1 + n2) ;

for i=1:n1
   h1(i) = length(find(d1 <= d1(i))) * 1/n1 - length(find(d2 <= d1(i))) * 1/n2 ;
end
for i=1:n2
   h2(i) = length(find(d1 <= d2(i))) * 1/n1 - length(find(d2 <= d2(i))) * 1/n2 ;
end
d = max([abs(h1) abs(h2)]) ;
n = sqrt(n1 * n2 / (n1 + n2)) ;
p = qks((n + 0.12 + 0.11/n) * d) ;
