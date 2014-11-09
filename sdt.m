function [dprime,logbeta,c] = sdt(varargin)
%SDT - Signal detection théory computations (d-prime, beta, criterion)
%   [dprime,logb,c] = sdt(s,r) where s and r are two vectors of 0's and 1's
%   OR:       [...] = sdt(SR) where SR is a N-by-2 matrix equals to [s r]
%   Example
%       >> 
%
%   See also: 

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2009 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2009-03-24 Creation
%                   
% ----------------------------- Script History ---------------------------------

if nargin<2 && size(s,2)==2
    r = s(:,2);
    s = s(:,1);
end

s=logical(varargin{1}(:));
r=logical(varargin{2}(:));
%Hit rate:
hr = sum(r(s))/sum(s);
fa = sum(r(~s))/sum(~s);
if hr==1
    hr = 1-1/(2*sum(s));
    warning(sprintf('Hit rate is approximated to: %g%%', 100*hr));
elseif hr==0
    hr = 1/(2*sum(s));
    warning(sprintf('Hit rate is approximated to: %g%%', 100*hr));
end
if fa==0
    fa = 1/(2*sum(~s));
    warning(sprintf('False alarm rate is approximated to: %g%%', 100*fa));
elseif fa==1
    fa = 1-1/(2*sum(~s));
    warning(sprintf('False alarm rate is approximated to: %g%%', 100*fa));
end


% Discrimination index (d') 
dprime = normalz(hr)-normalz(fa);
% Response bias (or criterion) 
c = -(normalz(hr)+normalz(fa))/2; 
% Log-likelihood ratio
logbeta = dprime * c;
return

function z = normalz(p, mu, sigma)
%  NORMALZ Normal z-score
%    >> z = normalz(p, [mu], [sigma])
if nargin < 3, sigma = 1; end
if nargin < 2, mu = 0; end
if nargin < 1, error('Not enough input parameters.'); end
z = mu+sqrt(2)*sigma*erfinv(2*p-1);
