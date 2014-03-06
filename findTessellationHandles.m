function [ hp, ha, hf ] = findTessellationHandles( varargin )
%findTessellationHandles - Find ancestors handles related to a patch surface
%  
% [ hp, ha, hf ] = findTessellationHandles 
%   Try to guess the handles to the patch, its axes and it figure
%         
% [ hp, ha, hf ] = findTessellationHandles( h )
%   h may be a (list of) handle to a patch, axes or figure

h=[];
hf=[];
ha=[];
hp=[];
if nargin>0
    h=varargin{1};
end
h=h(ishandle(h));
if isempty(h)
    h=0;
    h=[get(h(1), 'CurrentFigure') h ];
    h=[get(h(1), 'CurrentAxes') h ];
    h=[gco h ];    
end
if ~isempty(h)
    if isequal(get(get(h(end), 'Parent'), 'Type'), 'axes')
        h=[h get(h, 'Parent')];
    end
    if isequal(get(get(h(end), 'Parent'), 'Type'), 'figure')
        h=[h get(h(end), 'Parent')];
    end
end
for i=1:length(h)
    hp=[findobj([h(i)], 'Type', 'patch'); ...
        ]; % findobj([h(i)], 'Type', 'surface');];
    if ~isempty(hp)
        break
    end
end
switch length(hp)
    case 0
        hp=[];
        ha=findobj([h], 'Type', 'axes');
        hf=findobj([h], 'Type', 'figure');
        return
    case 1
        % nothing to do
    otherwise
        hp=hp(1);        
end

ha=get(hp, 'Parent');
hf=get(ha, 'Parent');

return


% 
% OLDIES
% 





if isequal(get(get(h, 'Parent'), 'Type'), 'axes')
    
end

if ~isempty(hp)
    ha=get(hp, 'Parent');
elseif isequal(htype, 'axes')
    ha=h;        
end 

if ~isempty(ha)
    hf=get(ha, 'Parent');
elseif isequal(ha, 'figure')
    hf=h;
end

if isempty(hp)    
    
    try, hp=hp(1); end
end

if isempty(hp)
    ha=get(hp, 'Parent');   
    if isempty(ha)
        ha=findobj(hf, 'type', 'axes');
    end
    hf=get(ha, 'Parent');
end