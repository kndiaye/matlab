function [h]=viewpoint_menu(action, varargin)
% viewpoint_menu - Add a menu to (easily) set viewpoint
%
%   viewpoint_menu(h) adds a menu in the figure containing the patch h
%   viewpoint_menu(action, ... ) runs various callbacks.
%
%   viewpoint_menu(ref,ori) change orientation
%       ref: ctf|mni|aims
%       ori: top|bottom|left|right|front|back
%   Example: 
%       >> viewpoint_menu('mni', 'top')
%
%   viewpoint_menu(ref,ori,h) change orientation for handle h

if nargin==0 
    action='create';
end
if ~ischar(action)
    varargin=[{action}, varargin];
    action='create';    
end
%try
    h=feval(sprintf('action_%s', lower(action)), varargin{:});
    %catch
    % warning(sprintf('Unknown action: %s', action));
    %end
return

function [hmenu]=action_create(hp)
if nargin<1
    hp=[];
end
[hp,ha,hf]=findTessellationHandles(hp);

% Remove previous instances
hmenu=findobj('Type', 'uimenu', 'Tag', mfilename, 'UserData', hp);
delete(hmenu);

hmenu = uimenu('Label',['Viewpoints'],  'Tag', mfilename);
set(hmenu, 'UserData', hp);
set(hmenu, 'Callback', 'set(findobj(gcbo, ''Label'', ''Z-flip''), ''checked'', iff(strncmp(get(get(get(gcbo,''UserData''), ''Parent''), ''Zdir''),''r'',1),''on'',''off''))');

vp={'Top', 'Bottom', 'Left', 'Right', 'Front', 'Back','Front Right','Front Left','Back Right','Back Left' };

t = uimenu('Parent',hmenu,'Label','CTF');
for i=1:length(vp)
    uimenu('Parent', t, 'Label', vp{i}, 'Callback', [ mfilename '(''ctf'', ''' lower(vp{i}) ''',gcbo);']);
end

t = uimenu('Parent',hmenu,'Label','MNI');
vp={'Top', 'Bottom', 'Left', 'Right', 'Front', 'Back'};
for i=1:length(vp)
    uimenu('Parent', t, 'Label', vp{i}, 'Callback', [ mfilename '(''mni'', ''' lower(vp{i}) ''',gcbo);']);
end

t = uimenu('Parent',hmenu,'Label','AIMS');
vp={'Top', 'Bottom', 'Left', 'Right', 'Front', 'Back'};
for i=1:length(vp)
    uimenu('Parent', t, 'Label', vp{i}, 'Callback', [ mfilename '(''aims'', ''' lower(vp{i}) ''',gcbo);']);
end

t=uimenu('Parent', hmenu, 'Label', 'Z-flip', 'Separator', 'on', ...
    'Callback',[ mfilename '(''zflip'',gcbo);'] );
if strncmp(get(ha, 'zdir'), 'r',1);
    set(t, 'Checked', 'on');
end

return


function [ho]=action_zflip(ho)
if nargin<1
    ho=[];
    hmnu=[];
end
if isequal(get(ho, 'type'), 'uimenu')
    hmnu=ho;
    ho=get(get(ho, 'Parent'), 'UserData');
end
[ho,ha]=findTessellationHandles(ho);
if strncmp(get(ha, 'zdir'), 'normal',1);   
    set(ha, 'zdir', 'reverse')
    set(hmnu, 'Checked', 'on')
else
    set(ha, 'zdir', 'normal')
    set(hmnu, 'Checked', 'off')
end            

        
function [ho]=action_ctf(vp,ho)
% Change viewpoint (vp) for object ho (which can be a patch handle or a
% menu handle)
if nargin<2
    ho=[];
    hmnu=[];
end
if isequal(get(ho, 'type'), 'uimenu')
    hmnu=ho;
    ho=get(get(ho, 'Parent'), 'UserData');
end
[ho,ha]=findTessellationHandles(ho);
z=strncmp(get(ha, 'zdir'), 'n',1);
switch lower(vp)
    case 'top'
        view(ha,[0,0,1])
        % view(ha,180*(1-z),90*(1-2*z))
    case 'bottom'
        view(ha,[0,0,-1])
        % view(ha,180*z,-90*(1-2*z))
    case 'left'
        view(ha,[0,1,0])
        % view(ha, 90+180*z,0)
    case 'right'
        view(ha,[0,-1,0])
        % view(ha,-90+180*z,0)
    case 'front'
        view(ha,[1,0,0])
        % view(ha,0,0)
    case 'back'
        view(ha,[-1,0,0])
        % view(ha,180,0)
    case 'front left'
        view(ha,[90+40 15])
    case 'front right'
        view(ha,[40 15])
        % view(ha,180,0)
    case 'back left'
        view(ha,[-90-40 15])
        % view(ha,180,0)
    case 'back right'
        view(ha,[-40 15])
        % view(ha,180,0)

end



function [ho]=action_mni(vp,ho)
% Change viewpoint (vp) for object ho (which can be a patch handle or a
% menu handle)
if nargin<2
    ho=[];
    hmnu=[];
end
if isequal(get(ho, 'type'), 'uimenu')
    hmnu=ho;
    ho=get(get(ho, 'Parent'), 'UserData');
end
[ho,ha]=findTessellationHandles(ho);
switch lower(vp)
    case 'top'
        view(ha,[0 0 1])
    case 'bottom'
        view(ha,[0 0 -1])
    case 'left'
        view(ha,[-1 0 0])
    case 'right'
        view(ha,[1 0 0])    
    case 'front'
        view(ha,[0 1 0])
    case 'back'
        view(ha,[0 -1 0])
    case 'zflip'
        if z
            set(ha, 'zdir', 'reverse')
            set(hmnu, 'Checked', 'on')
        else
            set(ha, 'zdir', 'normal')
            set(hmnu, 'Checked', 'off')
        end            
end


function [ho]=action_aims(vp,ho)
% Change viewpoint (vp) for object ho (which can be a patch handle or a
% menu handle)
if nargin<2
    ho=[];
    hmnu=[];
end
if isequal(get(ho, 'type'), 'uimenu')
    hmnu=ho;
    ho=get(get(ho, 'Parent'), 'UserData');
end
[ho,ha]=findTessellationHandles(ho);
switch lower(vp)
    case 'top'
        view(ha,[0 0 1])
    case 'bottom'
        view(ha,[0 0 -1])
    case 'left'
        view(ha,[-1 0 0])
    case 'right'
        view(ha,[1 0 0])    
    case 'front'
        view(ha,[0 1 0])
    case 'back'
        view(ha,[0 -1 0])
end
