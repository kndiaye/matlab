function [y]=continuity(x,l,dim,lm)
%continuity - Assess minimal continuity in data 
%   [y]=continuity(x,w,dim,wm)
%   x: ND-array of logical values (0/1)
%   w: length of consecutive values explored 
%   dim: dimension of x which is explored. Default: 1
%   wm: minimal true values in that window. Default: wm=w
%
% NB: This function is especially useful for assessing a minimal number of
% consecutive samples below a given significance threshold.
% E.g:  p is a Nc-channels x Nt-samples array of p values
% To assess a minimal length of 10 consecutive samples:
%   continuity(p,10,2)

% KND, 29-Aug-2005

if nargin<3
    dim=1;
end
if nargin<4
    lm=l;
end

sx=size(x);
x=logical(x);
x=nd2array(x,dim);

y=logical(zeros(size(x)));

mx=sx(dim);
for i=1:sx(dim)
    t=[-l+1:0];
    if i<l
        t=t+(l-i);        
    end
    while any(~y(i,:)) & max(t)<min(l,mx-i)
        y(i,:)=y(i,:) | sum(x(i+t,:))>=lm;
        t=t+1;
    end
end
y=nd2array(y,-dim,sx);
