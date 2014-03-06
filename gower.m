function  Y = gower(X)
%GOWER - Gower Centered Matrix
%   [Y] = gower(X)
%   Y(i,j)= X(i,j) - mean(X(:,j)) - mean(X(i,:)) + mean(X(:))

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

n=size(X);
if ~isequal(n(1), n(2:end))
    error('Squared matrix needed');
end
n=n(1);
Y=(eye(n) - ones(n)./n)* X *(eye(n) - ones(n).he/n);
