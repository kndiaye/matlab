function [loc,nzloc,nmemb]=idxmember(A,S,varargin)
% [loc,nzloc,nmemb]=idxmember(A,S) indexes of values A in the set S. 
%       loc: indices of values from A found in S (0 if not found)
%       nzloc: list of non-null indices, ie: S(nzloc) == intersect(A,S)
%       nmemb: values of A that are not in S, ie: nmemb == setdiff(A,S)
%
% [...] = idxmember(A,S,'rows')
%
% See: ISMEMBER

sizeS=size(S);
sizeA=size(A);
if (iscell(S))
    S=S(:);
end
if ischar(A)
    sizeA=[1 1];
elseif (iscell(A))
    A=A(:);
end
[ignore,loc]=ismember(A,S,varargin{:});
loc=reshape(loc, sizeA);
if nargout>1
    nzloc=nonzeros(loc);
end
if nargout>2
    nmemb=A(find(loc==0));
end