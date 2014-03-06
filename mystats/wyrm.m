function  r = wyrm(X,Y,alpha,NP)
%WYRM - Westfall-Young Randomization Method for multiple comparisons tests
%   [] = wyrm(X,alpha,N)
%
%   Example
%       >> wyrm
%
%   See also: 

% Ref: 
%      Pointwise Testing with Functional Data Using the Westfall-Young Randomization Method
%      http://cohesion.rice.edu/engineering/Statistics/emplibrary/lee_cox_070119.pdf

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2007 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2007-11-05 Creation
%                   
% ----------------------------- Script History ---------------------------------

X=X(:,:);
Y=Y(:,:);

alpha=0.05;
NP=100;

t=tvalue(X,Y);
[to,it]=sort(-(t));
sX=size(X);
N(1)=size(X,1);
N(2)=size(Y,1);
X=cat(1,X,Y);
[ignore,P]=sort(rand(NP,N(1)+N(2)),2);
pp=zeros([NP sX(2:end),1]);
n=prod(sX(2:end));
for i=1:NP    
    t(i,:)=tvalue(X(P(i,1:N(1)),:),X(P(i,N(1)+1:end),:));
    for j=1:n
        q(i,j)=max(t(i,it(j:end)));
    end
end
r=sum(q<=repmat(to, [NP,1]))/NP;
j=find(r>alpha);
if ~isempty(j);j=j(1);

