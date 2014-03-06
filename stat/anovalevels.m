function [I L]= anovalevels(X,nf,labels)
%ANOVALEVELS - Put labels on levels of each factor in a design matrix X
%   [I] = anovalevels(X) creates an array I with as many rows as there are
%   elements in X and as many columns as its dimensions, where X contains
%   the data of a full factorial ANOVA (see: myanova), so that each rows of
%   I indicate for each X(:) the level in each factor it corresponds to. 
%   The concatenation [I X(:)] can then be used with by rmaov2, for
%   example.
%
%   [I] = anovalevels(X, nf) consider only the first nf dimensions of X as
%   factors (the rest is supposed to be multivariate data)
%
%   [L,I] = anovalevels(X, nf, labels) uses the specified labels instead
%   of numerical indices. labels must be a cell array of length nf, with
%   each labels{i} being itself an array of length = size(X,i)
%
%   Example
%       >> anovalevels(rand(3,2))
%       >> anovalevels(rand(3,2),2,{1:3 , {'a' 'b'}})
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
% KND  2006-02-14 Creation
% KND  2008-11-11 Processes text labels
% KND  2010-05-04 Renamed factorlabels -> anovalevels
% ----------------------------- Script History ---------------------------------

sx=size(X);
if nargin<2
    nf=length(sx);
end
ns=prod(sx(1:nf));
if nargin==3
    nl=cellfun('length', labels);
    if ~all(nl(1:nf)==sx(1:nf) | ~(nl>1)) %| ~all(cellfun('isreal', [labels{nl==1}]) & (cellfun('length', [labels{nl==1}]) == sx(nl==1)))        
        error('Wrong size of labels')
    end
end
    
I=zeros(ns,nf);
for i=1:nf
    z=ones(prod(sx(1:i-1)),1)*(1:sx(i));
    z=z(:)*ones(1,prod(sx(i+1:end)));
    I(:,i)=z(:);
end

if nargin>2
    L=cell(size(I));
    for i=1:nf
        if iscell(labels{i})
            L(:,i)=labels{i}(I(:,i));
        else
            L(:,i)=num2cell(labels{i}(I(:,i)));
        end
    end
    %permute outputs
    J=I;
    I=L;
    L=J;
    clear J;
end