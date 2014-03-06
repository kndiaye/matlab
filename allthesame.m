function tf = allthesame(A,dim)
%ALLTHESAME - True if all elements are identical
%   [TF] = allthesame(A)
%   [TF] = allthesame(A,dim)
%   Works only on numerical/char array (not cells)
%   
%   Example
%       >> allthesame
%
%   See also: unique, nonunique

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2009 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2009-04-10 Creation
%                   
% ----------------------------- Script History ---------------------------------

s=size(A);
if nargin<2
    dim=[];
end
if isempty(dim)
    if sum(s)==max(s)
        [ign,dim]=max(s);
    else
        dim=1;
    end
end
if dim>1
    p=[dim setdiff(1:ndims(A),dim)];
    A=permute(A,p);
    s=[s(p) 1];
end
if iscell(A)
    ncol=prod(s(2:end));
    tf = logical(zeros(s(1)-1,ncol));
    for j=1:ncol
        for i=2:s(1)
            tf(i-1,j)=isequal(A(1,j),A(i,j));
            if ~tf(i-1,j)
                % don't explore the remaining lines for this column
                break;
            end
        end
   end
else
    tf = A(2:end,:)==repmat(A(1,:),s(1)-1,1);
end
tf=all(tf,1);
tf=reshape(tf, [1 s(2:end)]);
if dim>1
    tf=ipermute(tf,p);
end
return
