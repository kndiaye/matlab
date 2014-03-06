function q = qtukey(rr,cc,df,p,lowt,logp)
% Computes the quantiles of the maximum of rr studentized
% ranges, each based on cc means and with df degrees of freedom
% for the standard error, is less than q.
%
% Uses the secant method to find critical values.
%
% p = confidence level (1 - alpha) 
% rr = no. of rows or groups
% cc = no. of columns or treatments
% df = degrees of freedom of error term
%
% ir(1) = error flag = 1 if wprob probability > 1
% ir(2) = error flag = 1 if ptukey probability > 1
% ir(3) = error flag = 1 if convergence not reached in 50 iterations
% 	       = 2 if df < 2
%
% qtukey = returned critical value
 %
% If the difference between successive iterates is less than eps,
% the search is terminated

 %
% The algorithm is based on that of the reference.
%
% REFERENCE
% Copenhaver, Margaret Diponzio & Holland, Burt S.
% Multiple comparisons of simple effects in
% the two-way analysis of variance with fixed effects.
% Journal of Statistical Computation and Simulation,
% Vol.30, pp.1-15, 1988.

eps = 0.0001;
maxiter = 50;

if (df < 2 || rr < 1 || cc < 2)
    error;
end

% Initial value

x0 = qinv(p, cc, df);

% Find prob(value < x0)

valx0 = ptukey(x0, rr, cc, df, 1, 0) - p;

% Find the second iterate and prob(value < x1).
% If the first iterate has probability value
% exceeding p then second iterate is 1 less than
% first iterate; otherwise it is 1 greater.

if (valx0 > 0.0)
    x1 = fmax2(0.0, x0 - 1.0);
else
    x1 = x0 + 1.0;
end

valx1 = ptukey(x1, rr, cc, df, 1 ,0 ) - p;

% Find new iterate
for iter=1:maxiter
    q = x1 - ((valx1 * (x1 - x0)) / (valx1 - valx0));
    valx0 = valx1;
    % New iterate must be >= 0
    x0 = x1;
    if (q < 0.0)
        q = 0.0;
        valx1 = -p;
    end
    % Find prob(value < new iterate)

    valx1 = ptukey(ans, rr, cc, df, 1, 0) - p;
    x1 = q;

    % If the difference between two successive
    % iterates is less than eps, stop

    xabs = fabs(x1 - x0);
    if (xabs < eps)
        return 
    end
end

% If the difference between two successive
% iterates is less than eps, stop

xabs = fabs(x1 - x0);
if (xabs < eps)
    return
end
error('No convergence')



% qinv() :
% this function finds percentage point of the studentized range
% which is used as initial estimate for the secant method.
% function is adapted from portion of algorithm as 70
% from applied statistics (1974) ,vol. 23, no. 1
% by odeh, r. e. and evans, j. o.
%
%   p = percentage point
%   c = no. of columns or treatments
%   v = degrees of freedom
%   qinv = returned initial estimate
%
% vmax is cutoff above which degrees of freedom
% is treated as infinity.
 
function qi = qinv(p,c,v)
p0 = 0.322232421088;
q0 = 0.993484626060e-01;
p1 = -1.0;
q1 = 0.588581570495;
p2 = -0.342242088547;
q2 = 0.531103462366;
p3 = -0.204231210125;
q3 = 0.103537752850;
p4 = -0.453642210148e-04;
q4 = 0.38560700634e-02;
c1 = 0.8832;
c2 = 0.2368;
c3 = 1.214;
c4 = 1.208;
c5 = 1.4142;
vmax = 120.0;
ps = 0.5 - 0.5 * p;
yi = sqrt (log (1.0 / (ps * ps)));
t = yi + (((( yi * p4 + p3) * yi + p2) * yi + p1) * yi + p0) / (((( yi * q4 + q3) * yi + q2) * yi + q1) * yi + q0);
if (v < vmax)
    t = t + (t * t * t + t) / v / 4.0;
end
q = c1 - c2 * t;
if (v < vmax)
    q = q - c3 / v + c4 * t / v;
end
qi = t * (q * log (c - 1.0) + c5);

