function [L,RGB2L] = rgb2luminance(RGB,RGB2L)
%RGB2LUMINANCE - Computes luminance value of RGB color
%   [L] = rgb2luminance(RGB,RGB2L) where RGB is a M-by-N-by-3 or N-by-3 matrix
%   RGB2L is a 1-by-3 vector (default: [.3 .59 .11], 
%   Example
%       >> rgb2luminance
%
%   See also: rgb2yccr ; http://www.scantips.com/lumin.html

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2008 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2008-09-10 Creation
%                   
% ----------------------------- Script History ---------------------------------
if nargin<2
    RGB2L = [.30 .59 .11 ];
end
if numel(RGB2L)~=3
    error('You must provide a 3-element vector for RGB to luminance compuation');
end
RGB2L=RGB2L(:);
s=size(RGB);
if size(RGB,3)==3
    RGB=permute(RGB,[3,1,2]);
    RGB=RGB(:,:)';
    s=[s(1) s(2)];        
else
    s=[s(1) 1];
end
L = double(RGB)*RGB2L;
L = reshape(L,s);

