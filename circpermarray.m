function [y]=circpermarray(x,pv,dim)
% circpermarray - circularly permute values in an array
% 
% [y]=circpermarray(x,pv,dim)
%
% pv: length of the permutation. 
% dim: dimension on which permutation is done. 
%
% NB: The direction of permutation is top-down (dim==1) and
% left-right (dim==2). Of course!

if nargin<3
  [dim]=min(find(size(x)>1));
  if isempty(dim)
      dim=1;
  end
end
sx=size(x);
pd=[dim, 1:dim-1 dim+1:ndims(x)];
%permute dimensions
x=permute(x,pd);
pv=mod(pv, sx(dim));
x=x([end-pv+1:end 1:end-pv],:);
x=reshape(x,sx(pd));
y=ipermute(x,pd); 

return

  