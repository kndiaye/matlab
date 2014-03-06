function [Zz, Zp, Zg] = cheby1(n, Rp, W, stype)
% Generate an Chebyshev type I filter with Rp dB of pass band ripple.
%
% [b, a] = cheby1(n, Rp, Wc)
%    low pass filter with cutoff pi*Wc radians
%
% [b, a] = cheby1(n, Rp, Wc, 'high')
%    high pass filter with cutoff pi*Wc radians
%
% [b, a] = cheby1(n, Rp, [Wl, Wh])
%    band pass filter with edges pi*Wl and pi*Wh radians
%
% [b, a] = cheby1(n, Rp, [Wl, Wh], 'stop')
%    band reject filter with edges pi*Wl and pi*Wh radians
%
% [z, p, g] = cheby1(...)
%    return filter as zero-pole-gain rather than coefficients of the
%    numerator and denominator polynomials.
%
% References:
%
% Parks & Burrus (1987). Digital Filter Design. New York:
% John Wiley & Sons, Inc.

% Author: pkienzle@cs.indiana.edu

% Copyright (C) 1999 Paul Kienzle
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA



if (nargin>4 || nargin<3) || (nargout>3 || nargout<2)
    disp('[b, a] or [z, p, g] = cheby1 (n, Rp, W, [, ''ftype''])');
end

stop = nargin==4;
if stop && ~(strcmp(stype, 'high') || strcmp(stype, 'stop'))
    error ('cheby1: ftype must be ''high'' or ''stop''');
end

[r, c]=size(W);
if (~(length(W)<=2 && (r==1 || c==1)))
    error('cheby1: frequency must be given as w0 or [w0, w1]');
elseif (~all(W >= 0 & W <= 1))
    error('cheby1: critical frequencies must be in (0, 1)');
elseif (~(length(W)==1 || length(W) == 2))
    error('cheby1: only one filter band allowed');
elseif (length(W)==2 && ~(W(1) < W(2)))
    error('cheby1: first band edge must be smaller than second');
end

if (Rp < 0)
    error('cheby1: passband ripple must be positive decibels');
end

% Prewarp to the band edges to s plane
T = 2;       % sampling frequency of 2 Hz
Ws = 2/T*tan(pi*W/T);

% Generate splane poles and zeros for the chebyshev type 1 filter
C = 1; % default cutoff frequency
epsilon = sqrt(10^(Rp/10) - 1);
beta = ((sqrt(1+epsilon^2)+1)/epsilon)^(1/n);
r = C*(beta^2-1)/(2*beta);
R = C*(beta^2+1)/(2*beta);
Sz = [];
Sp = exp(1i*pi*(2*[1:n] + n - 1)/(2*n));
Sp = r*real(Sp) + 1i*R*imag(Sp);

% compensate for amplitude at s=0
Sg = prod(-Sp);
% if n is even, the ripple starts low, but if n is odd the ripple
% starts high. We must adjust the s=0 amplitude to compensate.
if (rem(n,2)==0)
    Sg = Sg/10^(Rp/20);
end

% splane frequency transform
[Sz, Sp, Sg] = sftrans(Sz, Sp, Sg, Ws, stop);

% Use bilinear transform to convert poles to the z plane
[Zz, Zp, Zg] = bilinear(Sz, Sp, Sg, T);

if nargout==2, [Zz, Zp] = zp2tf(Zz, Zp, Zg); end

end