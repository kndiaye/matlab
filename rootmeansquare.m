function [r]=rootmeansquare(F,dim);
%rootmeansquare() - compute root mean square 
% 
% [rms]=ROOTMEANSQUARE(F);
% F is a [N channels] x [T samples] x [...] field
% rms: will be [1] x [T samples] x [...] computed across sensors 
% taken as the 1st dimension of data F
%
% [rms]=ROOTMEANSQUARE(F,dim) computes rms along dimension 'dim'
%
% Nota: It is sometimes said to be equal to the standard deviation of
% the field. Which is not exactly the case, even when standard deviation is
% computed as the sqrt of the 2nd moment about the mean. 
% See also: STD
%
% Note for EEG data users:
% The RMS is NOT mean-corrected from the field average value at
% each sample as would be the case with the standard. deviation.
% However, scalp data are usually baseline corrected beforehand on
% a channel-by-channel basis. And for source imaging purpose it is
% advisable to use "average reference" (i.e. to remove the mean across
% sensor on a sample by sample basis), also called "reference free"
% voltages.
%
% Ref: 
% Lehmann D, Skrandies W. Reference-free identification of
% components of checkerboard-evoked multichannel potential
% fields. 
% Electroencephalogr Clin Neurophysiol 1980; 48: 609-21.
%
% Bertrand O, Perrin F, Pernier J. A theoretical justification of the
% average reference in topographic evoked potential studies. 
% Electroencephalography and Clinical Neurophysiology, 62, 116–123. 
%
% http://mathworld.wolfram.com/StandardDeviation.html

if nargin<2
    dim=1;
end 
r=sqrt(mean(abs(F).^2,dim));
%size(F,dim)* ?
return

% The following formula is therefroe WRONG:
% r=std(F,1,1);
