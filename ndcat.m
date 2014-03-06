function M = ndcat(d,varargin)
%NDCAT - Assemble matrices as blocks
%   [M] = ndcat(d,A,B,C,...) constructs the matrix M which is the
%   concatenation of matrices A, B, C,... along dimension(s) given in d.
%   NDCAT fills with zeros.
%       A,B,C,... are matrices to be assembled
%       d: Specify along which dimensions the concatenation should proceed
%          Examples:
%          d=[1 1] would place matrices in the diagonal, ie growing
%          both dimension 1 (rows) and dimension 2 (columns).
%          d=[0 1] would place matrices horizontally, that is without
%          increasing the 1st dimension (rows)
%          If d=[], default is to concatenate along the diagonal.
%          If d has multiple rows, each row corresponds to the 
%          concatenations with the corresponding matrix in the list:
%          d(1,:) specifies how B should be concatenated with A; 
%          d(2,:) specifies how C should then be concatenated with the
%          outcome of the previous concatenation (of A and B), etc.
%          d can also be provided as a cell array: d={[dB], [dC], etc}
%
%   Presently, NDCAT works only with 2-D matrices
%
%   Example
%       >> ndcat([1 1], ones(2,3), 2*eye
%
%   See also:

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2007
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2007-10-30 Creation
%
% ----------------------------- Script History ---------------------------------

if nargin==2
    M=varargin{1};
    return
end


%% Check input d
nm=nargin-1;
nd=0;
% sz=[];
for i=1:nm
    nd(i)=ndims(varargin{i});
    % sz(i,1:nd(i))=size(varargin{i});
end
if iscell(d)
    dd=[];
    for i=1:length(d)
        dd(i,1:length(d{i}))=d{i};
    end
    d=dd;
end
if isempty(d)
    % where to put matrices relatively to the others
    d=ones(1,max(nd));
end
if size(d,1)==1
    d=repmat(d, [nm-1,1]);
end
if size(d,1)~=(nm-1)
    error('Number of matrices and specifier ''d'' don''t match')
end
if size(d,2)==1
    d=[d ones(nm-1,max(nd)-1)];
end

%% recursive call
N=ndcat(d(1:end-1,:), varargin{1:end-1});
d=d(end,:);
nn=numel(N);
sn=size(N);
dn=ndims(N);
Z=varargin{end};
sz=size(Z);
dz=ndims(Z);
if isequal(d, [1 1])
    M=[N zeros(sn(1),sz(2)) ; zeros(sz(1),sn(2)) Z];
elseif isequal(d, [0 1])
    M=[ [N;zeros(max(0,sz(1)-sn(1)),sn(2))] [Z;zeros(max(0,sn(1)-sz(1)),sz(2))] ] ;
elseif isequal(d, [1 0])
    M=[ [N zeros(sn(1),max(0,sz(2)-sn(2)))];[Z zeros(sz(1),max(0,sn(2)-sz(2)))] ] ;
else
    error('Can''t process multidim arrays yet')


end

return
if nz<nd
    d(nd)=0;
    sz(nd)=0;
elseif nd<nz
    sn(nz)=0;
end
sm=sn+d.*sz;
M=zeros(sm);
idx=[1:numel(varargin{end})]';
r=0.*idx;
for j=1:nz-1
    r=r+[0:sz(j)-1]
    if sz(j)>1
        r=r+[0:sz(j)-1]'*ones(1,sz/(sz(j)-1));
    end
    idx=idx+r(:);
end
M(idx)=varargin{end};

return

% nd(2)=ndims(varargin{end});
% sz(2,1:nd(2))=size(varargin{end});
% ne=numel(N);
%% ndx = ndx + (v-1)*k(i);
%
% for i=1:nm
%     idx=[];
%     for j=1:nd(i)-1
%         z=idx
%         if i==1 && j==1
%             z=1;
%         end
%         ne=prod(msz(1:j))
%         for k=1:sz(i,j)
%             idx=[idx, z+ne*(k-1)]
%         end
%     end
%
%
%     M(idx)=varargin{i}
% end
%
% idx