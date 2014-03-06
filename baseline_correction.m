function [F]=baseline_correction(F,dc_offsetb,dc_offsete,Time,TimeDim)
%baseline_correction - DC offset, etc.
% [F]=baseline_correction(F,dc_offset_begin,dc_offset_end, TimeVector,TimeDim)
% 
% TimeDim designate the dimension on which to perform the baseline
% correction. 
% NB: if TimeDim=2 (or unset), F is assumed to be N channel x T samples x...
% (BrainStorm convention) 


if nargin<5
    TimeDim=2;
end
F=permute(F, [TimeDim 1:TimeDim-1 TimeDim+1:ndims(F)]);
sF=size(F);
if nargin<4
  Time=1:sF(1);
end

if dc_offsetb < Time(1)
  fprintf(2,['WARNING: Time parameter inferior to first valid' ...
	     ' latency (%f), setting it to %f\n'], dc_offsetb, Time(1))
end

if dc_offsete > Time(end)  
  fprintf(2,'WARNING: Time parameter superior to the last valid latency (%f), setting it to %f', dc_offsete, Time(end));
end
dc_offsetb=findclosest(dc_offsetb, Time);
dc_offsete=findclosest(dc_offsete, Time);

mF=repmat(mean(F(dc_offsetb:dc_offsete,:),1), [sF(1), 1]);
F=F-reshape(mF,sF);
F=ipermute(F, [TimeDim 1:TimeDim-1 TimeDim+1:ndims(F)]);