function  [Y] = renormalize(X,method,varargin)
error('Deprecated: see trim.m instead');

%RENORMALIZE - Renormalize data from its outliers
%   [Y] = renormalize(X,method,p)
%   Renormalize data from its outliers
%INPUTS:
%   X: data matrix (considered column-wise)
%   method,p: Specify method used and the parameters
%       -> 'quantile'/'q': replace values above the p-th quantiel by the p-th
%                          quantile(in the absolute values of X)
%   
%   Example
%       >> hist(renormalize(randn(10000,2),'quantile', .95))
%          % shows that the extreme 5% of a normal distribution get
%          % renormalized to ~2 
%
%   See also: quantile

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2006 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2006-02-09 Creation
%                   
% ----------------------------- Script History ---------------------------------

sX=size(X);
if prod(sX)==max(sX)
    X=X(:);
else
    X=X(:,:);
end
switch method
    case {'quantile', 'q'}
        Y=quantile(abs(X),varargin{1});
        Y=repmat(Y, size(X,1),1);        
        Y=X.*(abs(X)<Y)+sign(X).*Y.*(abs(X)>=Y);
end
Y=reshape(Y,sX);