function varargout = mediansplit(X,D,Y)
%MEDIANSPLIT - Split data in two equal groups on each side of the median
%   [A,M] = mediansplit(X) 
%   A are logical arrays such that with M is the median of X
%   A=+1 for X(A) > M; A=-1 for X(A) < M, and A=0 for X(A) = M
%
%   [A,M] = mediansplit(X,D) works along dimension D in X (default D=1)
%
%   [Z,A,M] = mediansplit(X,[],Y)
%   [Z,A,M] = mediansplit(X,D ,Y) 
%   will actually computes the median split of the data in Y according to X
%   X must be a vector of length L = size(Y,D) 
%   Z is a 3-by-... matrix with such that: 
%   Z(1,...)=mean(Y(A==+1)); Z(2,..)=mean(Y(A==-1)); Z(3,..)=mean(Y(A==0))  
%
%   Example
%       >> mediansplit(rand(1,10))
%
%   See also: 

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2008 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ----------------------------
% KND  2008-10-15 Creation
%                   
% ----------------------------- Script History ----------------------------

if nargin<1
    error('No data!')
elseif nargin<2
    D=[];
    Y=[];
elseif nargin<3
    Y=[];
elseif nargin>3
    error('%s accepts 1 to 3 inputs',mfilename);
else
    if ~isequal(size(X),size(Y)) 
        if prod(size(X))~=max(size(X))
            error('X should be a vector or of the same size as Y');
        end
        X=X(:);
        if isempty(D)
            if length(X) == size(Y,1)
                D=1;
            else
                error('X should be a vector matching size(Y,1) or you need to specify D');
            end
        elseif length(X) ~= size(Y,D)
            error('the vector X should be have a same length of size(Y,D)');
        end
        rm=[ones(1,D) 1];
        rm(D)=length(X);
        X=reshape(X,rm);
    end
end

if isempty(D)
    M=median(X);
else    
    M=median(X,D);
end        

if numel(M)>1
    if isempty(D)
        % the median is squeezed along one dimension but we don't know
        % which one, so we need to find out.        
        % We cannot compare directly the sizes of X and M because if D
        % happens to be the last dimension of X, the size of M may be
        % shorter by one dimension, and the ~= would raise an error... 
        % Thus this trick:
        ndX=ndims(X);
        ndM=ndims(M);
        nd=max(ndM,ndX);
        D = [size(X) zeros(1,nd-ndX)]~=[size(M) zeros(1,nd-ndM)];
    end
    rm=[ones(1,D) 1];
    rm(D)=size(X,D);
    M=repmat(M,rm);
end
A=(X > M) - (X < M);
if ~isempty(Y) && ~isequal(size(X),size(Y))
    rm=[size(Y)];
    rm(D)=1;
    A=repmat(A,rm);
end
sA=sum(A>0,D);
sB=sum(A<0,D);
if(~isequal(sA,sB))
    warning('Distribution(s) above and below median is/are not symmetrical!')
end
varargout={A,M};
if isempty(Y)
    return
end
if isempty(D)
    D=1; %It also works if Y is horizontal
end
Z=cat(D,sum(Y.*(A>0),D),sum(Y.*(A<0),D),sum(Y.*(A==0),D));
Z=Z./cat(D,sA,sB,sum(A==0,D));
varargout=[Z varargout];
return
