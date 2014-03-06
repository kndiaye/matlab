function [hmenu] = meeg_menu( varargin )
%MEEG_MENU - Add a MEEG related menu

[hp,ha,hf]=findTessellationHandles(varargin{:});
uhp=get(hp, 'UserData');

% Remove previous instances
hmenu=findobj(hf, 'Type', 'uimenu', 'Label', 'MEEG');
delete(hmenu);

hmenu=uimenu('Label', 'MEEG', 'Parent', hf);
t1 = cortex_menu;
set(t1, 'Parent', hmenu);
t1 = meegui_menu;
set(t1, 'Parent', hmenu, 'Separator', 'on');
t1 = viewpoint_menu('create',hp);
set(t1, 'Parent', hmenu, 'Separator', 'on');
t1 = scout_menu('create',hp);
set(t1, 'Parent', hmenu, 'Separator', 'on');

return
