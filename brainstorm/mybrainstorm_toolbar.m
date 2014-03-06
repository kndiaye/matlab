function [] = mybrainstorm_toolbar

hToolbar = findobj(gcf, 'tag', mfilename)
delete(hToolbar)
% Create the toolbar
hToolbar = uitoolbar(gcf, 'tag', mfilename);
th =hToolbar;

% Add a push tool to the toolbar
a = [.20:.05:0.95]
img1(:,:,1) = repmat(a,16,1)'
img1(:,:,2) = repmat(a,16,1);
img1(:,:,3) = repmat(flipdim(a,2),16,1);
pth = uipushtool(th,'CData',img1,...
    'TooltipString','My push tool',...
    'HandleVisibility','off')
% Add a toggle tool to the toolbar
img2 = im2cdata('~/yomega/img/sci/brain-icons/iconTiny_KnowYourBrain.png')

tth = uitoggletool(th,'CData',img2,'Separator','on',...
    'TooltipString','Your toggle tool',...
    'HandleVisibility','off', 'callback', '')



% Matlab icons
filename = fullfile(matlabroot,'/toolbox/matlab/icons/greenarrowicon.gif');
cdataRedo = im2cdata(filename)
cdataUndo = cdataRedo(:,[16:-1:1],:);

% Add the icon (and its mirror image = undo) to the latest toolbar
hUndo = uipushtool('cdata',cdataUndo, 'tooltip','undo', 'ClickedCallback','uiundo(gcbf,''execUndo'')');
hRedo = uipushtool('cdata',cdataRedo, 'tooltip','redo', 'ClickedCallback','uiundo(gcbf,''execRedo'')');

hToolbar = findall(hFig,'tag','FigureToolBar');
%hToolbar = get(hUndo,'Parent');  % an alternative
hButtons = findall(hToolbar);
set(hToolbar,'children',hButtons([4:end-4,2,3,end-3:end]));
set(hUndo,'Separator','on');

% Retrieve redo/undo object
undoObj = getappdata(hFig,'uitools_FigureToolManager');
if isempty(undoObj)
   undoObj = uitools.FigureToolManager(hFig);
   setappdata(hFig,'uitools_FigureToolManager',undoObj);
end
 
% Customize the toolbar buttons
latestUndoAction = undoObj.CommandManager.peekundo;
if isempty(latestUndoAction)
   set(hUndo, 'Tooltip','', 'Enable','off');
else
   tooltipStr = ['undo' latestUndoAction.Name];
   set(hUndo, 'Tooltip',tooltipStr, 'Enable','on');
end

return

% Add undo dropdown list to the toolbar
jToolbar = get(get(hToolbar,'JavaContainer'),'ComponentPeer');
if ~isempty(jToolbar)
    undoActions = get(undoObj.CommandManager.UndoStack,'Name');
    jCombo = javax.swing.JComboBox(undoActions(end:-1:1));
    set(jCombo, 'ActionPerformedCallback', @myUndoCallbackFcn);
    jToolbar(1).add(jCombo,5); %5th position, after printer icon
    jToolbar(1).repaint;
    jToolbar(1).revalidate;
end

end
% Drop-down (combo-box) callback function
function myUndoCallbackFcn(hCombo,hEvent)
itemIndex = get(hCombo,'SelectedIndex');  % 0=topmost item
itemName  = get(hCombo,'SelectedItem');
% user processing needs to be placed here
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
end

function cdata=im2cdata(filename)

% Load the icon
[cdata,map] = imread(filename);

if ~isempty(map)
% Convert white pixels into a transparent background
map(find(map(:,1)+map(:,2)+map(:,3)==3)) = NaN;

% Convert white pixels into a transparent background
map(find(map(:,1)+map(:,2)+map(:,3)==0)) = NaN;


% Convert into 3D RGB-space
cdata = ind2rgb(cdata,map);
elseif isinteger(cdata)
    cdata=double(cdata)./255;
end

end