function [y]=nd2array(x,dim,sx)
% nd2array - Reshape & permute N-dimensional data to (2 dimensional) array
%
% [y]=nd2array(x,dim [,sx])
% Permutes dimensions so that dim will be the first dimension (i.e. rows)
% of the to-be-created 2-d array. 
%INPUTS:
%   X:   a N-dimensional matrix
%   dim: dimension(s) to be put as rows. Default is to use the  first non
%        singleton dimension. dim can be a vector [dim1 ... dimN], in that
%        case, all these dimensions will be append to form the 1st
%        dimension of the output Y. 
%   sx:  if set to [], the shape of remaining dimensions in the output will
%        be preserved (i.e., equivalent to a permute)
%
% To return back to original shape, use negative dim: 
%   nd2array(y,-dim,size(x));
% If dim is a scalar or if size(y,1)==1, size(x,dim) will be ignored, 
% otherwise you must have: prod(size(x,dim)) == size(y,1)

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2009 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2009-04-16 Updated help
%                   
% ----------------------------- Script History ---------------------------------


if nargin<2
    dim = min(find(size(x)>1));
    if isempty(dim), dim = 1; end
end
if dim==0
    error('Dimension can''t be 0')
end
if all(dim>0)
    reshape2d=1;
    if nargin>2 && isempty(sx)
        reshape2d=0;
    end
    odim=setdiff(1:max(ndims(x),dim),dim);
    pd=[dim, odim];
    sx=[size(x) pd.*0+1];
    x=permute(x,pd);
    if reshape2d
        s2=[prod(sx(dim)) prod(sx(odim))];
    else
        s2=[prod(sx(dim)) sx(odim)];
    end
    y=reshape(x,s2);
elseif all(dim<0)
    if nargin<3
        error('Size of the original array is needed!')
    end
    dim=-dim;
    ndim=length(sx);
    if length(dim)==1 || size(x,1)==1
        sx(dim)=size(x,1);
    end
    odim=setdiff(1:ndim,dim);
    y=reshape(x,[sx(dim) sx(odim)]);
    y=ipermute(y,[dim odim]);
else
    error('You can''t mix positive and negative dim!')
end

