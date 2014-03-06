% This Matlab (version 4) program demonstrates how gif-images can be filtered.
% Two of Matlab's toolboxes are required: 
%       - the Signal Processing Toolbox
%       - the Image Processing Toolbox
% A one-dimensional Finite Impulse Response filter ('fir1') is 
% transformed to a two-dimensional FIR filter using the 'ftrans2' function.
% GIF-image 'original.gif' is filtered and saved as 'lowpass.gif', 
% 'bandpass.gif' and 'highpass.gif'
%
% Author: Paul van Diepen - Matlab Filter Program for Full Color Images
%         Scene Perception Research, October 1992 - April 1999
%         Laboratory for Experimental Psychology
%         University of Leuven, Belgium
% http://psy.van-diepen.com/pvdmatl.html

% FILTER PARAMETERS
f1 = 1;         % lowpass cut-off (cycl/deg)
f2 = 3;         % highpass cut-off (cycl/deg)
fnyquist = 23;  % Nyquist frequency (pixels/deg) (half the sample frequency)
n = 50;         % Filter order

% LOAD ORIGINAL IMAGE
[X, map] = gifread('original.gif');

% SEPARATE Red, Green, AND Blue CHANNELS
[R, G, B] = ind2rgb(X,map);

% TWO-DIMENSIONAL FOURIER TRANSFORM
FFTr = fft2(R);
FFTg = fft2(G);
FFTb = fft2(B);

% STORE DC-COMPONENT (THE AVERAGE COLOUR VALUE)
DCr = FFTr(1,1);
DCg = FFTg(1,1);
DCb = FFTb(1,1);

% REARRANGE QUADRANTS (THE DC-COMPONENT IS MOVED TO THE CENTRE OF THE SPECTRUM)
FFTr = fftshift(FFTr);
FFTg = fftshift(FFTg);
FFTb = fftshift(FFTb);

% LOWPASS FILTER
% RED
lowFFTr = freqz2( ftrans2(fir1(n, f1/fnyquist)), size(FFTr)) .* FFTr;
lowFFTr = rot90(fftshift(rot90(lowFFTr,2)),2);  % restore quadrant positions
lowFFTr(1,1) = DCr;                                             % restore dc-component
lowR = real(ifft2(lowFFTr));                            % inverse Fourier transform
d = find(lowR < 0); lowR(d) = zeros(size(d));           % remove negative intensities
d = find(lowR > 1); lowR(d) = ones(size(d));            % remove intensities above 1

% GREEN
lowFFTg = freqz2( ftrans2(fir1(n, f1/fnyquist)), size(FFTg)) .* FFTg;
lowFFTg = rot90(fftshift(rot90(lowFFTg,2)),2);  % restore quadrant positions
lowFFTg(1,1) = DCg;                                             % restore dc-component
lowG = real(ifft2(lowFFTg));                            % inverse Fourier transform
d = find(lowG < 0); lowG(d) = zeros(size(d));           % remove negative intensities
d = find(lowG > 1); lowG(d) = ones(size(d));            % remove intensities above 1

% BLUE
lowFFTb = freqz2( ftrans2(fir1(n, f1/fnyquist)), size(FFTb)) .* FFTb;
lowFFTb = rot90(fftshift(rot90(lowFFTb,2)),2);  % restore quadrant positions
lowFFTb(1,1) = DCb;                                             % restore dc-component
lowB = real(ifft2(lowFFTb));                            % inverse Fourier transform
d = find(lowB < 0); lowB(d) = zeros(size(d));           % remove negative intensities
d = find(lowB > 1); lowB(d) = ones(size(d));            % remove intensities above 1

% COMBINE COLOURS TO INDEXED IMAGE
[X, map] = rgb2ind(lowR, lowG, lowB, 256);

% STORE IMAGE
gifwrite(X, map, 'lowpass.gif');


% BANDPASS FILTER
% RED
midFFTr = freqz2( ftrans2(fir1(n, [f1,f2]/fnyquist)), size(FFTr)) .* FFTr;
midFFTr = rot90(fftshift(rot90(midFFTr,2)),2);  % restore quadrant positions
midFFTr(1,1) = DCr;                                             % restore dc-component
midR = real(ifft2(midFFTr));                            % inverse Fourier transform
d = find(midR < 0); midR(d) = zeros(size(d));           % remove negative intensities
d = find(midR > 1); midR(d) = ones(size(d));            % remove intensities above 1

% GREEN
midFFTg = freqz2( ftrans2(fir1(n, [f1,f2]/fnyquist)), size(FFTg)) .* FFTg;
midFFTg = rot90(fftshift(rot90(midFFTg,2)),2);  % restore quadrant positions
midFFTg(1,1) = DCg;                                             % restore dc-component
midG = real(ifft2(midFFTg));                            % inverse Fourier transform
d = find(midG < 0); midG(d) = zeros(size(d));           % remove negative intensities
d = find(midG > 1); midG(d) = ones(size(d));            % remove intensities above 1

% BLUE
midFFTb = freqz2( ftrans2(fir1(n, [f1,f2]/fnyquist)), size(FFTb)) .* FFTb;
midFFTb = rot90(fftshift(rot90(midFFTb,2)),2);  % restore quadrant positions
midFFTb(1,1) = DCb;                                             % restore dc-component
midB = real(ifft2(midFFTb));                            % inverse Fourier transform
d = find(midB < 0); midB(d) = zeros(size(d));           % remove negative intensities
d = find(midB > 1); midB(d) = ones(size(d));            % remove intensities above 1

% COMBINE COLOURS TO INDEXED IMAGE
[X, map] = rgb2ind(midR, midG, midB, 256);

% STORE IMAGE
gifwrite(X, map, 'bandpass.gif');

% HIGHPASS FILTER
% RED
highFFTr = freqz2( ftrans2(fir1(n, f2/fnyquist, 'high')), size(FFTr)) .* FFTr;
highFFTr = rot90(fftshift(rot90(highFFTr,2)),2);        % restore quadrant positions
highFFTr(1,1) = DCr;                                    % restore dc-component
highR = real(ifft2(highFFTr));                          % inverse Fourier transform
d = find(highR < 0); highR(d) = zeros(size(d)); % remove negative intensities
d = find(highR > 1); highR(d) = ones(size(d));  % remove intensities above 1

% GREEN
highFFTg = freqz2( ftrans2(fir1(n, f2/fnyquist, 'high')), size(FFTg)) .* FFTg;
highFFTg = rot90(fftshift(rot90(highFFTg,2)),2);        % restore quadrant positions
highFFTg(1,1) = DCg;                                    % restore dc-component
highG = real(ifft2(highFFTg));                          % inverse Fourier transform
d = find(highG < 0); highG(d) = zeros(size(d)); % remove negative intensities
d = find(highG > 1); highG(d) = ones(size(d));  % remove intensities above 1

% BLUE
highFFTb = freqz2( ftrans2(fir1(n, f2/fnyquist, 'high')), size(FFTb)) .* FFTb;
highFFTb = rot90(fftshift(rot90(highFFTb,2)),2);        % restore quadrant positions
highFFTb(1,1) = DCb;                                    % restore dc-component
highB = real(ifft2(highFFTb));                          % inverse Fourier transform
d = find(highB < 0); highB(d) = zeros(size(d)); % remove negative intensities
d = find(highB > 1); highB(d) = ones(size(d));  % remove intensities above 1

% COMBINE COLOURS TO INDEXED IMAGE
[X, map] = rgb2ind(highR, highG, highB, 256);

% STORE IMAGE
gifwrite(X, map, 'highpass.gif');

% (p) 1996, Paul van Diepen, Laboratory of Experimental Psychology, Leuven, Belgium