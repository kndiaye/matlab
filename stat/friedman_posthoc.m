function [p]=friedman_posthoc 



% /*
% * Post-hoc analyses for a Friedman test of mean ranks in dependent samples
% * 	    see Schaich & Hamerle (1984) and  Conover (1971, 1980) as cited by Bortz, Lienert & Boehnke (2000, p. 275)
% *
% * Author:
% * Timo Gnambs <timo@gnambs.at>
% * URL: http://timo.gnambs.at
% * Last modified: 2004-06-04
% *
% *
% * Literature:
% *    > Bortz, J., Lienert, G. & Boehnke, K. (2000). Verteilungsfreie Methoden in der Biostatistik. Berlin: Springer.
% *    > Schaich, E. & Hamerle, A. (1984). Verteilungsfreie statistische Prüfverfahren. Berlin: Springer.
% *    > Conover, W. J. (1971,1980). Practical nonparametric statistics. New York: Wiley.
% *
% * Instruction:
% * Modify the two passages titled "Configuration 1" and "Configuration 
% */.
% 
% 
% temporary.
% select if($casenum = 1).
% 
% 
% /* START Configuration 1 */
% * Load demo file.
% get file = spss_friedmanph.sav.
% * Significance level.
% compute #alpha = 0.05.
% * Number of variables to compare.
% compute #varcnt = 4.
% * Sample size.
% compute #sample = 5.
% 
% * Maximum number of allowed loops.
% * This value must be greater than the sample size (#sample), else SPSS produces errors.
% set mxloop = 500.
% 
% /* END Configuration 1 */
% 
% 
% compute #chisq = idf.chisq((1 - #alpha), (#varcnt - 1)).
% compute #t = abs(idf.t(#alpha / 2, (#sample - 1) * (#varcnt - 1))).
% write outfile = friedmanposthoctmp / #chisq #t.
% exe.
% 
% matrix.
% 
% /* Load data to matrix */
% read sig /file=friedmanposthoctmp /field = 1 to 16 /size = {1,2}.
% 
% 
% /* START Configuration 2 */
% 
% * Load variables to compare.
% get m /file=* /variables var1 var2 var3 var4.
% 
% /* END Configuration 2 */
% 
% 
% /* Ranked data */
% compute #rnked = m.
% loop #i = 1 to nrow(m) by 1.
% compute #tmp = rnkorder(m(#i,:)).
% compute #rnked(#i,:) = #tmp.
% end loop.
% 
% /* Sum of ranks */
% compute #sums = csum(#rnked).
% compute msums = #sums / nrow(m).
% 
% /* Rank differences */
% compute mdiff = ident(ncol(m),ncol(m)).
% loop #j = 1 to (ncol(m)) by 1.
% loop #k = 1 to #j by 1.
% compute mdiff(#j,#k) = msums(#j) - msums(#k).
% compute mdiff(#k,#j) = -mdiff(#j,#k).
% end loop.
% end loop.
% 
% /* Critical rank difference */
% compute cdiff = sqrt(sig(1,1)) * sqrt((ncol(m) * (ncol(m) + 1)) / (nrow(m) * 6)).
% compute cdiff2 = sig(1,2) * sqrt((2 * (mssq(#rnked) - mssq( #sums) / nrow(m))) / (nrow(m) * (nrow(m) - 1) * (ncol(m) - 1))).
% 
% /* Print results */
% print /title 'Post-hoc analyses for Friedman test'.
% print /title 'Author: Timo Gnambs <timo@gnambs.at>'.
% print /title '----------------------'.
% print ncol(m) /format = f8.0 /title 'Number of variables:'.
% print nrow(m) /format = f8.0 /title 'Sample size:'.
% print msums /format = f8.2 /title 'Mean rank of variables:' /cnames m.
% print mdiff /format f8.2 /title 'Mean rank difference of variables:'.
% print cdiff /format f8.2 /title 'Critical rank difference (Schaich & Hamerle, 1984):'.
% print cdiff2 /format f8.2 /title 'Critical rank difference (Conover, 1971, 1980):'.
% print /title '----------------------'.
% 
% end matrix.
% exe.
% 
% /* Delete temporary file */
% erase file = friedmanposthoctmp.
% exe.