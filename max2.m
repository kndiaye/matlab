function [V,I] = max2(X,ignore,dim)
%MAX2 - Maximum across multiple dimensions
%   [V,I] = max2(X,[],dim)
%       V is the maximum value across given dimension (dim)
%       I is the index in the given dimensions
%   (Note that [] must be here for compatibility reasons with max function)
%   
%   Example
%       >> max2(magic(3), [], [1 2])
%               9
%          Finds the maximum in rows and columns of the magic square
%
%   See also: max, imax

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2006 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2006-02-20 Creation
%                   
% ----------------------------- Script History ---------------------------------

if nargin<2
    [V,I]=max(X);
elseif length(dim)==1
    [V,I]=max(X,[],dim);    
else
    sX=size(X);
    X=nd2array(X,dim);
    [V,I]=max(X,[],1);
    V=nd2array(V,-dim,sX);
    I=ind2sub2(sX(dim),I);
    sX(dim)=1;
    sX(sX==1)=[];
%    I=reshape(I,[sX,length(dim)]);
end