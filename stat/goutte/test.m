function [p, s] = test(x1, x2, type)
%TEST statistical test of two samples.
%       TEST(X1, X2, 'test') gives the confidence level for
%       different tests of the two samples X1 and X2.
%
%       'test'   Null hypothesis      Assumption on distributions  Type
%       -----------------------------------------------------------------
%         't'    Means are equal      The variances are equal      t-test
%         'u'    Means are equal      The variances are not equal  t-test
%         'p'    Means are equal      The data are paired          t-test
%         'f'    Variances are equal                               F-test
%        
%       TEST(X1, X2) performs a t-test (for equal variances) by default.
%
%       [P S] = TEST(X1, X2, ['test']) returns the confidence level in P
%       and the value of the statistic (t or F) in S.
%
%       Ref: Press et al. 1992. Numerical recipes in C. 14.2, Cambridge.
%
%See also : TTEST, UTEST, PTEST, FTEST.
if (nargin == 2)
   type = 't' ;
end


if (type == 't')
   [p s] = ttest(x1, x2) ;
elseif (type == 'u')
   [p s] = uttest(x1, x2) ;
elseif (type == 'p')
   [p s] = pttest(x1, x2) ;
elseif (type == 'f')
   [p s] = ftest(x1, x2) ;
end

