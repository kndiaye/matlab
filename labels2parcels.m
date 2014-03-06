function [C,labels,ROI] = labels2parcels(r,norli,labels)
%LABELS2PARCELS - Creates a parcellation matrix from labels on a mesh
%   [C,labels,ROI] = labels2parcels(r)
%   From a labelling vector (r) of N points, it creates a [M-by-N]
%   parcellation matrix with ones (1) in a given line indicates that
%   the points of the corresponding columns belong to that region.
%
%   [C,labels,ROI] = labels2parcels(r,norli)
%   When norli=1, normalizes each line of C by the number of points
%   belonging to it (default: norli=0, ie don't normalize);
%    
%   [C,labels,ROI] = labels2parcels(r,norli,labels)
%   The values in r are referenced according to the labels given.
%
%
%   Example
%       >> C=labels2parcels(mni.atlas.r,0,1:116)
%
%   See also: 

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2006 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2006-02-06 Creation
%                   
% ----------------------------- Script History ---------------------------------
[l,i,j]=unique(r(:));
if nargin>2
    [ign,ll]=ismember(l,labels);
    j=ll(j);
else
    labels=l;
end
M=length(labels);
N=length(r);
C=sparse(j,(1:N)',ones(N,1),M,N,N);
if norli
    nC=1./(sum(C,2)+eps);
    nC(isnan(nC))=0;
    C=diag(nC)*C;
end