function [xf] = lowpassfilter(x,rf,tdim,df)
% lowpassfilter - easy to use low pass filter (zero phase)
%   [xf]=lowpassfilter(x,rf);
%   [xf]=lowpassfilter(x,rf,tdim);
%   [xf]=lowpassfilter(x,rf,tdim,df);
%   Low-pass filtering of data x below relative frequency: 
%       rf=Fc/FS (default: 0.01)
%   where Fc is the cutting frequency and FS is the sampling rate
%   Filtering is done along dimension tdim (default: the longest dimension)
%   df is the relative width of the attenuation:
%       df=(Fc-Fc2)/FS (default: 0.001)
% ___________________________                      
%                           :\
%                           : \
%                           :  \
%                           :   \
%                           :    \
%                           :     \________ 
%                           :     :      
%                    Fc/FS=rf    (rf+df)=Fc2/FS
%
% A causal fft algorithm is applied (i.e. no phase shift). The filter
% functions is constructed from a Hamming window.

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Based on Mario Chavez's LowPassFilter & EEGLAB eegfiltfft
% Copyright (C) 2006 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2006-04-19 Creation
%                   
% ----------------------------- Script History ---------------------------------

if nargin<2 % Default: ~6Hz/625Hz ~ 100ms sliding window
    rf=.05;
end
if nargin<3 % Default longest dimension
    [ignore,tdim]=max(size(x));
end
if nargin<4 % Default: ~0.5Hz/625Hz
    df=.001;
end

sx=size(x);
px=[tdim setdiff(1:ndims(x), tdim)];
if tdim>1
    x=permute(x,px);
end
%Ensure x has an even number of data point
if rem(sx(tdim),2)
    x = [x ; zeros([1 sx(px(2:end))])];
end

% Construct the filter function H(f) using frequencies in Nyquist units
N = sx(tdim)+rem(sx(tdim),2);
B = fir2(N-1,[0 rf*2 (rf+df)*2 1],[1 1 0 0]); 
H = abs(fft(B));  % Make zero-phase filter function
H=repmat(H',[ 1 sx(px(2:end))] );
k=1;
xf = real(ifft(fft(x) .* H));
xf = ipermute(reshape(xf(1:sx(tdim),:),sx(px)),px);

return

% This is the original function by Mario:

function xf = lowpassFilter(x,Fs,Fp2)
% function XF = lowpassFilter(X,FS,FP2)
%
% Bandpass filter for the signal x. An causal fft algorithm
% is applied (i.e. no phase shift). The filter functions is
% constructed from a Hamming window.
%
% Fs : sampling frequency
%
% The passband (Fp2) and stop band (Fs2) are defined as
%
% ---------------------------                      
%                           |\
%                           | \
%                           |  \
%                           |   \
%                           |    ----------------- 
%                           |    |
%                          Fp2  Fs2 = Fp2 + 0.5 (Hz)              
%
%  
%
% If NO OUTPUTS arguments are assigned the filter function H(f) and
% impulse response are plotted. 
%
% NOTE: for long data traces the filter is very slow.
%
% EXEMPLE 
%    x= sin(2*pi*12*[0:1/200:10])+sin(2*pi*30*[0:1/200:10])
%    y=lowpassFilter(x,200,10);    lowpass filter between 0 and 10 Hz
%------------------------------------------------------------------------
% Originally produced by the Helsinki University of Technology,
% Adapted by Mariecito SCHMUCKEN 2001
%------------------------------------------------------------------------
Fs2 = Fp2 + 0.5;

if size(x,1) == 1
    x = x';
end
% Make x even
Norig = size(x,1);
if rem(Norig,2)
    x = [x' zeros(size(x,2),1)]';
end

% Normalize frequencies  
Ns2 = Fs2/(Fs/2);
Np2 = Fp2/(Fs/2);

% Construct the filter function H(f)
N = size(x,1);
Nh = N/2;

% B = fir2(N-1,[0 Ns1 Np1 Np2 Ns2 1],[0 0 1 1 0 0]); 
B = fir2(N-1,[0 Np2 Ns2 1],[1 1 0 0]); 
H = abs(fft(B));  % Make zero-phase filter function
IPR = real(ifft(H));

% Visual display if off
% if nargout == 0
%     figure,
%     subplot(2,1,1)
%     f = Fs*(0:Nh-1)/(N);
%     plot(f,H(1:Nh));
%     xlim([0 2*Fs2])
%     ylim([0 1]); 
%     title('Filter function H(f)')
%     xlabel('Frequency (Hz)')
%     subplot(2,1,2)
%     plot((1:Nh)/Fs,IPR(1:Nh))
%     xlim([0 2/Fp2])
%     xlabel('Time (sec)')
%     ylim([min(IPR) max(IPR)])
%     title('Impulse response')
% end


if size(x,2) > 1
    for k=1:size(x,2)
        xf(:,k) = real(ifft(fft(x(:,k)) .* H'));
    end
    xf = xf(1:Norig,:);
else
    xf = real(ifft(fft(x') .* H));
    xf = xf(1:Norig);
end
