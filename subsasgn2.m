function X = subsasgn2(X,v,varargin)
%SUBSASGN2 - User-friendlier subscripted assignment.
%   [Y] = subsasgn2(X,v,i,dim) outputs array Y where some values in X have
%   been replaced by the value given in v
%
%   Example
%       >> subsasgn(magic(5),0,3,2) set the 3rd column to 0
%       NaN's
%
%   See also: 

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2010 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2010-04-21 Creation
%                   
% ----------------------------- Script History ---------------------------------

sx=size(X);
if nargin<2
    return; %previously error('No indices given!')
elseif nargin>2
    inputs=varargin;
    if rem(nargin-1,3)
        error('Indices & dimensions should be given in triplets')
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
    S.subs{dim(i)}=setdiff(1:sx(dim(i)),idx{i});
end
X=subsasgn(X,S,v);
if nargout>1 & isinf(dim)
    error('Structure S cannot be output when using Inf as dimension');
end
return