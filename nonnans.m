function [S,loc,i] = nonnans(S,dim)
%nonnans - Non-NaN matrix elements.
%
%   V=nonnans(S) is a full column vector of the non-nans elements of S.
%   This gives the s, but not the i and j, from [i,j,s] = find(isnan(S)).
%   Be aware that if S is a matrix, it outputs a single column vector.
%   [V,L]=nonanas(S) also outputs indices of non-NaN values 
%   
%   B = nonnans(A,dim) will return a matrix without the NaN's removing the
%   whole rows/columns in each dimension specified in the vector [dim]
%   
%   Example
%       >> histk
%
%   See also: NONZEROS, NUMREP

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2006
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2006-02-07 Creation
%
% ----------------------------- Script History ---------------------------------
loc=find(~isnan(S));
if nargin<2
    S=S(loc);
else        
    s=size(S);
    i=[];
    i=find(isnan(S));    
    e= ['[' sprintf('i(:,%d),',1:ndims(S)) ']=ind2sub(size(S),i);'];
    eval(e)
    i(:,size(i,2)+1:max(dim))=1;
    for d=dim(:)'
        e = ['S(' ...
            repmat(':,',1,d-1) sprintf('i(:,%d)',d) repmat(',:',1,ndims(S)-d) ...
            ')=[];'];
        eval(e)
        
    end
end
