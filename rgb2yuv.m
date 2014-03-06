function [YUV]=rgb2yuv(RGB);
% rgb2yuv - Converts RGB colors to YUV coding (CCIR 601)
%    [YUV]=rgb2yuv(RGB)
%
%See: http://www.commentcamarche.net/video/couleur.php3#YUV
%     http://www.fourcc.org/fccyvrgb.php
% Author: KND.

M= [ ...
    +0.299 +0.587 +0.114 ; ...
    -0.147 -0.289 +0.436 ;...
    +0.615 -0.515 -0.100 ];
YUV=RGB*M';
