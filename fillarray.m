function Y = fillarray(C,X,S,O)
%FILLARRAY - Fill an array with given values
%   [Y] = fillarray(C,X,S)
%       Creates an array of size S whose values in position C are X
%       C and X should be either numerical arrays or cell lists of the same
%       length. Each cell should be of the same length, but X or X{i} may be
%       scalar, in which case it is expanded to match C{i} length. If X is
%       an array
%   [Y] = fillarray(C,[],S) and [Y] = fillarray(C,1,S)
%       Fills the array of size S with ones (default value).
%   [Y] = fillarray(C,X)
%       Fills a vertical array at positions C with values in X. 
%       The length of Y is the maximum index found in C
%   [Y] = fillarray(C) 
%       Fills a vertical array of size [max(C) 1] with 1's at positions C
%   [Y] = fillarray(C,X,S,O)
%       Non specified values are O (O=1, if you want ones instead of zeros)
%
%   Example
%       >> fillarray
%
%   See also: sparse

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2006
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2006-01-05 Creation
% KND  2008-01-23 Input size S is no more mandatory
% KND  2010-03-22 Corr. Bug. & parsing inputs
% ----------------------------- Script History ---------------------------------

if nargin<1 || nargin>4
    error('Wrong number of inputs')
end

if nargin<2
    X=[];
end
if ~iscell(C)
    C={C};
    if ~iscell(X) && ~isempty(X)
        X={X};
    end
end
if ~isempty(X)
    nX=numel(X);
    nC=numel(C);
    if ~iscell(X)
        if  nX==1
            X = repmat({X},nC,1);
            nX=nC;
        else
            X = num2cell(X);
        end
    end

    if nC~=nX
        error('Sizes of C and X do not match');
    end
end


if nargin<3
    S=[];
end
if nargin<4
    O=0;
end
if isempty(S)
    S=[NaN];
end
if length(S)<2 && ~isnan(S(1))
    S=[S 1];
end
if all(~isnan(S))
    Y=zeros(S);
else
    Y=[];
end
twopass=1;
if ~isequal(O,0) 
    twopass=2;
end
while twopass
    Y(:)=O;
    if isempty(X)
        Y([C{:}])=ones(length([C{:}]),1);
    else %if max(S)==prod(S)
        for i=1:length(C)
            if length(X{i})==1
                X{i}=repmat(X{i}, length(C{i}),1);
            end
            if isvector(C{i})
                Y(C{i})=X{i};
            elseif size(C{i},2) == 2
                if all(isnan(NaN))
                    S=[Inf];
                end
                for j=1:size(C{i},1)
                    Y(C{i}(j,1),C{i}(j,2))=X{i}(j);
                end
            else
                error('C must be a 1-D list of absolute indices or subs indices (currently for 2D arrays only)')
            end
        end
    end
    twopass = twopass-1;
end

if all(isnan(S)) %verticalize Y 
    Y=Y(:);
end
<<<<<<< .mine
=======
    >>>>>>> .r687
