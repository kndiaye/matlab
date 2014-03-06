function [X]=detrend2(X,o,i,d)
% detrend2 - polynomial detrending 
%       Y = detrend2(X,o,i,d) removes trends in data
%
%   X: input data array
%   o: order of the fitted polynom (default 1, i.e. linear detrending)
%   i: indices of the control points (default: [], i.e. all points)
%   d: dimension to work on (default: 1)

%   See also: detrend

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2010 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2010-04-21 Creation
%                   
% ----------------------------- Script History ---------------------------------

if nargin < 2
	o = 1;
end
if nargin < 3
	i = [];
end
if nargin < 2
	d = 1;
end
nd = ndims(X);
if d>nd
    error(sprintf('X has only %d dimensions', nd));
end
sx = size(X);

if o==0
    r = ones(1,nd);
    r(d) = sx(d);   
    
    S.type='()';
    S.subs = repmat({':'},1,nd);
    S.subs{d} = i;
    X = X - repmat(mean(subsref(X,S),d),r);
    return
end

error


% polynomial adjustment
%---------------------------------------------------------------------------
G     = [];
for i = 0:p
	d = [1:m].^i;
	G = [G d(:)];
end
y     = x - G*(pinv(G)*x);


% detrend - remove linear trend
% addpath('/pclxserver2/home/ndiaye/mtoolbox/spm2')
% F=spm_detrend(F',1)';
