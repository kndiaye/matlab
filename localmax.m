function [Y,I] = localmax(X,N,dim)
%LOCALMAX - Finds local maxima
%   [Y,I] = localmax(X)
%   [Y,I] = localmax(X,N)
%   Looks for local maxima in vector X.
%   Search window can be enlarged using input N. Default: N=1, ie.
%   each local maximum must be greater than or equal to its immediate
%   neighbours
%
%   Example
%       >> localmax
%
%   See also: max

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2006
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2006-01-27 Creation
% KND  2008-09-18 Only the first value of a constant plateau is returned
% KND  2009-03-25 try/catch in case there is no license for the stats toolbox  
%
% ----------------------------- Script History ---------------------------------

if nargin<1
    error('No data!')
end
if nargin<2
    N=1;
end
if numel(X)~=max(size(X))
    error('X should be unidimensional')
end

X=X(:)';
n=length(X);

if N>=n
    N=n-1;
    error(sprintf('Not enough elements in X (of length %d)\nSearch window should be reduced to: N=%d', n, N));
end
t=1:n;
try
    XX=[buffer(X,2*N+1,2*N,repmat(X(1),1,2*N)) ...
        fliplr(flipud(buffer(fliplr(X(end-2*N+1:end)),2*N+1,2*N, repmat(X(end),1,2*N))))];
    XX=XX(:,N+1:end-N);
catch
    XX=X;
    for i=1:N;
        XX=[X(1,[repmat(1,1,i) t(1:end-i)]); ...
            XX; ...
            X(1,[t(i+1:end) repmat(t(end),1,i)])];
    end
end

YY=repmat(X,[2*N+1 1]);

I=find(all(YY>=XX));
dI=diff(I)==1;
I(logical([0 dI])) = [];
Y=X(I);

return

Y=reshape(Y,[length(Y)/prod(sX(3:end)) sX(3:end)]);
Y=ipermute(Y,pX);
I=mod(I-1,prod(sX(2)))+1;
I=reshape(I,[length(I)/prod(sX(3:end)) sX(3:end)]);
I=ipermute(I,pX);

return



N = length(x);               % N: Number of elements in time series
x_prev = [x(1) x(1:(N-1))];  % x_prev: Previous element in time series
x_next = [x(2:N) x(N)];      % x_next: Next element in time series
f = ( (x<=x_prev) & (x<=x_next) );  % f:  True where x takes on a local
%     minimum value

