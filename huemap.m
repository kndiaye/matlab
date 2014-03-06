function [cmap]=huemap(hue,n,beta,skew)
% huemap - creates a colormap around a given hue
%
% [cmap]=huemap(hue,n,beta)
% The colormap is from black to white, centered around the hue
% INPUTS:
%   hue: a 1x3 or 3x3 RGB colormap. First line is the hue. Other are
%        optional
%        Second is the bottom of the spectrum (default: black). 
%        Third is the top default: white.  
%   n: number of colors in the colormap, default the size of the current
%      colormap
%   beta: a parameter for the shape of the spectrum, default=0
%         beta>0 => more contrast
%         If beta is a 2x1 vector, beta(1) apply to the darker part of the
%         spectrum and beta(2) apply to its lighter part.
% OUTUTS:
%   cmap: a nx3 colormap
if size(hue,1)<2
    hue(2,:)=[0 0 0];
end
if size(hue,1)<3
    hue(3,:)=[1 1 1];
end
if nargin<3
    beta=0;
end
if length(beta)==1
    beta=[beta beta];
end
if nargin<2
    n=size(colormap,1);
end
% From BRIGHTEN function:
tol = sqrt(eps);
glight=1 - min(1-tol,beta(2));
gdark=1/(1 + max(-1+tol,-beta(1)));

% lighter hues
b=linspace(0,1,n-round(n/2)+1).^glight';
cmap = [ ones(n-round(n/2)+1,1)*hue(1,:) + b*[hue(3,:)-hue(1,:)] ];

% remove duplicated center hue
cmap(1,:)=[];
% darker hues
b=linspace(0,1,round(n/2)).^gdark';
b=flipud(b);
cmap=[ ones(round(n/2),1)*(hue(1,:)) + b*(hue(2,:)-hue(1,:))  ; cmap];

cmap=max(cmap,0);
cmap=min(cmap,1);
return
