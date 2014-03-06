function [keep,c,clim]=showpercent(p,hpatch,basecolor,cmap,asym)
%showpercent - Set the colormap to display some percentage of active sources
%
%[keep,c,clim]=showpercent(p,hpatch,basecolor,cmap,asym) 
%  Set the colormap to display some percentage of the most active sources
%  of the cortical surface (according to FaceVertexCData).
%INPUTS:
%   p: the percentage to keep (if p<0, the actual number, i.e. -p==keep)
%OPTIONAL INPUTS:
%   hpatch: handle to the patch surface. If missing, find it... If array,
%           If this is not a handle but an array of numbers, showpercent
%           compute the colormap that would display p% of those values.
%   basecolor: color to be used for unactive sources [.6 .6 .6]
%   cmap: colormap to use, if missing use the colormap of the figure
%   asym: 0:symmetical colormap (to display +/- values), 
%         1: positive; -1:negative values only
%OUTPUT:
%   keep: number of sources;
%   c: the new colormap
%   clim: the new limits for the colormap
%
% If FaceVertexCData is >=0 the CLim properties are changed to display only
% the p% most active sources and the lowest color is set to the basecolor.
% Otherwise (some FVCData<0), the ColorMap is symmetrized, with basecolor
% inserted in the middle to "mute" low-amplitude sources.

if p==0
    return
end
if nargin<2
    hpatch=findTessellationHandles;
end
if nargin<3 || isempty(basecolor)
    basecolor=[.6 .6 .6];
end
if nargin<4 || isempty(cmap)
    cmap=get(get(get(hpatch, 'Parent'), 'Parent'), 'Colormap');
    cmap=cmap(~all((cmap==repmat(basecolor, size(cmap,1), 1))'),:);        
end
if nargin<5
    asym=NaN;
end
if ishandle(hpatch)
cdata=get(hpatch, 'FaceVertexCData');
else
    cdata=hpatch;
end
cdata=cdata(:);
if p>0
    % Number of vertices to keep so that it make only X% 
    keep=round(p/100*size(cdata,1)); 
else
    keep=-p;    
end
if p==100 | keep == length(cdata)
    top=max(abs(cdata));
    bot=-top;
    c=cmap;   
elseif (isnan(asym) && any(cdata>0) & any(cdata<0)) || ~asym 
    f=-sort(-abs(cdata));
    bot=-f(1);
    top=f(1);
    noff=size(cmap,1)/2*f(keep)/(f(1) - f(keep));
    c=[cmap(1:end/2,:) ; repmat(basecolor, ceil(2*noff), 1) ; cmap(end/2+1:end,:)];
    %bot=cdata(f(keep))
    %neg=find(cdata<0);
    %pos=find(cdata>0);
    %nmap=length(colormap);  
    %c=[fliplr(flipud(cmap)); repmat(basecolor,nmap*100/p,1) ; cmap];
    % top=-bot;
    %     if top < 0
    %         top=-top;bot=-bot;
    %     end
elseif (isnan(asym) & all(cdata>=0)) || asym>0 
    f=-sort(-(cdata));
    top=f(1);
    % Alt. version: Colormap show also lower bound
    % bot=0;
    % noff=size(cmap,1)*f(keep)/(f(1) - f(keep));
    % c=[repmat(basecolor, ceil(2*noff), 1) ; cmap(1:end,:)];
    bot = f(keep+1);
    c=([basecolor; cmap]);
elseif (isnan(asym) & all(cdata<=0)) || asym<0 
    f=-sort(-(cdata));
    top=-f(keep+1);
    % Alt. version: Colormap show also lower bound
    % bot=0;
    % noff=size(cmap,1)*f(keep)/(f(1) - f(keep));
    % c=[repmat(basecolor, ceil(2*noff), 1) ; cmap(1:end,:)];
    bot = -f(1);
    c=([cmap;basecolor]);
    
end
if ishandle(hpatch)
    set(get(hpatch, 'Parent'), 'CLim', [bot top]);
    colormap(get(hpatch, 'Parent'),c);
end 
return


% ====================================================


% Previous version
cmap=hot(100).*(1-flipud(cumsum(ones(100,3))/100)*.6)+ ...
    (flipud(cumsum(ones(100,3))/100)*.6)



if any(cdata>0) & any(cdata<0)
    bot=cdata(f(keep))    
else
    bot=cdata(f(keep));
    top=cdata(f(1));
    if all(cdata<0)
        % All negative sign
        bot=-bot;
        top=-top;
    end    
    set(gca, 'CLim', [bot top]);
    if nargin < 4
        [ign, ci]=unique(colormap, 'rows');
        c=colormap;
        c=c(ci,:);
        if size(c,1) < size(colormap,1)    
            disp('Changing previous ColorMap')
            c=([basecolor; c(2:end,:)]);
        else
            disp('Adding gray to previous ColorMap')
            c=([basecolor; c]);
        end
    else
        c=([basecolor; cmap]);
    end
    
end
colormap(c);
colorbar
