function [Y,w,ft,ft2]=imgfilt(X,lf,hf,revfilt,filtorder,phaseshift)
%imgfilt - filters image
% [Y,w,ft,ft2]=imgfilt(X,lf,hf,revfilt,filtorder,phaseshift)
%   X: 
%   lf: lowest frequency in output (default: 0)
%   hf: highest frequency in output (default: infinity)
%       [lf,hf] produces a bandpass filte or a stop-band if revfilter=1
%       
%   revfilt: reverse filter properties
%   filteorder: default 50, see: help fir1
%   phaseshift: 'random' = random permutation of phases
%Requires: Image Processing Toolbox


if nargin==0
    load mandrill
    subplot(2,2,1); imagesc(X)
    subplot(2,2,2); imagesc(imgfilt(X,0,10,0,50));
    subplot(2,2,3); imagesc(imgfilt(X,5,50,1));
    subplot(2,2,4); imagesc(imgfilt(X,0,5,[],[],'random'));
    colormap(gray)
    return    
end
    
X=double(X);    
sx=[size(X) 1];
fnyquist = min(sx(1),sx(2))/2;  
%fnyquist = sx(1)/2;
if nargin<2
    lf=[];
end
if nargin<3
    hf=[];
end
if nargin<4
    revfilt = [];
end
if nargin<5
    filtorder = [];
end
if nargin<6
    phaseshift = [];
end


if isempty(hf) 
    hf=inf;
end
if isempty(lf)    
    lf=0;
end
if isempty(revfilt)
    revfilt = 0;
end
if revfilt
    if lf==0
        lf=hf; 
        hf=0;
        revfilt=0;
    elseif isinf(hf)
        hf=lf; 
        lf=0;
        revfilt=0;
    end
end
if isempty(filtorder)
    filtorder = 50;
end
if ischar(phaseshift)
    switch phaseshift
        case 'random'
        %shouldn't permute the dc component
            phaseshift = [1 randperm(prod(sx(1:2))-1)+1];
    end
end

if ~isempty(phaseshift)
    sp=[size(phaseshift) 1];
    if prod(sp(1:2))==prod(sx(1:2))
       phaseshift = reshape(phaseshift,sx(1:2));
       sp=[size(phaseshift) 1];
    end
    if sp(1)==1
        phaseshift = repmat(phaseshift, [sx(1) 1 1]);
    end
    if sp(2)==1
        phaseshift = repmat(phaseshift, [1 sx(2) 1]);
    end
    if sp(3)==1
        phaseshift = repmat(phaseshift, [1 1 sx(3)]);
    end
end

for ilayer=1:sx(3);
    % Compute Fourier transform
    ft = fft2(X(:,:,ilayer));
    dc=ft(1);
    ft(1)=0;
    % Move quadrants so that low freq are in the middle
    ft = fftshift(ft);
    if isinf(hf) & lf == 0
        % do nothing
        ft2 = ft;
    else
        if isinf(hf) 
            % User asked for a high-pass filter
            w = ftrans2(fir1(filtorder, lf/fnyquist,'high'));
        elseif lf==0 
            % User asked for a low-pass filter
            w = ftrans2(fir1(filtorder, hf/fnyquist));
        else
            % User asked for a band-pass / stop-band filter
            if revfilt
                w = ftrans2(fir1(filtorder, [lf,hf]/fnyquist, 'stop'));
            else
                w = ftrans2(fir1(filtorder, [lf,hf]/fnyquist, 'bandpass'));
            end
        end
        % Compute filter in the frequency space
        w=freqz2(w, size(ft));
        % Apply filter
        ft2 = w .* ft;
    end
    % Restore quadrant positions 
    ft2 = ifftshift(ft2);
    if ~isempty(phaseshift)
        ft2 = abs(ft2) .* exp(i*angle(ft2(phaseshift(:,:,ilayer))));   
    end
    ft2(1) = dc;
    % Inverse FFT 
    Y(:,:,ilayer)=real(ifft2(ft2));
end
if all(X(:)>=0 & X(:)<=1)
    Y=max(min(Y,1),0);
end
return

x=imread('C:\Documents and Settings\ndiayek\My Documents\My Pictures\photos\Karim & Anne Sénégal Hiver 2006-2007\DSC02099.JPG');
x=mean(x,3);
f=fftshift(fft2(x));
g=gausswin2([size(f)],[.2]);


