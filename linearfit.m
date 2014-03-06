function  [slope, offset,R2,SCE,P,T] = linearfit(y,x)
%LINEARFIT - One line description goes here.
%   [slope,offset,R2,SCE,P,T] = linearfit(Y,X)
%   Solves the equation:
%       Y = slope * X + offset
%   Y: Data to fit. Should be a N-element vector or a 2D matrix with N lines
%   X: Fitting data. Should be a N-element vector. If missing: X=1:length(Y)
%   R2: Explained variance, also known as the square of the Pearson
%       Product-Moment Correlation Coefficient (R=sqrt(R2))
%   SCE: Sum of of the squared distance between Y and the linear fit
%   P: Non directional probability assuming normal distribution.
%      When a specific hypothesis is made on the direction of the correlation
%      (slope > 0 OR slope < 0) you should divide P by 2 to get the
%      directional p-value
%   T: Approximate T-value corresponding to the R

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2006 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2006-02-20 Creation
% KND  2008-07-01 Check X, Y order in inputs
%                   
% ----------------------------- Script History ---------------------------------
if nargin>1 && isvector(y) && ~isvector(x)
    warning('X and Y were inverted as inputs!')
    tmp=y;
    y=x;
    x=tmp;
    clear tmp;
end    
if numel(y)==max(size(y))
    y=y(:);
end
if nargin==1
    x=1:size(y,1);
end
x=x(:);
x=[x ones(size(x))];
if(size(y,1) ~= size(x,1))
  error('Length of x and y must be the same');
end
m=(y'/x')';
slope=m(1,:);
offset=m(2,:);
RES = (x*m-y);
SCE = sum(RES.^2,1);
my=x(:,2)*mean(y,1);
SCY = sum((y-my).^2,1);
SCER= sum((x*m-my).^2);
if SCY>0
    R2 = SCER./SCY;
else
    R2=NaN;
end
if nargout>3
    df= length(x)-2;
    T = sqrt(R2)./sqrt((1-R2)./(df));
    P = betainc( df ./ (df + T.*T), df/2, 0.5);
end
    
    
return