function V = cov2(X,varargin)
%COV2 - Multidimensional Covariance
%   [V] = cov2(X)
%   Computes the M-by-M-by-[...] covariance matrix of data X, which are
%   given as N-by-M-by-[...] matrix , N observations and M variables.
%   Example
%       >> V=cov2(X(:,:,:))
%
%   See also: 

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2006 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2006-02-14 Creation
%                   
% ----------------------------- Script History ---------------------------------

sX=[size(X) 1];
X=reshape(X,sX(1),sX(2),prod(sX(3:end)));
V=zeros(sX(2), sX(2), prod(sX(3:end)));
for i=1:size(X,3);
    V(:,:,i)=cov(X(:,:,i),varargin{:});
end