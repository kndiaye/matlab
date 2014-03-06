function [sz,idx]=piecemeal(p) % ,dim,minsize)
% piecemeal - find continuous segments of true in a logical array
%
%   [sz,idx]=piecemeal(p)
%INPUT:
%   p: logical vector
%OUPUTS:
%   sz: size of the chunks/clusters/segment...
%   idx: position of the first element of each chunk

dim=1;
p=p(:);
p=logical(p);
np=size(p,dim);
dip=diff(cumsum(p),2);
dp1=find(dip==1)+2;
dp2=find(dip==-1)+2;
if isequal(p(1),[1])
    dp1=[1; dp1];   
    if isequal(p(2),[0])
        dp2=[2; dp2];
    end
elseif isequal(p(2),[1])
    dp1=[2; dp1];
end    
if isequal(p(end),[1])
    dp2=[dp2; np+1];       
end    
sz=dp2-dp1;
idx=dp1;

return

% one patch per col
dp=diff(p);
fdp=find(dp)
pfdp=p(fdp)

fx=[fdp; fdp];
fx=[1 fx(:)' length(p)]
fy=[[p(fdp) p(end)]; [p(fdp) p(end)]];
fy=[fy(:)'];
