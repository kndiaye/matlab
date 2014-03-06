function [p,u] = u_test(X1,X2)
% u_test - Mann-Whitney-Wilcoxon U test

n = [size(X1,1) ; size(X2,1)];
n(3) = n(1)+n(2); % total N
n(4) = n(3)*(n(3)+1)/2; % N(N+1)/2
[smaller smaller] = min(n(1:2)); % smallest sample
larger = 3-smaller;

X = cat(1,X1,X2);
X=X(:,:);
[R] = tiedrank(X,1)

if smaller == 1
    T = sum(X(1:n(1),:));
else
    T = sum(X((n(1)+1):end,:));
end
u=T-n(4);

nflops = exp(gammaln(n(3)+1)-gammaln(n(smaller)+1)-gammaln(n(larger)+1))
if  nflops < 2000
    % exact computation
    z=1:n(3);
    M=combnk(z,n(smaller));
    pdf=sum(z(M),2); 
    %probability density function of the MWW distribution
    %to compute the p-value see how many values are more extreme of the observed
    %T and then divide for the total number of combinations
    p=length(pdf(pdf>=T))/length(pdf);
else
    mu = 
    
    mT=k*N1/2; %mean
    sT=realsqrt(prod(L)/12*(N1-2*B/N/(N^2-1))); %standard deviation
    zT=(abs(T-mT)-0.5)/sT; %z-value with correction for continuity
    %p=1-normcdf(zT); %p-value
    p = 1-(0.5 * erfc(-zT ./ sqrt(2)));
end


return



L=[length(x1) length(x2)]; k=min(L); N=sum(L); N1=N+1; %set the basic parameter

[A,B]=tiedrank([x1(:); x2(:)]); %compute the ranks and the ties
%Compute the Mann-Whitney-Wilcon statistic summing the ranks of the sample with
%the less number of elements.
if L(1)<=L(2)
    T=sum(A(1:k));
else
    T=sum(A(k+1:end));
end

%There is an alternative formulation of this test that yields a statistic
%commonly denoted by U. U is related to T by the formula U=T-k*(k+1)/2,
%where k is the size of the smaller sample (or either sample if both contain
%the same number of individuals). For a presentation of the U statistic, see:
% S. Siegel and N. J. Castellan, Jr., Nonparametric Statistics for the
% Behavioral Sciences, 2d ed. McGraw-Hill, New York, 1988, Section 6.4, â€œThe
% Wilcoxon-Mann-Whitney U Test.â€?
%For a detailed derivation and discussion of the Mann-Whitney test as developed
%here, as well as its relationship to U, see:
% F. Mosteller and R. Rourke, Sturdy Statistics: Nonparametrics and Order
% Statistics, Addison-Wesley, Reading, MA, 1973, Chapter 3, â€œRanking Methods for
% Two Independent Samples.â€?
U=T-k*(k+1)/2;


function c = combnk(v,k)
%COMBNK All combinations of the N elements in V taken K at a time.
%   C = COMBNK(V,K) produces a matrix, with K columns. Each row of C has
%   K of the elements in the vector V. C has N!/K!(N-K)! rows.  K must be
%   a nonnegative integer.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 2.12.2.2 $  $Date: 2004/12/24 20:46:48 $

[m, n] = size(v);

if min(m,n) ~= 1
    error('stats:combnk:VectorRequired','First argument has to be a vector.');
end

if n == 1
    n = m;
    flag = 1;
else
    flag = 0;
end

if n == k
    c = v(:).';
elseif n == k + 1
    tmp = v(:).';
    c   = tmp(ones(n,1),:);
    c(1:n+1:n*n) = [];
    c = reshape(c,n,n-1);
elseif k == 1
    c = v.';
elseif n < 17 && (k > 3 || n-k < 4)
    rows = 2.^(n);
    ncycles = rows;

    for count = 1:n
        settings = (0:1);
        ncycles = ncycles/2;
        nreps = rows./(2*ncycles);
        settings = settings(ones(1,nreps),:);
        settings = settings(:);
        settings = settings(:,ones(1,ncycles));
        x(:,n-count+1) = settings(:);
    end

    idx = x(sum(x,2) == k,:);
    nrows = size(idx,1);
    [rows,ignore] = find(idx');
    c = reshape(v(rows),k,nrows).';
else
    P = [];
    if flag == 1,
        v = v.';
    end
    if k < n && k > 1
        for idx = 1:n-k+1
            Q = combnk(v(idx+1:n),k-1);
            P = [P; [v(ones(size(Q,1),1),idx) Q]];
        end
    end
    c = P;
end
