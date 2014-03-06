function [hp]=imagepval(p,thd)
% imaepval - image p-values
if nargin<2
    thd=0,
end
imagesc(-log(p))
colorbar
colormap([.6 .6 .6 ; jet])
set(gca,'CLim', [-log(thd) max(get(gca,'CLim'))])

