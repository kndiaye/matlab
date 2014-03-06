function  C = bitget2(A,BITS)
%BITGET2 - Get bit values (also from arrays)
%   [C] = bitget2(A,BITS) returns a N-by-B array
%         where N = numel(A) and B=numel(BITS)
%
%   Example
%       >> bitget2([1 5 3 15], [1:3])
%
%   See also: bitget

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2009 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2009-03-31 Creation
%                   
% ----------------------------- Script History ---------------------------------

A=A(:);
for i=1:numel(A)
    C(i,:)=bitget(A(i),BITS);
end