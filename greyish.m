function [cmap]=greyish(cmap,p,greycolor,style)
%GREYISH - Make a colormap more grey
%   [cmap2]=greyish(cmap,p,greycolor)
%   Make the colors in cmap (default: current color map) to go from a
%   grey color (default: .6 .6 .6) to the hues already present. The amount
%   of grey-ing is given by p (default: p=1/3). Greater p make the colormap
%   more grey. 
%
%   [cmap2]=greyish(cmap,p,greycolor,style)
%       style = 'bottom'(default) 'middle' 'top' 

if nargin<1
    cmap=colormap;
end
if nargin<2 || isempty(p)
    p=1/3;
end
if p==0
    return
end
if nargin<3 || isempty(greycolor)
    greycolor=[.6 .6 .6];
end
if nargin<4
    style=0;
end
if ischar(style)
    switch(style)
        case 'bottom', style = 0 ;
        case 'top', style = 1;
        case 'middle', style = 0.5 ;
    end
end

if p<0
    %in earlier versions, negative p's put the grey at the top 
    p=-p;
    style=1-style;
end
nc = size(cmap,1);
if p<=1    
    n=round(nc*p);
else
    n=p;
end
if style == .5
    n=(n/2);
    x=linspace(0,1,ceil(n)+1)'*[1 1 1];
    x(end,:)=[];
    if size(x,1)<=n
        x=[flipud(x); 0 0 0; x(2:end,:)];
    else
        x=[flipud(x);x(2:end,:)];
    end
else
    x=linspace(0,1,n+1)'*[1 1 1];
    x(end,:)=[];
end
%x=x.^(1 - min(1-sqrt(eps),abs(beta)));

if style == 0 && p > 0
    cmap(1:n,:)=repmat(greycolor,n,1).*(1-x)+cmap(1:n,:).*x;
elseif (style ==1 && p > 0) || (style == 0 && p < 0)
    nc=length(cmap);
    cmap(nc+1-[1:n],:)=repmat(greycolor,n,1).*flipud(x)+cmap(nc+1-[1:n],:).*x;
elseif style==.5
    i = nc*style+ceil([-(n):(n-1)]);
    i=i(i>0 & i<=nc);
    cmap(i,:)=repmat(greycolor,length(i),1).*(1-x)+cmap(i,:).*x;
end


return
b=([[n:-1:1]/n]'*[1 1 1]).^(300);
c=hot(n).*(1-b*.6)+ (b*.6);