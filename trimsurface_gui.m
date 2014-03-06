function []=trimsurface_gui(varargin)
% trimsurface_gui - GUI interface for trimsurface
%   trimsurface(h) pops up a window for trimming surface whose handle is h

if nargin>=1
    if ischar(varargin{1})
        action=varargin{1};
        varargin(1)=[];
    else
        action='init';    
    end
else
    action='init';    
end
feval(sprintf('action_%s', action), varargin{:});
return

function action_init(varargin)
%%%%%%%%%%%%%%%%%%%%%
%%% General Info. %%%
%%%%%%%%%%%%%%%%%%%%%
Black      =[0       0        0      ]/255;
LightGray  =[192     192      192    ]/255;
LightGray2 =[160     160      164    ]/255;
MediumGray =[128     128      128    ]/255;
White      =[255     255      255    ]/255;

Title='Surface Trimmer';
WindowStyle='normal';
Interpreter='none';
if nargin<=4,
    Resize = 'off';
end

%%%%%%%%%%%%%%%%%%%%%%%
%%% Create TrimFig %%%
%%%%%%%%%%%%%%%%%%%%%%%
FigWidth=100;FigHeight=300;
FigPos(3:4)=[FigWidth FigHeight];
FigColor=get(0,'Defaultuicontrolbackgroundcolor');
TextForeground = Black;
if sum(abs(TextForeground - FigColor)) < 1
    TextForeground = White;
end

TrimFig=dialog(                               ...
    'Visible'         ,'on'      , ...
    'Name'            ,Title      , ...
    'Pointer'         ,'arrow'    , ...
    'Units'           ,'points'   , ...
    'UserData'        ,''         , ...
    'Tag'             ,Title      , ...
    'HandleVisibility','on'       , ...
    'Color'           ,FigColor   , ...
    'NextPlot'        ,'add'      , ...
    'WindowStyle'     ,WindowStyle, ...
    'Resize'          ,Resize       ...
);
Temp=get(0,'Units');
set(0,'Units','points');
ScreenSize=get(0,'ScreenSize');
set(0,'Units',Temp);
FigPos(1)=(ScreenSize(3)-FigWidth)/2;
FigPos(2)=(ScreenSize(4)-FigHeight)/2;
FigPos(3)=FigWidth;
FigPos(4)=FigHeight;
set(TrimFig,'Position',FigPos);
set(TrimFig,'WindowButtonDownFcn','trimsurface_gui(''btndwn'', gcbf)');

tags='XYZ';
setappdata(TrimFig, 'Tags', tags);
for i=1:3
    hui(i)=uicontrol('style', 'slider', 'unit', 'normalized', ...
        'position', [.15+(i-1)*0.3 .1 .1 .75 ],'enable', 'on',...
        'callback', 'trimsurface_gui(''btndwnslider'', gcbf, gcbo)',...
        'tag', [tags(i)]);    
end
set(hui, 'max', 1)
set(hui, 'min', -1)
set(hui, 'value', 0)
for i=4:6
    hui(i)=uicontrol('style', 'checkbox', 'unit', 'normalized', ...
        'position', [.15+(i-4)*0.3 .85 .1 .05 ]);
    set(hui(i), 'callback', 'trimsurface_gui(''chkbox'',gcbf, gcbo)');
    set(hui(i), 'units', 'pixels');
    set(hui(i), 'position', get(hui(i), 'position').*[1 1 0 0]+[0 0 20 20]);
    set(hui(i),'units', 'normalized')
    set(hui(i),'tag', ['d' tags(i-3)])
    set(hui(i),'Tooltip', 'Hide the other side of the plane');
end
for i=7:9
    hui(i)=uicontrol('style', 'checkbox', 'unit', 'normalized', ...
        'position', [.25+(i-7)*0.3 .1 .075 .75 ], 'value',1, ...
        'callback', 'trimsurface_gui(''toggleslider'', gcbf, get(gcbo, ''UserData''))',...
        'tag', ['c' tags(i-6)], 'UserData' , hui(i-6),...
        'Tooltip', 'Activate / Deactivate this cut');
end


hui(end+1)=uicontrol('style', 'edit', 'unit', 'normalized', 'enable', 'off', ...
    'position',  [.1 .9 .8 .05 ], 'min', 0, 'max', 0);
if nargin>0
    hp=varargin{1};
else
    hp=findTessellationHandles;
end
hui(end+1)=uicontrol('style', 'pushbutton', 'string', 'Unhide all', ...
    'unit', 'normalized', 'position',  [.15 .05 .7 .05 ], ...
            'callback', 'trimsurface_gui(''unhide'',gcbf)');

hui(end+1)=uicontrol('style', 'pushbutton', 'string', 'Use OpenGL', ...
    'unit', 'normalized', 'position',  [.15 .00 .7 .05 ], ...
    'UserData',get(get(hp, 'Parent'), 'Parent'), 'callback', 'set(get(gcbo, ''UserData''), ''Renderer'', ''opengl'');');

action_selectsurface(TrimFig,hp)
action_adjustsliders(TrimFig,hp);
return

function action_adjustsliders(varargin)
hf=varargin{1};
hp=varargin{2};
tags=getappdata(hf,'Tags'); 
dim=get(hp, 'Vertices');
dim=[min(dim);max(dim)];
for i=1:3
    hui=findobj(hf, 'style', 'slider', 'tag', tags(i));
    set(hui, 'min', dim(1,i), 'max', dim(2,i), 'value', mean(dim(:,i)))
    setappdata(hf, tags(i), mean(dim(:,i)));
    setappdata(hf, ['d' tags(i)], 1);    
end

function action_trim(varargin)
hf=varargin{1};
tags=getappdata(hf, 'Tags');
if nargin<2
    for i=1:3
        xyz(i)=getappdata(hf,  tags(i));
    end
else    
    xyz=varargin{2};
end
if nargin<3
    for i=1:3
        dxyz(i)=getappdata(hf,  ['d' tags(i)]);
    end
else
    dxyz=varargin{3};
end
dxyz=2*dxyz-1;
% hui(i)=findobj(hf, 'style', 'slider', 'tag', tags(i));
hp=getappdata(hf, 'Surface');
trimsurface(hp,xyz,dxyz)


function action_selectsurface(varargin)
hf=varargin{1};
hp=varargin{2};
setappdata(hf, 'Surface', hp)


function action_btndwn(varargin)
%Right click to toggle slider
hf=varargin{1};
if ~isequal(get(hf, 'SelectionType'),'alt')
return
end
if nargin>=2
    ho=varargin{2};
else
    ho=overobj('uicontrol')
    if ~isequal(get(ho, 'style'), 'slider')
        return
    end
end
if isequal(get(ho, 'enable')=='on')
    set(ho, 'enable','off')
    setappdata(hf,get(ho, 'tag'), 'NaN')
else
    set(ho, 'enable','on')
    setappdata(hf,get(ho, 'tag'), 0)    
end
action_update(hf)

function action_toggleslider(varargin)
%Right click to toggle slider
hf=varargin{1};
    ho=varargin{2};
if isequal(get(ho, 'enable'),'on')
    set(ho, 'enable','off')
    setappdata(hf,get(ho, 'tag'), NaN)
else
    set(ho, 'enable','on')
    setappdata(hf,get(ho, 'tag'),get(ho, 'Value'))    
end
action_update(hf)


function action_btndwnslider(varargin)
hf=varargin{1};
ho=varargin{2};
setappdata(hf,get(ho, 'tag'), get(ho, 'Value'))
action_update(hf)

function action_chkbox(varargin)
hf=varargin{1};
ho=varargin{2};
setappdata(hf,get(ho, 'tag'), get(ho, 'Value'))
action_update(hf)


function action_update(varargin)
hf=varargin{1};
tags=getappdata(hf, 'Tags');
for i=1:3
    xyz(i)=getappdata(hf, tags(i));
    if ~isnan(xyz(i))    
        set(findobj(hf, 'tag', [tags(i)]), 'value', xyz(i));
    end
    dxyz(i)=getappdata(hf, ['d' tags(i)]);
    set(findobj(hf, 'tag', ['d' tags(i)]), 'value', dxyz(i));   
end
sxyz=[sprintf('%2.2f ', xyz)];
set(findobj(hf, 'style', 'edit'), 'string', sxyz)
action_trim(hf, xyz, dxyz)

function action_unhide(varargin)
hf=varargin{1};
hp=getappdata(hf, 'Surface');
trimsurface(hp,[NaN NaN NaN])
