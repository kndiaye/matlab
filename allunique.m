function [T,I,U] = allunique(X)
%ALLUNIQUE - Tests if all elements are unique (no duplicate)
%   [T,I,U] = allunique(X) 
%  
% Inputs: 
%   X: matrix/vector
% Outputs:
%   T: is 1 if there is no duplicated element in X
%   I: indices of the non-unique elements
%	U: list of unique elements: U =unique(X)
%   Example
%       >> allunique
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
% KND  2008-07-09 Creation
%                   
% ----------------------------- Script History ---------------------------------
U=unique(X(:));
T=numel(U) == numel(X);
if nargout>0
    I = find(~ismember(U,X(:)));
end