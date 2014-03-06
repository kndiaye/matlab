function [z]=zscore(a,t,dim)
% zscore - compute z-score
% [z]=zscore(a, t ,[dim])
if nargin<3
    dim=2;
end
sz=size(a);
if nargin<2
    t=1:sz(dim)
end
if length(t)==1
    t=1:t;
end
z = normalize(a,'baseline',dim,t,'z');
return


% 
% [z]=zscore(a, t ,[dim])
% 
% a: N-by-T matrix
% t: baseline samples: single value=nb of samples (t<T) or array=index 
% dim: Time dimension (default, 2)
% ex: >> z=zscore(F, 100)  -> 100 first samples
%     >> z=zscore(F, 1:100) -> idem
if nargin<3
    dim=2;
end
sz=size(a);
if nargin<2
    t=1:sz(dim)
end
if length(t)==1
    t=1:t;
end
nd=ndims(a);
a=permute(a, [dim setdiff(1:nd,dim)]);
z=a(:,:)./(repmat(std(a(t,:)),sz(dim),1) + eps);
z=reshape(z,sz([dim setdiff(1:nd,dim)]));
z=ipermute(z, [dim setdiff(1:nd,dim)]);

