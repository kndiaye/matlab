function [hmenu]= scouts_menu(action, varargin)
% cortex_menu - Menu related to cortical surface processing

if nargin==0
    action='create';
end
switch lower(action)

    case 'create'
        hmenu = uimenu('Label','Scout manager');

        cback='uhp=get(findTessellationHandles, ''UserData'');';

%         set(hmenu, 'Callback',[ cback ...
%             'if isfield(uhp, ''vertconn''), state=''on''; else state=''off''; end;'...
%             'set(findobj(gcbo, ''Label'', ''Smooth surface''), ''Enable'',state);'...
%             'set(findobj(gcbo, ''Label'', ''Adv. Smooth surface''), ''Enable'', state);'...
%             ]);

%         t1 = uimenu('Parent',hmenu,...
%             'Label','Define scout',...
%         

    
        return
end
