function  [Y] = trim(X,method,varargin)
%trim() - Trim data from its outliers (values are discarded)
%   [Y] = trim(X,p) trims p% at both tails of the data
%   [Y] = trim(X,[p1 p2]) trims p1% of the lower and p2% at the upper tail
%   [Y] = trim(X,method) trims data from their outliers using various
%   methods:
%
%INPUTS:
%   X: data matrix (considered column-wise)
%   p or [p1 p2]: scalars specify the percentages of data to trim. 
%                 If p/p1/p2 are >= 1, trims an exact number of elements
%   method = {'name' params }: Specify method used and the parameters
%   { 'quantile'/'q'  [ p ] } standard trimming (default behavior)
%   { 'threshold'/'t' [ t ] } remove values above a given threshold p
%          if p=[p1 p2], trimming is done between p1 (min) and p2 (max)
%   Example
%      >> hist([trim(randn(10000,2),'quantile',.95) randn(10000,1)],50)
%          % shows the extreme 5% of (two) normal distributions getting
%          % trimmed to ~2 in comparison with the unchanged 3rd one
%
%   See also: quantile, stat/winsor

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2006 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2006-02-09 Creation
% KND  2008-10-13 Example in help
% KND  2010-02-18 Renamed clipping() as trim()
% ----------------------------- Script History ---------------------------------

sX=size(X);
if prod(sX)==max(sX)
    X=X(:);
else
    X=X(:,:);
end
if nargin==2 && isnumeric(method)
    varargin{1} = method;    
    method = 'quantile';
end
switch method
    case {'quantile', 'q'}
        Y=quantile(abs(X),varargin{1},1);
        Y=Y(:)';
        Y=repmat(Y, size(X,1),1);        
        Y=X.*(abs(X)<Y)+sign(X).*Y.*(abs(X)>=Y);
    case {'threshold', 't'}
        Y=X;
        Y(Y>varargin{1}(end))=varargin{1}(end);
        if length(varargin{1})>1
            Y(Y<varargin{1}(1))=varargin{1}(1);
        end
end
Y=reshape(Y,sX);