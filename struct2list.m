function [C]=struct2list(S,depth,flat)
%struct2list - List each field and its content in an vertical cell array
%
%   [C]=struct2list(S)
%   Lists each fieldname and its content into a 2-column cell array. This
%   is useful to pass structures as argument to function according to the
%   scheme: 
%       function('name', value, 'name', value, ...)
%
%   [C]=struct2list(S,depth) also expand the subfields which are
%   themselves struct's. Down to a given depth. Use depth=Inf to explore
%   the full arborescence. Default: depth=0 (i.e. no recursion)
%
%   [C]=struct2list(S,depth,flat) if flat=1 (default) the structure is
%   'flattened' i.e. the field names in the first column are of the form:
%   'field.subfield' .
%
%   If S is an array of struct's, C will be (N-by-2)-by-size(S)
%
%   Example
%       >> struct2list(ver,Inf,1)
%
%   See also:

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2009
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2009-04-03 Creation
%
% ----------------------------- Script History ---------------------------------
if nargin<1
    error('No input!');
end
if ~isstruct(S)
  error('S should be a struct or a struct array!');
end

if nargin<2
    depth=0;
end
if nargin<3
    flat=1;
end
C=[];
nS = numel(S);
f=fieldnames(S);
nf=numel(f);
for i_S=1:nS
    D=[];
    c=struct2cell(S(i_S));
    for i=1:nf
        fi = f(i);
        x = c(i);
        if depth
            if isstruct(x{1})
                if flat		  		  
		  x = struct2list(x{1}, depth-1);
		  nsub=size(x,1);	      
		  if isempty(x)
		    fi = { fi{1} };
		    x={[]};
		  else
		    fi = [repmat([ fi{1} '.' ],nsub,1) strvcat(x(:,1))];
		    fi = cellstr(fi);
		    x=x(:,2);	
		  end
                else
		  x = {struct2list(x{1}, depth-1)};
                end
	    end
        end
        D = [ D ; [fi x]];
    end
    C=cat(3,C,D);
end
C=reshape(C, [ size(C,1) size(C,2) size(S)]);
