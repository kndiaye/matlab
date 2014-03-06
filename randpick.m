function [Y,I] = randpick(X,N,dim)
%RANDPICK - Pick N values at random in an array
%   [Y] = randpick(X,N)
%
%   Example
%       >> randpick
%
%   See also: 

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2009 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2009-10-25 Creation
%                   
% ----------------------------- Script History ---------------------------------
if nargin<2
    N=1;
end
if ndims(X)>2
    error
end
if isvector(X)
    X=X(:);
end
S=size(X);
if isinf(N)
    N=S(1);
end
if N>S(1)
    warning('randpick:Duplicates','Some value will be repeated!')
end
[I,I] = sort(rand(max([S;N 0])));
I=I(1:N,:);
for j=1:S(2);
    %in case N > S(1), mod() is needed
    Y=X(mod(I(:,j)-1,S(1))+1,:);
end
