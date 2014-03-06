function [cmap]=grayish(cmap,p,graycolor)
%GRAYISH - Make a colormap more gray
%   [cmap2]=grayish(cmap,p,graycolor)
%   Make the colors in cmap (default: current color map) to go from a
%   gray color (default: .6 .6 .6) to the hues already present. The amount
%   of gray-ing is given by p (default: p=1/3). Greater p make the colormap
%   more gray. 
%   
if nargin<1
    cmap=colormap;
end
if nargin<2
    p=1/3;
end
if p==0
    return
end
if nargin<3
    graycolor=[.6 .6 .6];
end
n=abs(p);
if n<=1
    n=round(length(cmap)*n);
end
x=linspace(0,1,n+1)'*[1 1 1]; 
x(end,:)=[];
%x=x.^(1 - min(1-sqrt(eps),abs(beta)));
if p>0
    cmap(1:n,:)=repmat(graycolor,n,1).*(1-x)+cmap(1:n,:).*x;    
else
    nc=length(cmap);
    cmap(nc+1-[1:n],:)=repmat(graycolor,n,1).*flipud(x)+cmap(nc+1-[1:n],:).*x;
end

return
b=([[n:-1:1]/n]'*[1 1 1]).^(300);
c=hot(n).*(1-b*.6)+ (b*.6);