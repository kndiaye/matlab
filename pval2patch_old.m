function [hp]=pval2patch(p,X,thd,color)
% pval2patch - plot a patch surface onto a graph where p==1
%   [hp]=pval2patch(p)
%   [hp]=pval2patch(X,p)

isholdon=ishold;
hold on
h0=get(gca, 'children');
color=[.85 .85 .85];

if nargin>1
    tmp=p;
    p=X;
    X=tmp;
    clear tmp;
end

p=logical(p(:))';
% one patch per col
dp=diff(p);
fdp=find(dp);
pfdp=p(fdp);

fx=[fdp; fdp];
fx=[1 1 fx(:)' length(p) length(p)];
fy=[[p(fdp) p(end)]; [p(fdp) p(end)]];
fy=[0 fy(:)' 0];

ylim=get(gca, 'Ylim');
fy=ylim(2)*fy + ylim(1)*(~fy);

if exist('X', 'var')
    fx=X(fx);
end

% fy=[p(1) fy];
hp=patch(fx',fy',color);
set(gca, 'Children', [h0;hp; ])
if ~(isholdon)
    set(gca, 'NextPlot', 'replace');
end
