function [RGB]=yuv2rgb(YUV);
% yuv2rgb - Converts YUV colors to RGB coding (CCIR 601)
%    [RGB]=yuv2rgb(YUV)
%See also: rgb2yuv
%See: http://www.commentcamarche.net/video/couleur.php3#YUV
%     http://www.fourcc.org/fccyvrgb.php
% Author: KND.

M= [ ...
    +0.299 +0.587 +0.114 ; ...
    -0.147 -0.289 +0.436 ;...
    +0.615 -0.515 -0.100 ];
RGB=YUV*inv(M)';