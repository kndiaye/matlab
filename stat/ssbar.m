function [CI ,fx] = ssbar(X,nf,rp,alpha)
%SSBAR - Statistical Significance Bars
%   [CI] = ssbar(X,nf,rp,fx,alpha)
%
%   Example
%       >> ssbar
%
%   See also: 
%   Reference: 
%       Statistical significance bars (SSB): A way to make graphs
%       more interpretable. Christian D. Schunn (2007)


% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2007 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2007-10-25 Creation
%                   
% ----------------------------- Script History ---------------------------------

if nargin<2
    nf=ndims(X)-1
end
if nargin<3
    rp=1:nf
end
if nargin<4
    alpha=0.05;
end

ng=size(X);
nr=ng(nf+1);
ng=ng(1:nf);
png=prod(ng);
[p,F,fx,epsilon,df,dfe,SS,SSe,SSt]=myanova(X,nf,rp);
CI=0.*p;
for i=1:length(fx)
    %number of cells
    k = prod(ng(fx{i}));     
    % number of 
    n = nr*png/k;
    MSe = SSe(i,:)./dfe(i);
    if n<120
        CI(i,:)=1/2*sqrt(MSe / n) * tukeyhsd(n,k,alpha);
    else
        warning('n=%d & k=%d too big for Tukey''s HSD  computation',n,k)
        CI(i,:)=NaN;
    end
end    

return


% Validation data:
% One way ANOVA from Loftus & Masson, 1994
% Exposure Duration Per Word (sec)
% 1 Sec 2 Sec 5 Sec
X= [
    10 13 13
    6 8 8
    11 14 14
    22 23 25
    16 18 20
    15 17 17
    1 1 4
    12 15 17
    9 12 12
    8 9 12
    ]';
% From Schunn, 2000:
[c]=ssbar(X); % [c,fx]=ssbar(X,1,1,0.05)
k=3 ; n = 10 ; MSe = 0.615
CI = 0.48
