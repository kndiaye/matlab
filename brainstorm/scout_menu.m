function [hmenu]= scouts_menu(action, varargin)
% cortex_menu - Menu related to cortical surface processing

if nargin==0
    action='init';
end
switch(action)
    case {'init', 'create'}
        hmenu=action_init(varargin{:});
        if nargout>0
            varargout={hmenu};
        end
    case 'click'
        [idx_scout,hctx,hbtn]=action_click(varargin{:});
        if nargout>0
            varargout={idx_scout,hctx,hbtn};
        else
            z=get(hctx, 'FaceVertexCData');
            assignin('base', 'ans', idx_scout);
            disp(sprintf('Scout #:%d  Value:%g', idx_scout, z(idx_scout)));
        end
end


function [hbtn]=action_init(varargin)
hmenu = uimenu('Label','Scout manager');
cback='uhp=get(findTessellationHandles, ''UserData'');';
% delete(findobj(gcf, 'Tag', mfilename, 'Style', 'pushbutton'))
% hbtn=uicontrol('Style', 'pushbutton','Tag', mfilename);
hbtn=uimenu('Label','Pick one...', 'Parent', hmenu, 'Tag', mfilename);
test_select3d;
set(hbtn, 'Callback', 'scout_menu(''click'', gcbo);');
action_set(hbtn, varargin{:});

%         set(hmenu, 'Callback',[ cback ...
%             'if isfield(uhp, ''vertconn''), state=''on''; else state=''off''; end;'...
%             'set(findobj(gcbo, ''Label'', ''Smooth surface''), ''Enable'',state);'...
%             'set(findobj(gcbo, ''Label'', ''Adv. Smooth surface''), ''Enable'', state);'...
%             ]);

%         t1 = uimenu('Parent',hmenu,...
%             'Label','Define scout',...
%

function b=test_select3d
if exist('select3d')<2
    warning('Function needs BrainStorm/PublicToolbox/OtherTools/select3D.m')
    b=0;
else
    b=1;
end

function[hbtn]=action_set(hbtn,varargin)
if nargin==2
    set(hbtn, 'UserData', varargin{1});
elseif nargin>1 && mod(nargin-1,2)==0
    set(hbtn, varargin{:});
end


function [vi,hctx,hbtn]=action_click(varargin)
if ~test_select3d
    return
end
hctx=[];
if nargin==0
    hbtn=gcbo;
else
    if isequal(get(varargin{1}, 'Tag'), mfilename)
        hbtn=varargin{1};
        hctx=get(hbtn, 'UserData');
    else
        hctx=varargin{1};
        hbtn=[];
    end
end
if isempty(hctx)
    try
        hctx=findTessellationHandles;
    catch
    end
end
if isempty(hctx)
    error('No surface found');
    return
end
ax=get(hctx, 'Parent');
axes(ax);
[x, y, button] = ginput(1);
[p v vi f fi]=select3d(hctx);;

figure('Name', sprintf('Vertex %d [%0.2g %0.2g %0.2g]', vi, v));
ctx=getappdata(hctx)
if button > 1
    if isempty(fieldnames(ctx))   
        fv.faces = get(hctx,'Faces');
        fv.vertices = get(hctx,'Vertices');        
        vc=tess_vertices_connectivity(fv);
        f=get(hctx,'FaceVertexCData');
        if all(f)
            % use CLim 
            f=f.*(f>min(get(ax,'Clim')));
        end
        
    end
end


if not(isfield(ctx, 'tex'))
%     warning('No texture (''AppData''.tex) is associated with this cortical surface')
    return
end
if ~isfield(ctx, 'time')
    ctx.time=1:size(ctx.tex,2);
end
plot(ctx.time, ctx.tex(vi,:));
hold on;
if isfield(ctx, 'htime')
    stem(ctx.time(get(ctx.htime, 'Value')), ctx.tex(vi,get(ctx.htime, 'Value')), '.r');
end
% psh_scout_cbk=['ginput(1);' scout_cbk];




