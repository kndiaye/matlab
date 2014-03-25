function h = patchplot(X,Y,varargin)
%PATCHPLOT - One line description goes here.
%   [h] = patchplot(Y)
%   [h] = patchplot(X,Y)
%   [h] = patchplot(X,Y,varargin)
%
%   Example
%       >> patchplot
%
%   See also:

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2009
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2009-04-06 Creation
%
% ----------------------------- Script History ---------------------------------

if nargin==1
    Y=X;
    X=[];
end
if numel(Y)==max(size(Y))
    Y=Y(:);
end
Y=Y(:,:);
if isempty(X)
    X=1:size(Y,1);
end
bl=0;
if nargin>1
    try
        i = strmatch('baseline', lower(varargin(1:2:end)), 'exact');
        if ~isempty(i)
            bl=varargin{2*i};
            varargin((2*i-1):(2*i))=[];
        else
            bl=0;
        end
    end
end

minY = zeros(1,size(Y,2))+bl;
% minY(all(Y>=0,1),:)=min(Y,[],1);
% minY(all(Y<=0,1),:)=min(Y,[],1);
X=X([1 1:end end]);
Y = [minY;Y;minY];
%Y(end+1,:) = Y(1,:);

for i=1:size(Y,2)
    if size(Y,2)>1
        C=rand(1,3);
    else
        C=[.87 .87 .87];
    end
    h(i)=patch(X,Y,C,varargin{:});
end
% Move it to the back layer
hh = get(gca, 'children');
set(gca, 'children',[ hh(hh~=h);h]);