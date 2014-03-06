function [y,b]=quantile(X,u,dim,mode)
% quantile - Quantile of a vector
%   [y] = quantile(X,u)
%       With 0 <= u <= 1 : Find the value(s) 'y' so that:
%           u = [ The proportion of values in X <= y ]
%       If X is a matrix, the quantile will be taken along the 1st dimension
%       If u is a matrix, outputs numel(u) values
%
%   [y] = quantile(X,u,dim) along dimension dim
%   [y,b]=quantile(X,u) also outputs a logical array of those values below
%   the quantile.
%
%   Examples
%       >> quantile(X,0.5) outputs the median
%       >> quantile(X,0.95) outputs the level of the highest 5%
%

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2006
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2006-01-05 Creation
% KND  2008-10-13 NxMxPx... matrix outputs a 1xMxPx... matrix
% KND  2009-03-05 Accepts list vector in u
% ----------------------------- Script History ---------------------------------
u=u(:);
if nargin<2
    error('Threshold needed!')
end
sX=size(X);
if nargin<3
    if prod(sX)==max(sX)
        X=X(:);
    else
        error('Choose a dimension on which to compute quantiles');
    end
else
    pX=[dim setdiff(1:ndims(X),dim)];
    X=permute(X,pX);
end
[X,i]=sort(X);
q1 = min(floor(u*sX(1)+1),sX(1));
q2 = max(ceil(u*sX(1)),1);
y1 = X(q1,:);
y2 = X(q1,:);
y =(y1+y2)/2;
if prod(sX)~=max(sX) % X wasn't a vector
    nu = numel(u);
    %if nu>1
    % y is made into a P-row matrix (1-by-N-by-...)    
    sX(dim)=1;
    y=reshape(y, [nu sX 1]);
    %else
    %    y=reshape(y, [sX(2:end) 1]);
    %end
end
if nargout > 1
    b = i < round((q1+q2)/2);
    if prod(sX)~=max(sX) % X wasn't a vector
        nu = numel(u);
        if nu>1
            b=reshape(b, [nu sX(2:end) 1]);
        else
            b=reshape(b, [sX(2:end) 1]);
        end
    end
    b=permute(b,[2:ndims(b) 1]);
end