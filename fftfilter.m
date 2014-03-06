function [xf] = fftfilter(x,Fc,SR,tdim,df)
% fftfilter - Filter signal (using FFT transform)
%   [xf]=fftfilter(x,Fc,SR)
%       Fc =[ HPFc LPFc ] are high- and low-pass cutoff frequencies 
%       SR: Sampling rate
%       Set one Fc to NaN to use one-sided filter. For a notch (band-stop)
%       filter use one single value.
%
%   [xf]=fftfilter(x,Fc,SR,tdim)
%       Filtering is done along dimension tdim (default: the longest
%       dimension)
%
% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Based on EEGLAB eegfiltfft() & Matlab's fftfilt
% Copyright (C) 2011
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2011-06-09 Creation
%
% ----------------------------- Script History ---------------------------------


% A causal fft algorithm is applied (i.e. no phase shift). The filter
% functions is constructed from a Hamming window.
notch=0;
if nargin<3 
    error
end
if numel(Fc)==1
    notch = 1;
    Fc(2)=Fc(1);
end
sx=size(x);
if nargin<4 % Default longest dimension
    [ignore,tdim]=max(sx);
end

%Ensure x has an even number of data point
if rem(sx(tdim),2)
    sx0 = sx;
    sX0(tdim) = 1;
    x = cat(tdim, x, zeros(sx0));
end

nyq = sx(tdim)/2;

f = [0:nyq-1 nyq:-1:1]./sx(tdim)*SR; % Frequency vector for plotting

% find closest freq in fft decomposition
if ~isnan(Fc(1)) && Fc(1) ~= 0
    [tmp idxl]=min(abs(f-Fc(1)));
else
    idxl = 0;
end;
if ~isnan(Fc(2)) && Fc(2) ~= 0
    [tmp idxh]=min(abs(f-Fc(2)));
else
    %idxh = ceil(length(fv)/2);
    idxh = nyq;
end;

% filter the data
xf=fft(x,[],tdim);
if notch
    xf(idxl+1:idxh-1)=0;
    if mod(length(xf),2) == 0
        xf(end/2:end)=0;
    else
        xf((end+1)/2:end)=0;
    end;
else
    xf(1:idxl)=0;
    xf(end-idxl:end)=0;
    xf(idxh:end)=0;
end;
xf = 2*real(ifft(xf));

return



% Construct the filter function H(f) using frequencies in Nyquist units
N = sx(tdim)+rem(sx(tdim),2);
B = fir2(N-1,[0 rf*2 (rf+df)*2 1],[1 1 0 0]);
H = abs(fft(B));  % Make zero-phase filter function
H=repmat(H',[ 1 sx(px(2:end))] );
k=1;
xf = real(ifft(fft(x) .* H));
xf = ipermute(reshape(xf(1:sx(tdim),:),sx(px)),px);


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
