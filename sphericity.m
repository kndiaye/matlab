function [eGG,eHF,eLB,fx] = sphericity(X,nf)
%SPHERICITY - Epsilon for sphericity correction (muldimensional data)
%   [eGG,eHF,eLB,fx] = sphericity(X,nf)
%   Computes Greenhouse-Geisser, Huynh-Feldt nd Lower-Bound epsilons for
%   each factor of X which is a matrix: 
%           N1 x N2 x ... x N(nf) x N(subjects) x [ ... ] 
%   nf is the number of factors (leading to nfx effects)
%   Note: Subject MUST BE on dimension nf+1
%OUTPUT:
%   eGG: Greenhouse-Geisser epsilon: (nfx)-by-[...] matrix
%   eHF: Huynh-Feldt epsilon: (nfx)-by-[...] matrix
%   eLB: Lower-bound estimate = 1/(#levels-1)
%   fx: cell list of effect (see myanova)
%
%   See also: myanova
%   Ref: http://www.psych.upenn.edu/~baron/rpsych.pdf

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2006
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2006-02-14 Creation
%
% ----------------------------- Script History ---------------------------------

sx=size(X);
nX=ndims(X);
NM=prod(sx(nf+2:nX));
N=sx(nf+1); % NB of subjects
NC=prod(sx(1:nf)); % NB of Cells
X=permute(X,[nf+1 1:nf nf+2:nX]);
fx={};
for i=1:nf
    fx=[fx ; num2cell(nchoosek(1:nf,i),2)];
end
nfx=length(fx);
eGG=zeros([nfx,sx(nf+2:nX) 1]);
if nargout>1
    eHF=zeros([nfx,sx(nf+2:nX) 1]);
end
if nargout>2
    eLB=zeros([nfx,sx(nf+2:nX) 1]);
end

for i=1:nfx
    Y=permute(X,[1 fx{i}+1 setdiff(2:nf+1,[1+fx{i}]) nf+2:nX]);
    NL=prod(sx(fx{i})); % Number of levels
    Y=reshape(Y,N,NL,NC/NL,NM);    
    v=cov2(mean(Y,3));  
    eGG(i,:)=NL^2*(mean(diag2(v)) - squeeze(mean(mean(v,2),1))').^2/(NL-1)./...
        (squeeze(sum(sum(v.^2,1),2))' - 2*NL*squeeze(sum(mean(v,1).^2,2))' + NL^2*squeeze(mean(mean(v,1),2))'.^2);
    clear v;
    if nargout>1
        eHF(i,:)=(N*(NL-1)*eGG(i,:)-2)./((NL-1)*(N-1-(NL-1)*eGG(i,:)));
    end
    if nargout>2
        eLB(i,:)=1./(NL-1);
    end
end

return


function [y]=diag2(x)
% Diagonal of the first 2D plan of N-by-N-by-[...] multidimensional array X
sx=[size(x) 1];
n=sx(1);
nm=prod(sx(3:end));
y=x(repmat((1:n+1:n^2)',1,nm) +repmat(n^2*[0:nm-1],n,1));
y=reshape(y,[sx(1),sx(3:end)]);

function V = cov2(X,varargin)
%COV2 - Multidimensional Covariance
%   [V] = cov2(X)
%   Computes the M-by-M-by-[...] covariance matrix of data X, which are
%   given as N-by-M-by-[...] matrix, N observations and M variables.
sX=[size(X) 1];
X=reshape(X,sX(1),sX(2),prod(sX(3:end)));
X=X-repmat(sum(X,1)/sX(1),sX(1),1);
V=zeros(sX(2), sX(2), prod(sX(3:end)));
for i=1:size(X,3);
    V(:,:,i)= (X(:,:,i)' * X(:,:,i)) / (sX(1)-1);
end