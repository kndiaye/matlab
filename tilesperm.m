function [B,tp]=tilesperm(A,C,tp)
% Permute blocks (or tiles) of a rectangular matrix (e.g. image)
%
%   B = tilesperm(A,C) will be a matrix of the same size as A but wherein
%   rectangular block (tiles) have been randomly permuted
%
%INPUTS:
%       A: original matrix (e.g. image)
%       C = [v h]: number of tiles [vertically horizontally]
%
%   [B,tp] = tilesperm(A,C[,tp]) 
%       tp: is the permutation table, it can be given as a 3rd argument.
%       If not given or empty, a random permutation table is generated at
%       runtime.
%
%See also: tiles, subarray, imgfilt

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

if nargin<3
    tp=[];
end

S=[size(A) 1];
AA=A;
B=zeros(S,class(A));
    
for i3=1:S(3)
    A=AA(:,:,i3);
    [T]=tiles(A,C);
    t=cellfun('prodofsize', T);
    t=t==prod(size(T{1}));
    if isempty(tp)
        tp=randperm(sum(t));
    end
    T(t)= subarray(T(t),tp,Inf);
    n1=ceil(S(1)/C(1));
    n2=ceil(S(2)/C(2));
    for i1=1:C(1)
        for i2=1:C(2)
            B( (1+(i1-1)*n1):min(S(1),i1*n1) , (1+(i2-1)*n2):min(S(2),i2*n2) , i3 ) = T{ (i1-1)*C(2) + i2 };
        end
    end
end