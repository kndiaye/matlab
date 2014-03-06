function [B,I] = nonunique(A,varargin)
%NONUNIQUE - Retrieves non-unique elements
%   [B,I] = nonunique(A)
%   [B,I] = nonunique(A, 'rows')
%
%   Example
%       >> nonunique
%
%   See also: 

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2008 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2008-09-03 Creation
%                   
% ----------------------------- Script History ---------------------------------

% Example data:
% A=flipud([0 0 1:3 3 3 4:10 13]')
% size(A),
% [b,i]=nonunique(A)
% i{:},A(cat(1,i{:}))

[C,J,K] = unique(A,varargin{:});
% Now find indices of nonunique elements 
% First sort the indices listed in K
[k,i]=sort(K);
% 1) those where two successive location in K point to the same value of C
j=[(diff(k)==0)];
% 2) you want only one item of each duplicate, keep the first of each
% series of repeated values
j = j & [1;[diff(diff(k))~=0]];
% Retrieves the values they correspond to in A
B = C(K(i(j)),:);
if nargout<2
    return
end
% if requested by the user, output the indices of these duplicates
k=i(j);
for i=1:length(k)
   I{i,1} = find(K==K(k(i)));
end
