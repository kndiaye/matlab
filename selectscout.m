function [vi,p,fi,v,f]=selectscout(ctx)
% selectscout - Select scout on the cortical surface
%   [vi,p,fi,v,f]=selectscout(ctx) selects a vertex on the patch surface ctx
%       If ctx not given, find the tessellation.
%       If ctx=[] the surface used is the one one which the user click.
if nargin<1
    ctx=findTessellationHandles;
end
if ~isempty(ctx)    
    axes(get(ctx, 'Parent'));
end

ginput(1);
if isempty(ctx)   
    ctx=gco;
end
[p v vi f fi]=select3d(ctx);
