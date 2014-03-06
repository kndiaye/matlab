function [ varargout ] = view_MNEresults(action,varargin)
% view_MNEresults - Diplays BrainStorm results
%
% [ hf ] = view_MNEresults(fv,cdata)
% [ hf ] = view_MNEresults(faces,verts,cdata)
% [ hf ] = view_MNEresults(fv,cdata,time)

if nargin<1
    error('No data!')
elseif nargin==1 || ~ischar(action)
    varargin=[{action} varargin ];
    action='init';
end

try
    varargout={eval(sprintf('action_%s(varargin{:});',action))};
catch
    eval(sprintf('action_%s(varargin{:});',action)); 
end

%__________________________________________________________________________
%
%% ACTION INIT
%
function [hf]=action_init(varargin)
if isfield(varargin{1}, 'faces')
    ctx=varargin{1};
    varargin(1)=[];
else
    if nargin>=3
        ctx.faces=varargin{1};
        ctx.vertices=varargin{2};
        varargin([1 2])=[];
    else
        error('not enough inputs!')
    end
end
if ~isempty(varargin)
    if isnumeric(varargin{1})
        ctx.tex=varargin{1};
        if length(varargin)>1
            if isnumeric(varargin{2})
                ctx.time=varargin{2};
            end
        end
    end
end 

if(size(ctx.vertices,2) ~= 3), % assume transposed
    ctx.vertices = ctx.vertices';  % if the assumption is wrong, will crash below anyway
end

if size(ctx.vertices,1) ~= size(ctx.tex,1)
    if size(ctx.vertices,1) == size(ctx.tex,2)
        ctx.tex=ctx.tex';
    else
        error(sprintf('Data provided are ill-shaped\nVertices: %d\nData: %s',size(ctx.vertices,1),sprintf('%d ',size(ctx.tex))))
        return;
    end
end

nsamples=size(ctx.tex,2);

if isfield(ctx, 'time') 
    if length(ctx.time) ~= nsamples
    error('Incorrect time vector (bad nuimber of samples)')
    end
    u.time=ctx.time;
else
    u.time=[1:nsamples];
end

if ~isfield(ctx,'tex')
    warning('No data provided. Distance to origin is used')
    ctx.tex = rownorm(ctx.vertices);
end

hf=figure;
hp=carto_cortex(ctx, ctx.tex(:,1));
u.hpax=get(hp, 'parent');
ha=u.hpax;
if any(ctx.tex(:)>0) & any(ctx.tex(:)<0)
    u.cmap=jet(256);
    u.cmapsym=0;
else
    u.cmap=hot(256);
    u.cmapsym=1;
end
colormap(u.cmap)

hcbar=colorbar;
hcmap=uicontrol('Style', 'slider');
set(hcmap, 'Units', get(hcbar, 'Units'));
set(hcmap, 'Min', min(0,-(log10(size(ctx.tex,1)))+2) , 'Max', 2, 'Value', 2);
set(hcmap, 'Position', get(hcbar, 'Position')*[1 0 0 0; 0 1 0 0;  1.7 0 .5 0 ;0 0 0 1 ]);
set(hcmap, 'Callback', sprintf('%s(''%s'',gcbf)',mfilename,'cmap'));

hcmap2=uicontrol('Style', 'slider');
set(hcmap2, 'Units', get(hcbar, 'Units'));
set(hcmap2, 'Max', 1 , 'Min', 0 , 'Value', 1);
set(hcmap2, 'Position', get(hcmap, 'Position')*[1 0 0 0; 0 1 0 0;  1.1 0 1 0 ;0 0 0 1 ]);
set(hcmap2, 'Callback', sprintf('%s(''%s'',gcbf)',mfilename,'cmap2'));

%Tick box above & below colormap slider
hcmaptop=uicontrol('Style', 'checkbox', 'Units', 'normalized');
set(hcmaptop, 'Position', get(hcmap, 'position')*[1 0 0 0; 0 1 0 0; 0 0 1 1 ; 0 1 0 0])
hcmapbot=uicontrol('Style', 'checkbox', 'Units', 'normalized');
set(hcmapbot, 'Position', get(hcmap, 'position')*[1 0 0 0; 0 1 0 0; 0 -1 1 1 ; 0 0 0 0])
set([hcmapbot hcmaptop] , 'Callback', sprintf('%s(''%s'',gcbf)',mfilename,'cmap'));

% Number of active sources (with the colormap)
hcmaptxt=uicontrol('Style', 'edit');
set(hcmaptxt, 'Units', 'normalized')
set(hcmaptxt, 'Position', get(hcmapbot, 'Position')*[1 0 0 0; 0 1 0 0; -2 0 0 0; 0 0 0 0]+[0 -0.07 0.1 0.05 ])
set(hcmaptxt, 'Callback', sprintf('%s(''%s'',gcbf)',mfilename,'cmaptxt'));

% Slider to control the time
htime=uicontrol('Style', 'slider', 'Value', 1, 'Min', 1, 'Max', 1+eps);
if nsamples>1
    set(htime, 'SliderStep', [1/ceil(nsamples-1) min(.05, 100/ceil(nsamples-1))]);
    set(htime, 'Max', nsamples);
else
    set(htime, 'SliderStep', [1 1]);
end
set(htime, 'Units', 'normalized')
set(htime, 'Position', [ .02 .045 .8 .045])
set(htime, 'Callback', sprintf('%s(''%s'',gcbf)',mfilename,'timeslider'));

% Label to display Time (in time units)
htimetxtu=uicontrol('Style', 'edit'); 
set(htimetxtu, 'Units', 'normalized')
set(htimetxtu, 'Position', get(htime, 'Position')*[1 0 0 0; 0 1 0 0; 0 0 0 0; 0 1 0 1]+[0 0 0.1 0])
set(htimetxtu, 'Callback', sprintf('%s(''%s'',gcbf)',mfilename,'timetxtu'));

% Label to display Time (in samples) 
htimetxts=uicontrol('Style', 'edit');
set(htimetxts, 'Units', 'normalized')
set(htimetxts, 'Position', get(htimetxtu, 'Position')*[1 0 0 0; 0 1 0 0; 0 0 1 0; 0 1.3 0 1])
set(htimetxts, 'Callback', sprintf('%s(''%s'',gcbf)',mfilename,'timetxts'));


% To point a scout
hscout=scout_button('init','Position', [.7 .1 .1 .05]);
set(hscout, 'callback', [...
    '[vi,hctx]=scout_button(''click'', gcbo); '...
    'figure(''Tag'', ''scout:plot'', ''Name'', sprintf(''Scout: #%d'', vi));'...
    'plot(getfield(get(gcbf, ''UserData''), ''time''),subarray(getfield(get(hctx, ''UserData''), ''tex''),vi))'...
    ]);
% Set user data in the figure
u.hp=hp;
u.hcmap=hcmap;
u.hcmaptop=hcmaptop;
u.hcmapbot=hcmapbot;
u.hcmaptxt=hcmaptxt;
u.hcmap2=hcmap2;

u.htime=htime;
u.htimetxtu=htimetxtu;
u.htimetxts=htimetxts;
set(hf, 'UserData', u);

% Add tooltips
set(u.htime, 'TooltipString', 'Time')
set(u.htimetxtu, 'TooltipString', 'Time (in samples)')
set(u.htimetxts, 'TooltipString', 'Time (in sec)')
set(u.hcmaptxt, 'TooltipString', 'Number of active sources')
set(u.hcmap, 'TooltipString', 'Percentage of active sources')

% set(u.hp, 'ButtonDownFcn', 'rotate3d on');
rotate3d(hf, 'on')

meeg_menu

return


%__________________________________________________________________________
%
%% ACTION COLORMAP FROM SLIDER
%
function []=action_cmap(hf,ho)
u=get(hf, 'UserData');
n=power(10,get(u.hcmap, 'Value'));
s=get(u.hcmaptop, 'Value')-get(u.hcmapbot, 'Value');
if s==0 && ~get(u.hcmaptop, 'Value')     
    s=u.cmapsym;
end
n=action_colormap(u.hp,n,s);
set(u.hcmaptxt, 'String',num2str(n));
colorbar('peer', u.hpax);
%rotate3d;
return
%__________________________________________________________________________
%
%% ACTION COLORMAP FROM TEXT
%
function []=action_cmaptxt(hf,ho)
u=get(hf, 'UserData');
cdata=get(u.hp, 'FaceVertexCData');
set(u.hcmap, 'Value', log10(100*str2num(get(u.hcmaptxt, 'String'))/size(cdata,1)));
action_cmap(hf)
return
%__________________________________________________________________________
%
%% ACTION COLORMAP APPLY
%
function [n]=action_colormap(hp,n,s)
n=showpercent(n,hp,[],[],s);
return
%__________________________________________________________________________
%
%% ACTION COLORMAP CROP
%
function []=action_cmap2(hf,ho)
u=get(hf, 'UserData');
ctx=get(u.hp, 'UserData');
s=get(u.hcmaptop, 'Value')-get(u.hcmapbot, 'Value');
v=ctx.tex(:,get(u.htime, 'Value'));
% q=power(10,get(u.hcmap2, 'Value'))
q=get(u.hcmap2, 'Value');
% Slider is more ergonomic as we may want to use to remove one or few
% outliers
q=(q)^(1/6);
t=get(u.hpax,'CLim');
if s==0
    cmap=colormap(u.hpax);
    n=size(cmap,1);
    x=sum(all(cmap==repmat(cmap(ceil(n/2),:),n,1),2));
    v(abs(v)<t(2)*x/n)=[];
    t(2)=quantile(abs(v),q);
    t(1)=-t(2);
% do nothing
elseif s>0
    v(v<t(1))=[];
    t(2)=quantile(v,q);
elseif s<0
    v(v>t(2))=[];
    t(1)=quantile(v,q);
end
set(u.hpax,'Clim',[t])
colorbar('peer', u.hpax);
% action_cmap(hf)
return





%__________________________________________________________________________
%
%% ACTION SCOUT BUTTON (scoutbtn)
%
function [h]=action_scoutbtn(hf)
u=get(hf, 'UserData');
[p v vi f fi]=select3d(u.hp);
figure('Name', sprintf('Scout: Vert#%d [%0.2g %0.2g %0.2g]', vi, v));
ctx=get(u.hp, 'UserData');
h=plot(u.time, ctx.tex(vi,:));
hold on; 
stem(u.time(get(u.htime, 'Value')), ctx.tex(vi,get(u.htime, 'Value')), '.r');
assignin('caller', 'vi', vi)


%__________________________________________________________________________
%
%% ACTION TIME SLIDER (timeslider)
%
function []=action_timeslider(hf)
u=get(hf, 'UserData');
set(u.htime, 'Value',round(get(u.htime, 'Value')));
ctx=get(u.hp, 'UserData');
set(u.hp, 'FaceVertexCData',ctx.tex(:,get(u.htime, 'Value')));
set(u.htimetxts, 'String', num2str(get(u.htime, 'Value')));
set(u.htimetxtu, 'String', num2str(u.time(get(u.htime, 'Value'))));
colorbar('peer', u.hpax);
rotate3d;


%__________________________________________________________________________
%
%% ACTION TIME TEXT IN TIME UNITS (timetxtu) 
%
function [h]=action_timetxtu(hf)
u=get(hf, 'UserData');
t=get(u.htime, 'Value');
set(u.htime, 'Value', whichTime(str2num(get(u.htimetxtu, 'String')),u.time));
if t~=get(u.htime, 'Value');
    action_timeslider(hf)
    rotate3d;
end

%__________________________________________________________________________
%
%% ACTION TIME TEXT IN SAMPLES (timetxts) 
%
function [h]=action_timetxts(hf)
u=get(hf, 'UserData');
t=get(u.htime, 'Value');
set(u.htime, 'Value', str2num(get(u.htimetxts, 'String')));
if t~=get(u.htime, 'Value');
    action_timeslider(hf)
    rotate3d;
end
return

F=gcf;
% t0 = findobj(get(F,'Children'),'Flat','Label','&Help');
% set(findobj(t0,'Position',1),'Separator','on');
% t0=uimenu('Label', 'test')
% t0 = uicontextmenu('Parent',F,'HandleVisibility','CallBack');

t0=uimenu('Label', 'test')
t1 = uimenu('Parent',t0,'Position',1,...
    'Label','SPM web',...
    'CallBack','web(''http://www.fil.ion.ucl.ac.uk/spm'');');
t1 = uimenu('Parent',t0,'Position',1,...
    'Label','SPM help','ForegroundColor',[0 1 0],...
    'CallBack','spm_help');

t0=uimenu('Parent', F,'Label','Colours','HandleVisibility','off');
t1=uimenu('Parent',t0,'Label','ColorMap');
t2=uimenu('Parent',t1,'Label','Gray','CallBack','spm_figure(''ColorMap'',''gray'')');
t2=uimenu('Parent',t1,'Label','Hot','CallBack','spm_figure(''ColorMap'',''hot'')');
t2=uimenu('Parent',t1,'Label','Pink','CallBack','spm_figure(''ColorMap'',''pink'')');
t2=uimenu('Parent',t1,'Label','Gray-Hot','CallBack','spm_figure(''ColorMap'',''gray-hot'')');
t2=uimenu('Parent',t1,'Label','Gray-Pink','CallBack','spm_figure(''ColorMap'',''gray-pink'')');
t1=uimenu('Parent',t0,'Label','Effects');
t2=uimenu('Parent',t1,'Label','Invert','CallBack','spm_figure(''ColorMap'',''invert'')');
t2=uimenu('Parent',t1,'Label','Brighten','CallBack','spm_figure(''ColorMap'',''brighten'')');
t2=uimenu('Parent',t1,'Label','Darken','CallBack','spm_figure(''ColorMap'',''darken'')');
t0=uimenu('Parent', F,'Label','Clear','HandleVisibility','off','CallBack','spm_figure(''Clear'',gcbf)');
t0=uimenu('Parent', F,'Label','SPM-Print','HandleVisibility','off','CallBack','spm_figure(''Print'',gcbf)');



return
