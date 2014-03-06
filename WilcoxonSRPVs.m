function [T,pvl,pvr,pvz,R,supp,cdf] = WilcoxonSRPVs(Z,Y);
% [T,pvl,pvr,pvzR,supp,cdf] = WilcoxonSRPVs(Z)
% computes for a data vector Z Wilcoxon's signed-rank
% test statistic
%    T  =  sum_{i=1}^n sign(Z(i)) R(i) ,
% where R(i) denotes the rank of |Z(i)| among the non-zero 
% components of (|Z(1)|, |Z(2)|, |Z(3)|, ..., |Z(n)|).
% 
% In case of Z(i) = 0 we set R(i) = 0, i.e. components equal
% to zero are ignored.
% 
% In case of ties among the absolute values of Z's components,
% we use the usual convention of mean ranks.
%
% In case of two input arguments, say X and Y, the program
% WilcoxonSRPVs(X,Y) works with Z := X - Y.
%
% In addition we compute left-, right- and two-sided P-values
%    pvl  =  Pr(T_o <= T) ,
%    pvr  =  Pr(T_o >= T) ,
%    pvz  =  2 * min(pvl, pvr) .
% Here T_o = sum_{i=1}^n S(i)*R(i) with independent random signs
% S(1), S(2), ..., S(n), while R is viewed temporarily as a fixed
% vector.
% 
% Additional output arguments are
% - supp : a vector containing all support points of the
%          distribution function F(.) := Pr(T_o <= .),
% - cdf : a vector containing the numbers cdf(i) = F(supp(i)).
% 
% Lutz Duembgen, March 26, 2003

if nargin == 2
	Z = Z - Y;
end
 
R = abs(Z);
S = sign(Z);
JJ = find(R > 0);
R(JJ) = LocalRanks(R(JJ));
T = sum(sign(Z).*R);

N = length(JJ);
R2 = ceil(2*sort(R(JJ)));
h2 = N*(N+1);
h1 = ceil(h2/2);
% Now we work temporarily with the test statistic
%    T2  =  T + N(N+1)/2
%        =  sum_{i=1}^N 1{Z(i) > 0} 2R(i)
% taking values in {0,1,...,N(N+1)}:
cdf = ones(1,h2+1);
m = 1;
for i=1:N
	m_new = m+R2(i);
	cdf(R2(i)+1:m_new) = (cdf(1:m) + cdf(R2(i)+1:m_new))/2;
	cdf(1:R2(i)) = cdf(1:R2(i))/2;
	m = m_new;
end

if nargout >= 6
	supp = [0:h2] - h1;
end

ind = h1 + T + 1;
pvl = cdf(ind);
if ind >= 2
	pvr = 1 - cdf(ind-1);
else
	pvr = 1;
end
pvz = 2*min(pvl,pvr);

if nargout==0
	fprintf(1,'Test statistic : %5.1f\n', T)
	fprintf(1,'(standardized : %6.3f)\n', T/norm(R))
	fprintf(1,'Left-sided P-value  : %6.4f\n', pvl)
	fprintf(1,'Right-sided P-Value : %6.4f\n', pvr)
	fprintf(1,'Two-sided P-Value   : %6.4f\n', pvz)
end
return


function rv = LocalRanks(x);
% rv = LocalRanks(x)
% computes the vector rv of ranks of x with the usual 
% convention of averaging ranks in case of ties.
% 
% Lutz Duembgen, 23.02.1999

n = length(x);
rv = zeros(size(x));

[hv,ar] = sort(x);

a = 1;
for b=2:n
   if hv(b) > hv(a)
      hv(a:b-1) = (a+b-1)/2;
      a = b;
   end;
end;
hv(a:n) = (a+n)/2;
rv(ar) = hv;
return
