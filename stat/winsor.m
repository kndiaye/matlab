function [X,wtf] = winsor(X,p,dim)
% WINSOR - Winsorize data
%
%    [W,wtf] = winsor(X,p)
%    Replace p% (or p samples, if p>=1) in X at both ends by the p-th
%    quantile values; wtf is a logical array of those elements which have
%    been winsorized.
%
%    [W] = winsor(X,[p_top p_bottom])
%    Remove possibly asymmetric %/samples at the top and at the bottom
%
%    [W] = winsor(X,p,dim)
%    Default is to work on dimension 1
%
%   See also: quantile, clipping

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2009
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2009-10-09 Creation
%                   
% ----------------------------- Script History ---------------------------------

sX=size(X);
if nargin<2
    error('Missing p argument!');    
end
if nargin<3
    dim=1;
  if isvector(X)
    [dim,dim]=max(sX);
  end
end
N = sX(dim);
if numel(p)<1 || numel(p)>2
  error('p must be a 1- or 2-element');
end
if numel(p)==1
  p(2)=p;
end
if any(p<1)
    do_warn=any(rem(N,1./p));
    p(p<1)=round(N*p(p<1));
    if do_warn
        warning('Number of trimmed values rounded to: top=%d ; bottom=%d',p(1),p(2));
    end
end
if sum(p>=N)
  error('Can''t trim all the data! Use a smaller p.');
end
if dim>1
  X=permute(X, [dim setdiff(1:length(sX),dim)]);  
end
X=X(:,:);
NC=size(X,2);
[j,j]=sort(X);
j = j+repmat(sX(1)*[0:NC-1],sX(1),1);
% Replace values in the upper tail
X(j(N-p(2)+1:N,:)) = repmat(X(j(N-p(2),:)),p(2),1);
% Replace values in the lower tail
X(j(1:p(1),:)) = repmat(X(j(p(1)+1,:)),p(1),1);
%X=reshape(X,N-p(1)-p(2),NC);
if dim>1
  X=ipermute(X, [dim setdiff(1:length(sX),dim)]);  
end
if nargout>1
  wtf=logical(zeros(sX));
  wtf([j(1:p(1),:) j(N-p(2)+1:N,:)])=1;
end
%sX(dim)=N-p(1)-p(2);
X=reshape(X,sX);
return