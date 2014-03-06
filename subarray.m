function [Y,S]=subarray(X,varargin)
% subarray - Retrieves subparts from a ND-array using subscripted reference
%
% [Y,S]=subarray(X,idx,dim)
% [Y]=subarray(X,idx1,dim1,idx2,dim2,...)
% [Y]=subarray(X,{idx1,dim1,idx2,dim2,...}) or {idx{:};dim{:}}
% Retrieves Y a subpart of a N-dimension array X based on subscripted
% references specified in inputs idx and dim (see below)
%
% INPUTS:
%     X: a ND-array
%   idx: indices of values to retrieve in the given dimension
%        If negative indices start from the end
%        E.g. 0 is the last element in the dimension, -1 the one before etc.
%        Indices can also be specified as logical.
%   dim: dimension on which the operation is done
%        Default: dim = first non-singleton. So that, if X is a vector,
%        subarray(X,n) outputs the n-th element of it.
%        * if dim<0: remove the subpart and output the remainder
%        * if dim=+Inf or -Inf, then output the given elements after
%          vertical vector reshaping (i.e. using linear indexing).
%        If the same dimension is specified in multiple places only the
%        last one will be taken into account.
%        If other dimensions are specified along with Inf, an error will
%        ensue.
%        Dimensions need not to be specified in any specific ordered.
%
% OUTPUTS:
%	  Y: a multiple dimension array depending on the given inputs.
%     S: a structure that can be used in a call with SUBSREF to
%        output Y from X. However, if Inf has been used as a dimension
%        specifier, S cannot be output.
%
% Examples using matrix M = magic(3)
%   >> subarray(M,1) retrieves the first row of matrix M
%   >> subarray(M,[3 2],2) retrieves the 3rd and 2nd columns of M (in that
%                          order)  
%   >> subarray(M,1,5) retrieves the whole matrix M since M has less than 5
%                      dimensions
%	>> subarray(M,1,-2) retrieves all but the first column of M
%   >> subarray(M,1,-2,2,1) is equivalent to M(2,[2 3]) (but this wouldn't
%                           be equivalent if M had more than 2 dimensions)
%   >> subarray(M,0,1) retrieves the last line of M
%   >> subarray(M,2,Inf) retrieves the 2nd element of M(:)
%   >> subarray(M,[-1 -2],-Inf) retrieves all but the second-to-last and
%                               next-to-last elements of M(:)
%   >> subarray(M,[false true true],2) retrieves the 2nd and 3rd columns
%
%
% Note: This function is useful when one doesn't know the number of
% dimensions of X. E.g. to retrieve the 3rd and 4th "line" of the 2nd
% dimension of a ND array (say, X is 4-by-5-by-3-by-...)
%   >> subarray(X,[3 4] ,2)
%   outputs a 4-by-[2]-by-3-by-... array
%
% See also: SUBSREF

% Author: K. N'Diaye, kndiaye01<at>yahoo.fr
% Copyright (C) 2007
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html

% Version 1.0
% ----------------------------- Script History ----------------------------
% KND  2007-05-22 Published on Matlab Central
% KND  2007-10-28 Allows logical indexing
% KND  2009-02-26 Consistent behaviour with multiple "Inf"'s used as dim
% KND  2009-11-12 Corrected bug when any dim > ndims
% ----------------------------- Script History ----------------------------


sx=size(X);
if nargin<2
    Y=X;
    return; %previously error('No indices given!')
elseif nargin>2
    inputs=varargin;
    if rem(nargin-1,2)
        error('Indices & dimensions should be given in pairs')
    end
else
    if iscell(varargin{1})
        % when a single cell is given as an input,
        inputs=varargin{1}(:)';
    else
        % when no dimension is specified use the first non-singleton
        inputs=varargin(1);
        dim=[find(sx>1) 1];
        inputs{2}=dim(1);
    end
end
% inputs should be split in indices and dimensions
idx=inputs(1:2:end);
dim=[inputs{2:2:end}];
%indiced in dimensions that are negative will behave as "excluders"
exclude=logical(dim<0);
dim=abs(dim);
% if length(unique(dim))<length(dim)
%     error('The same dimension is repeatedly specified.');
% end
if any(isinf(dim))
    if any(~isinf(dim))
        error('In specifying dimensions, dim=+Inf or dim-Inf cannot be used in combination with other finite dimensions.')
    end
    % When dim is infinite, reshape X into a 1-column vector so that
    % elements will be taken from it directly
    sx=prod(sx);
    X=X(:);
    dim=ones(1,sum(isinf(dim)));
end

% we make sure that we have enough 1's if an extra dimension is asked for
sx=[sx ones(1,max(dim)-2)];
nd=length(sx);
% makes up the list of indices
for i=1:length(idx)
    if islogical(idx{i})
        % logical indices
        tmp=1:sx(dim(i));
        idx{i}=tmp(idx{i});
    else
        % negative indices are renumberd from the end
        idx{i}(idx{i}<=0)=sx(dim(i))+idx{i}(idx{i}<=0);
    end
end
% defines the structure to be passed to SUBSERF function
S.type='()';
S.subs=cell(nd,1);
for i=find(exclude)
    S.subs(dim(i))={1:sx(dim(i))};
end
% retrieves elements from dimensions that are positive
S.subs(dim(~exclude))=idx(~exclude);
% retrieves unspecified dims
unspec=1:nd;
unspec(dim)=[];
% all elements of unspecified dimensions are retrieved
S.subs(unspec)={':'};
for i=find(exclude)
    % dim that were negative asked for those elements that are not
    % specified in idx
    S.subs{dim(i)}=setdiff(S.subs{dim(i)},idx{i});
end
Y=subsref(X,S);
if nargout>1 & isinf(dim)
    error('Structure S cannot be output when using Inf as dimension');
end
return
