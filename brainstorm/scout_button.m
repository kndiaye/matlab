function [varargout]= scout_button(action,varargin)
% Add a GUI button on a figure to click scouts etc.
% scout_button;
% [hbtn] = scout_button;
% [hbtn] = scout_button('action', 'Property1', ...);
%          e.g. scout_button('init','Position', [x y dx dy])
%               scout_button('set','UserData', handle_cortex)
%               scout_button('click', handle_cortex)
%
if nargin==0
    action='init';
end
switch(action)
    case 'init'
        hbtn=action_init(varargin{:});
        if nargout>0
            varargout={hbtn};
        end
    case 'click'
        [idx_scout,hctx,hbtn]=action_click(varargin{:});
        if nargout>0
            varargout={idx_scout,hctx,hbtn};
        else
            ns = numel(idx_scout);
            z=get(hctx, 'FaceVertexCData');
            assignin('base', 'ans', idx_scout);
            for i=1:min(ns,10)
                fprintf('\nScout #:%d', idx_scout(i));
                if ~isempty(z)
                    fprintf('\tValue:%g', z(idx_scout(i)));
                end
                fprintf(' (variable ans has been changed)\n');
            end
            if ns>1 && ~isempty(z)
                fprintf('... %d scouts in the cluster ...\n',ns);
                fprintf('Mean value : %g \n',mean(z(idx_scout)));
            end
        end
end

function [hbtn]=action_init(varargin)
delete(findobj(gcf, 'Tag', mfilename, 'Style', 'pushbutton'))
hbtn=uicontrol('Style', 'pushbutton','Tag', mfilename);
test_select3d;
set(hbtn, 'String', 'Scout');
set(hbtn, 'Units', 'normalized');
set(hbtn, 'Callback', 'scout_button(''click'', gcbo);');
action_set(hbtn, varargin{:});

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

%
ctx=getappdata(hctx);
if button > 1
    if isempty(fieldnames(ctx))
        fv.faces = get(hctx,'Faces');
        fv.vertices = get(hctx,'Vertices');
        vc=tess_vertices_connectivity(fv);
        f=get(hctx,'FaceVertexCData');

        if size(f,2)==3
            % try to guess what appears "activated"
            [v,n]=histk(f,'rows');
            v=v(n>.25*size(f,1),:);
            f = ~ismember(f,v, 'rows');
        end
        if all(f)
            fprintf('Using Color threshold, based on CLim')
            % use CLim
            f=f.*(f>min(get(ax,'Clim')));
        end
    end

    [c,sz,mc,v2c] = clustering(f,vc);
    if v2c(vi) == 0
        vi = []
    else
        vi = c{v2c(vi)};
    end
    hold on
    hplot=plot3(fv.vertices(vi,1),fv.vertices(vi,2),fv.vertices(vi,3),'.');
    drawnow;
    pause(1)
    delete(hplot)
    hold off
end
if not(isfield(ctx, 'tex'))
    %     warning('No texture (''AppData''.tex) is associated with this cortical surface')
    return
end
figure('Name', sprintf('Vertex %d [%0.2g %0.2g %0.2g]', vi, v));
if ~isfield(ctx, 'time')
    ctx.time=1:size(ctx.tex,2);
end
plot(ctx.time, ctx.tex(vi,:));
hold on;
if isfield(ctx, 'htime')
    stem(ctx.time(get(ctx.htime, 'Value')), ctx.tex(vi,get(ctx.htime, 'Value')), '.r');
end
% psh_scout_cbk=['ginput(1);' scout_cbk];

