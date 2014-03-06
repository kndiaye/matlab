function  [prep prep2]= p_rep(p,tails)
%P_REP - Probability of re
%   [prep prep2] = p_rep(p,tails)
%   Computes prep, the probabilityy of replication according to Killeen
%   prep2 is the approximation
%   Example
%       >> p_rep(ttest(
%
%   References: Peter Killeen (2005) An alternative to null-hypothesis
%   significance tests. Psychological Science, 16, 345-353.

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2007 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2007-10-28 Creation
%                   
% ----------------------------- Script History ---------------------------------
if nargin==0
    p = (-4.5:.05:-.5);    
    % p = 10.^(p-.5).*(mod(2*p,2))+10.^(p+log10(.5)).*(1-mod(2*p,2));
    p = 10.^(p-.5);
    plot(p,p_rep(p), 'LineWidth', 2, 'marker', 'none')
    set(gca, 'XScale', 'log')
    set(gca, 'Ygrid', 'on')
    set(gca, 'XTick', [.0001 .001 .01 .1])
    set(gca, 'XTickLabel', get(gca, 'XTick'))
    set(gca, 'Xgrid', 'on')
    set(gca, 'XMinorGrid', 'off')
    xlabel('p value')
    ylabel('p_{rep}')
    title('$\displaystyle p_{rep} = \left(1+\left(\frac{p}{1-p}\right)^{\frac{2}{3}}\right)^{-1}$','interpreter','latex')
    axis square
    set([gca get(gca, 'Title') get(gca, 'Xlabel') get(gca, 'Ylabel')], 'FontSize', 16)
end

if nargin<2
    tails=1;
end
if not(isequal(tails, 1) || isequal(tails, 2))
    error('Tails should be 1 or 2')
end
p=p./tails;
prep=normcdf(norminv(1-(p))./2.^.5);
prep2=1./(1+(p./(1-p)).^(2/3));
return


function p = normcdf(z)
p = 0.5 * erfc(-z ./ sqrt(2));
