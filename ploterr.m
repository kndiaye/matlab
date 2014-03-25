function [h,Options]=ploterr(x,y,s,varargin)
% ploterr - plot with a patch representing dispersion/error around the value
% [h]=ploterr(x,y,s)
% [h]=ploterr(y,s)
% [h]=ploterr(y)
%
% Plots data y with their dispersion s, given abscissa x.
%INPUTS:
%   x: T-long vector, abscissa for data point (if not given: x=[1:length(y)])
%   y: T-by-N matrix of mean data points (N may be 1)
%   s: T-by-N matrix of dispersion around mean for each data point
%OUTPUT:
%   h is N-by-2 array of handles: h(:,1) are the lines, h(:,2) the patches
%
% [h]=ploterr(x,y,s, 'Color', [r g b], 'FaceColor', [r g b], ...)
% [h]=ploterr(x,y,s, Options)
%
%OPTIONS:
%   'Color': Color of the curve(s) as [R G B] triplet(s)
%   'PatchColor': Color of the patch (representing dispersion)
%   'FaceAlpha': Transparency of the patch surface
%   'EdgeAlpha': Transparency of the edge of the patch
%
% If no s is provided. Default is to plot the STANDARD ERROR around the
% mean: 
%       s=std(y)/sqrt(n);
%       y=mean(y);
% ie. y is assumed to be a [ K x T x N ] matrix (of K observations/subjects) 

if nargin<2
    y=x;
    x=[];
end
if nargin<3
    s=[];
end
if ~isempty(s) && ischar(s)
    varargin=[{s} varargin];
    s=[];    
end
Options.Color=get(gca, 'ColorOrder');
Options.Color([1 2 3],:)=Options.Color([1 3 2],:);
Options.PatchColor=brighten(Options.Color,.97);
Options.FaceAlpha = 0.35;
Options.EdgeAlpha = 0.5;
if nargin>3
    Options=mergestructs(Options,struct(varargin{:}));
end
if isempty(s)
    s=shiftdim(std(y),1)./sqrt(size(y,1));
    y=shiftdim(mean(y),1);
end
if isempty(x)
    x=[1:size(y,1)]';
end

if numel(y)~=max(size(y)) 
    % Not a 1-D vector, recursively ploterr() each level across dimensions
    holdstate=ishold;
    y=y(:,:);
    s=s(:,:);
    for i=1:size(y,2)
        o=Options;
        o.Color=circshift(Options.Color,1-i);
        o.PatchColor=circshift(Options.PatchColor,1-i);
        [h(i,:)]=ploterr(x,y(:,i),s(:,i),o);
        hold on
    end    
    if ~holdstate
        hold off
    end
    return
end

px=[x(:); flipud(x(:))];    % use px=[x1;x2(end:-1:1)]; if row vecs
py=[ y(:)-s(:) ; flipud(y(:)+s(:)) ];    % use ...

holdstate=ishold;
delete(plot(x(1),y(1)));
hold on
% We want the patch to be under the curve
h=[patch(px, py, Options.PatchColor(1,:))];
h=[plot(x,y, 'LineWidth', 2,'Color', Options.Color(1,:)) h];

% set(h, 'FaceAlpha', .5)
set([h(:,2)], 'FaceAlpha', Options.FaceAlpha);
set([h(:,2)], 'EdgeAlpha', Options.EdgeAlpha);

if ~holdstate
    hold off;
end

return

