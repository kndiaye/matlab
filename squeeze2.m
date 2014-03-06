function b = squeeze(a,dims)
%SQUEEZE Remove singleton dimensions & squeeze some others
%   B = SQUEEZE(A) behaves as the native SQUEEZE()
%   B = SQUEEZE(A, [d1 d2 ... ]) reshapes so that dimensions d1, d2 etc.
%   are merged into a single one
%
%   For example,
%       squeeze(rand(2,1,3))
%   is 2-by-3.
%
%   See also SHIFTDIM, SQUEEZE.

if nargin==1
    b=squeeze(a);
end

if ndims(a)>2,
  siz = size(a);
  siz(siz==1) = []; % Remove singleton dimensions.
  siz = [siz ones(1,2-length(siz))]; % Make sure siz is at least 2-D
  b = reshape(a,siz);
else
  b = a;
end
