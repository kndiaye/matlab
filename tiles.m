function [T,idx]=tiles(A,C)
% tiles - extract subparts (a.k.a tiles or blocks) of a matrix 
%   [T,idx]=tiles(A,C)
%       Cuts N-dimensional matrix A into pieces and extract them as a cell array of tiles
%       C is a N-by-1 vector defining how each dimension of A is cut
%
%See also: tilesperm, subarray

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2008 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2008-09-04 Updated comments & help
%                   
% ----------------------------- Script History ---------------------------------

S=size(A);
if ndims(A)>2
    error('Cannot process matrices with more than 2 dimensions');
end
C=[C ones(1,max(0,length(S)-length(C)))];
if any(C(length(S)+1:end)~=1)
    error('Cuts cannot be made along those dimensions');
end
if any(C>S)    
    error('Cuts cannot be made along those dimensions');
end
%number of tiles
NT=prod(C);
T={};
idx={};
n1=ceil(S(1)/C(1));
n2=ceil(S(2)/C(2));

for i1=1:C(1)
    for i2=1:C(2)
        T   = [T    { A( (1+(i1-1)*n1):min(S(1),i1*n1) , (1+(i2-1)*n2):min(S(2),i2*n2) )}];
       % idx = [idx  { sub2ind(S, (1+(i1-1)*n1):min(S(1),i1*n1) , (1+(i2-1)*n2):min(S(2),i2*n2)) }];        
    end
end