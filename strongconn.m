function  [M,C] = strongconn(A,tol)
%STRONGCONN - Find strongly connected components from a graph
%   [M,C] = strongconn(G)
%       Finds the strongly connected sets of vertices
%                in the (directed) graph matrix G
%          A = 0-1 matrix displaying accessibility
%          C = displays the equivalent classes
%
%   See also: dmperm
%   Web: http://www.nist.gov/dads/HTML/stronglyConnectedCompo.html

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2006
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2006-01-11 Creation
%
% ----------------------------- Script History






function [c,v] = dig(a,tol)
[m,n] = size(G);
if m~=n 'Not a Square Matrix', break, end
b=abs(a); o=ones(size(a)); x=zeros(1,n);
msg='The Matrix is Irreducible !'; v='Connected Directed Graph !';
if (nargin==1) tol=n*eps*norm(a,'inf'); end

% Create a companion matrix
b>tol*o; c=ans; if (c==o) msg, break, end

% Compute accessibility in at most n-step paths
for k=1:n
    for j=1:n
        for i=1:n
            % If index i accesses j, where can you go ?
            if c(i,j) > 0  c(i,:) = c(i,:)+c(j,:); end
        end
    end
end
% Create a 0-1 matrix with the above information
c>zeros(size(a)); c=ans; if (c==o) msg, break, end

% Identify equivalence classes
d=c.*c'+eye(size(a)); d>zeros(size(a)); d=ans;
v=zeros(size(a));
for i=1:n find(d(i,:)); ans(n)=0; v(i,:)=ans; end

% Eliminate displaying of identical rows
i=1;
while(i<n)
    for k=i+1:n
        if v(k,1) == v(i,1)
            v(k,:)=x;
        end
    end
    i=i+1;
end
j=1;
for i=1:n
    if v(i,1)>0
        h(j,:)=v(i,:);
        j=j+1;
    end
end
v=h;
