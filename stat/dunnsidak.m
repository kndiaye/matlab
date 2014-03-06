function [sig,alpha]=dunnsidak(alpha, n)
% DUNNSIDAK - Dunn-Sidak adjustment of alpha level for multiple comparisons
%   alpha2=dunnsidak(alpha1, n) computes the new alpha2 to use when running
%   n tests in order to achieve a familywise error rate of alpha
%    alpha = 1 - (1-alpha1).^(1./n)
%
%   [sig,alphas]=holm(alpha,p) assess the significance of the p-values
%   coming from multiple tests according to the Dunn-Sidak correction
%   yielding a familywise error rate of alpha. p being a vector of
%   p-values, sig will be a logical vector of the same size.
%
% See also: holm, hochberg

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2007 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2007-11-05 Creation
%                   
% ----------------------------- Script History ---------------------------------

if numel(n)==1 & n>=1
    alpha=1-(1-alpha).^(1./n);
    sig=alpha;
    return
end
p=n;
n=numel(p);
alpha=dunnsidak(alpha,n);
sig=p<=alpha;