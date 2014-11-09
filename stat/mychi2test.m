function [P,X2,E]=mychi2test(C)
%   [P]=chi2test(C) tests for the null hypothesis that the observations in
%   the rows of crosstable C are independent


C_rows = sum(C,2);
nr = size(C,1); 
C_cols = sum(C,1);
nc = size(C,2);
if nr==1 || nc ==1
  error('C should be at least 2(groups)-by-2(modalities)');
end

N = sum(C_rows);
% degrees of freedom
dof = (nc-1)*(nr-1);
E = (repmat(C_rows,[1 nc]).*repmat(C_cols,[nr 1]))./repmat(N,[nr,nc]);
X2 = sum(sum(((E-C).^2)./E,1),2);
P = 1-chi2_cdf(X2,dof);
% Chi2 cdf is unusable for low counts:
P( N<50 | any(any(E<5,1),2) ) = NaN;

return


% cook up some sample data
k = 5;
p = rand(1,k); p = p./sum(p);
M = 200; N = 250;
x = randsample(1:k,M,true,p); m = histc(x,1:k);
y = randsample(1:k,N,true,p); n = histc(y,1:k);

% Do the test by hand
phat = (m+n) ./ (M+N);
em = phat*M; en = phat*N;
chi2 = sum(([m n] - [em en]).^2 ./ [em en]);
df = k-1;
pval = 1 - chi2cdf(chi2,df);

% Trick CHI2GOF into doing a two sample test. Note the
% nparams value must be such that 2*k - nparams - 1 = k-1
[~,pval,stats] = chi2gof(1:10,'ctrs',1:10,'freq',[m n], ...
           'expected',[em en],'nparams',k, 'emin',0)

% Use CROSSTAB
[tbl,chi2,pval] = crosstab([x y],[ones(size(x)) 2*ones(size(y))])




