% [x,v,flag,out,df,d2f] = fminunc (f,x,opt,...) - M*tlab-like optimization
% 
% Imitation of m*tlab's fminunc(). The optional 'opt' argument is a struct,
% e.g. produced by 'optimset()'.
% 
% Supported options
% -----------------
% Diagnostics, [off|on] : Be verbose
% Display    , [off|iter|notify|final]
% : Be verbose unless value is "off"
% GradObj    , [off|on] : Function's 2nd return value is derivatives
% Hessian    , [off|on] : Function's 2nd and 3rd return value are
% derivatives and Hessian.
% TolFun     , scalar   : Termination criterion (see 'ftol' in minimize())
% TolX       , scalar   : Termination criterion (see 'utol' in minimize())
% MaxFunEvals, int      : Max. number of function evaluations
% MaxIter    , int      : Max. number of algorithm iterations
% 
% These non-m*tlab are provided to facilitate porting code to octave:
% -----------------------
% "MinEquiv" , [off|on] : Don't minimize 'fun', but instead return the
% option passed to minimize().
% 
% "Backend"  , [off|on] : Don't minimize 'fun', but instead return
% [backend, opt], the name of the backend
% optimization function that is used and the
% optional arguments that will be passed to it. See
% the 'backend' option of minimize().
% 
% This function is a front-end to minimize().


% Copyright (C) 2008, 2009 VZLU Prague, a.s.
%
% This file is part of Octave.
%
% Octave is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or (at
% your option) any later version.
%
% Octave is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with Octave; see the file COPYING.  If not, see
% <http://www.gnu.org/licenses/>.
%
% Author: Jaroslav Hajek <highegg@gmail.com>

% -*- texinfo -*-
% @deftypefn{Function File} {} fminunc (@var{fcn}, @var{x0}, @var{options})
% @deftypefnx{Function File} {[@var{x}, @var{fvec}, @var{info}, @var{output}, @var{grad}, @var{hess}]} = fminunc (@var{fcn}, @dots{})
% Solve a unconstrained optimization problem defined by the function @var{fcn}.
% @var{fcn} should accepts a vector (array) defining the unknown variables,
% and return the objective function value, optionally with gradient.
% In other words, this function attempts to determine a vector @var{x} such
%
% that @code{@var{fcn} (@var{x})} is a local minimum.
% @var{x0} determines a starting guess.  The shape of @var{x0} is preserved
% in all calls to @var{fcn}, but otherwise it is treated as a column vector.
% @var{options} is a structure specifying additional options.
% Currently, @code{fminunc} recognizes these options:
% @code{'FunValCheck'}, @code{'OutputFcn'}, @code{'TolX'},
% @code{'TolFun'}, @code{'MaxIter'}, @code{'MaxFunEvals'},
% @code{'GradObj'}, @code{'FinDiffType'}.
%
% If @code{'GradObj'} is @code{'on'}, it specifies that @var{fcn},
% called with 2 output arguments, also returns the Jacobian matrix
% of right-hand sides at the requested point.  @code{'TolX'} specifies
% the termination tolerance in the unknown variables, while
% @code{'TolFun'} is a tolerance for equations.  Default is @code{1e-7}
% for both @code{'TolX'} and @code{'TolFun'}.
%
% For description of the other options, see @code{optimset}.
%
% On return, @var{fval} contains the value of the function @var{fcn}
% evaluated at @var{x}, and @var{info} may be one of the following values:
%
% @table @asis
% @item 1
% Converged to a solution point.  Relative gradient error is less than specified
% by TolFun.
% @item 2
% Last relative step size was less that TolX.
% @item 3
% Last relative decrease in func value was less than TolF.
% @item 0
% Iteration limit exceeded.
% @item -3
% The trust region radius became excessively small.
% @end table
%
% Optionally, fminunc can also yield a structure with convergence statistics
% (@var{output}), the output gradient (@var{grad}) and approximate hessian
% (@var{hess}).
%
% Note: If you only have a single nonlinear equation of one variable, using
% @code{fminbnd} is usually a much better idea.
% @seealso{fminbnd, optimset}
% @end deftypefn

% PKG_ADD: all_opts ('fminunc');

function [x, fval, info, output, grad, hess] = fminunc (fcn, x0, options)
if nargin<3
    options = struct ();
end
% Get default options if requested.
if (nargin == 1 && ischar (fcn) && strcmp (fcn, 'defaults'))
    x = optimset ('MaxIter', 400, 'MaxFunEvals', Inf, ...
        'GradObj', 'off', 'TolX', 1.5e-8, 'TolFun', 1.5e-8, ...
        'OutputFcn', [], 'FunValCheck', 'off', ...
        'FinDiffType', 'central');
    return;
end

if (nargin < 2 || nargin > 3 || ~ ismatrix (x0))
    print_usage ();
end

if (ischar (fcn))
    fcn = str2func (fcn, 'global');
end

xsiz = size (x0);
n = numel (x0);

has_grad = strcmpi (optimget (options, 'GradObj', 'off'), 'on');
cdif = strcmpi (optimget (options, 'FinDiffType', 'central'), 'central');
maxiter = optimget (options, 'MaxIter', 400);
maxfev = optimget (options, 'MaxFunEvals', Inf);
outfcn = optimget (options, 'OutputFcn');

funvalchk = strcmpi (optimget (options, 'FunValCheck', 'off'), 'on');

if (funvalchk)
    % Replace fcn with a guarded version.
    fcn = @(x) guarded_eval (fcn, x);
end

% These defaults are rather stringent. I think that normally, user
% prefers accuracy to performance.

macheps = eps (class (x0));

tolx = optimget (options, 'TolX', sqrt (macheps));
tolf = optimget (options, 'TolFun', sqrt (macheps));

factor = 0.1;
% FIXME: TypicalX corresponds to user scaling (???)
autodg = true;

niter = 1;
nfev = 0;

x = x0(:);
info = 0;

% Initial evaluation.
fval = fcn (reshape (x, xsiz));
n = length (x);

if (~isempty (outfcn))
    optimvalues.iter = niter;
    optimvalues.funccount = nfev;
    optimvalues.fval = fval;
    optimvalues.searchdirection = zeros (n, 1);
    state = 'init';
    stop = outfcn (x, optimvalues, state);
    if (stop)
        info = -1;
        break;
    end
end

nsuciter = 0;
lastratio = 0;

grad = [];

% Outer loop.
while (niter < maxiter && nfev < maxfev && ~ info)

    grad0 = grad;

    % Calculate function value and gradient (possibly via FD).
    if (has_grad)
        [fval, grad] = fcn (reshape (x, xsiz));
        grad = grad(:);
        nfev =nfev + 1;
    else
        grad = fdjac (fcn, reshape (x, xsiz), fval, cdif)(:);
        nfev = nfev + (1 + cdif) * length (x);
    end

    if (niter == 1)
        % Initialize by identity matrix.
        hesr = eye (n);
    else
        % Use the damped BFGS formula.
        y = grad - grad0;
        sBs = sumsq (w);
        Bs = hesr'*w;
        sy = y'*s;
        theta = 0.8 / max (1 - sy / sBs, 0.8);
        r = theta * y + (1-theta) * Bs;
        hesr = cholupdate (hesr, r / sqrt (s'*r), '+');
        [hesr, info] = cholupdate (hesr, Bs / sqrt (sBs), '-');
        if (info)
            hesr = eye (n);
        end
    end

    % Second derivatives approximate the hessian.
    d2f = norm (hesr, 'columns').';
    if (niter == 1)
        dg = d2f;
        xn = norm (dg .* x);
        % FIXME: something better?
        delta = factor * max (xn, 1);
    end

    % FIXME: maybe fixed lower and upper bounds?
    dg = max (0.1*dg, d2f);

    % FIXME -- why tolf*n*xn? If abs (e) ~ abs(x) * eps is a vector
    % of perturbations of x, then norm (hesr*e) <= eps*xn, i.e. by
    % tolf ~ eps we demand as much accuracy as we can expect.
    if (norm (grad) <= tolf*n*xn)
        info = 1;
        break;
    end

    suc = false;
    decfac = 0.5;

    % Inner loop.
    while (~ suc && niter <= maxiter && nfev < maxfev && ~ info)

        s = - doglegm (hesr, grad, dg, delta);

        sn = norm (dg .* s);
        if (niter == 1)
            delta = min (delta, sn);
        end

        fval1 = fcn (reshape (x + s, xsiz)) (:);
        nfev =nfev+1;

        if (fval1 < fval)
            % Scaled actual reduction.
            actred =  (fval - fval1) / (abs (fval1) + abs (fval));
        else
            actred = -1;
        end

        w = hesr*s;
        % Scaled predicted reduction, and ratio.
        t = 1/2 * sumsq (w) + grad'*s;
        if (t < 0)
            prered = -t/(abs (fval) + abs (fval + t));
            ratio = actred / prered;
        else
            prered = 0;
            ratio = 0;
        end

        % Update delta.
        if (ratio < min(max(0.1, 0.8*lastratio), 0.9))
            delta *= decfac;
            decfac ^= 1.4142;
            if (delta <= 1e1*macheps*xn)
                % Trust region became uselessly small.
                info = -3;
                break;
            end
        else
            lastratio = ratio;
            decfac = 0.5;
            if (abs (1-ratio) <= 0.1)
                delta = 1.4142*sn;
            elseif (ratio >= 0.5)
                delta = max (delta, 1.4142*sn);
            end
        end

        if (ratio >= 1e-4)
            % Successful iteration.
            x = x+s;
            xn = norm (dg .* x);
            fval = fval1;
            nsuciter =nsuciter +1;
            suc = true;
        end

        niter =niter +1;

        % FIXME: should outputfcn be only called after a successful iteration?
        if (~ isempty (outfcn))
            optimvalues.iter = niter;
            optimvalues.funccount = nfev;
            optimvalues.fval = fval;
            optimvalues.searchdirection = s;
            state = 'iter';
            stop = outfcn (x, optimvalues, state);
            if (stop)
                info = -1;
                break;
            end
        end

        % Tests for termination conditions. A mysterious place, anything
        % can happen if you change something here...

        % The rule of thumb (which I'm not sure M*b is quite following)
        % is that for a tolerance that depends on scaling, only 0 makes
        % sense as a default value. But 0 usually means uselessly long
        % iterations, so we need scaling-independent tolerances wherever
        % possible.

        % The following tests done only after successful step.
        if (ratio >= 1e-4)
            % This one is classic. Note that we use scaled variables again,
            % but compare to scaled step, so nothing bad.
            if (sn <= tolx*xn)
                info = 2;
                % Again a classic one.
            elseif (actred < tolf)
                info = 3;
            end
        end

    end
end

% Restore original shapes.
x = reshape (x, xsiz);

output.iterations = niter;
output.successful = nsuciter;
output.funcCount = nfev;

if (nargout > 5)
    hess = hesr'*hesr;
end

return

% An assistant function that evaluates a function handle and checks for
% bad results.
function [fx, gx] = guarded_eval (fun, x)
if (nargout > 1)
    [fx, gx] = fun (x);
else
    fx = fun (x);
    gx = [];
end

if (~ (isreal (fx) && isreal (jx)))
    error ('fminunc:notreal', 'fminunc: non-real value encountered');
elseif (complexeqn && ~ (isnumeric (fx) && isnumeric(jx)))
    error ('fminunc:notnum', 'fminunc: non-numeric value encountered');
elseif (any (isnan (fx(:))))
    error ('fminunc:isnan', 'fminunc: NaN value encountered');
end
return

%~function f = rosenb (x)
%~  n = length (x);
%~  f = sumsq (1 - x(1:n-1)) + 100 * sumsq (x(2:n) - x(1:n-1).^2);
%~test
%~ [x, fval, info, out] = fminunc (@rosenb, [5, -5]);
%~ tol = 2e-5;
%~ assert (info > 0);
%~ assert (x, ones (1, 2), tol);
%~ assert (fval, 0, tol);
%~test
%~ [x, fval, info, out] = fminunc (@rosenb, zeros (1, 4));
%~ tol = 2e-5;
%~ assert (info > 0);
%~ assert (x, ones (1, 4), tol);
%~ assert (fval, 0, tol);

% Solve the double dogleg trust-region minimization problem:
% Minimize 1/2*norm(r*x)^2  subject to the constraint norm(d.*x) <= delta,
% x being a convex combination of the gauss-newton and scaled gradient.

% TODO: error checks
% TODO: handle singularity, or leave it up to mldivide?

function x = doglegm (r, g, d, delta)
% Get Gauss-Newton direction.
b = r' \ g;
x = r \ b;
xn = norm (d .* x);
if (xn > delta)
    % GN is too big, get scaled gradient.
    s = g ./ d;
    sn = norm (s);
    if (sn > 0)
        % Normalize and rescale.
        s = (s / sn) ./ d;
        % Get the line minimizer in s direction.
        tn = norm (r*s);
        snm = (sn / tn) / tn;
        if (snm < delta)
            % Get the dogleg path minimizer.
            bn = norm (b);
            dxn = delta/xn; snmd = snm/delta;
            t = (bn/sn) * (bn/xn) * snmd;
            t -= dxn * snmd^2 - sqrt ((t-dxn)^2 + (1-dxn^2)*(1-snmd^2));
            alpha = dxn*(1-snmd^2) / t;
        else
            alpha = 0;
        end
    else
        alpha = delta / xn;
        snm = 0;
    end
    % Form the appropriate convex combination.
    x = alpha * x + ((1-alpha) * min (snm, delta)) * s;
end

