function [E,N,J] = histk(X,varargin)
%HISTK - Histogram count and ranking
%   [E,N,J] = histk(X)
%       E is the list of values in X ranked by their relative frequency
%       N is their number of occurences
%       J is the class to which each element of X belongs to, so: E(J) == X
%
%   [E,...] = histk(X, 'rows') works on rows
%
% Note: histk() works even if (numeric) X contains NaN and Inf
%
% See also: hist, histc, histfun()

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2006
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND   2009-10-22 ReCreation
% KND   2006-10-23 Fix NaN issue
% ----------------------------- Script History ---------------------------------
if ischar(X)
    [U,I,J]=unique(X, 'rows');
else
    if nargin<2 || ~isequal(lower(varargin{1}), 'rows')
        if ~isvector(X)
            for i=1:size(X(:,:),2)
                if nargout<3
                    [E{i},N{i}]=histk(X(:,i));
                else
                    [E{i},N{i},J{i}]=histk(X(:,i));
                end
            end
            return
        end
    end    
    [U,I,J]=unique(X,varargin{:});
end
if isnumeric(X)
    % special treatment for possible NaNs in numeric arrays
    nans = isnan(U);
    if any(nans)
        U(nans)=[];
        U(end+1)=NaN;
        J(ismember(J,find(nans)))=length(U);
    end
end
% Bin data into classes and sort them classes according to their
% cardinality (in decreasing order)
[N,i]=sort(-histc(J,1:length(U)));
% Because we tricked sort using negative values :
N=-N;
if ischar(X)
    % In case X is a char array, keep the rest of the rows with "(i,:)" instead
    % of only "(i)"
    E=U(i,:);
elseif size(U,2)>1
    E=U(i,:);
else
E=U(i);
end
if nargout>2
    [J,J]=ismember(J,i);
elseif nargout==0
    E=[E N];
end
