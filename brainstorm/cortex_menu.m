function [varargout]= cortex_menu(action, varargin)
% cortex_menu - Menu related to cortical surface processing
%
%   cortex_menu('action') with following possible actions:
%         create
%         vertconn_state(ho,hctx)
%         compute_vertconn(hctx)
%         smooth_surface(hctx,a, nIterations)
%         trimsurface
%         curvature
%         extent_threshold(hctx,z)
%         move_hemi_away(hctx)
%         move_hemi_closer(hctx)
%         open_hemi(hctx)
%         move_hemi_closer(hctx)
%         hide_hemi(hctx)

if nargin==0
    action='create';
end
try
    varargout={eval(sprintf('action_%s(varargin{:});',action))};
catch
    eval(sprintf('action_%s(varargin{:});',action));
end

return

function [hmenu]=action_create
delete(findobj(gcf, 'Tag', mfilename))
hmenu = uimenu('Label','Surface processing','Tag',mfilename);
cback='o=findTessellationHandles; uhp=get(o, ''UserData''); if isempty(uhp); uhp.vertices=get(o, ''Vertices''); uhp.faces=get(o, ''Faces''); uhp.h=o; end;';

set(hmenu, 'Callback',[ ...
    'cortex_menu(''vertconn_state'', gcbf);'...
    ]);

t = uimenu('Parent',hmenu,...
    'Label','Vertex Connectivity',...
    'CallBack',[ ...
    sprintf('%s(''%s'',gcbo);',mfilename,'compute_vertconn')
    ]);

t = uimenu('Parent',hmenu,...
    'Label','Smooth surface',...
    'CallBack',[ sprintf('%s(''%s'',gcbo);',mfilename,'smooth_surface') ]);

t = uimenu('Parent',hmenu,...
    'Label','Adv. Smooth surface',...
    'CallBack',[ cback ...
    'vals=inputdlg({''Smoothing factor'',''Iterations''}, ''Smooting parameters'', 1 , {''.3'', ''20''});'...
    sprintf('%s(''%s'',gcbo,str2num(vals{1}),str2num(vals{2}));',mfilename,'smooth_surface')...
    'clear uhp p vals;'...
    ]);

t = uimenu('Parent',hmenu,...
    'Label','Move hemispheres apart','Enable', 'on',...
    'CallBack',[ ...
    sprintf('%s(''%s'',gcbo);',mfilename,'move_hemi_away')
    ]);

t = uimenu('Parent',hmenu,...
    'Label','Put closer hemispheres','Enable', 'on',...
    'CallBack',[ ...
    sprintf('%s(''%s'',gcbo);',mfilename,'move_hemi_closer')
    ]);

t = uimenu('Parent',hmenu,...
    'Label','Open hemispheres','Enable', 'on',...
    'CallBack',[ ...
    sprintf('%s(''%s'',gcbo);',mfilename,'open_hemi')
    ]);

t = uimenu('Parent',hmenu,...
    'Label','Back to original surface',...
    'CallBack',[ cback ...
    sprintf('%s(''%s'',gcbo);',mfilename,'revert_surface')
    ]);

t = uimenu('Parent',hmenu,...
    'Label','Add surface curvature',...
    'CallBack',[ ...
    'cs=curvature_cortex(uhp,uhp.vertconn,.1,0);'... %'cs=blend_anatomy_data(cs, uhp.data);'...
    'set(uhp.h, ''FaceVertexCData'', cs);'...
    'clear cs uhp;'...
    ],'Enable', 'off');


t = uimenu('Parent',hmenu,...
    'Label','Trim surface',...
    'Separator', 'on', ...
    'CallBack',[ cback ...
    'trimsurface_gui(uhp.h);'...
    'clear vuhp;'...
    ],'Enable', 'on');



t = uimenu('Parent',hmenu,...
    'Label','Hide/show hemispheres',...
    'Separator', 'on', ...
    'CallBack',[ ...
    sprintf('%s(''%s'',gcbo);',mfilename,'hide_hemi')
    ],'Enable', 'on');


t = uimenu('Parent',hmenu,...
    'Label','Remove small clusters',...
    'Separator', 'on', ...
    'CallBack',[ sprintf('%s(''%s'',gcbo);',mfilename,'extent_threshold') ],'Enable', 'on');



return

function []=action_revert_surface(ho,hctx)
if nargin<1 || ~isequal(get(hctx, 'type'), 'patch')
    hctx=findTessellationHandles;
end
uhp=get(hctx, 'UserData');
if isempty(uhp); return; end;
set(uhp.h, 'Vertices', uhp.vertices);
    
function []=action_vertconn_state(ho,hctx)
if ~exist('tess_vertices_connectivity')
    try
        figure
        if ~ispc
            addpath('~/mtoolbox/brainstorm3/toolbox/misc/')
        end
        addpath('/mtoolbox/brainstorm3/toolbox/misc/')
    end
    if ~exist('tess_vertices_connectivity')
        errordlg({...
            'You need to add the path of the BrainStorm Toolbox' ...
            'E.g.:' ...
            '  >> addpath(''C:/BrainStorm/Toolbox'')'}, 'No BrainStorm found')
        return
    end
end
set(findobj(gcbo, 'Label', 'Vertex Connectivity'), 'Checked', 'off');
set(findobj(gcbo, 'Label', 'Vertex Connectivity'), 'Enable', 'off');
set(findobj(gcbo, 'Label', 'Smooth surface'), 'Enable','off');
set(findobj(gcbo, 'Label', 'Adv. Smooth surface'), 'Enable', 'off');
if nargin<2
    hctx=findTessellationHandles;
end
uhp=get(hctx, 'UserData');
if isempty(uhp); return; end;
set(findobj(gcbo, 'Label', 'Vertex Connectivity'), 'Enable', 'on');
if isfield(uhp, 'vertconn'),
    state='on';
else
    state='off';
end;
set(findobj(gcbo, 'Label', 'Vertex Connectivity'), 'Checked', state);
set(findobj(gcbo, 'Label', 'Smooth surface'), 'Enable',state);
set(findobj(gcbo, 'Label', 'Adv. Smooth surface'), 'Enable', state);
clear uhp;


function []=action_compute_vertconn(hctx)
if nargin<1 || ~isequal(get(hctx, 'type'), 'patch')
    hctx=findTessellationHandles;
end
uhp=get(hctx, 'UserData');
if isempty(uhp); return; end;
uhp.vertconn=tess_vertices_connectivity(uhp);
set(uhp.h, 'UserData', uhp);
h=uhp.h
clear uhp;
action_vertconn_state(get(h, 'parent'), h);



function action_smooth_surface(hctx,a, nIterations)
if nargin<1 || ~isequal(get(hctx, 'type'), 'patch')
    hctx=findTessellationHandles;
end
if nargin<3
    nIterations=10;
end
if nargin<2
    a = .3;
end
uhp=get(hctx, 'UserData');
if isempty(uhp); return; end;
p=handle2struct(uhp.h);
p=lowerfields(p.properties);
if ~isfield(uhp,'vertconn')
    action_compute_vertconn(hctx)
    uhp=get(hctx, 'UserData');
end
[v]=tess_smooth(p.vertices',a, nIterations,uhp.vertconn);
set(uhp.h, 'Vertices', v');


function [curvature,curvature_sigmoid]=compute_curvature(hctx,VertConn,sigmoid_const)
if nargin<3
    sigmoid_const=0.1;
end
FV=get(hctx);
normals=get(hctx,'VertexNormals');
nVertices=size(normals,1);
%Make the normals unit norm
[nrm,normalsnrm]=colnorm(normals');
%compute average angle on each vertex
curvature=zeros(nVertices,1);
curvature_sigmoid=zeros(nVertices,1);
for i=1:nVertices %for all vertices
    nNeighbours=length(VertConn{i}); %number of neighbours
    edgevector=FV.Vertices(VertConn{i},:)-repmat(FV.Vertices(i,:),nNeighbours,1); %vectors joining vertex with neighbours
    [nrm,edgevector]=colnorm(edgevector');
    curvature(i)=mean(acos(normalsnrm(:,i)'*edgevector))-pi/2;
    curvature_sigmoid(i)= 1./(1+exp(-curvature(i).*sigmoid_const))-0.5;
end



function []=spatialextent(ho,hctx)
uhp=get(findTessellationHandles, 'UserData');
if isempty(uhp); return; end;


function action_trimsurface
uhp=get(findTessellationHandles, 'UserData');
trimsurface_gui(uhp.h)

function action_curvature


function []=action_extent_threshold(hctx,z)
if nargin==0 || ~isequal(get(hctx, 'type'), 'patch')
    hctx=findTessellationHandles;
end
uhp=get(hctx, 'UserData');
if isempty(uhp); return; end;
c=colormap;
fv=get(uhp.h, 'FaceVertexCData');
if prod(caxis)>=0
    fv(abs(fv)<=min(caxis))=0;
else
    cb=c(ceil(length(c)/2),:);
    cb=repmat(cb,length(c),1);
    fv(abs(fv)<max(caxis)*(sum(all(c==cb,2))/length(cb)))=0;
end
if nargin<2
    z=inputdlg('Minimal size:', 'Spatial Extent Threshold',1,{'10'});
    if isempty(z);return;end
    z=str2num(z{1});
    if isempty(z);return;end
end
[clu,sz]=clustering(fv,uhp.vertconn);
clu=clu(sz>=z);
fv(setdiff(1:length(fv),[clu{:}]))=0;
set(uhp.h, 'FaceVertexCData',fv)

function []=action_move_hemi_away(hctx)
if nargin<1 || ~isequal(get(hctx, 'type'), 'patch')
    hctx=findTessellationHandles;
end
uhp=get(hctx, 'UserData');
if isempty(uhp);
    uhp.h = hctx;
    %return;
end;
v=get(uhp.h, 'Vertices');
if size(v,1)==10774 || size(v,1)==12045
    fprintf('MNI4Yann cortex');
    v(1:5418,1)=v(1:5418,1)+1/2*mean(v(1:5418,1));
    v(5419:10774,1)=v(5419:10774,1)+1/2*mean(v(5419:10774,1));
    if size(v,1)==12045
        v(10774:end,3)=v(10774:end,3)-1/2*mean(v(10774:end,3));
    end
elseif size(v,1)==15028
    nR = 7509;% first right
    fprintf('Brainstorm Default Subject\n');
    v(1:nR,2)=v(1:nR,2)+1/2*mean(v(1:nR,2));
    v(nR+1:end,2)=v(nR+1:end,2)+1/2*mean(v(nR+1:end,2));
    % Open with a given angle
    %     a= -75/360*2*pi; % in deg/rad
    %     t = exp(j*a)*(v(1:nR,2)+j*(v(1:nR,1)+.07));
    %     v(1:nR,2) = real(t);
    %     v(1:nR,1) = imag(t)-.07;
    %     %
else
    f=get(uhp.h, 'Faces');
    %try to guess which is the orthosagittal axis
    m=median(v);
    % it should be the one where as few faces as possible cross the
    % median plane
    for i=1:3
        left  = v(:,i)<m(i);
        right = v(:,i)>m(i);
        s(i) = sum(any(right(f),2) & any(left(f),2));
    end
    [min_s,lr_dim] = min(s);
    % Now we have it, we must found the position of the sagittal plane
    fun = @(m) sum(any(reshape(v(f,lr_dim),size(f,1),3)>m,2)&any(reshape(v(f,lr_dim),size(f,1),3)<m,2));
    [m,s] = fzero(fun,m(lr_dim));

    left  = v(:,lr_dim)<m;
    right = v(:,lr_dim)>m;
    v(:,lr_dim)=v(:,lr_dim)+(max(v(:,lr_dim))-min(v(:,lr_dim)))/4*right;
end
set(uhp.h, 'Vertices', v);
axis image

function []=action_move_hemi_closer(hctx)
if nargin<1 || ~isequal(get(hctx, 'type'), 'patch')
    hctx=findTessellationHandles;
end
uhp=get(hctx, 'UserData');
if isempty(uhp); return; end;
v=get(uhp.h, 'Vertices');
if size(v,1)==10774 || size(v,1)==12045
    v(1:5418,1)=v(1:5418,1)-1/2*mean(v(1:5418,1));
    v(5419:10774,1)=v(5419:10774,1)-1/2*mean(v(5419:10774,1));
    if size(v,1)==12045
        v(10774:end,3)=v(10774:end,3)+1/2*mean(v(10774:end,3));
    end
elseif size(v,1)==15028
    nR = 7509;
    fprintf('Brainstorm Default Subject');
    v(1:nR,2)=v(1:nR,2)-1/2*mean(v(1:nR,2));
    v(nR+1:end,2)=v(nR+1:end,2)-1/2*mean(v(nR+1:end,2));

else
    v(:,1)=v(:,1)+10*(-1+2*(v(:,1)>0));
end
set(uhp.h, 'Vertices', v);
axis image

function []=action_open_hemi(hctx)
if nargin<1 || ~isequal(get(hctx, 'type'), 'patch')
    hctx=findTessellationHandles;
end
uhp=get(hctx, 'UserData');
if isempty(uhp);
    uhp.h = hctx;
    %return;
end;
v=get(uhp.h, 'Vertices');
if size(v,1)==10774 || size(v,1)==12045
    fprintf('MNI4Yann cortex');
    v(1:5418,1)=v(1:5418,1)+1/2*mean(v(1:5418,1));
    v(5419:10774,1)=v(5419:10774,1)+1/2*mean(v(5419:10774,1));
    if size(v,1)==12045
        v(10774:end,3)=v(10774:end,3)-1/2*mean(v(10774:end,3));
    end
elseif size(v,1)==15028
    nR = 7509;% first right
    fprintf('Brainstorm Default Subject\n');
    % v(1:nR,2)=v(1:nR,2)+1/2*mean(v(1:nR,2));
    %v(nR+1:end,2)=v(nR+1:end,2)+1/2*mean(v(nR+1:end,2));
    % Open with a given angle
    a= -60/360*2*pi; % in deg/rad
    t = exp(j*a)*(v(1:nR,2)+j*(v(1:nR,1)+.07));
    v(1:nR,2) = real(t);
    v(1:nR,1) = imag(t)-.07;
    %
else
    f=get(uhp.h, 'Faces');
    %try to guess which is the orthosagittal axis
    m=median(v);
    % it should be the one where as few faces as possible cross the
    % median plane
    for i=1:3
        left  = v(:,i)<m(i);
        right = v(:,i)>m(i);
        s(i) = sum(any(right(f),2) & any(left(f),2));
    end
    [min_s,lr_dim] = min(s);
    % Now we have it, we must found the position of the sagittal plane
    fun = @(m) sum(any(reshape(v(f,lr_dim),size(f,1),3)>m,2)&any(reshape(v(f,lr_dim),size(f,1),3)<m,2));
    [m,s] = fzero(fun,m(lr_dim));

    left  = v(:,lr_dim)<m;
    right = v(:,lr_dim)>m;
    v(:,lr_dim)=v(:,lr_dim)+(max(v(:,lr_dim))-min(v(:,lr_dim)))/4*right;
end
set(uhp.h, 'Vertices', v);
axis image



function []=action_move_hemi_closer(hctx)
if nargin<1 || ~isequal(get(hctx, 'type'), 'patch')
    hctx=findTessellationHandles;
end
uhp=get(hctx, 'UserData');
if isempty(uhp); return; end;
v=get(uhp.h, 'Vertices');
if size(v,1)==10774 || size(v,1)==12045
    v(1:5418,1)=v(1:5418,1)-1/2*mean(v(1:5418,1));
    v(5419:10774,1)=v(5419:10774,1)-1/2*mean(v(5419:10774,1));
    if size(v,1)==12045
        v(10774:end,3)=v(10774:end,3)+1/2*mean(v(10774:end,3));
    end
elseif size(v,1)==15028
    nR = 7509;
    fprintf('Brainstorm Default Subject');
    v(1:nR,2)=v(1:nR,2)-1/2*mean(v(1:nR,2));
    v(nR+1:end,2)=v(nR+1:end,2)-1/2*mean(v(nR+1:end,2));

else
    v(:,1)=v(:,1)+10*(-1+2*(v(:,1)>0));
end
set(uhp.h, 'Vertices', v);
axis image

function []=action_hide_hemi(hctx)
if nargin<1 || ~isequal(get(hctx, 'type'), 'patch')
    hctx=findTessellationHandles;
end
uhp=get(hctx, 'UserData');
if isempty(uhp);
    uhp.h = hctx;
    %return;
end;
v=get(uhp.h, 'Vertices');
if size(v,1)==10774 || size(v,1)==12045
    fprintf('MNI4Yann cortex');
    LR = [ones(1,5418) 2*ones(1,5356) ];
    if size(v,1)==12045
        % cerebellum
        LR = [LR zeros(1,1272)];
    end
elseif size(v,1)==15028
    LR = [ones(1,7509) 2*ones(1,7519) ];
else
    f=get(uhp.h, 'Faces');
    %try to guess which is the orthosagittal axis
    m=median(v);
    % it should be the one where as few faces as possible cross the
    % median plane
    for i=1:3
        left  = v(:,i)<m(i);
        right = v(:,i)>m(i);
        s(i) = sum(any(right(f),2) & any(left(f),2));
    end
    [min_s,lr_dim] = min(s);
    % Now we have it, we must found the position of the sagittal plane
    fun = @(m) sum(any(reshape(v(f,lr_dim),size(f,1),3)>m,2)&any(reshape(v(f,lr_dim),size(f,1),3)<m,2));
    [m,s] = fzero(fun,m(lr_dim));

    left  = v(:,lr_dim)<m;
    right = v(:,lr_dim)>m;
    v(:,lr_dim)=v(:,lr_dim)+(max(v(:,lr_dim))-min(v(:,lr_dim)))/4*right;
end
alpha = get(uhp.h,'FaceVertexAlphaData');
if alpha(find(LR==1,1)) == 0
    alpha(LR==1) = 1;
    alpha(LR==2) = 0;
elseif alpha(find(LR==2,1)) == 0
    alpha(LR==1) = 1;
    alpha(LR==2) = 1;
else
    alpha(LR==1) = 0;
    alpha(LR==2) = 1;
end
if all(alpha==1)
    set(uhp.h,'alphadatamapping','none',...
        'FaceVertexAlphaData',alpha,....
        'FaceAlpha','flat',...
        'backfacelighting','unlit')
else
    set(uhp.h,'alphadatamapping','scaled',...
        'FaceVertexAlphaData',alpha,....
        'FaceAlpha','interp',...
        'backfacelighting','lit')
end
%set(uhp.h, 'VerticesAlphaDapa', v);


