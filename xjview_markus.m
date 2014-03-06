function xjview_karim(varargin)
% PWD=pwd; eval('cd D:\Gschwind\Data\VISIONCHIM');
% %P = genpath(pwd);rmpath(P);
% cd(PWD)
addpath('C:\Program Files\MATLAB\R2006b\work\xjview\matlab')
% xjview, version 4
%
% usage 1: xjview (no argument)
%           for displaying a result img file, or multiple image files,
%           (which will be loaded later) and changing p-value or t/f-value
% usage 2: xjview(imagefilename)
%           for displaying the result img file and changing p-value or
%           t-value
%           Example: xjView spmT_0002.img
%                    xjView('spmT_0002.img')
%                    xjView mymask.img
% usage 3: xjview(imagefilename1, imagefilename2, ...)
%           for displaying the result img files and changing p-value or
%           t/f-value
%           Example: xjView spmT_0002.img spmT_0005.img spmT_0007.img
%                    xjView('spmT_0002.img', 'spmT_0003.img', 'spmT_0006.img')
%                    xjView myMask1.img myMask2.img myMask3.img
% usage 4: xjview(mnicoord, intensity)
%           for displaying where are the mni coordinates
%           mnicoord: Nx3 matrix of mni coordinates
%           intensity: (optional) Nx1 matrix, usually t values of the
%           corresponding voxels
%           Example: xjView([20 10 1; -10 2 5],[1;2])
%                    xjView([20 10 1; -10 2 5])
%           Note: to use xjview this way, you may need to modify the value
%           of M and DIM in the begining of xjview.m
%
% http://people.hnl.bcm.tmc.edu/cuixu/xjView
%
% by Xu Cui and Jian Li 2/21/2005
% last modified: 02/18/2007 (add colorbar max control)
% last modified: 11/16/2006 (keyboard shortcut for open image and open roi file)
% last modified: 06/16/2006 (spm5 compatible)
% last modified: 05/30/2006 (left/right flip, path of mask.img and templateFile.img)
% last modified: 05/08/2006 (debug CallBack_volumePush function, change handles.intensity{1} to intensity)
% last modified: 04/03/2006 (modify tr)
% last modified: 12/28/2005 (modify SPM process)
%
% Thank Sergey Pakhomov for sharing his database (MNI Space Utility).
% Thank Yuval Cohen for the maximize figure function (maximize.m)
%

% TODO
% Send SPM to workspace

warnstate = warning;
warning off;

% pre-set values
% important! you need compare the display of xjview and spm. If you find
% xjview flipped the left/right, you need to set leftrightflip = 1;
% otherwise leave it to 0.
leftrightflip = 0;
% leftrightflip = 1 ; %must be on in the CMU...
% Now with spm-flip = 1; xjview-flip=1

% You only need to change M and DIM when you want to use xjview under
% 'usage 4'.
M = ...
    [-4   0     0    84;...
    0     4     0  -116;...
    0     0     4   -56;...
    0     0     0     1];
DIM = [41 48 35]';
TR = 2; % you don't need to set TR is you only use the viewing part of xjview

% system settings
try
    spmdir = spm('dir');
    spm('defaults', 'fmri');
catch
    disp('Please add spm path.');
    warning(warnstate(1).state);
    return
end

if ispc
    os = 'windows';
elseif isunix
    os = 'linux';
else
    warndlg('I don''t know what kind of computer you are using. I assumed it is unix.', 'What computer are you using?');
    os = 'linux';
end
screenResolution = get(0,'ScreenSize');

xjviewpath = fileparts(which('xjview'));

% pre-set values
pValue = 0.001;
intensityThreshold = 0;
clusterSizeThreshold = 5;


% Appearance Settings
figurePosition =                    [0.100,   0.050,    0.660,    0.880];
sectionViewPosition =               [0.5,0.61,0.45,0.45];
glassViewAxesPosition =             [0.000,   0.600,    0.464,    0.400];
if screenResolution(3) <= 1024
    figurePosition =                    [0.100,   0.050,    0.700,    0.900];
    sectionViewPosition =               [0.5,       0.61,   0.45,   0.46];
    glassViewAxesPosition =             [0.000,   0.600,    0.464,    0.400];
end

left =                              0.01;
editBoxHeight =                     0.05;
editBoxWidth =                      0.200;
editBoxLeft =                       0.100;

controlPanelPosition =              [left,     0.080,  0.500,      0.500];
stretchMatrix =                     diag([controlPanelPosition(3),controlPanelPosition(4),controlPanelPosition(3),controlPanelPosition(4)]);
controlPanelOffset =                controlPanelPosition' .* [1,1,0,0]';
heightUnit  =                       0.055;

sliderPosition =                    stretchMatrix*[0.000,   0*heightUnit,    1.000,           editBoxHeight]' + controlPanelOffset;
pValueTextPosition =                stretchMatrix*[0.000,   1*heightUnit,    editBoxWidth,    editBoxHeight]' + controlPanelOffset;
pValueEditPosition =                stretchMatrix*[0.110,   1*heightUnit,    editBoxWidth*4/3,    editBoxHeight]' + controlPanelOffset;
intensityThresholdTextPosition =    stretchMatrix*[0.400,   1*heightUnit,    editBoxWidth,    editBoxHeight]' + controlPanelOffset;
intensityThresholdEditPosition =    stretchMatrix*[0.520,   1*heightUnit,    editBoxWidth*3/3,    editBoxHeight]' + controlPanelOffset;
dfTextPosition =                    stretchMatrix*[0.740,   1*heightUnit,    0.8-0.74,    editBoxHeight]' + controlPanelOffset;
dfEditPosition =                    stretchMatrix*[0.800,   1*heightUnit,    editBoxWidth,    editBoxHeight]' + controlPanelOffset;
clusterSizeThresholdTextPosition =  stretchMatrix*[0.000,   2*heightUnit,    editBoxWidth,    editBoxHeight]' + controlPanelOffset;
clusterSizeThresholdEditPosition =  stretchMatrix*[0.150,   2*heightUnit,    editBoxWidth,    editBoxHeight]' + controlPanelOffset;
pickThisClusterPushPosition =       stretchMatrix*[0.400,   2*heightUnit,    editBoxWidth*1,    editBoxHeight]' + controlPanelOffset;
selectThisClusterPushPosition =     stretchMatrix*[0.600,   2*heightUnit,    editBoxWidth*1,    editBoxHeight]' + controlPanelOffset;
clearSelectedClusterPushPosition =   stretchMatrix*[0.800,   2*heightUnit,    editBoxWidth*1,    editBoxHeight]' + controlPanelOffset;
thisClusterSizeTextPosition =       stretchMatrix*[0.600,   2*heightUnit,    editBoxWidth,    editBoxHeight]' + controlPanelOffset;
thisClusterSizeEditPosition =       stretchMatrix*[0.800,   2*heightUnit,    editBoxWidth,    editBoxHeight]' + controlPanelOffset;
loadImagePushPosition =             stretchMatrix*[0.000,   3*heightUnit,    editBoxWidth,    editBoxHeight]' + controlPanelOffset;
imageFileEditPosition =             stretchMatrix*[0.200,   3*heightUnit,    1-editBoxWidth,    editBoxHeight]' + controlPanelOffset;
saveImagePushPosition =             stretchMatrix*[0.000,   4*heightUnit,    editBoxWidth,    editBoxHeight]' + controlPanelOffset;
saveImageFileEditPosition =         stretchMatrix*[0.200,   4*heightUnit,    1-editBoxWidth,    editBoxHeight]' + controlPanelOffset;
saveResultPSPushPosition =          stretchMatrix*[0.000,   5*heightUnit,    editBoxWidth,    editBoxHeight]' + controlPanelOffset;
resultPSFileEditPosition =          stretchMatrix*[0.200,   5*heightUnit,    1-editBoxWidth,    editBoxHeight]' + controlPanelOffset;
displayIntensityTextPosition =      stretchMatrix*[0.000,   3*heightUnit,    editBoxWidth+0.1,    editBoxHeight]' + controlPanelOffset;
allIntensityRadioPosition =         stretchMatrix*[0.250,   3*heightUnit,    editBoxWidth,    editBoxHeight]' + controlPanelOffset;
positiveIntensityRadioPosition =    stretchMatrix*[0.400,   3*heightUnit,    editBoxWidth,    editBoxHeight]' + controlPanelOffset;
negativeIntensityRadioPosition =    stretchMatrix*[0.550,   3*heightUnit,    editBoxWidth,    editBoxHeight]' + controlPanelOffset;
renderViewCheckPosition =           stretchMatrix*[0.780,   3*heightUnit,    editBoxWidth,    editBoxHeight]' + controlPanelOffset;
hideControlPushPosition =           stretchMatrix*[0.200,   4*heightUnit,    editBoxWidth,    editBoxHeight]' + controlPanelOffset;
volumePushPosition =                stretchMatrix*[0.000,   4*heightUnit,    editBoxWidth,    editBoxHeight]' + controlPanelOffset;
commonRegionPushPosition =          stretchMatrix*[0.200,   4*heightUnit,    editBoxWidth,    editBoxHeight]' + controlPanelOffset;
%knd
paramestPushPosition =              stretchMatrix*[0.800,   4*heightUnit,    editBoxWidth*.5, editBoxHeight]' + controlPanelOffset;
%--
displayPushPosition =               stretchMatrix*[0.200,   4*heightUnit,    editBoxWidth,    editBoxHeight]' + controlPanelOffset;
allinonePushPosition =              stretchMatrix*[0.400,   4*heightUnit,    editBoxWidth,    editBoxHeight]' + controlPanelOffset;
searchPushPosition =                stretchMatrix*[0.000,   6*heightUnit,    editBoxWidth,    editBoxHeight]' + controlPanelOffset;
searchContentEditPosition =         stretchMatrix*[0.200,   6*heightUnit,    editBoxWidth*2,    editBoxHeight]' + controlPanelOffset;
searchTextPosition =                stretchMatrix*[0.600,   6*heightUnit,    editBoxWidth,    editBoxHeight]' + controlPanelOffset;
searchEnginePopPosition =           stretchMatrix*[0.600,   6*heightUnit,    1-0.6,    editBoxHeight]' + controlPanelOffset;
overlayPushPosition =               stretchMatrix*[0.000,   5*heightUnit,    editBoxWidth,    editBoxHeight]' + controlPanelOffset;
overlayEditPosition =               stretchMatrix*[0.200,   5*heightUnit,    0.6-editBoxWidth,    editBoxHeight]' + controlPanelOffset;
overlayPopPosition =                stretchMatrix*[0.600,   5*heightUnit,    1-0.6,    editBoxHeight]' + controlPanelOffset;
helpPosition =                      stretchMatrix*[0.800,   5*heightUnit,    editBoxWidth,    editBoxHeight]' + controlPanelOffset;
infoTextBoxPosition =               stretchMatrix*[0.000,   8*heightUnit,    1,           editBoxHeight*9]' + controlPanelOffset;
%xjViewPosition =                    stretchMatrix*[0.400,   13*heightUnit,    editBoxWidth*2.5,    editBoxHeight*3]' + controlPanelOffset;
%connameTextBoxPosition =            stretchMatrix*[0.000,   8*heightUnit,    1,           editBoxHeight*9]' + controlPanelOffset;

sectionViewListboxPosition =        [sectionViewPosition(1)+0.4, sectionViewPosition(2)+0.02, 0.1, 0.14];
sectionViewMoreTargetPushPosition = [sectionViewListboxPosition(1),sectionViewListboxPosition(2)-0.02,0.10,0.02];
xHairCheckPosition =                [sectionViewListboxPosition(1),sectionViewListboxPosition(2)+0.14,0.15,0.02];
setTRangeEditPosition =             [sectionViewListboxPosition(1),sectionViewListboxPosition(2)-0.06,0.10,0.02];
setTRangeTextPosition =             [sectionViewListboxPosition(1),sectionViewListboxPosition(2)-0.04,0.10,0.02];

getStructurePushPosition =          [glassViewAxesPosition(1), glassViewAxesPosition(2)-0.06, editBoxWidth/2, editBoxHeight/2];
structureEditPosition =             [getStructurePushPosition(1), getStructurePushPosition(2), 1, getStructurePushPosition(4)];
framePosition =                     (controlPanelPosition - controlPanelOffset')*1.05 + 0.95*controlPanelOffset';

%knd
setContrastNameTextPosition =       [glassViewAxesPosition(1),glassViewAxesPosition(2)-0.026,0.6,0.03];
setContrastListPosition     =       [setContrastNameTextPosition(1)+setContrastNameTextPosition(3)+.01,setContrastNameTextPosition(2),0.05,setContrastNameTextPosition(4)];
setContrastListPosition     =       [glassViewAxesPosition(1)+.05*glassViewAxesPosition(3),glassViewAxesPosition(2)-0.026,glassViewAxesPosition(3)*.95,0.03];
setIndivResultsListPosition =       [setTRangeTextPosition(1)-0.25,setTRangeEditPosition(2),0.20,setTRangeEditPosition(4)];
%-- knd

% draw figure and control
figureBKcolor=[176/255 252/255 188/255];
figureBKcolor=get(0,'Defaultuicontrolbackgroundcolor');
f = figure('unit','normalized','position',figurePosition,'Color',figureBKcolor,'defaultuicontrolBackgroundColor', figureBKcolor,...
    'Name','xjView', 'Tag', 'xjView', 'NumberTitle','off','resize','off','CloseRequestFcn', {@CallBack_quit, warnstate(1).state}, 'visible','off');
handles = guihandles(f);

% databases
try
    X = load('TDdatabase');
    handles.DB = X.DB;
    handles.wholeMaskMNIAll = X.wholeMaskMNIAll;
catch
    errordlg('I can''t find TDdatabase.mat','TDdatabase not found');
end

handles.figure = f;
handles.frame = uicontrol(handles.figure,'style','frame',...
    'unit','normalized',...
    'position',framePosition,...
    'Visible','off');
handles.slider = uicontrol(handles.figure,'style','slider',...
    'unit','normalized',...
    'position',sliderPosition,...
    'max',1,'min',0,...
    'sliderstep',[0.01,0.10],...
    'callback',@CallBack_slider,...
    'value',0,'Visible','on');
handles.pValueTextPosition = uicontrol(handles.figure,'style','text',...
    'unit','normalized','position',pValueTextPosition,...
    'string','pValue=','horizontal','left');
handles.pValueEdit = uicontrol(handles.figure,'style','edit',...
    'unit','normalized','position',pValueEditPosition,...
    'horizontal','left',...
    'String', num2str(pValue),...
    'BackgroundColor', 'w',...
    'callback',@CallBack_pValueEdit);
handles.intensityThresholdText = uicontrol(handles.figure,'style','text',...
    'unit','normalized','position',intensityThresholdTextPosition,...
    'string',' intensity=','horizontal','left');
handles.intensityThresholdEdit = uicontrol(handles.figure,'style','edit',...
    'unit','normalized','position',intensityThresholdEditPosition,...
    'horizontal','left',...
    'BackgroundColor', 'w',...
    'String', num2str(intensityThreshold),...
    'callback',@CallBack_intensityThresholdEdit);
handles.dfText = uicontrol(handles.figure,'style','text',...
    'unit','normalized','position',dfTextPosition,...
    'string','df= ','horizontal','right');
handles.dfEdit = uicontrol(handles.figure,'style','edit',...
    'unit','normalized','position',dfEditPosition,...
    'horizontal','left',...
    'BackgroundColor', 'w',...
    'String', '',...
    'callback',@CallBack_dfEdit);
handles.clusterSizeThresholdText = uicontrol(handles.figure,'style','text',...
    'unit','normalized','position',clusterSizeThresholdTextPosition,...
    'string','cluster size >=','horizontal','left');
handles.clusterSizeThresholdEdit = uicontrol(handles.figure,'style','edit',...
    'unit','normalized','position',clusterSizeThresholdEditPosition,...
    'horizontal','left',...
    'BackgroundColor', 'w',...
    'String', num2str(clusterSizeThreshold),...
    'callback',@CallBack_clusterSizeThresholdEdit);
handles.thisClusterSizeText = uicontrol(handles.figure,'style','text',...
    'unit','normalized','position',thisClusterSizeTextPosition,...
    'string','size= ','horizontal','right', 'visible', 'off');
handles.thisClusterSizeEdit = uicontrol(handles.figure,'style','edit',...
    'unit','normalized','position',thisClusterSizeEditPosition,...
    'horizontal','left',...
    'Enable', 'inactive',...
    'String', '','visible','off');

handles.imageFileEdit = uicontrol(handles.figure,'style','edit',...
    'unit','normalized','position',imageFileEditPosition,...
    'horizontal','left',...
    'String', '',...
    'BackgroundColor', 'w',...
    'callback',@CallBack_imageFileEdit,...
    'visible','off');
handles.saveImageFileEdit = uicontrol(handles.figure,'style','edit',...
    'unit','normalized','position',saveImageFileEditPosition,...
    'horizontal','left',...
    'BackgroundColor', 'w',...
    'String', 'myMask.img',...
    'callback',@CallBack_saveImageFileEdit,...
    'visible','off');
handles.saveResultPSEdit = uicontrol(handles.figure,'style','edit',...
    'unit','normalized','position',resultPSFileEditPosition,...
    'horizontal','left',...
    'BackgroundColor', 'w',...
    'String', 'myResult.ps',...
    'callback',@CallBack_saveResultPSEdit,...
    'visible','off');
handles.loadImagePush = uicontrol(handles.figure,'style','push',...
    'unit','normalized','position',loadImagePushPosition,...
    'string','Load Image','callback',@CallBack_loadImagePush,...
    'visible','off');
handles.saveImagePush = uicontrol(handles.figure,'style','push',...
    'unit','normalized','position',saveImagePushPosition,...
    'string','Save Image','callback',@CallBack_saveImagePush,...
    'visible','off');
handles.saveResultPSPush = uicontrol(handles.figure,'style','push',...
    'unit','normalized','position',saveResultPSPushPosition,...
    'string','Save Result','callback',@CallBack_saveResultPSPush,...
    'visible','off');
handles.getStructurePush = uicontrol(handles.figure,'style','push',...
    'unit','normalized','position',getStructurePushPosition,...
    'string','Get Structure','callback',@CallBack_getStructurePush,'visible','off');
handles.structureEdit = uicontrol(handles.figure,'style','edit',...
    'unit','normalized','position',structureEditPosition,...
    'horizontal','center',...
    'enable', 'on',...
    'UserData',struct(...
    'hReg',    [],...
    'M',    M,...
    'D',    DIM,...
    'xyz',    [0 0 0]    ));
handles.pickThisClusterPush = uicontrol(handles.figure,'style','push',...
    'unit','normalized','position',pickThisClusterPushPosition,...
    'string','Pick Cluster/Info','callback',@CallBack_pickThisClusterPush);
handles.selectThisClusterPush = uicontrol(handles.figure,'style','push',...
    'unit','normalized','position',selectThisClusterPushPosition,...
    'string','Select Cluster','callback',@CallBack_selectThisClusterPush);
handles.clearSelectedClusterPush = uicontrol(handles.figure,'style','push',...
    'unit','normalized','position',clearSelectedClusterPushPosition,...
    'string','Clear Selection','callback',@CallBack_clearSelectedClusterPush);

handles.displayIntensityText = uicontrol(handles.figure,'style','text',...
    'unit','normalized','position',displayIntensityTextPosition,...
    'string','display intensity','horizontal','left');
handles.allIntensityRadio = uicontrol(handles.figure,'style','radio',...
    'unit','normalized',...
    'string','All',...
    'position',allIntensityRadioPosition,...
    'value', 1,...
    'callback',@CallBack_allIntensityRadio);
handles.positiveIntensityRadio = uicontrol(handles.figure,'style','radio',...
    'unit','normalized',...
    'string','Only +',...
    'position',positiveIntensityRadioPosition,...
    'callback',{@CallBack_allIntensityRadio,'+'});
handles.negativeIntensityRadio = uicontrol(handles.figure,'style','radio',...
    'unit','normalized',...
    'string','Only -',...
    'position',negativeIntensityRadioPosition,...
    'callback',{@CallBack_allIntensityRadio,'-'});
handles.renderViewCheck = uicontrol(handles.figure,'style','checkbox',...
    'unit','normalized',...
    'string','Render View' ,...
    'horizontal', 'right',...
    'position',renderViewCheckPosition,...
    'callback', @CallBack_renderViewCheck);

handles.sectionViewListbox = uicontrol(handles.figure,'style','listbox',...
    'unit','normalized',...
    'String', {'single T1','avg152PD','avg152T1','avg152T2','avg305T1','ch2','ch2bet','aal','brodmann'}, ...
    'value',3,...
    'position',sectionViewListboxPosition,...
    'callback',@CallBack_sectionViewListbox);

handles.xHairCheck = uicontrol(handles.figure,'style','checkbox',...
    'unit','normalized',...
    'string','XHairs Off' ,...
    'horizontal','left',...
    'position',xHairCheckPosition,...
    'callback',@CallBack_xHairCheck);
handles.sectionViewMoreTargetPush = uicontrol(handles.figure,'style','push',...
    'unit','normalized','position',sectionViewMoreTargetPushPosition,...
    'string','other ...','callback',@CallBack_sectionViewMoreTargetPush);
handles.setTRangeEdit = uicontrol(handles.figure,'style','edit',...
    'unit','normalized','position',setTRangeEditPosition,'BackgroundColor', 'w',...
    'string','auto','callback',@CallBack_setTRangeEdit);
handles.setTRangeText = uicontrol(handles.figure,'style','text',...
    'unit','normalized','position',setTRangeTextPosition,...
    'string','colorbar max');
handles.hideControlPush = uicontrol(handles.figure, 'style', 'push',...
    'unit','normalized',...
    'String', '<', 'position', hideControlPushPosition,...
    'visible','off');
handles.volumePush = uicontrol(handles.figure, 'style', 'push',...
    'unit','normalized',...
    'String', 'volume', ...
    'position', volumePushPosition,...
    'callback', @CallBack_volumePush);
handles.commonRegionPush = uicontrol(handles.figure, 'style', 'push',...
    'unit','normalized',...
    'String', 'common region', ...
    'position', commonRegionPushPosition,...
    'callback', @CallBack_commonRegionPush);
handles.displayPush = uicontrol(handles.figure, 'style', 'push',...
    'unit','normalized',...
    'String', 'display', ...
    'position', displayPushPosition,...
    'callback', @CallBack_displayPush,...
    'visible','off');
handles.allinonePush = uicontrol(handles.figure, 'style', 'push',...
    'unit','normalized',...
    'String', 'all in one', ...
    'position', allinonePushPosition,...
    'callback', @CallBack_allinonePush,...
    'visible','off');
%knd:
handles.setContrastNameText = uicontrol(handles.figure,'style','text',...
    'unit','normalized','position',setContrastNameTextPosition, 'FontSize', 13,...
    'string',' ... ','callback',@CallBack_setContrastNameTextPosition);
handles.contrastListPush = uicontrol(handles.figure, 'style', 'popup',...
    'unit','normalized',...
    'String', [ {''}'], ... % getfield(evalin('base','SS'),'sub2pr')),[],23)')], ...
    'position', setContrastListPosition,...
    'callback', @CallBack_contrastListPush,...
    'visible','on');

handles.indivResultsListPush(1) = uicontrol(handles.figure, 'style', 'popup',...
    'unit','normalized',...
    'String', [ {''}'], ... % getfield(evalin('base','SS'),'sub2pr')),[],23)')], ...
    'position', setIndivResultsListPosition,...
    'callback', @CallBack_indivResultsListPush,...
    'visible','on');
 
handles.paramestPush(1) = uicontrol(handles.figure, 'style', 'push',...
    'unit','normalized',...
    'String', 'Vox Betas', ...
    'position', paramestPushPosition'.*[1 1 2 1],...
    'callback', {@CallBack_paramestRegionPush, 'vox'},...
    'buttondownfcn',  {@CallBack_paramestRegionPush, 'vox', 0},...
    'visible','on');
handles.paramestPush(2) = uicontrol(handles.figure, 'style', 'push',...
    'unit','normalized',...
    'String', 'Cluster', ...
    'position', paramestPushPosition-[paramestPushPosition(3) 0 0 0]',...
    'callback',  {@CallBack_paramestRegionPush, 'clu'},...
    'buttondownfcn',  {@CallBack_paramestRegionPush, 'clu', 0},...    
    'visible','on');
handles.paramestPush(3) = uicontrol(handles.figure, 'style', 'push',...
    'unit','normalized',...
    'String', 'Sphere', ...
    'position', paramestPushPosition-2*[paramestPushPosition(3) 0 0 0]',...
    'callback', {@CallBack_paramestRegionPush, 'sph'},...
    'visible','on');
%--knd

handles.searchPush = uicontrol(handles.figure, 'style','push',...
    'unit','normalized','position',searchPushPosition,...
    'String', 'search','callback',@CallBack_searchPush, 'ForeGroundColor',[0 0 1]);
handles.searchContentEdit = uicontrol(handles.figure, 'style','edit',...
    'unit','normalized','position',searchContentEditPosition,...
    'ForeGroundColor',[0 0 1],...
    'BackgroundColor', 'w',...
    'horizontal','left','callback', @CallBack_searchContentEdit);
handles.searchText = uicontrol(handles.figure, 'style','text',...
    'unit','normalized','position',searchTextPosition,...
    'string', '  in',...
    'horizontal','left',...
    'visible','off');
handles.searchEnginePop = uicontrol(...
    'Units','normalized', ...
    'ListboxTop',0, ...
    'Position',searchEnginePopPosition, ...
    'String',{'Brede';'Jede';'xBrain.org';'Google Scholar';'Pubmed';'Wikipedia'}, ...
    'Style','popupmenu', ...
    'value',1);
handles.overlayPush = uicontrol(handles.figure, 'style','push',...
    'unit','normalized','position',overlayPushPosition,...
    'String', 'overlay','callback',@CallBack_overlayPush);
handles.overlayEdit = uicontrol(handles.figure, 'style','edit',...
    'unit','normalized','position',overlayEditPosition,...
    'BackgroundColor', 'w',...
    'horizontal','left',...
    'callback', @CallBack_overlayEdit);
handles.overlayPop = uicontrol(handles.figure, 'style','popupmenu',...
    'unit','normalized','position',overlayPopPosition,...
    'string', sort(fieldnames(handles.wholeMaskMNIAll)),...
    'horizontal','left',...
    'callback', @CallBack_overlayPop);

handles.helpPush = uicontrol(handles.figure, 'style','push',...
    'unit','normalized','position',helpPosition,...
    'String', 'help','callback','web http://people.hnl.bcm.tmc.edu/cuixu/xjView','ForeGroundColor',[0 0 1],...
    'horizontal','left', ...
    'visible','off');
handles.infoTextBox = uicontrol(handles.figure, 'style','edit',...
    'unit','normalized','position',infoTextBoxPosition,...
    'String', 'Welcome to xjView 4','ForeGroundColor','k', 'BackgroundColor', 'w',...
    'horizontal','left', ...'fontname','times',...
    'max',2, 'min',0);
try
    s = urlread('http://people.hnl.bcm.tmc.edu/cuixu/xjView/toUser.txt');
    set(handles.infoTextBox, 'String', s);
end

handles.glassViewAxes = axes('unit','normalized','position',glassViewAxesPosition,'XTick',[],'YTick',[],'visible','off');


handles.testEdit = uicontrol(handles.figure,'style','edit',...
    'unit','normalized','position',[0.1 0.4 0.2 0.05],...
    'horizontal','left',...
    'callback',@test,...
    'visible','off');

% menu
cSHH = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on')
hMenuFile = findobj(get(handles.figure,'Children'),'flat','Label','&File');
if ~isempty(hMenuFile)
    hMenuFileOpen = findobj(get(handles.figure,'Children'),'Label','&Open...');
    set(hMenuFileOpen, 'label', 'Open Figure...');
    hMenuFileSave = findobj(get(handles.figure,'Children'),'Label','&Save');
    set(hMenuFileSave, 'label', 'Save Figure ...');
    hMenuFileSaveAs = findobj(get(handles.figure,'Children'),'Label','Save &As...');
    set(hMenuFileSaveAs, 'label', 'Save Figure As ...');
else
    hMenuFile = uimenu(handles.figure, 'label', '&File');
end

set(hMenuFile,'ForegroundColor',[0 0 1]);
set(findobj(hMenuFile,'Position',1),'Separator','on');
%knd
uimenu('Parent',hMenuFile,'Position',1,'ForegroundColor',[0 0 1],...
    'Label','Open SPM file (SPM.mat) ...',...
    'CallBack',@CallBack_loadSPMmat, 'Accelerator', 'o');
%--knd
uimenu('Parent',hMenuFile,'Position',1,'ForegroundColor',[0 0 1],...
    'Label','Open Images (*.img) ...',...
    'CallBack',@CallBack_loadImagePush, 'Accelerator', 'o');
uimenu('Parent',hMenuFile,'Position',2,'ForegroundColor',[0 0 1],...
    'Label','Save Current Image (*.img) ...',...
    'CallBack',{@CallBack_saveImagePush, '', 0});
uimenu('Parent',hMenuFile,'Position',3,'ForegroundColor',[0 0 1],...
    'Label','Save Current Image as Mask (*.img) ...',...
    'CallBack',{@CallBack_saveImagePush, '', 1});
uimenu('Parent',hMenuFile,'Position',4,'ForegroundColor',[0 0 1],...
    'Label','Save Result (*.ps/pdf) ...',...
    'CallBack',@CallBack_saveResultPSPush);

hMenuHelp = findobj(get(handles.figure,'Children'),'flat','Label','&Help');
if isempty(hMenuHelp)
    hMenuHelp = uimenu(handles.figure, 'label', 'xjView &Help');
end
set(hMenuHelp,'ForegroundColor',[0 0 1]);
uimenu('Parent',hMenuHelp,'Position',1,'ForegroundColor',[0 0 1],...
    'Label','xBrain.org: brain mapping database',...
    'CallBack','web http://www.xbrain.org -browser');
uimenu('Parent',hMenuHelp,'Position',2,...
    'Label','xjview help','ForegroundColor',[0 0 1],...
    'CallBack','web http://people.hnl.bcm.tmc.edu/cuixu/xjView');
set(findobj(hMenuHelp,'Position',3),'Separator','on');
set(0,'ShowHiddenHandles',cSHH)

if exist('cuixuBOLDretrieve')
    hMenuAnalyze = uimenu('label','&Analyze','ForegroundColor',[0 0 1],'visible','on');
    hMenuPreprocess = uimenu(hMenuAnalyze,'label','Preprocess','ForegroundColor',[0 0 1],'callback', @CallBack_preprocess);
    hMenuProcess = uimenu(hMenuAnalyze,'label','Process (GLM estimation)','ForegroundColor',[0 0 1],'callback',@CallBack_process);
    hMenuSPMProcess = uimenu(hMenuAnalyze,'label','SPMProcess (GLM using SPM)','ForegroundColor',[0 0 1],'callback',@CallBack_SPMProcess);
    hMenuGLMPeak = uimenu(hMenuAnalyze,'label','GLM on peak BOLD','ForegroundColor',[0 0 1],'callback',@CallBack_GLMPeak);
    hMenuContrast = uimenu(hMenuAnalyze,'label','Contrast','ForegroundColor',[0 0 1],'callback',@CallBack_contrast);
    hMenuFDR = uimenu(hMenuAnalyze,'label','FDR','ForegroundColor',[0 0 1],'callback',@CallBack_fdr);
    hMenuROI = uimenu(hMenuAnalyze,'label','ROI: retrieve signal','ForegroundColor',[0 0 1],'callback',@CallBack_timeSeries);
    hMenuROIPlot = uimenu(hMenuAnalyze,'label','ROI: plot','ForegroundColor',[0 0 1],'callback',@CallBack_plotROI, 'Accelerator', 'm');
    hMenuROIIndividualPlot = uimenu(hMenuAnalyze,'label','ROI: individual plot','ForegroundColor',[0 0 1],'callback',@CallBack_plotIndividualROI);
    hMenuROIIndividualPlotWithBehavior = uimenu(hMenuAnalyze,'label','ROI: individual plot with behavior','ForegroundColor',[0 0 1],'callback',@CallBack_plotIndividualROIWithBehavior);
    hMenuROICorrelationPlot = uimenu(hMenuAnalyze,'label','ROI: correlation plot','ForegroundColor',[0 0 1],'callback',@CallBack_plotCorrelationROI);
    %hMenuWholeBrainCorrelation = uimenu(hMenuAnalyze,'label','Whole brain correlation','ForegroundColor',[0 0 1],'callback',@CallBack_wholeBrainCorrelation);
    hMenuBehaviorAnalysis = uimenu(hMenuAnalyze,'label','Behavior analsyis','ForegroundColor',[0 0 1],'callback',@CallBack_behaviorAnalysis);
    hMenuHeadMovementAnalysis = uimenu(hMenuAnalyze,'label','Head movement analsyis','ForegroundColor',[0 0 1],'callback',@CallBack_headMovementAnalysis);
    hMenuModelComparison = uimenu(hMenuAnalyze,'label','Linear model comparison','ForegroundColor',[0 0 1],'callback',@CallBack_modelComparison);

    hMenuHNLOnly = uimenu('label','For H&NL Only','ForegroundColor',[0 0 1],'visible','on');
    hMenuNew2Old = uimenu(hMenuHNLOnly,'label','Format convert','ForegroundColor',[0 0 1],'callback',@CallBack_new2old);
    hMenuPreprocessCluster = uimenu(hMenuHNLOnly,'label','Preprocess (on cluster)','ForegroundColor',[0 0 1],'callback',{@CallBack_preprocess, 'cluster'});
    hMenuProcessCluster = uimenu(hMenuHNLOnly,'label','Process (GLM, on cluster)','ForegroundColor',[0 0 1],'callback',{@CallBack_process, 'cluster'});
    hMenuSPMProcessCluster = uimenu(hMenuHNLOnly,'label','SPM Process (GLM using SPM, on cluster)','ForegroundColor',[0 0 1],'callback',{@CallBack_SPMProcess, 'cluster'});
    hMenuGLMPeakCluster = uimenu(hMenuHNLOnly,'label','GLM on peak BOLD (on cluster)','ForegroundColor',[0 0 1],'callback',{@CallBack_GLMPeak, 'cluster'});
end

figurecm = uicontextmenu;
uimenu(figurecm,'label','Red','callback','set(gcf,''color'',''r'')');
uimenu(figurecm,'label','White','callback','set(gcf,''color'',''w'')');
uimenu(figurecm,'label','Gray','callback','set(gcf,''color'',[0.925, 0.914,  0.847])');
%set(handles.figure,'uicontextmenu',figurecm);
set(handles.figure,'WindowButtonDownFcn',@figureMouseUpFcn);

set(handles.figure,'visible','on');

% save pre-set values
handles.system = os;
handles.spmdir = spmdir;
handles.screenResolution = screenResolution;
handles.pValue = pValue;
handles.intensityThreshold = intensityThreshold;
handles.clusterSizeThreshold = clusterSizeThreshold;
handles.sectionViewPosition = sectionViewPosition;
handles.sectionViewTargetFile = getSectionViewTargetFile(spmdir, 'avg152T1');
%knd
if ~isempty(findstr('gazemo', pwd))
    handles.sectionViewTargetFile = fullfile(fileparts(mfilename('fullpath')), 'group','anat', 'mean-no120.img');
end
guidata(f, handles);

% global variables for rotation matrix M and dimension
global M_;
global DIM_;
global TR_;
global LEFTRIGHTFLIP_;
global TMAX_; % colorbar max to display in section view
M_ = M;
DIM_ = DIM;
TR_ = TR;
LEFTRIGHTFLIP_ = leftrightflip;
TMAX_ = 'auto';

% check input arguments
if length(varargin) == 0
    %CallBack_loadSPMmat(handles.loadImagePush)

    if exist(fullfile(pwd,'SPM.mat'), 'file')
        xSPM=load(fullfile(pwd,'SPM.mat'));
        numc=listdlg('ListString' , {xSPM.SPM.xCon.name}, 'SelectionMode' , 'single', 'InitialValue', length(xSPM.SPM.xCon));
        if ~isempty(numc)
            %MG:02.04.2008 CallBack_loadImagePush(handles.loadImagePush, [], {fullfile(xSPM.SPM.swd,xSPM.SPM.xCon(numc).Vspm.fname)});
            CallBack_loadImagePush(handles.loadImagePush, [], fullfile(xSPM.SPM.swd,xSPM.SPM.xCon(numc).Vspm.fname));
        end
    end

elseif isstr(varargin{1})
    if isempty(findstr('.mat', varargin{1}))
        CallBack_loadImagePush(handles.loadImagePush, [], varargin);
    else
        CallBack_loadSPMmat(handles.loadImagePush, [], varargin{1});
    end
else
    mniCoord = varargin{1};
    if length(varargin) < 2
        intensity = ones(size(mniCoord,1),1);
    else
        intensity = varargin{2};
    end
    thisStruct.mni = mniCoord;
    thisStruct.intensity = intensity;
    thisStruct.M = M;
    thisStruct.DIM = DIM';
    CallBack_loadImagePush(handles.loadImagePush, [], thisStruct);
end



function test(hObject, eventdata)
handles = guidata(gcbo);
set(hObject, 'String', num2str(handles.pValue));
vars = evalin('base','who');
vars
x = evalin('base',vars{1});
x
handles.DIM


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FDR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_fdr(hObject, eventdata)
handles = guidata(hObject);
set(handles.infoTextBox, 'string', {'Right now FDR only works for T-test image.'});
if length(handles.imageFileName) > 1
    set(handles.infoTextBox, 'string', {'I can only work for a single image file. You opened multiple files.'});
    return
end

q = get(handles.pValueEdit,'String');
q = str2num(q);
if get(handles.allIntensityRadio, 'Value')
    positive = 1;
elseif get(handles.positiveIntensityRadio, 'Value')
    positive = 1;
elseif get(handles.negativeIntensityRadio, 'Value')
    positive = -1;
end
xjviewpath = fileparts(which('xjview'));
maskImageFile = fullfile(xjviewpath, 'mask.img');
[threshold, pvalue] = fdr(handles.imageFileName{1}, q, positive, maskImageFile);
set(handles.pValueEdit,'string',pvalue);
CallBack_pValueEdit(handles.pValueEdit, eventdata);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% model comparison
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_modelComparison(hObject, eventdata)
answer = getVariable({'y','x (full model)', 'x (reduced model)'});

if isempty(answer)
    return;
end

if ~isempty(answer{1})
    y = evalin('base',answer{1});
else
    return;
end
if ~isempty(answer{2})
    xf = evalin('base',answer{2}); % full model
else
    return;
end
if ~isempty(answer{3})
    xr = evalin('base',answer{3}); % reduced model
else
    xr = [];
end

% make vector column vector
[r, c] = size(y);
if r==1; y = y'; end
[r, c] = size(xf);
if r<c; xf = xf'; end
[r, c] = size(xr);
if r<c; xr = xr'; end

format long;
disp('------------------------------------------')
TotalVariance = var(y)
n = size(y, 1);
dfTotal = n - 1

disp('------------------------------------------')
disp('Full Model:');
beta = linearregression(y,xf)
predictedy = [xf ones(size(xf, 1),1)] * beta;
residual = y - predictedy;
r2 = 1 - (var(residual) / var(y))
ResidualVarianceFullModel =  var(residual)
ModelVarianceFullModel =  var(predictedy);
dfResidualFull = n - size(xf, 2) - 1

if isempty(xr)
    return;
end

disp('------------------------------------------')
disp('Reduced Model:');
beta = linearregression(y,xr)
predictedy = [xr ones(size(xr, 1),1)] * beta;
residual = y - predictedy;
r2 = 1 - (var(residual) / var(y))
ResidualVarianceReducedModel =  var(residual)
ModelVarianceReducedModel =  var(predictedy);
dfResidualReduced = n - size(xr, 2) - 1

disp('------------------------------------------')
disp('Model Comparison (is the full model significantly better than the reduced model?):');
dfDenominator = dfResidualFull;
dfNumerator = dfResidualReduced - dfResidualFull;
F = (ResidualVarianceReducedModel - ResidualVarianceFullModel)/dfNumerator / (ResidualVarianceFullModel / dfDenominator);
disp(['f(' num2str(dfNumerator) ',' num2str(dfDenominator) ')=' num2str(F)])
pvalue = 1-spm_Fcdf(F, [dfNumerator dfDenominator])
%
% F = ModelVarianceFullModel/size(xf,2) / (ModelVarianceReducedModel/size(xr,2));
% disp(['f(' num2str(size(xf,2)) ',' num2str(size(xr,2)) ')=' num2str(F)])
% pvalue = 1-spm_Fcdf(F, [size(xf,2) size(xr,2)])

format short;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% behavior analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_behaviorAnalysis(hObject, eventdata)
global TR_;
answer = getVariable({'event data file','correlator', 'head movement files'});

if isempty(answer)
    return;
end

if ~isempty(answer{1})
    Pe = evalin('base',answer{1}); % event files
    numsubj = size(Pe, 1);
else
    Pe = [];
end
if ~isempty(answer{2})
    Pc = evalin('base',answer{2}); % correlator files
    numsubj = size(Pc, 1);
else
    Pc = [];
end
if ~isempty(answer{3})
    P = evalin('base',answer{3}); % headmovment files
    numsubj = size(P, 1);
else
    P = [];
end

if isempty(Pe) && isempty(Pc) && ~isempty(P)
    colors = 'rgbcmk';
    figure;
    Maximize(gcf);
    for ii=1:size(P,1)

        kk = mod(ii,8);
        if kk == 0
            kk = 8;
        end
        subplot(4,2,kk)

        tmp = load(deblank(P(ii,:)));
        tmp2 = fieldnames(tmp);
        hm = eval(['tmp.' tmp2{1}]);
        hmcell = struct2cell(hm);
        hmname = fieldnames(hm);
        for jj=1:length(hmname)
            plot(hmcell{jj}, colors(jj));
            hold on
        end
        legend(hmname)
        title(['subject ' num2str(ii)])

        if mod(ii,8) == 0
            figure;
            Maximize(gcf);
        end

    end
    return
end

colors=[1 0 0;
    0 0 1;
    0 0 0;
    1 0 1;
    0 1 1;
    0 1 0;
    1 1 0;
    1 0.5 0.5;
    .5 .5 1;
    .5 .5 .5;
    1 .5 0;
    1 0 .5;
    0 1 .5;
    .5 1 0;
    0 .5 1;
    .5 0 1];
colors = repmat(colors, 10, 1);

% allow user to select which subject to plot
prompt=['I find you have ' num2str(numsubj) ' subjects.  Please let me know which subject(s) you want me to use to generate the plots.'];
name='Which subject(s) to plot?';
numlines=1;
defaultanswer={['[1:'  num2str(numsubj) ']']};

whichtoplot=inputdlg(prompt,name,numlines,defaultanswer);
if isempty(whichtoplot)
    return;
end
whichtoplot = eval(whichtoplot{1});


%% event
if ~isempty(Pe)
    figure;
    Maximize(gcf);
    for ii=whichtoplot
        kk = mod(ii,4);
        if kk == 0
            kk = 4;
        end
        subplot(4,2,2*kk-1)



        tmp = load(deblank(Pe(ii,:)));
        tmp2 = fieldnames(tmp);
        hm = eval(['tmp.' tmp2{1}]);
        hmcell = struct2cell(hm);
        hmname = fieldnames(hm);
        for jj=1:length(hmname)
            toplot1 = [];
            toplot2 = [];
            for mm = 1:length(hmcell{jj})
                toplot1 = [toplot1 hmcell{jj}(mm) hmcell{jj}(mm) nan];
                toplot2 = [toplot2 0 1 nan];
            end
            plot(toplot1, toplot2, 'color', colors(jj,:));
            ylim([0 4])
            hold on
        end
        legend(hmname)
        title(['subject ' num2str(ii)])
        xlabel('time in s');

        %% prepare interval data for later plot
        alltimes{ii} = [];
        for jj=1:length(hmname)
            alltimes{ii} = union(alltimes{ii}, hmcell{jj});
        end

        subplot(4,2,2*kk)
        for jj=1:length(hmname)
            roundhmcell{jj} = round(hmcell{jj}*1);
            signal = zeros(1, max(roundhmcell{jj})+1);
            signal(roundhmcell{jj}+1) = 1;
            signal = signal - mean(signal);
            y = fft(signal);
            plotlength = round(length(y))/1;
            plot([1:plotlength]/plotlength, abs(y(1:plotlength)).^2, 'color', colors(jj,:));
            hold on
        end
        legend(hmname)
        xlabel('frequency');
        ylabel('fft power');
        title(['subject ' num2str(ii)])

        subplot(4,2,2*kk-1)
        if ~isempty(P) % if there is head movement data
            tmp = load(deblank(P(ii,:)));
            tmp2 = fieldnames(tmp);
            hm = eval(['tmp.' tmp2{1}]);
            hmcell = struct2cell(hm);
            hmname = fieldnames(hm);
            for jj=1:length(hmname)
                plot(TR_*[0:length(hmcell{jj})-1],hmcell{jj},'color', [.5 .5 .5]);
                hold on
            end
        end

        if mod(ii,4) == 0 && ii~=size(Pe, 1)
            figure;
            Maximize(gcf);
        end
    end

    %% now I plot correlogram of intervals
    figure;
    kk = 1;
    for ii=whichtoplot
        alltimes{ii} = sort(alltimes{ii});
        intervals = diff(alltimes{ii});
        corrlag(intervals,intervals,[max(-10, -length(intervals)+2) : min(10, length(intervals)-2)], colors(ii,:));
        hold on;
        legendname{kk} = ['sub ' num2str(ii)];
        kk = kk+1;
    end
    legend(legendname)
    xlabel('lag');
    ylabel('correlation coefficient');
    title('correlogram of intervals')
end

%% correlator

if ~isempty(Pc)

    tmp = load(deblank(Pc(1,:)));
    tmp2 = fieldnames(tmp);
    hm = eval(['tmp.' tmp2{1}]);

    C = hm;
    cenames = fields(C);
    for jj=1:length(cenames)
        eval(['correlatornames{jj} = fields(C.' cenames{jj} ');']);
        for kk=1:length(correlatornames{jj})
            eval(['C.' cenames{jj} '.' correlatornames{jj}{kk} '= [];']);
        end
    end

    %list all plot names in command window for selection
    promt{1} = 'Please select which two correlators do you want to plot. The first one will be x and the second will be y.  The two have to be of the same length.';
    promt{2} = 'index   event    correlator';
    count = 1;
    for jj=1:length(cenames)
        eval(['correlatornames{jj} = fields(C.' cenames{jj} ');']);
        for kk=1:length(correlatornames{jj})
            promt{count+2} = sprintf('%d         %s         %s', count,  cenames{jj}, correlatornames{jj}{kk});
            count = count + 1;
        end
    end
    promt{count+2} = '';

    if count == 1
        return
    end
    promt = char(promt);
    name='Please select which two correlator do you want to plot. The first one will be x and the second will be y.';
    numlines=1;
    if count == 1
        defaultanswer={['You don''t have more than one correlators. Click Cancel']};
    else
        defaultanswer={['[1 '  num2str(count-1) ']']};
    end

    whichplot=inputdlg(promt,name,numlines,defaultanswer);
    if isempty(whichplot)
        return;
    end
    whichplot = eval(whichplot{1});

    figure;
    Maximize(gcf);
    for ii=whichtoplot
        tmp = load(deblank(Pc(ii,:)));
        tmp2 = fieldnames(tmp);
        hm = eval(['tmp.' tmp2{1}]);
        count = 1;
        for jj=1:length(cenames)
            eval(['correlatornames{jj} = fields(C.' cenames{jj} ');']);
            for kk=1:length(correlatornames{jj})
                tmp2 = eval(['hm.' cenames{jj} '.' correlatornames{jj}{kk} ';']);
                if size(tmp2,1) == 1
                    tmp2 = tmp2';
                end
                eval(['C.' cenames{jj} '.' correlatornames{jj}{kk} '= [C.' cenames{jj} '.' correlatornames{jj}{kk} '; tmp2];']);

                if whichplot(1) == count
                    x = tmp2;
                    xlabeltext = [correlatornames{jj}{kk} ' at ' cenames{jj}];
                end
                if whichplot(2) == count
                    y = tmp2;
                    ylabeltext = [correlatornames{jj}{kk} ' at ' cenames{jj}];
                end
                count = count + 1;
            end
        end

        kk = mod(ii,16);
        if kk == 0
            kk = 16;
        end
        subplot(4,4,kk)

        plot2(x,y, 'b', 1);
        xlabel(xlabeltext)
        ylabel(ylabeltext)
        title(['subject ' num2str(ii)])
        try
            % convert to colum vector
            if size(x,1)==1
                x = x';
            end
            if size(y,1)==1
                y = y';
            end

            % remove NaN
            tmpposx = find(isnan(x) | isinf(x));
            tmpposy = find(isnan(y) | isinf(y));
            x([tmpposx; tmpposy]) = [];
            y([tmpposx; tmpposy]) = [];

            b = linearregression(y,x);

            totalvar = var(y);
            residvar = var(y - x*b(1) - b(2));
            modelvar = totalvar - residvar;
            dfm = 1;
            dft = length(x) - 1;
            dfr = dft - dfm;
            mmodelvar = modelvar/dfm;
            mresidvar = residvar/dfr;
            F = mmodelvar/mresidvar;
            pvalue = 1-spm_Fcdf(F, [dfm dfr]);

            title(sprintf('sub %d, pValue=%g', ii, pvalue))
            xx=[min(x):(max(x)-min(x))/10:max(x)];
            yy=b(1) * xx + b(2);
            hold on;
            plot(xx,yy,'g');
        end

        if mod(ii,16) == 0 && ii~=size(Pc, 1)
            figure;
            Maximize(gcf);
        end
    end

    % plot the average
    count = 1;
    for jj=1:length(cenames)
        eval(['correlatornames{jj} = fields(C.' cenames{jj} ');']);
        for kk=1:length(correlatornames{jj})
            if whichplot(1) == count
                eval(['x = C.' cenames{jj} '.' correlatornames{jj}{kk} ';']);
                xlabeltext = [correlatornames{jj}{kk} ' at ' cenames{jj}];
            end
            if whichplot(2) == count
                eval(['y = C.' cenames{jj} '.' correlatornames{jj}{kk} ';']);
                ylabeltext = [correlatornames{jj}{kk} ' at ' cenames{jj}];
            end
            count = count + 1;
        end
    end

    figure
    plot2(x,y, 'b', 1);
    xlabel(xlabeltext)
    ylabel(ylabeltext)
    try
        % convert to colum vector
        if size(x,1)==1
            x = x';
        end
        if size(y,1)==1
            y = y';
        end

        % remove NaN
        tmpposx = find(isnan(x) | isinf(x));
        tmpposy = find(isnan(y) | isinf(y));
        x([tmpposx; tmpposy]) = [];
        y([tmpposx; tmpposy]) = [];

        b = linearregression(y,x);

        totalvar = var(y);
        residvar = var(y - x*b(1) - b(2));
        modelvar = totalvar - residvar;
        dfm = 1;
        dft = length(x) - 1;
        dfr = dft - dfm;
        mmodelvar = modelvar/dfm;
        mresidvar = residvar/dfr;
        F = mmodelvar/mresidvar;
        pvalue = 1-spm_Fcdf(F, [dfm dfr]);

        title(sprintf('pValue=%g; slope=%g; constant=%g', pvalue, b(1), b(2)))
        xx=[min(x):(max(x)-min(x))/10:max(x)];
        yy=b(1) * xx + b(2);
        hold on;
        plot(xx,yy,'g');
    end
end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% head movement analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_headMovementAnalysis(hObject, eventdata)
answer = getVariable({'head movement files'});

if isempty(answer)
    return;
end
if isempty(answer{1})
    return;
end

P = evalin('base',answer{1}); % headmovment files

colors = 'rgbcmk';
figure;
Maximize(gcf);
for ii=1:size(P,1)

    kk = mod(ii,8);
    if kk == 0
        kk = 8;
    end
    subplot(4,2,kk)

    tmp = load(deblank(P(ii,:)));
    tmp2 = fieldnames(tmp);
    hm = eval(['tmp.' tmp2{1}]);
    hmcell = struct2cell(hm);
    hmname = fieldnames(hm);
    for jj=1:length(hmname)
        plot(hmcell{jj}, colors(jj));
        hold on
    end
    legend(hmname)
    title(['subject ' num2str(ii)])

    if mod(ii,8) == 0
        figure;
        Maximize(gcf);
    end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% contrast
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_contrast(hObject, eventdata)

answer = getVariable({'beta files', 'contrast vector'});

if isempty(answer)
    return;
end
if isempty(answer{1}) | isempty(answer{2})
    return;
end

[filename, pathname] = uiputfile('*.img', 'Save t-test image as', '');
if isequal(filename,0) | isequal(pathname,0)
    return
else
    thisfilename = fullfile(pathname, filename);
end


P1 = evalin('base',answer{1}); % beta image files
c = evalin('base',answer{2}); % contrast vector

if iscell(P1)
    [];
else
    disp('format wrong');
    return;
end


h = waitbar(0,'Please wait...');
V=spm_vol(deblank(P1{1}(1,:)));
M1={spm_read_vols(V)};
contr = zeros(size(M1{1},1), size(M1{1},2), size(M1{1},3), size(P1{1},1));

for ii=1:size(P1{1},1)
    for jj=1:length(P1)
        if c(jj)~=0
            V=spm_vol(deblank(P1{jj}(ii,:)));
            M1{jj}=spm_read_vols(V);
            contr(:,:,:,ii) = contr(:,:,:,ii)+c(jj)*double(M1{jj});
        end
    end

    waitbar(ii/size(P1{1},1),h,['finished ' num2str(ii) ' of ' num2str(size(P1{1},1))]);
end
close(h);


df = size(P1{1},1)-1;

T = squeeze(t(permute(contr,[4 1 2 3])));   % return a 41*48*35 matrix
xjviewpath = fileparts(which('xjview'));
V=spm_vol(fullfile(xjviewpath, 'mask.img'));
m=spm_read_vols(V);
T = T.*m;

targetfilename = thisfilename;
global M_;
global DIM_;
V.mat = M_;
V.dim = [DIM_(1) DIM_(2) DIM_(3) 16];
V.fname = targetfilename;
V.descrip = ['SPM{T_[' num2str(df) '.0]} ' num2str(c)];
V = spm_write_vol(V,T);

handles = guidata(hObject);
[tmp,tmp,ext] = fileparts(thisfilename);
if isempty(ext)
    ext = '.img';
elseif isequal(lower(ext), '.img')
    ext = '';
end
CallBack_loadImagePush(handles.loadImagePush, [], {[thisfilename ext]});

return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SPM process (use SPM processing)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_SPMProcess(hObject, eventdata, singleOrCluster)

answer = getVariable({'Image files', 'Event time data', 'Modulator','Other regressor (e.g. headmovement)'});

if isempty(answer)
    return;
end
if isempty(answer{1}) | isempty(answer{2})
    return;
end

P = evalin('base',answer{1}); % subject directories
E = evalin('base',answer{2}); % event time
try
    Modulator = evalin('base',answer{3}); % modulator
catch
    Modulator = [];
end
try
    headmovement = evalin('base',answer{4}); % other regressor such as headmovement
catch
    headmovement = [];
end

if nargin < 3
    singleOrCluster = 'single';
end


prompt='I will create a folder under each subject''s directory and put the SPM output files (including beta images, SPM.mat etc) for that subject into that folder. Please give a name to the folder (example: FixedEffect). No space or strange characters allowed.';
name='Give a name to SPM output folder';
numlines=1;
defaultanswer={'FixedEffect'};

wheretosave=inputdlg(prompt,name,numlines,defaultanswer);

if isempty(wheretosave)
    return
else
    wheretosave = wheretosave{1};
end

currentdir = pwd;

if strcmp(singleOrCluster, 'cluster')
    handles = guidata(hObject);
    set(handles.infoTextBox, 'string', {'This will do SPM GLM estimation using cluster.', 'Check out xjviewtmp directory'});

    mkdir('xjviewtmp');
    cd('xjviewtmp');
    system('rm *');

    fid = fopen('processALL.pbs','wt');
    fprintf(fid,'#!/bin/bash\n\n');
    fprintf(fid,'for ((s=1;s<=%d;s++))\n', size(P,1));
    fprintf(fid,'do\n\tsleep 3.5\n\tqsub %s/process.pbs -v "s=$s" -N SPM_$s\ndone\n', pwd);
    fclose(fid);

    save P P;
    save E E;
    save Modulator Modulator;
    save headmovement headmovement;
    fid = fopen('process.pbs','wt');
    fprintf(fid,'#!/bin/bash\n\n');
    fprintf(fid,'#PBS -l nodes=1:ppn=1,walltime=04:00:00\n');
    fprintf(fid,'#PBS -N process\n');
    fprintf(fid,'#PBS -e %s\n', pwd);
    fprintf(fid,'#PBS -o %s\n\n', pwd);
    fprintf(fid,'sleep 3.5\n\n');
    fprintf(fid,'PATH=/usr/local/bin:$PATH\n\n');
    fprintf(fid,'matlab -nojvm -nodisplay \\\n');
    fprintf(fid,'-logfile "%s/process.$s.$PBS_JOBID.log" \\\n', pwd);


    fprintf(fid,['-r "addpath ~/gang/xjview;'...
        'wheretosave = ''%s'';'...
        'cd %s; '...
        'load P; '...
        'load E; '...
        'load Modulator;'...
        'load headmovement;'...
        'tmp=load(deblank(P($s,:)));'...
        'fd=fields(tmp);'...
        'eval([''Pi=tmp.'' fd{1} '';'']);'...
        'N = size(Pi,1);'...
        'tmp=load(deblank(E($s,:))); '...
        'fd=fields(tmp); '...
        'eval([''EE=tmp.'' fd{1} '';'']); '...
        'thisModulator = [];'...
        'if ~isempty(Modulator);'...
        'tmp = load(deblank(Modulator($s,:)));  '...
        'fd=fields(tmp); '...
        'eval([''thisModulator=tmp.'' fd{1} '';'']);'...
        'end;'...
        '[otherregressor{1}.C, otherregressor{1}.name]=struct2matrix(N, EE, thisModulator);'...
        'if ~isempty(headmovement);'...
        'tmp = load(deblank(headmovement($s,:)));  '...
        'fd=fields(tmp); '...
        'eval([''thisheadmovement=tmp.'' fd{1} '';'']);'...
        'tmphd = struct2cell(thisheadmovement);'...
        'tmpname = fieldnames(thisheadmovement);'...
        'for kk=1:length(tmphd);'...
        '[r,c] = size(tmphd{kk});'...
        'if r==1; tmphd{kk} = tmphd{kk}''; end;'...
        'otherregressor{1}.C = [otherregressor{1}.C tmphd{kk}];'...
        'otherregressor{1}.name = [otherregressor{1}.name {tmpname{kk}}];'...
        'end;'...
        'end;'...
        'subDir = fileparts(deblank(Pi(1,:))); '...
        'for kk=1:length(subDir); '...
        'if subDir(end-kk+1)==filesep;'...
        'pos=kk;'...
        'break;'...
        'end;'...
        'end; '...
        'subDir(end-pos+1:end)=[]; '...
        'cd(subDir); '...
        'try;' ...
        'rmdir(wheretosave, ''s'');'...
        'end;'...
        'mkdir(wheretosave);'...
        'cd(wheretosave);'...
        'spm_defaults;'...
        'disp(subDir);'...
        'cuixuprocess(N, [0], {}, {}, {}, [], otherregressor, Pi, 16);'...
        'disp(''done!'');'...
        'exit;"'], wheretosave, pwd);

    fclose(fid);

    system(['ssh cluster.hnl.bcm.tmc.edu  PATH=$PATH:/usr/local/pbs/i686/bin bash ' pwd '/processALL.pbs']);
    cd ..
elseif  strcmp(singleOrCluster, 'single')
    handles = guidata(hObject);
    set(handles.infoTextBox, 'string', {'This will do SPM GLM estimation.'});
    for ii=1:size(P,1)
        tmp=load(deblank(P(ii,:)));
        fd=fields(tmp);
        eval(['Pi=tmp.' fd{1} ';']);
        N = size(Pi,1);
        tmp=load(deblank(E(ii,:)));
        fd=fields(tmp);
        eval(['EE=tmp.' fd{1} ';']);
        thisModulator = [];
        if ~isempty(Modulator)
            tmp = load(deblank(Modulator(ii,:)));
            fd=fields(tmp);
            eval(['thisModulator=tmp.' fd{1} ';']);
        end
        [otherregressor{1}.C, otherregressor{1}.name]=struct2matrix(N, EE, thisModulator);
        if ~isempty(headmovement)
            tmp = load(deblank(headmovement(ii,:)));
            fd=fields(tmp);
            eval(['thisheadmovement=tmp.' fd{1} ';']);

            tmphd = struct2cell(thisheadmovement);
            tmpname = fieldnames(thisheadmovement);
            for kk=1:length(tmphd)
                [r,c] = size(tmphd{kk});
                if r==1; tmphd{kk} = tmphd{kk}'; end
                otherregressor{1}.C = [otherregressor{1}.C tmphd{kk}];
                otherregressor{1}.name = [otherregressor{1}.name {tmpname{kk}}];
            end
        end
        subDir = fileparts(deblank(Pi(1,:)));
        for kk=1:length(subDir);
            if subDir(end-kk+1)==filesep;
                pos=kk;
                break;
            end;
        end;
        subDir(end-pos+1:end)=[];
        cd(subDir);
        try
            rmdir(wheretosave, 's');
        end
        mkdir(wheretosave);
        cd(wheretosave);

        spm_defaults;
        disp(subDir);
        cuixuprocess(N, [0], {}, {}, {}, [], otherregressor, Pi, 16);

        tmp = get(handles.infoTextBox, 'string');
        set(handles.infoTextBox, 'string', [tmp; {['SPM Processing subject ' num2str(ii) ' / ' num2str(size(P,1)) ' ...']}]);
        disp(['----finished ' num2str(ii) ' out of ' num2str(size(P,1)) ' subjects----']);
    end
    tmp = get(handles.infoTextBox, 'string');
    set(handles.infoTextBox, 'string', [tmp; {'Done!'}]);
end

cd(currentdir)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% GLMPeak (only do regression on peak BOLD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_GLMPeak(hObject, eventdata, singleOrCluster)

answer = getVariable({'Image data', 'Event time data', 'Modulator'});

if isempty(answer)
    return;
end
if isempty(answer{1}) | isempty(answer{2}) | isempty(answer{3})
    return;
end

directoryname = uigetdir(pwd, 'Pick a Directory to Save Your Beta Files...');
if isequal(directoryname, 0)
    return;
end

P = evalin('base',answer{1}); % subject directories
E = evalin('base',answer{2}); % event time
Modulator = evalin('base',answer{3}); % modulator


if nargin < 3
    singleOrCluster = 'single';
end

if strcmp(singleOrCluster, 'cluster')
    mkdir('xjviewtmp');
    cd('xjviewtmp');
    system('rm *');

    fid = fopen('processALL.pbs','wt');
    fprintf(fid,'#!/bin/bash\n\n');
    fprintf(fid,'for ((s=1;s<=%d;s++))\n', size(P,1));
    fprintf(fid,'do\n\tsleep 3.5\n\tqsub %s/process.pbs -v "s=$s" -N pro_$s\ndone\n', pwd);
    fclose(fid);

    save P P;
    save E E;
    save Modulator Modulator;
    fid = fopen('process.pbs','wt');
    fprintf(fid,'#!/bin/bash\n\n');
    fprintf(fid,'#PBS -l nodes=1:ppn=1,walltime=08:00:00\n');
    fprintf(fid,'#PBS -N process\n');
    fprintf(fid,'#PBS -e %s\n', pwd);
    fprintf(fid,'#PBS -o %s\n\n', pwd);
    fprintf(fid,'sleep 3.5\n\n');
    fprintf(fid,'PATH=/usr/local/bin:$PATH\n\n');
    fprintf(fid,'matlab -nojvm -nodisplay \\\n');
    fprintf(fid,'-logfile "%s/process.$s.$PBS_JOBID.log" \\\n', pwd);

    fprintf(fid,['-r "addpath ~/gang/xjview; '...
        'cd %s; '...
        'load P; '...
        'load E; '...
        'load Modulator; '...
        'tmp=load(deblank(P($s,:))); '...
        'fd=fields(tmp); '...
        'eval([''SS=tmp.'' fd{1} '';'']); '...
        'tmp=load(deblank(E($s,:))); '...
        'fd=fields(tmp); '...
        'eval([''EE=tmp.'' fd{1} '';'']); '...
        'tmp = load(deblank(Modulator($s,:)));  fd=fields(tmp);  eval([''MM=tmp.'' fd{1} '';'']);'...
        'names = fieldnames(EE);'...
        'for jj=1:length(names);'...
        'eval([''MM.'' names{jj} ''.time = EE.'' names{jj} '';'']);'...
        'end;'...
        'xjviewpath = fileparts(which(''xjview''));'...
        'cuixuGLMpeak(MM, SS, ''%s'', [''subject'' num2str($s)], fullfile(xjviewpath, ''mask.img''), [4 6], 100, 2, fullfile(xjviewpath, ''templateFile.img''));'...
        'exit;"'], pwd, directoryname);

    fclose(fid);

    system(['ssh cluster.hnl.bcm.tmc.edu  PATH=$PATH:/usr/local/pbs/i686/bin bash ' pwd '/processALL.pbs']);
    cd ..
elseif strcmp(singleOrCluster, 'single')
    xjviewpath = fileparts(which('xjview'));
    handles = guidata(hObject);
    set(handles.infoTextBox, 'string', {'This will do simple GLM estimation on peak BOLD.'});
    for ii = 1:size(P,1)
        tmp = get(handles.infoTextBox, 'string');
        set(handles.infoTextBox, 'string', [tmp; {['Processing subject ' num2str(ii) ' / ' num2str(size(P,1)) ' ...']}]);
        tmp=load(deblank(P(ii,:)));
        fd=fields(tmp);
        eval(['SS=tmp.' fd{1} ';']);
        tmp=load(deblank(E(ii,:)));
        fd=fields(tmp);
        eval(['EE=tmp.' fd{1} ';']);
        tmp=load(deblank(Modulator(ii,:)));
        fd=fields(tmp);
        eval(['MM=tmp.' fd{1} ';']);
        % convert Modulator and E to be recognized by cuixuGLMpeak
        names = fieldnames(EE);
        for jj=1:length(names)
            eval(['MM.' names{jj} '.time = EE.' names{jj} ';']);
        end
        cuixuGLMpeak(MM, SS, directoryname, ['subject' num2str(ii)], fullfile(xjviewpath, 'mask.img'), [4 6], 100, 2, fullfile(xjviewpath, 'templateFile.img'));
        disp(['----finished ' num2str(ii) ' out of ' num2str(size(P,1)) ' subjects----']);
    end
    tmp = get(handles.infoTextBox, 'string');
    set(handles.infoTextBox, 'string', [tmp; {'Done!'}]);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% process (use my own process code, cuixuAGLM, estimation on detrended relative BOLD)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_process(hObject, eventdata, singleOrCluster)

answer = getVariable({'Image data', 'Event time data', 'Modulator'});

if isempty(answer)
    return;
end
if isempty(answer{1}) | isempty(answer{2})
    return;
end

directoryname = uigetdir(pwd, 'Pick a Directory to Save Your Beta Files...');
if isequal(directoryname, 0)
    return;
end

P = evalin('base',answer{1}); % subject directories
E = evalin('base',answer{2}); % event time
try
    Modulator = evalin('base',answer{3}); % modulator
catch
    Modulator = [];
end


if nargin < 3
    singleOrCluster = 'single';
end

if strcmp(singleOrCluster, 'cluster')
    mkdir('xjviewtmp');
    cd('xjviewtmp');
    system('rm *');

    fid = fopen('processALL.pbs','wt');
    fprintf(fid,'#!/bin/bash\n\n');
    fprintf(fid,'for ((s=1;s<=%d;s++))\n', size(P,1));
    fprintf(fid,'do\n\tsleep 3.5\n\tqsub %s/process.pbs -v "s=$s" -N pro_$s\ndone\n', pwd);
    fclose(fid);

    save P P;
    save E E;
    save Modulator Modulator;
    fid = fopen('process.pbs','wt');
    fprintf(fid,'#!/bin/bash\n\n');
    fprintf(fid,'#PBS -l nodes=1:ppn=1,walltime=08:00:00\n');
    fprintf(fid,'#PBS -N process\n');
    fprintf(fid,'#PBS -e %s\n', pwd);
    fprintf(fid,'#PBS -o %s\n\n', pwd);
    fprintf(fid,'sleep 3.5\n\n');
    fprintf(fid,'PATH=/usr/local/bin:$PATH\n\n');
    fprintf(fid,'matlab -nojvm -nodisplay \\\n');
    fprintf(fid,'-logfile "%s/process.$s.$PBS_JOBID.log" \\\n', pwd);

    fprintf(fid,['-r "addpath ~/gang/xjview; '...
        'cd %s; '...
        'load P; '...
        'load E; '...
        'load Modulator; '...
        'tmp=load(deblank(P($s,:))); '...
        'fd=fields(tmp); '...
        'eval([''M=tmp.'' fd{1} '';'']); '...
        'if isnumeric(M); M=double(M); elseif isstr(M); V=spm_vol(M); M =spm_read_vols(V); else; error(''I don not understand the fileformat''); end;' ...
        'tmp=load(deblank(E($s,:))); '...
        'fd=fields(tmp); '...
        'eval([''EE=tmp.'' fd{1} '';'']); '...
        'if ~isempty(Modulator); tmp = load(deblank(Modulator($s,:)));  fd=fields(tmp);  eval([''thisModulator=tmp.'' fd{1} '';'']); else; thisModulator=[]; end;'...
        'M = permute(M,[4 1 2 3]); '...
        '[tmp,tmp,M]=mAveDetrend(M,100); '...
        'M = permute(M,[2 3 4 1]); '...
        '[a,b,c]=fileparts(deblank(P($s,:)));'...
        'cuixuAGLM(M,EE,{''%s'', b}, thisModulator); '...
        'exit;"'], pwd, directoryname);

    fclose(fid);

    system(['ssh cluster.hnl.bcm.tmc.edu  PATH=$PATH:/usr/local/pbs/i686/bin bash ' pwd '/processALL.pbs']);
    cd ..
elseif strcmp(singleOrCluster, 'single')
    handles = guidata(hObject);
    set(handles.infoTextBox, 'string', {'This will do simple GLM estimation.'});
    for ii=1:size(P,1)
        tmp = get(handles.infoTextBox, 'string');
        set(handles.infoTextBox, 'string', [tmp; {['Processing subject ' num2str(ii) ' / ' num2str(size(P,1)) ' ...']}]);
        tmp=load(deblank(P(ii,:)));
        fd=fields(tmp);
        eval(['M=tmp.' fd{1} ';']);
        if isnumeric(M); M=double(M); elseif isstr(M); V=spm_vol(M); M =spm_read_vols(V); else; error('I don''t understand the fileformat'); end;
        tmp=load(deblank(E(ii,:)));
        fd=fields(tmp);
        eval(['EE=tmp.' fd{1} ';']);
        if ~isempty(Modulator); tmp = load(deblank(Modulator(ii,:)));  fd=fields(tmp);  eval(['thisModulator=tmp.' fd{1} ';']); else; thisModulator=[]; end;
        M = permute(M,[4 1 2 3]);
        [tmp,tmp,M]=mAveDetrend(M,100);
        M = permute(M,[2 3 4 1]);
        [a,b,c]=fileparts(deblank(P(ii,:)));
        cuixuAGLM(M,EE,{directoryname, b}, thisModulator);
        disp(['----finished ' num2str(ii) ' out of ' num2str(size(P,1)) ' subjects----']);
    end
    tmp = get(handles.infoTextBox, 'string');
    set(handles.infoTextBox, 'string', [tmp; {'Done!'}]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% convert new data format to old
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_new2old(hObject, eventdata)
answer = getVariable({'subjects directories'});
if isempty(answer)
    return;
end
if isempty(answer{1})
    return;
end
P = evalin('base',answer{1}); % subject directories
new2old(P);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% pre-process
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_preprocess(hObject, eventdata, singleOrCluster)
answer = getVariable({'subjects directories'});
if isempty(answer)
    return;
end
if isempty(answer{1})
    return;
end
P = evalin('base',answer{1}); % subject directories

if nargin < 3
    singleOrCluster = 'single';
end

if strcmp(singleOrCluster, 'cluster')
    mkdir('xjviewtmp');
    cd('xjviewtmp');
    system('rm *');

    fid = fopen('preprocessALL.pbs','wt');
    fprintf(fid,'#!/bin/bash\n\n');
    fprintf(fid,'for ((s=1;s<=%d;s++))\n', size(P,1));
    fprintf(fid,'do\n\tsleep 3.5\n\tqsub %s/preprocess.pbs -v "s=$s" -N pre_$s\ndone\n', pwd);
    fclose(fid);

    save P P;
    fid = fopen('preprocess.pbs','wt');
    fprintf(fid,'#!/bin/bash\n\n');
    fprintf(fid,'#PBS -l nodes=1:ppn=1,walltime=08:00:00\n');
    fprintf(fid,'#PBS -N preprocess\n');
    fprintf(fid,'#PBS -e %s\n', pwd);
    fprintf(fid,'#PBS -o %s\n\n', pwd);
    fprintf(fid,'sleep 3.5\n\n');
    fprintf(fid,'PATH=/usr/local/bin:$PATH\n\n');
    fprintf(fid,'matlab -nojvm -nodisplay \\\n');
    fprintf(fid,'-logfile "%s/preprocess.$s.$PBS_JOBID.log" \\\n', pwd);
    fprintf(fid,['-r "addpath ~/gang/xjview; cd ' pwd '; load P; cuixuSmartPreprocess(P, $s);exit;"']);
    fclose(fid);

    system(['ssh cluster.hnl.bcm.tmc.edu  PATH=$PATH:/usr/local/pbs/i686/bin bash ' pwd '/preprocessALL.pbs']);
    cd ..
elseif strcmp(singleOrCluster, 'single')
    handles = guidata(hObject);
    set(handles.infoTextBox, 'string', {'What will be done in preprocessing is:',...
        '1. Converting DICOM files',...
        '2. Re-align',...
        '3. Coregister',...
        '4. Slice timing',...
        '5. Normalize',...
        '6. Smooth','',...
        'This function creates a directory ''preprocessing'' under your homeDir and put all preprocessing files there. It also saves the head movement matrix in ''headmovement.mat''. The intermediate files are removed',''});
    for ii=1:size(P,1)
        tmp = get(handles.infoTextBox, 'string');
        set(handles.infoTextBox, 'string', [tmp; {['Preprocessing subject ' num2str(ii) ' / ' num2str(size(P,1)) ' ...']}]);
        cuixuSmartPreprocess(P, ii);
    end
    tmp = get(handles.infoTextBox, 'string');
    set(handles.infoTextBox, 'string', [tmp; {'Done!'}]);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% ROI: TimeSeries
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_timeSeries(hObject, eventdata)

global TR_;
handles = guidata(hObject);
if ~isfield(handles,'currentDisplayMNI') | isempty(cell2mat(handles.currentDisplayMNI'))
    %errordlg('No voxels found.','error');
    set(handles.infoTextBox, 'string', 'No voxels found.');
    beep
    return;
end

answer = getVariable({'Image data', 'Event time data', 'Correlator', 'Effects to be removed (e.g. headmovement)'});
%answer=inputdlg('Input the name of the variable (in the base workspace) which contains the image file name list, or the 4-D data matrix. If you wish to select the image files directly, click cancel.', 'Variable Name?', 1, {'P'});
if isempty(answer)
    return;
end
if isempty(answer{1})
    return;
end

searchContent = get(handles.searchContentEdit,'string');
if isempty(searchContent)
    searchContent = num2str(coord(1,3));
end
searchContent = ['ROI_' searchContent];
[filename, pathname] = uiputfile('*.mat', 'Save result to', searchContent);
if isequal(filename,0) | isequal(pathname,0)
    return
else
    thisfilename = fullfile(pathname, filename);
end


P = evalin('base',answer{1}); % data
try
    E = evalin('base',answer{2}); % event
catch
    E = [];
end
try
    C = evalin('base',answer{3}); % correlator
catch
    C = [];
end
try
    headmovement = evalin('base',answer{4}); % headmovement
catch
    headmovement = [];
end

mni = cell2mat(handles.currentDisplayMNI');
coord = mni2cor(mni, handles.M{1});


if ischar(P)
    h = waitbar(0,'Please wait...');
    for ii=1:size(P,1)
        tmp = load(deblank(P(ii,:)));
        tmp1 = fields(tmp);
        eval(['M = tmp.' tmp1{1} ';']);
        if isnumeric(M)
            M = double(M);
        end
        if ~isempty(E)
            tmp = load(deblank(E(ii,:)));
            tmp1 = fields(tmp);
            eval(['event{ii} = tmp.' tmp1{1} ';']);
            if ~isstruct(event{ii})
                error('I need you specify the event in a structure, not a cell array!');
                return
            end
        else
            event = {};
        end

        if ~isempty(headmovement) % if headmovement is present (or any other effects to be removed), then get rid of it first
            H = [];
            tmp = load(deblank(headmovement(ii,:)));
            fd=fields(tmp);
            eval(['thisheadmovement=tmp.' fd{1} ';']);

            tmphd = struct2cell(thisheadmovement);
            for kk=1:length(tmphd)
                [r,c] = size(tmphd{kk});
                if r==1; tmphd{kk} = tmphd{kk}'; end
                H = [H  tmphd{kk}];
            end
            for kk=1:size(coord,1)
                b = linearregression(squeeze(M(coord(kk,1), coord(kk,2), coord(kk,3), :)),H);
                M(coord(kk,1), coord(kk,2), coord(kk,3), :) = squeeze(M(coord(kk,1), coord(kk,2), coord(kk,3), :)) - H*b(1:end-1);
            end
        end

        [eventResponse{ii}, time{ii}, wholeOriginal{ii}, wholeAbsolute{ii}, wholeBaseline{ii}, removedEvent{ii}, remainedEvent{ii}] = cuixuBOLDretrieve(M, coord, event{ii}, 50, -20, 100, 0, TR_);

        if ~isempty(C)
            tmp = load(deblank(C(ii,:)));
            tmp1 = fields(tmp);
            eval(['correlator{ii} = tmp.' tmp1{1} ';']);
            if ~isstruct(correlator{ii})
                error('I need you specify the correlator in a structure, not a cell array!');
                return
            end

            names = fields(correlator{ii});
            for kk=1:length(names)
                eval(['names2 = fields(correlator{ii}.' names{kk} ');']);
                for mm=1:length(names2)
                    eval(['correlator{ii}.' names{kk} '.' names2{mm} ' = correlator{ii}.' names{kk} '.' names2{mm} '(remainedEvent{ii}.' names{kk} ');']);;
                end
            end
        end
        waitbar(ii/size(P,1),h,['finished ' num2str(ii) ' of ' num2str(size(P,1))]);
        disp(['finished ' num2str(ii) ' of ' num2str(size(P,1))]);
    end
    close(h)
elseif isnumeric(P) % never used!
    P = double(P);
    if ~isempty(E)
        tmp = load(deblank(E(ii,:)));
        tmp1 = fields(tmp);
        eval(['event{ii} = tmp.' tmp1{1} ';']);
    else
        event = {};
    end
    [eventResponse{ii}, time{ii}, wholeOriginal{ii}, wholeAbsolute{ii}, wholeBaseline{ii}, removedEvent{ii}, remainedEvent{ii}] = cuixuBOLDretrieve(P, coord, event{ii}, 50, -20, 100, 0, TR_);
end

if ~exist('correlator')
    correlator = {};
end

mat = handles.M{1};
save(thisfilename, 'eventResponse', 'time', 'wholeOriginal', 'wholeAbsolute', 'wholeBaseline', 'correlator', 'coord', 'mni', 'removedEvent','remainedEvent', 'event', 'mat', 'P', 'headmovement');
CallBack_plotROI(hObject, eventdata, thisfilename);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% plot ROI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_plotROI(hObject, eventdata, filename)
handles = guidata(hObject);

if ~exist('filename')
    if findstr('SPM2',spm('ver'))
        P = spm_get([0:1],'*.mat','Select ROI result file');
    elseif findstr('SPM5',spm('ver'))
        P = spm_select([0:1],'mat','Select ROI result file');
    end
else
    P = filename;
end

if isempty(P)
    return;
end
load(deblank(P));

if ~exist('mni')
    set(handles.infoTextBox, 'string', {'Oops! I donnt find the variable mni. Please open a proper mat file.'});
    return
end

delete(gcf)
xjview(mni);

% allow user to select which subject to plot
prompt=['I find you have ' num2str(length(eventResponse)) ' subjects.  Please let me know which subjects you want me to use to generate the plots.'];
name='Which subject(s) to plot?';
numlines=1;
defaultanswer={['[1:'  num2str(length(eventResponse)) ']']};

whichtoplot=inputdlg(prompt,name,numlines,defaultanswer);
if isempty(whichtoplot)
    return;
end
whichtoplot = eval(whichtoplot{1});


response = eventResponse{1};

eventisstruct = 0;
if isstruct(response)
    eventisstruct = 1;
    f = fieldnames(response);
    response = struct2cell(response);
else
    f = num2cell([1:length(response)]);
    for ii=1:length(response)
        f{ii} = num2str(f{ii});
    end
end
for jj=1:length(response)
    response{jj} = [];
end

if exist('correlator') & ~isempty(correlator) & eventisstruct==1
    C = correlator{1};
    cenames = fields(C);
    for jj=1:length(cenames)
        eval(['correlatornames{jj} = fields(C.' cenames{jj} ');']);
        for kk=1:length(correlatornames{jj})
            eval(['C.' cenames{jj} '.' correlatornames{jj}{kk} '= [];']);
        end
    end
    for ii=whichtoplot%1:length(correlator)
        for jj=1:length(cenames)
            eval(['correlatornames{jj} = fields(C.' cenames{jj} ');']);
            for kk=1:length(correlatornames{jj})
                tmp2 = eval(['correlator{ii}.' cenames{jj} '.' correlatornames{jj}{kk} ';']);
                if size(tmp2,1) == 1
                    tmp2 = tmp2';
                end
                eval(['C.' cenames{jj} '.' correlatornames{jj}{kk} '= [C.' cenames{jj} '.' correlatornames{jj}{kk} '; tmp2];']);
            end
        end
    end
end

if eventisstruct == 1
    for ii=1:length(eventResponse)
        for kk=1:length(f)
            eval(['tmptmp{kk} = eventResponse{ii}.' f{kk} ';']);
        end
        eventResponse{ii} = tmptmp;
    end
end

for ii=whichtoplot%1:length(eventResponse)
    for jj=1:length(eventResponse{1})
        response{jj} = [response{jj}; eventResponse{ii}{jj}];
    end
end

if isempty(response)
    msgbox('Nothing to plot');
    return
end

% error Matlab 6.5 takes 'time' as a function
% -- and growls when time{1} is used
if not(exist('time', 'var'))
    time=[];
end



v = version;
figure;
%colors='rbkmcgyrbkmcgyrbkmcgyrbkmcgyrbkmcgyrbkmcgyrbkmcgy';
colors=[1 0 0;
    0 0 1;
    0 0 0;
    1 0 1;
    0 1 1;
    0 1 0;
    1 1 0;
    1 0.5 0.5;
    .5 .5 1;
    .5 .5 .5;
    1 .5 0;
    1 0 .5;
    0 1 .5;
    .5 1 0;
    0 .5 1;
    .5 0 1];
colors = repmat(colors, 10, 1);
thislabel = {};
for ii=1:length(response)
    if v(1)=='6'
        ff = errorbar(time{1}, meannan(response{ii}), stdnan(response{ii})/sqrt(size(response{ii},1)));
        set(ff,'color',colors(ii, :));
        thislabel = [thislabel {''} f(ii)];
    elseif v(1)=='7'
        errorbar(time{1}, meannan(response{ii}), stdnan(response{ii})/sqrt(size(response{ii},1)), 'color', colors(ii, :));
        thislabel = [thislabel f(ii)];
    end
    hold on;
end
xlabel('time (s)');
ylabel('relative BOLD');
legend(thislabel)
hold off;

[row,col]  = size(response);
if row == 1; response = response'; end;
ResponseForPlot = cell2struct(response, f, 1);

if exist('correlator') & ~isempty(correlator)
    %list all plot names in command window for selection
    promt{1} = 'I will plot BOLD amplitude vs correlator. Here are all the correlators:';
    promt{2} = 'index   event    correlator';
    count = 1;
    for jj=1:length(cenames)
        eval(['correlatornames{jj} = fields(C.' cenames{jj} ');']);
        for kk=1:length(correlatornames{jj})
            promt{count+2} = sprintf('%d         %s         %s', count,  cenames{jj}, correlatornames{jj}{kk});
            count = count + 1;
        end
    end
    promt{count+2} = 'Which plots do you want me to show?';

    promt = char(promt);
    name='Please select which plots to show';
    numlines=1;
    defaultanswer={['[1:'  num2str(count-1) ']']};

    whichplot=inputdlg(promt,name,numlines,defaultanswer);
    if isempty(whichplot)
        return;
    end
    whichplot = eval(whichplot{1});

    count = 1;
    for jj=1:length(cenames)
        eval(['correlatornames{jj} = fields(C.' cenames{jj} ');']);
        for kk=1:length(correlatornames{jj})
            if ~ismember(count, whichplot)
                count = count + 1;
                continue;
            end

            eval(['x = C.' cenames{jj} '.' correlatornames{jj}{kk} ';']);

            uniquex = unique(x);
            pos = find(isnan(uniquex));
            uniquex(pos) = [];

            if(length(uniquex)<10)  % only if the correlator is discrete, then plot BOLD vs time for each correlator
                figure;
                thislabel = {};
                for ii=1:length(uniquex)
                    pos = find(x==uniquex(ii));
                    eval(['z = meannan(ResponseForPlot.' cenames{jj} '(pos,:));']);
                    eval(['stdz = stdnan(ResponseForPlot.' cenames{jj} '(pos,:))/sqrt(length(pos));']);

                    if v(1)=='6'
                        ff = errorbar(time{1}, z, stdz);
                        set(ff,'color',colors(ii, :));
                        thislabel = [thislabel {''} {(num2str(uniquex(ii)))}];
                    elseif v(1)=='7'
                        errorbar(time{1}, z, stdz, 'color', colors(ii, :));
                        thislabel = [thislabel {(num2str(uniquex(ii)))}];
                    end
                    hold on;
                end
                legend(thislabel);
                xlabel('time in second');
                ylabel('BOLD');
                title([cenames{jj} ' ' correlatornames{jj}{kk}])
            end

            count = count + 1;
        end
    end

    peakpoint = inputdlg({'I will plot peak BOLD. What points in time do you considered as peak BOLD?'}, 'Peak point',1,{'4 6'});
    if isempty(peakpoint); return; end
    peakpoint = str2num(peakpoint{1});

    count = 1;
    for jj=1:length(cenames)
        eval(['correlatornames{jj} = fields(C.' cenames{jj} ');']);
        for kk=1:length(correlatornames{jj})
            if ~ismember(count, whichplot)
                count = count + 1;
                continue;
            end

            eval(['y = mean(ResponseForPlot.' cenames{jj} '(:,findind(time{1},peakpoint)), 2);']);
            eval(['x = C.' cenames{jj} '.' correlatornames{jj}{kk} ';']);


            figure
            plot(x,y, 'sb');
            hold on;
            plot2(x,y,'r',1);

            xlabel(correlatornames{jj}{kk})
            ylabel('peak relative BOLD');
            legend(cenames{jj})
            try
                % convert to colum vector
                if size(x,1)==1
                    x = x';
                end
                if size(y,1)==1
                    y = y';
                end

                % remove NaN
                tmpposx = find(isnan(x) | isinf(x));
                tmpposy = find(isnan(y) | isinf(y));
                x([tmpposx; tmpposy]) = [];
                y([tmpposx; tmpposy]) = [];

                b = linearregression(y,x);

                totalvar = var(y);
                residvar = var(y - x*b(1) - b(2));
                modelvar = totalvar - residvar;
                dfm = 1;
                dft = length(x) - 1;
                dfr = dft - dfm;
                mmodelvar = modelvar/dfm;
                mresidvar = residvar/dfr;
                F = mmodelvar/mresidvar;
                pvalue = 1-spm_Fcdf(F, [dfm dfr]);

                title(sprintf('pValue=%s; slope=%g; constant=%g', pvalue, b(1), b(2)))
                xx=[min(x):(max(x)-min(x))/10:max(x)];
                yy=b(1) * xx + b(2);
                hold on;
                plot(xx,yy,'g');
            end
            count = count + 1;
        end
    end
end

function index = findind(vector1, vector2)
kk = 1;
for ii=1:length(vector2)
    tmp = find(vector1 == vector2(ii));
    if ~isempty(tmp)
        index(kk) = tmp;
        kk = kk+1;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% plot ROI, individual by individual, with behavior timing on it
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_plotIndividualROIWithBehavior(hObject, eventdata)
global TR_;
handles = guidata(hObject);

if findstr('SPM2',spm('ver'))
    P = spm_get([0:1],'*.mat','Select ROI result file');
elseif findstr('SPM5',spm('ver'))
    P = spm_select([0:1],'mat','Select ROI result file');
end

if isempty(P)
    return;
end
load(P);

answer = getVariable({'headmovement data (optional)'});


try
    Ph = evalin('base',answer{1}); % headmovement
catch
    Ph = [];
end

colors=[1 0 0;
    0 0 1;
    0 0 0;
    1 0 1;
    0 1 1;
    0 1 0;
    1 1 0;
    1 0.5 0.5;
    .5 .5 1;
    .5 .5 .5;
    1 .5 0;
    1 0 .5;
    0 1 .5;
    .5 1 0;
    0 .5 1;
    .5 0 1];
colors = repmat(colors, 10, 1);


figure;
Maximize(gcf);
for ii=1:length(event)
    kk = mod(ii,8);
    if kk == 0
        kk = 8;
    end
    subplot(4,2,kk)

    m = mean(wholeOriginal{ii});
    s = std(wholeOriginal{ii});
    mx = max(wholeOriginal{ii});
    mn = min(wholeOriginal{ii});
    ylowerlimit = mn;

    hm = event{ii};
    hmcell = struct2cell(hm);
    hmname = fieldnames(hm);
    for jj=1:length(hmname)
        toplot1 = [];
        toplot2 = [];
        for mm = 1:length(hmcell{jj})
            toplot1 = [toplot1 hmcell{jj}(mm) hmcell{jj}(mm) nan];
            toplot2 = [toplot2 m-s m+s nan];
        end
        plot(toplot1, toplot2, 'color', colors(jj,:));
        hold on
    end
    legend(hmname)
    title(['subject ' num2str(ii)])
    xlabel('time in s');

    if ~isempty(Ph) % if there is head movement data
        tmp = load(deblank(Ph(ii,:)));
        tmp2 = fieldnames(tmp);
        hm = eval(['tmp.' tmp2{1}]);
        hmcell = struct2cell(hm);
        hmname = fieldnames(hm);
        for jj=1:length(hmname)
            plot(TR_*[0:length(hmcell{jj})-1],mn-s+s*hmcell{jj}/max(abs(hmcell{jj})),'color', [.5 .5 .5]);
            ylowerlimit = min(ylowerlimit, min(mn-s+s*hmcell{jj}/max(abs(hmcell{jj}))));
            hold on
        end
    end

    % plot imaging data
    plot(TR_*[0:length(wholeOriginal{ii})-1], wholeOriginal{ii}, 'k');
    hold on;
    ylim([ylowerlimit mx])

    if mod(ii,8) == 0 && ii~=length(event)
        figure;
        Maximize(gcf);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% plot ROI, individual by individual
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_plotIndividualROI(hObject, eventdata, filename)
handles = guidata(hObject);

if ~exist('filename')
    if findstr('SPM2',spm('ver'))
        P = spm_get([0:1],'*.mat','Select ROI result file');
    elseif findstr('SPM5',spm('ver'))
        P = spm_select([0:1],'mat','Select ROI result file');
    end
else
    P = filename;
end

if isempty(P)
    return;
end
load(deblank(P));

if ~exist('mni')
    set(handles.infoTextBox, 'string', {'Oops! I donnt find the variable mni. Please open a proper mat file.'});
    return
end

delete(gcf)
xjview(mni);

response = eventResponse{1};

eventisstruct = 0;
if isstruct(response)
    eventisstruct = 1;
    f = fieldnames(response);
    response = struct2cell(response);
else
    f = num2cell([1:length(response)]);
    for ii=1:length(response)
        f{ii} = num2str(f{ii});
    end
end
for jj=1:length(response)
    response{jj} = [];
end

if exist('correlator') & ~isempty(correlator) & eventisstruct==1
    C = correlator{1};
    cenames = fields(C);
    for jj=1:length(cenames)
        eval(['correlatornames{jj} = fields(C.' cenames{jj} ');']);
        for kk=1:length(correlatornames{jj})
            eval(['C.' cenames{jj} '.' correlatornames{jj}{kk} '= [];']);
        end
    end
    for ii=1:length(correlator)
        for jj=1:length(cenames)
            eval(['correlatornames{jj} = fields(C.' cenames{jj} ');']);
            for kk=1:length(correlatornames{jj})
                tmp2 = eval(['correlator{ii}.' cenames{jj} '.' correlatornames{jj}{kk} ';']);
                if size(tmp2,1) == 1
                    tmp2 = tmp2';
                end
                eval(['C.' cenames{jj} '.' correlatornames{jj}{kk} '= [C.' cenames{jj} '.' correlatornames{jj}{kk} '; tmp2];']);
            end
        end
    end
end

if eventisstruct == 1
    for ii=1:length(eventResponse)
        for kk=1:length(f)
            eval(['tmptmp{kk} = eventResponse{ii}.' f{kk} ';']);
        end
        eventResponse{ii} = tmptmp;
    end
end

for ii=1:length(eventResponse)
    for jj=1:length(eventResponse{1})
        response{jj} = [response{jj}; eventResponse{ii}{jj}];
    end
end

if isempty(response)
    msgbox('Nothing to plot');
    return
end


% error Matlab 6.5 takes 'time' as a function
% -- and growls when time{1} is used
if not(exist('time', 'var'))
    time=[];
end


v = version;
figure;
%colors='rbkmcgyrbkmcgyrbkmcgyrbkmcgyrbkmcgyrbkmcgyrbkmcgy';
colors=[1 0 0;
    0 0 1;
    0 0 0;
    1 0 1;
    0 1 1;
    0 1 0;
    1 1 0;
    1 0.5 0.5;
    .5 .5 1;
    .5 .5 .5;
    1 .5 0;
    1 0 .5;
    0 1 .5;
    .5 1 0;
    0 .5 1;
    .5 0 1];
colors = repmat(colors, 10, 1);
thislabel = {};
for ii=1:length(response)
    if v(1)=='6'
        ff = errorbar(time{1}, meannan(response{ii}), stdnan(response{ii})/sqrt(size(response{ii},1)));
        set(ff,'color',colors(ii, :));
        thislabel = [thislabel {''} f(ii)];
    elseif v(1)=='7'
        errorbar(time{1}, meannan(response{ii}), stdnan(response{ii})/sqrt(size(response{ii},1)), 'color', colors(ii, :));
        thislabel = [thislabel f(ii)];
    end
    hold on;
end
xlabel('time (s)');
ylabel('relative BOLD');
legend(thislabel)
hold off;

figure;
Maximize(gcf);
for jj=1:length(eventResponse)
    wheretoplot = mod(jj, 16);
    if wheretoplot == 0;
        wheretoplot = 16;
        subplot(4,4,wheretoplot)
    else
        subplot(4,4,wheretoplot)
    end
    for ii=1:length(response)
        if v(1)=='6'
            ff = errorbar(time{1}, meannan(eventResponse{jj}{ii}), stdnan(eventResponse{jj}{ii})/sqrt(size(eventResponse{jj}{ii},1)));
            set(ff,'color',colors(ii, :));
            %thislabel = [thislabel {''} f(ii)];
        elseif v(1)=='7'
            errorbar(time{1}, meannan(eventResponse{jj}{ii}), stdnan(eventResponse{jj}{ii})/sqrt(size(eventResponse{jj}{ii},1)), 'color', colors(ii, :));
            %errorbar(time{1}, meannan(response{ii}), stdnan(response{ii})/sqrt(size(response{ii},1)), 'color', colors(ii, :));
            %thislabel = [thislabel f(ii)];
        end
        hold on;
    end
    title(['subject ' num2str(jj)])

    if mod(jj, 16)==0 && jj~=length(eventResponse)
        figure;
        Maximize(gcf);
    end
end



[row,col]  = size(response);
if row == 1; response = response'; end;
for jj=1:length(eventResponse)
    ResponseForPlot{jj} = cell2struct(eventResponse{jj}, f, 2);
end

if exist('correlator') & ~isempty(correlator)
    %list all plot names in command window for selection
    promt{1} = 'I will plot BOLD amplitude vs correlator. Here are all the correlators:';
    promt{2} = 'index   event    correlator';
    count = 1;
    for jj=1:length(cenames)
        eval(['correlatornames{jj} = fields(C.' cenames{jj} ');']);
        for kk=1:length(correlatornames{jj})
            promt{count+2} = sprintf('%d         %s         %s', count,  cenames{jj}, correlatornames{jj}{kk});
            count = count + 1;
        end
    end
    promt{count+2} = 'Which plots do you want me to show?';

    promt = char(promt);
    name='Please select which plots to show';
    numlines=1;
    defaultanswer={['[1:'  num2str(count-1) ']']};

    whichplot=inputdlg(promt,name,numlines,defaultanswer);
    if isempty(whichplot)
        return;
    end
    whichplot = eval(whichplot{1});

    peakpoint = inputdlg({'What points in time do you considered as peak BOLD?'}, 'Peak point',1,{'4 6'});
    if isempty(peakpoint); return; end
    peakpoint = str2num(peakpoint{1});

    count = 1;
    for jj=1:length(cenames)
        eval(['correlatornames{jj} = fields(C.' cenames{jj} ');']);
        for kk=1:length(correlatornames{jj})
            if ~ismember(count, whichplot)
                count = count + 1;
                continue;
            end
            figure;
            Maximize(gcf);
            for ii=1:length(eventResponse)
                wheretoplot = mod(ii, 16);
                if wheretoplot == 0;
                    wheretoplot = 16;
                    subplot(4,4,wheretoplot)
                else
                    subplot(4,4,wheretoplot)
                end


                eval(['y = mean(ResponseForPlot{ii}.' cenames{jj} '(:,findind(time{1},peakpoint)), 2);']);
                eval(['x = correlator{ii}.' cenames{jj} '.' correlatornames{jj}{kk} ';']);

                %plot(x,y, 'sb');
                %hold on;
                pos = find(isnan(x));
                x(pos) = [];
                y(pos) = [];
                pos = find(isnan(y));
                x(pos) = [];
                y(pos) = [];
                if length(x) < 1
                    continue;
                end
                plot2(x,y,'r',1);

                xlabel(correlatornames{jj}{kk})
                ylabel(['peak BOLD at ' cenames{jj}]);
                %legend(cenames{jj})
                try
                    % convert to colum vector
                    if size(x,1)==1
                        x = x';
                    end
                    if size(y,1)==1
                        y = y';
                    end

                    % remove NaN
                    tmpposx = find(isnan(x) | isinf(x));
                    tmpposy = find(isnan(y) | isinf(y));
                    x([tmpposx; tmpposy]) = [];
                    y([tmpposx; tmpposy]) = [];

                    b = linearregression(y,x);

                    totalvar = var(y);
                    residvar = var(y - x*b(1) - b(2));
                    modelvar = totalvar - residvar;
                    dfm = 1;
                    dft = length(x) - 1;
                    dfr = dft - dfm;
                    mmodelvar = modelvar/dfm;
                    mresidvar = residvar/dfr;
                    F = mmodelvar/mresidvar;
                    pvalue = 1-spm_Fcdf(F, [dfm dfr]);

                    title(sprintf('subject %d, pValue=%s', ii, pvalue))
                    xx=[min(x):(max(x)-min(x))/10:max(x)];
                    yy=b(1) * xx + b(2);
                    hold on;
                    plot(xx,yy,'g');
                end
                if mod(ii, 16)==0 && ii~=length(eventResponse)
                    figure;
                    Maximize(gcf);
                end
            end % end of loop subject
            count = count + 1;
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% plot ROI: correlation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_plotCorrelationROI(hObject, eventdata)

if findstr('SPM2',spm('ver'))
    P = spm_get([0:100],'*.mat','Select ROI result file(s)');
elseif findstr('SPM5',spm('ver'))
    P = spm_select([0:100],'mat','Select ROI result file(s)');
end

if isempty(P)
    return;
end

N = size(P,1);
t = [-20:20];

v = version;

if N == 1
    load(deblank(P));
    tmp = [];
    for jj=1:length(wholeAbsolute)
        tmp = [tmp; corrlag(wholeAbsolute{jj},wholeAbsolute{jj},t)];
    end
    figure;
    errorbar(t, mean(tmp,1), std(tmp)/sqrt(length(wholeAbsolute)));
    xlabel('lag in scan number');
    ylabel('auto correlation');
    title(deblank(P))
    return
else
    figure;
    colors='rbkmcgyrbkmcgyrbkmcgyrbkmcgyrbkmcgyrbkmcgyrbkmcgy';
    legendlabel = {};
    totalPermute = nchoosek([1:N],2);
    for ii=1:size(totalPermute,1)
        tmp = [];
        s1 = load(deblank(P(totalPermute(ii,1),:)));
        s2 = load(deblank(P(totalPermute(ii,2),:)));
        for jj=1:length(s1.wholeAbsolute)
            tmp = [tmp; corrlag(s1.wholeAbsolute{jj},s2.wholeAbsolute{jj},t)];
        end
        errorbar(t, mean(tmp,1), std(tmp)/sqrt(length(s1.wholeAbsolute)), colors(ii));
        xlabel('lag in scan number');
        ylabel('cross correlation');
        hold on;
        if v(1) == '6'
            legendlabel = [legendlabel, {'', P(totalPermute(ii,:),:)}];
        elseif v(1) == '7'
            legendlabel = [legendlabel, {P(totalPermute(ii,:),:)}];
        end
    end
    legend(legendlabel);
    hold off;
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% whole brain correlation analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_wholeBrainCorrelation(hObject, eventdata)
% answer = getVariable({'Which data file?'});
% if isempty(answer)
%     return;
% end
% if isempty(answer{1})
%     return;
% end
% P = evalin('base',answer{1}); % subject directories
if findstr('SPM2',spm('ver'))
    P = spm_get([0:1],'*.mat','Whole Brain Signal file');
elseif findstr('SPM5',spm('ver'))
    P = spm_select([0:1],'mat','Whole Brain Signal file');
end

if isempty(P)
    return
end

load(deblank(P));
M = double(M);

N=zeros(size(M,4), size(M,1) * size(M,2) * size(M,3));

mm = 1;
for ii=1:2:size(M,1)
    for jj=1:3:size(M,2)
        for kk=1:2:size(M,3)
            N(:, mm) = squeeze(M(ii,jj,kk,:));
            mm = mm + 1;
            cor(mm,:) = [ii jj kk];
        end
    end
end

N(:, mm:end) = [];

C=corrcoef(N);
C(find(isnan(C))) = 0;

for ii=1:4
    CC{ii} = abs(C)>(0.5+ii/10);
end

K = {zeros(1, size(C,1)),zeros(1, size(C,1)),zeros(1, size(C,1)),zeros(1, size(C,1))};
for ii=1:size(C,1)
    for jj=1:4
        K{jj}(ii) = sum(CC{jj}(ii,:)) - 1;
    end
end

x=[0:size(C,1)];
for jj=1:4
    y{jj}=zeros(size(x));
end

for ii=1:length(x)
    for jj=1:4
        y{jj}(ii) = sum(K{jj} == x(ii));
    end
end

figure;
loglog(x,y{1}, x, y{2}, x, y{3}, x, y{4});
xlabel('degree');
ylabel('counts');
legend('0.6', '0.7', '0.8', '0.9');
axis equal


z = sum(abs(C))-1;
zx = 0:max(z);
for ii=1:length(zx)-1
    pos = find(z>zx(ii) & z<=zx(ii+1));
    zy(ii) = length(pos);
end
figure;
loglog(zx(1:length(zy)),zy);
xlabel('weighted degree');
ylabel('counts');
axis equal

xjview(cor2mni(coord, handles.M{1}), z);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% get/select variable names in base workspace
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function vars = getVariable(titles)
vars = evalin('base','who');
height = 0.07;
f = dialog('unit','normalized', 'menubar','none', 'position', [0.3 0.2 0.4 0.4], 'name', 'pick variables', 'NumberTitle','off');
uicontrol(f,'style','text',...
    'unit','normalized',...
    'String', 'Available variables', ...
    'position',[0 0.9 0.5 0.1/2]);
variableListbox = uicontrol(f,'style','listbox','tag','variableListbox',...
    'unit','normalized',...
    'String', vars, ...
    'value',1,...
    'position',[0 0 0.5 0.9]);
okPush = uicontrol(f,'style','push',...
    'unit','normalized',...
    'String', 'OK', ...
    'position',[0.55 0.05 0.2 height],...
    'callback','uiresume');
cancelPush = uicontrol(f,'style','push',...
    'unit','normalized',...
    'String', 'Cancel', ...
    'position',[0.75 0.05 0.2 height],...
    'callback','delete(gcf)');

uicontrol(f,'style','text',...
    'unit','normalized',...
    'String', titles{1}, ...
    'position',[0.5 0.9 0.5 0.1/2]);
imageDataPush = uicontrol(f,'style','push',...
    'unit','normalized',...
    'String', '->', ...
    'position',[0.5 0.8 0.1 height],...
    'callback', [...
    'xyouneverfindme=findobj(get(gcf,''Children''),''flat'',''tag'',''imageDataEdit'');'...
    'yyouneverfindme=findobj(get(gcf,''Children''),''flat'',''tag'',''variableListbox'');'...
    'allyouneverfindme=get(yyouneverfindme,''string'');'...
    'selectedyouneverfindme=allyouneverfindme{get(yyouneverfindme,''value'')};'...
    'set(xyouneverfindme,''string'',selectedyouneverfindme);'...
    'clear allyouneverfindme selectedyouneverfindme xyouneverfindme yyouneverfindme;']);
imageDataEdit = uicontrol(f,'style','edit','tag','imageDataEdit',...
    'unit','normalized',...
    'String', '', ...
    'BackgroundColor', 'w',...
    'position',[0.6 0.8 0.3 height]);

if length(titles)>=2
    uicontrol(f,'style','text',...
        'unit','normalized',...
        'String', titles{2}, ...
        'position',[0.5 0.7 0.5 0.1/2]);
    eventDataPush = uicontrol(f,'style','push',...
        'unit','normalized',...
        'String', '->', ...
        'position',[0.5 0.6 0.1 height],...
        'callback', [...
        'xyouneverfindme=findobj(get(gcf,''Children''),''flat'',''tag'',''eventDataEdit'');'...
        'yyouneverfindme=findobj(get(gcf,''Children''),''flat'',''tag'',''variableListbox'');'...
        'allyouneverfindme=get(yyouneverfindme,''string'');'...
        'selectedyouneverfindme=allyouneverfindme{get(yyouneverfindme,''value'')};'...
        'set(xyouneverfindme,''string'',selectedyouneverfindme);'...
        'clear allyouneverfindme selectedyouneverfindme xyouneverfindme yyouneverfindme;']);

    eventDataEdit = uicontrol(f,'style','edit','tag','eventDataEdit',...
        'unit','normalized',...
        'String', '', ...
        'BackgroundColor', 'w',...
        'position',[0.6 0.6 0.3 height]);
end
if length(titles)>=3
    uicontrol(f,'style','text',...
        'unit','normalized',...
        'String', titles{3}, ...
        'position',[0.5 0.5 0.5 0.1/2]);
    correlatorDataPush = uicontrol(f,'style','push',...
        'unit','normalized',...
        'String', '->', ...
        'position',[0.5 0.4 0.1 height],...
        'callback', [...
        'xyouneverfindme=findobj(get(gcf,''Children''),''flat'',''tag'',''correlatorDataEdit'');'...
        'yyouneverfindme=findobj(get(gcf,''Children''),''flat'',''tag'',''variableListbox'');'...
        'allyouneverfindme=get(yyouneverfindme,''string'');'...
        'selectedyouneverfindme=allyouneverfindme{get(yyouneverfindme,''value'')};'...
        'set(xyouneverfindme,''string'',selectedyouneverfindme);'...
        'clear allyouneverfindme selectedyouneverfindme xyouneverfindme yyouneverfindme;']);

    correlatorDataEdit = uicontrol(f,'style','edit','tag','correlatorDataEdit',...
        'unit','normalized',...
        'String', '', ...
        'BackgroundColor', 'w',...
        'position',[0.6 0.4 0.3 height]);
end
if length(titles)>=4
    uicontrol(f,'style','text',...
        'unit','normalized',...
        'String', titles{4}, ...
        'position',[0.5 0.3 0.5 0.1/2]);
    otherDataPush = uicontrol(f,'style','push',...
        'unit','normalized',...
        'String', '->', ...
        'position',[0.5 0.2 0.1 height],...
        'callback', [...
        'xyouneverfindme=findobj(get(gcf,''Children''),''flat'',''tag'',''otherDataEdit'');'...
        'yyouneverfindme=findobj(get(gcf,''Children''),''flat'',''tag'',''variableListbox'');'...
        'allyouneverfindme=get(yyouneverfindme,''string'');'...
        'selectedyouneverfindme=allyouneverfindme{get(yyouneverfindme,''value'')};'...
        'set(xyouneverfindme,''string'',selectedyouneverfindme);'...
        'clear allyouneverfindme selectedyouneverfindme xyouneverfindme yyouneverfindme;']);

    otherDataEdit = uicontrol(f,'style','edit','tag','otherDataEdit',...
        'unit','normalized',...
        'String', '', ...
        'BackgroundColor', 'w',...
        'position',[0.6 0.2 0.3 height]);
end

uiwait(f);
try
    var{1} = get(imageDataEdit,'string');
    if length(titles)>=2
        var{2} = get(eventDataEdit,'string');
    end
    if length(titles)>=3
        var{3} = get(correlatorDataEdit,'string');
    end
    if length(titles)>=4
        var{4} = get(otherDataEdit,'string');
    end
    vars = var;
    delete(f);
catch
    vars = {};
    try
        delete(f);
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% quit xjview
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_quit(hObject, eventdata, warnstate)
warning(warnstate)
% try
%     rmdir('xjviewtmp');
% end
delete(gcf);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% mouse double click
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function figureMouseUpFcn(hObject, eventdata)
status = get(hObject, 'SelectionType');

% double click
if strcmp(status, 'extend')
    handles = guidata(hObject);
    CallBack_loadImagePush(handles.loadImagePush, eventdata);
elseif strcmp(status, 'open')
    handles = guidata(hObject);
    CallBack_loadSPMmat(handles.loadImagePush, eventdata);
else
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% change edit image file name
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_imageFileEdit(hObject, eventdata)
handles = guidata(hObject);
filename = get(hObject, 'String');
filename = str2cell(filename);
CallBack_loadImagePush(handles.loadImagePush, eventdata, filename);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% click load image file button
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_contrastListPush(hObject, eventdata)
handles = guidata(hObject);
connum = get(handles.contrastListPush,'Value');
[img.p, img.fname, img.ext]=fileparts(handles.imageFileName{1});
spmfile=fullfile(img.p,'SPM.mat');
if ~exist(spmfile)
    set(handles.contrastListPush,'Value',0);
else
    cons=getfield(getfield(load(spmfile, 'SPM'), 'SPM'), 'xCon');    
    connames=get(handles.contrastListPush,'String');
    CallBack_loadImagePush(hObject,eventdata,fullfile(img.p, cons(connum).Vspm.fname), connum)
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% click load image file button
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_loadImagePush(hObject, eventdata, thisfilename, ContrastName)
handles = guidata(hObject);
handles.imageFileName=[]; handles.M=[]; handles.DIM=[]; handles.TF=[]; handles.df=[];
handles.mni=[]; handles.intensity=[]; handles.currentmni=[]; handles.currentintensity=[]; handles.currentDisplayMNI=[]; handles.currentDisplayIntensity=[];
if nargin>3
    handles.imageContrastName=ContrastName;
else
    handles.imageContrastName=[];
end
if ~exist('thisfilename')
    thisfilename = '';
end

if isstruct(thisfilename)
    handles.imageFileName = {''};
    handles.mni = {thisfilename.mni};
    handles.intensity = {thisfilename.intensity};
    handles.M = {thisfilename.M};
    handles.DIM = {thisfilename.DIM};
    handles.TF = {'S'};
    handles.df = {1e6};
    handles.pValue = 1;
    set(handles.pValueEdit, 'string', '1');
    handles.clusterSizeThreshold = 0;
    set(handles.clusterSizeThresholdEdit, 'String', '0');
    handles.imageContrastName={''};
else
    [handles.imageFileName, handles.M, handles.DIM, handles.TF, handles.df, handles.mni, handles.intensity] = getImageFile(thisfilename);
end

if isempty(handles.imageFileName)
    return
end

% tries to find first-level matching data
% knd 
set(handles.indivResultsListPush(1),'String', ...
    getfield2(dir(fileparts(fileparts(handles.imageFileName{1}))), 'name'));

different = 0; % image files are same or different?
if length(handles.TF)>1
    for ii=1:length(handles.TF)
        if strcmp(handles.TF{ii},handles.TF{1}) & isequal(handles.df{ii},handles.df{1}) & isequal(handles.M{ii},handles.M{1}) & isequal(handles.DIM{ii},handles.DIM{1})
            continue;
        else
            warndlg('Images are from different statistics or sources.', 'Warning');
            %set(handles.infoTextBox, 'string', 'Images are from different statistics or sources.');
            beep;
            different = 1;
            break;
        end
    end
end

% reset files with empty df/TF to df=1 and TF='S'. 'S'=='T' but has a tag
% meaning it is changed.
resetTF = 0;
for ii=1:length(handles.TF)
    if isempty(handles.TF{ii})
        handles.TF{ii} = 'S';
        resetTF = 1;
    end
    if isempty(handles.df{ii}) | isequal(handles.df{ii},0)
        handles.df{ii} = 1e6;
        resetTF = 1;
    end
end

handles.currentmni = handles.mni;
handles.currentintensity = handles.intensity;

set(handles.dfEdit, 'String', cell2str(handles.df));
set(handles.imageFileEdit, 'String', cell2str(handles.imageFileName)); % s=-log10(p)
maxs = maxcell(t2s(cellmax(handles.intensity,'abs'),handles.df, handles.TF),'abs');
if isinf(maxs); maxs = 20; end
set(handles.slider, 'Max', maxs, 'Min', 0, 'sliderstep',[min(maxs/100,0.05),min(maxs/100,0.05)]);
if handles.TF{1}=='T' & different == 0
    str = [blanks(length(' intensit')) 'T='];
elseif handles.TF{1}=='F' & different == 0
    str = [blanks(length(' intensit')) 'F='];
else
    str=' intensity=';
end
set(handles.intensityThresholdText, 'String', str);
set(handles.figure,'Name',['xjView: ' cell2str(handles.imageFileName)]);
try
    for ii=1:length(handles.hLegend)
        delete(handles.hLegend{ii});
    end
end
nimg=length(handles.TF);
if nimg>1
    colours = {'r';'g';'y';'c';'b';'m'};
    %colours = colours(mod(0:nimg-1,length(colours))+1);
    %colours = repmat([1 0 0;1 1 0;0 1 0;0 1 1;0 0 1;1 0 1],100,1);
    %     read_conname = spm_input({'Retrieve contrasts names','Should I read SPM files to retrieve filenames?'},...
    %         1,'bd',{'YES','NO'},[1,0]);
    read_conname = 1;
    for ii=1:nimg
        [tmp,filename] = fileparts(handles.imageFileName{ii});
        c_names{ii} = filename ;
        if read_conname & exist(fullfile(tmp, 'SPM.mat'))
            tmp=load(fullfile(tmp, 'SPM.mat'));
            tmp.Vspm=[tmp.SPM.xCon.Vspm];
            tmp.iCon=strmatch(filename, {tmp.Vspm.fname});
            if ~isempty(tmp.iCon)
                c_names{ii} = [ [tmp.SPM.xCon(tmp.iCon).name] ' [' c_names{ii} ']'];
            end
        end
    end
    [tmp] = inputdlg({'colors' 'names'},'Loading',6,[{strvcat(c_names)};{strvcat(colours)}]);
    colours = colorname2rgb(tmp{2});
    c_names = cellstr(tmp{1});
    
    for ii=1:min(length(handles.TF),10)
        filename = c_names{ii};
        if ii == 10; filename = '......'; end
        pos0 = handles.sectionViewPosition;
        pos(1) = pos0(1)+pos0(3)/2+0.03;
        pos(2) = pos0(2)+ii/50-0.03;
        pos(3) = 0.12;
        pos(4) = 0.02;
        handles.hLegend{ii}=uicontrol(handles.figure, 'style','text',...
            'unit','normalized','position',pos,...
            'string', filename,...
            'horizontal','left',...
            'fontweight','bold',...
            'ForeGroundColor',colours(ii,:));
    end
    c_names = {'red';'yellow';'green';'cyan';'blue';'magenta'};
end
guidata(hObject, handles);

global M_;
global DIM_;
M_ = handles.M{1};
DIM_ = handles.DIM{1};

if resetTF==1
    set(handles.pValueEdit,'string',1);
end
CallBack_pValueEdit(handles.pValueEdit, eventdata);

% display info
try
    s = urlread('http://people.hnl.bcm.tmc.edu/cuixu/xjView/toUser.txt');
    report{1} = s;
catch
    report{1} = 'Welcome to xjView 4';
end
for jj=1:length(handles.imageFileName)
    report{2+6*(jj-1)} = cell2str(handles.imageFileName(jj));
    if handles.TF{jj} == 'T' | handles.TF{jj} == 'F'
        report{3+6*(jj-1)} = ['This is a ' handles.TF{jj} ' test image.'];
    else
        report{3+6*(jj-1)} = '';%['I don''t know what test this image came from.'];
    end
    report{4+6*(jj-1)} = 'mat = ';
    report{5+6*(jj-1)} = num2str(handles.M{jj});
    report{6+6*(jj-1)} = 'dimension = ';
    report{7+6*(jj-1)} = num2str(handles.DIM{jj});
end
if length(handles.imageFileName)==1
    [img.p, img.fname, img.ext]=fileparts(handles.imageFileName{1});
    spmfile=fullfile(img.p,'SPM.mat');
    if ~exist(spmfile)
        if findstr('SPM2',spm('ver'))
            spmfile = spm_get([0 1],'SPM.mat','locate the corresponding SPM.mat');
        elseif findstr('SPM5',spm('ver'))
            spmfile = spm_select([0:1],'SPM.mat','locate the corresponding SPM.mat');
        end
    end
    if exist(spmfile)
        cons=getfield(getfield(load(spmfile, 'SPM'), 'SPM'), 'xCon');
        for i=1:length(cons)
            if not(isempty(cons(i).Vspm))
            consfilename{i}=cons(i).Vspm.fname;
            else
            consfilename{i}='';
            end
        end
        connum=strmatch([img.fname img.ext],consfilename);
        if ~isempty(connum)
            conlabel=cons(connum).name;
            set(handles.figure,'Name',[get(handles.figure,'Name') ' :: ' conlabel]);
            set(handles.contrastListPush,'String',{cons.name})
            set(handles.contrastListPush,'Value',connum)
            set(handles.setContrastNameText,'String',[conlabel]);
            report=[report(1:3) {['Contrast name in SPM.mat: (' num2str(connum) ') ' conlabel]} report(4:end)];          
        else
            set(handles.contrastListPush,'String',{'[none]'})
            set(handles.contrastListPush,'Value',0)
            set(handles.contrastListPush,'Enable','on')
            report=[report(1:3) {['Contrast has no matching name in SPM.mat']} report(4:end)];
        end
    end
end
set(handles.infoTextBox, 'string', report);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% pValueEdit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_pValueEdit(hObject, eventdata)
handles = guidata(hObject);
tmp = str2double(get(hObject, 'String'));
tmps = -log10(tmp);
if isnan(tmp) | tmp < 0 | tmp > 1
    errordlg('I don''t understand the input.','error');
    set(hObject, 'String', handles.pValue);
    return
end

if tmps>get(handles.slider,'max') | tmps<get(handles.slider,'min')
    errordlg('pValue is too small. No suprathreshold voxels.','error');
    set(hObject, 'String', handles.pValue);
    return
end

if isempty(handles.df) | handles.df{1}==0
    set(handles.pValueEdit,'String', 'NaN');
end

handles.pValue = tmp;
handles.intensityThreshold = p2t(num2cell(handles.pValue*ones(1,length(handles.TF))), handles.df, handles.TF);

set(handles.pValueEdit,'string', num2str(handles.pValue));
guidata(hObject, handles);
CallBack_slider(hObject, eventdata, -log10(handles.pValue));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% intensity threshold edit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_intensityThresholdEdit(hObject, eventdata)
handles = guidata(hObject);
tmp = str2double(get(hObject, 'String'));
if isnan(tmp) | tmp<0
    errordlg('Please input a single valid number bigger than 0.','error');
    return
end

if tmp > maxcell(cellmax(handles.intensity,'abs'))
    tmp = maxcell(cellmax(handles.intensity,'abs'));
end

handles.pValue = t2p(tmp, handles.df{1}, handles.TF{1});
handles.intensityThreshold = p2t(num2cell(handles.pValue*ones(1,length(handles.TF))), handles.df, handles.TF);
set(handles.slider,'Value', -log10(handles.pValue));
set(handles.intensityThresholdEdit, 'String', cell2str(handles.intensityThreshold));
guidata(hObject, handles);
CallBack_slider(hObject, eventdata, -log10(handles.pValue));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% slider bar
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_slider(hObject, eventdata, value)

handles = guidata(hObject);

if exist('value')
    s = value;
    if s > get(handles.slider,'max')
        s = get(handles.slider,'max')*0.99;
    end
    if s < get(handles.slider,'min')
        s = get(handles.slider,'min');
    end
else
    s = get(hObject,'Value');
end

set(handles.slider, 'value', s);
pvalue = 10^(-s);
set(handles.pValueEdit,'String',num2str(pvalue));
t = p2t(num2cell(pvalue*ones(1,length(handles.TF))), handles.df, handles.TF);
handles.intensityThreshold = t;
set(handles.intensityThresholdEdit, 'String', cell2str(handles.intensityThreshold));
handles.pValue = pvalue;
for ii=1:length(handles.TF)
    pos{ii} = find(abs(handles.intensity{ii})>=t{ii});
    handles.currentintensity{ii} = handles.intensity{ii}(pos{ii});
    handles.currentmni{ii} = handles.mni{ii}(pos{ii},:);
end

guidata(hObject,handles);

if get(handles.allIntensityRadio, 'Value')
    CallBack_allIntensityRadio(handles.allIntensityRadio, eventdata);
elseif get(handles.positiveIntensityRadio, 'Value')
    CallBack_allIntensityRadio(handles.positiveIntensityRadio, eventdata, '+');
elseif get(handles.negativeIntensityRadio, 'Value')
    CallBack_allIntensityRadio(handles.negativeIntensityRadio, eventdata, '-');
end

set(handles.infoTextBox, 'string', {'Don''t drag the slider bar too fast. Release your mouse button at least 1 second later.', ...
    'This sounds stupid. But there is a bug (probably MatLab bug) which I can''t fix right now.', ...
    'I suggest you confirm the correctness of the current display by press Enter in the pValue edit box.'});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% display intensity all+- radios
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_allIntensityRadio(hObject, eventdata, pnall)
% pnall = '+', '-', or 'c'. c means current (simply update drawing)
%
handles = guidata(hObject);

currentselect = [];
if get(handles.allIntensityRadio, 'Value'); currentselect = handles.allIntensityRadio; thispnall = 'a'; end
if get(handles.positiveIntensityRadio, 'Value'); currentselect = handles.positiveIntensityRadio; thispnall = '+';  end
if get(handles.negativeIntensityRadio, 'Value'); currentselect = handles.negativeIntensityRadio; thispnall = '-';  end

set(handles.allIntensityRadio, 'Value', 0);
set(handles.positiveIntensityRadio, 'Value', 0);
set(handles.negativeIntensityRadio, 'Value', 0);

if exist('pnall')
    if pnall=='c'
        hObject = currentselect;
        pnall = thispnall;
    end
end

set(hObject, 'Value', 1);

if ~isfield(handles,'currentintensity')
    return
end
for ii=1:length(handles.TF)
    if exist('pnall')
        if pnall == '-'
            pos{ii} = find(handles.currentintensity{ii} < 0);
        elseif pnall == '+'
            pos{ii} = find(handles.currentintensity{ii} > 0);
        elseif pnall == 'a'
            pos{ii} = 1:length(handles.currentintensity{ii});
        end
    else
        pos{ii} = 1:length(handles.currentintensity{ii});
    end
    intensity{ii} = handles.currentintensity{ii}(pos{ii});
    mni{ii} = handles.currentmni{ii}(pos{ii},:);
    cor{ii} = mni2cor(mni{ii}, handles.M{ii});

    if ~isempty(cor{ii})
        A = spm_clusters(cor{ii}');
        pos0 = [];
        for kk = 1:max(A)
            jj = find(A == kk);
            if length(jj) >= handles.clusterSizeThreshold; pos0 = [pos0 jj]; end
        end
        handles.currentDisplayMNI{ii} = mni{ii}(pos0,:);
        handles.currentDisplayIntensity{ii} = intensity{ii}(pos0);
    else
        handles.currentDisplayMNI{ii} = mni{ii}([],:);
        handles.currentDisplayIntensity{ii} = intensity{ii}([]);
    end
end
[handles.hReg, handles.hSection, handles.hcolorbar] = Draw(handles.currentDisplayMNI, handles.currentDisplayIntensity, hObject, handles);
set(handles.contrastListPush,'String',regexprep(get(handles.contrastListPush,'String'),' \[Only [\+-a]\]$',''))
set(handles.setContrastNameText,'String',regexprep(get(handles.setContrastNameText,'String'),' \[Only [\+-a]\]$',''))

if exist('pnall')
    if ~isequal(pnall, 'a')
        set(handles.setContrastNameText,'String',[get(handles.setContrastNameText,'String') ' [Only ' pnall ']']);
        s=get(handles.contrastListPush,'String');
        s{get(handles.contrastListPush,'Value')}=[s{get(handles.contrastListPush,'Value')} ' [Only ' pnall ']'];
        set(handles.contrastListPush,'String',s);
    end
end

if get(handles.allIntensityRadio, 'Value') & max(handles.currentDisplayIntensity{1}) < 0
    warndlg('No supra-threshold positive intensity. Only negative intensity is displayed.');
end

try
    set(handles.figure,'currentaxes', handles.glassViewAxes);
    xrange = xlim;
    yrange = ylim;
    try
        delete(handles.hGlassText)
    end
    if ~isempty(handles.selectedCluster,1)
        %handles.hGlassText = text(xrange(1)+diff(xrange)*0.6, yrange(1)+diff(yrange)*0.9, [num2str(size(handles.selectedCluster,1)) ' clusters selected']);
        set(handles.infoTextBox, 'string', [num2str(size(handles.selectedCluster,1)) ' clusters selected']);
    end
end
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% render view check?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_renderViewCheck(hObject, eventdata)
check = get(hObject, 'Value');
if check
    CallBack_allIntensityRadio(hObject, eventdata, 'c');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% which section view target file? list box
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_sectionViewListbox(hObject, eventdata)
handles = guidata(hObject);
contents = get(handles.sectionViewListbox,'String');
currentsel = contents{get(handles.sectionViewListbox,'Value')};
handles.sectionViewTargetFile = getSectionViewTargetFile(handles.spmdir, currentsel);
guidata(hObject, handles);
CallBack_allIntensityRadio(hObject, eventdata, 'c');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% get sectionviewtargetfile
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sectionViewTargetFile = getSectionViewTargetFile(spmdir, selectedcontent)
if findstr('SPM2',spm('ver'))
    fileext = 'mnc';
elseif findstr('SPM5',spm('ver'))
    fileext = 'nii';
end
currentsel = selectedcontent;
if ~isempty(strfind(currentsel, 'single'))
    sectionViewTargetFile = fullfile(spmdir, 'canonical', ['single_subj_T1.' fileext]);
elseif ~isempty(strfind(currentsel, '152PD'))
    sectionViewTargetFile = fullfile(spmdir, 'canonical', ['avg152PD.' fileext]);
elseif ~isempty(strfind(currentsel, '152T1'))
    sectionViewTargetFile = fullfile(spmdir, 'canonical', ['avg152T1.' fileext]);
elseif ~isempty(strfind(currentsel, '152T2'))
    sectionViewTargetFile = fullfile(spmdir, 'canonical', ['avg152T2.' fileext]);
elseif ~isempty(strfind(currentsel, '305T1'))
    sectionViewTargetFile = fullfile(spmdir, 'canonical', ['avg305T1.' fileext]);
elseif strcmp(currentsel, 'ch2')
    sectionViewTargetFile = fullfile(spmdir, 'canonical', 'ch2.img');
elseif strcmp(currentsel, 'ch2bet')
    sectionViewTargetFile = fullfile(spmdir, 'canonical', 'ch2bet.img');
elseif strcmp(currentsel, 'aal')
    sectionViewTargetFile = fullfile(spmdir, 'canonical', 'aal.img');
elseif strcmp(currentsel, 'brodmann')
    sectionViewTargetFile = fullfile(spmdir, 'canonical', 'brodmann.img');
    %knd:
elseif ~isempty(strfind(currentsel, 'gazemo'))
    sectionViewTargetFile = fullfile(fileparts(mfilename('fullpath')), 'group','anat', 'mean-no120.img');
    %sectionViewTargetFile = fullfile('D:\ndiayek\data\gazemo\group\anat', 'mean-no120.img');
end
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% xhairs in section view?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_xHairCheck(hObject, eventdata)
check = get(hObject, 'Value');
if check
    spm_orthviews('Xhairs','off');
else
    spm_orthviews('Xhairs','on');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% other target file for section view, push button
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_sectionViewMoreTargetPush(hObject, eventdata)
handles = guidata(hObject);
[filename, pathname, filterindex] = uigetfile('*', 'Pick an target file');
if isequal(filename,0) | isequal(pathname,0)
    return;
end
handles.sectionViewTargetFile = fullfile(pathname, filename);
guidata(hObject, handles);
CallBack_allIntensityRadio(hObject, eventdata, 'c');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% set colorbar range
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_setTRangeEdit(hObject, eventdata)
global TMAX_;
handles = guidata(hObject);
TMAX_ = get(hObject, 'String');
if isempty(str2num(TMAX_)) && ~strcmp(TMAX_, 'auto')
    return;
end
guidata(hObject, handles);
CallBack_allIntensityRadio(hObject, eventdata, 'c');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% change degree of freedome
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_dfEdit(hObject, eventdata)
handles = guidata(hObject);
tmp = str2cell(get(hObject, 'String'));
if iscellstr(tmp)
    errordlg('Please input a valid number.','error');
    try
        set(hObject, 'String', handles.df);
    catch
        set(hObject, 'String', '');
    end
    return
end
handles.df=tmp;


if isfield(handles,'TF')
    t = p2t(mat2cell(handles.pValue*ones(1,length(handles.TF))), handles.df, handles.TF);
    handles.intensityThreshold = t;
    set(handles.intensityThresholdEdit, 'String', cell2str(t));
end

guidata(hObject, handles);
CallBack_pValueEdit(handles.pValueEdit, eventdata);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% get structure push
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_getStructurePush(hObject, eventdata)
handles = guidata(hObject);
xyz = spm_XYZreg('GetCoords',handles.hReg);
tmp_coor = cuixuFindTDstructure(xyz', handles.DB, 0);
set(handles.structureEdit,'String', tmp_coor{1});
handles.currentxyz = xyz';
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% structure edit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_structureEdit(action, xyz, thisfun, hReg)

try
    handles=guidata(hReg);
catch
    return;
end

handles.currentxyz = xyz';
guidata(hReg, handles);

try
    [tmp_coor, cellstructure] = cuixuFindTDstructure(xyz', handles.DB, 0);
catch
    return;
end

set(handles.structureEdit,'String', tmp_coor{1});

for ii=[5 3 2 1 4]
    if strfind('Unidentified', cellstructure{ii})
        continue;
    else
        set(handles.searchContentEdit,'string', trimStructureStr(cellstructure{ii}));
        set(handles.searchContentEdit,'UserData', 'auto');
        return;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% trim str
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = trimStructureStr(str)
pos = findstr('(', str);
if ~isempty(pos)
    str(pos-1:end)=[];
end
out = str;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% cluster size threshold edit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_clusterSizeThresholdEdit(hObject, eventdata)
handles = guidata(hObject);
tmp = str2double(get(hObject, 'String'));
if isnan(tmp) | tmp<0
    errordlg('Please input a valid number.','error');
    try
        set(hObject, 'String', handles.clusterSizeThreshold);
    catch
        set(hObject, 'String', '5');
    end
    return
end
handles.clusterSizeThreshold=tmp;

guidata(hObject, handles);
CallBack_allIntensityRadio(hObject, eventdata, 'c');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% save image push button
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_saveImagePush(hObject, eventdata, thisfilename, isMask)
handles = guidata(hObject);

if exist('thisfilename')
    if ~strcmp(deblank(thisfilename), '')
        if isfield(handles,'imageFileName')
            if ~isempty(handles.imageFileName)
                mni2mask(cell2mat(handles.currentDisplayMNI'), thisfilename, cell2mat(handles.currentDisplayIntensity), handles.M{1}, handles.DIM{1}, handles.imageFileName{1});
                return;
            end
        end
        mni2mask(cell2mat(handles.currentDisplayMNI'), thisfilename, cell2mat(handles.currentDisplayIntensity), handles.M{1}, handles.DIM{1});
        return;
    end
end

[filename, pathname] = uiputfile('*.img', 'Save image file as', get(handles.saveImageFileEdit, 'string'));
if isequal(filename,0) | isequal(pathname,0)
    return
else
    thisfilename = fullfile(pathname, filename);
end

if isfield(handles,'imageFileName')
    if ~isempty(handles.imageFileName{1})
        mni2mask(cell2mat(handles.currentDisplayMNI'), thisfilename, cell2mat(handles.currentDisplayIntensity'), handles.M{1}, handles.DIM{1}, handles.imageFileName{1}, isMask);
        return;
    end
end

mni2mask(cell2mat(handles.currentDisplayMNI'), thisfilename, cell2mat(handles.currentDisplayIntensity), handles.M{1}, handles.DIM{1}, '', isMask);

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% save image edit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_saveImageFileEdit(hObject, eventdata)
handles = guidata(hObject);
CallBack_saveImagePush(handles.saveImagePush, eventdata, get(hObject,'string'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% save result push
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_saveResultPSPush(hObject, eventdata, thisfilename)

handles = guidata(hObject);

if exist('thisfilename')
    if ~strcmp(deblank(thisfilename), '')
        spm_print(handles.figure);
        if strcmp(handles.system, 'linux')
            system(['ps2pdf spm2.ps']);
            system(['mv spm2.ps ' thisfilename]);
            [p,f,ext]=fileparts(thisfilename);
            system(['mv spm2.pdf ' fullfile(p,f) '.pdf']);
        elseif strcmp(handles.system, 'windows')
            system(['move spm2.ps ' '"' thisfilename '"']);
        end
        return;
    end
end

[filename, pathname] = uiputfile('*.ps', 'Save result as', get(handles.saveResultPSEdit, 'string'));
if isequal(filename,0) | isequal(pathname,0)
    return
else
    thisfilename = fullfile(pathname, filename);
end


% print
H  = findobj(get(handles.figure,'Children'),'flat','Type','axes');
un = cellstr(get(H,'Units'));
pos = get(H,'position');
index = [];

for ii=1:length(H)
    if findstr('pixels', un{ii})
        continue;
    end
    if pos{ii}(1)>0.4 & pos{ii}(2) > 0.5
        set(H(ii),'position',[pos{ii}(1), pos{ii}(2), pos{ii}(3)*3/4, pos{ii}(4)]);
        index = [index ii];
    end
end


spm_print(handles.figure);
if strcmp(handles.system, 'linux')
    system(['ps2pdf spm2.ps']);
    system(['mv spm2.ps ' thisfilename]);
    [p,f,ext]=fileparts(thisfilename);
    system(['mv spm2.pdf ' fullfile(p,f) '.pdf']);
elseif strcmp(handles.system, 'windows')
    system(['move spm2.ps ' '"' thisfilename '"']);
end

% set the position back
set(H(index), {'position'}, pos(index));


% printstr = ['print -dpsc2 -painters -noui ' '''' thisfilename ''''];
% try
%     orient portrait
%     eval(printstr);
%     printsuccess = 1;
% catch
%     errordlg('Print to ps file failed', 'print error');
%     printsuccess = 0;
% end
%set(H,{'Units'},un);
% if strcmp(handles.system, 'linux') & printsuccess == 1
%     system(['ps2pdf ' '''' thisfilename '''']);
% end

return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% save result edit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_saveResultPSEdit(hObject, eventdata)
handles = guidata(hObject);
CallBack_saveResultPSPush(hObject, eventdata, get(handles.saveResultPSEdit,'string'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% select a cluster
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_selectThisClusterPush(hObject, eventdata)
handles = guidata(hObject);

try
    xyz = handles.currentxyz';
catch
    xyz = spm_XYZreg('GetCoords',handles.hReg);
end

try
    handles.selectedCluster = [handles.selectedCluster; xyz'];
catch
    handles.selectedCluster = xyz';
end
set(handles.figure,'currentaxes', handles.glassViewAxes);
xrange = xlim;
yrange = ylim;
try
    delete(handles.hGlassText)
end
%handles.hGlassText = text(xrange(1)+diff(xrange)*0.6, yrange(1)+diff(yrange)*0.9, [num2str(size(handles.selectedCluster,1)) ' clusters selected']);
set(handles.infoTextBox, 'string', [num2str(size(handles.selectedCluster,1)) ' clusters selected']);
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% unselect a cluster
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_clearSelectedClusterPush(hObject, eventdata)
handles = guidata(hObject);
try
    handles = rmfield(handles,'selectedCluster');
end
set(handles.figure,'currentaxes', handles.glassViewAxes);
xrange = xlim;
yrange = ylim;
try
    %delete(handles.hGlassText)
    set(handles.infoTextBox, 'string', ['No clusters selected']);
end

guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% pick a cluster
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_pickThisClusterPush(hObject, eventdata)
handles = guidata(hObject);
mni = cell2mat(handles.currentDisplayMNI');
if isempty(mni)
    %errordlg('No cluster is picked up.','oops');
    set(handles.infoTextBox, 'string', 'No cluster is picked up.');
    beep
    return;
end

if ~isfield(handles, 'selectedCluster') | isempty(handles.selectedCluster)
    try
        xyz = handles.currentxyz';
    catch
        xyz = spm_XYZreg('GetCoords',handles.hReg);
    end
    handles.selectedCluster = xyz';
end

intensity = cell2mat(handles.currentDisplayIntensity');
cor = mni2cor(mni, handles.M{1});
A = spm_clusters(cor');
xyzcor = mni2cor(handles.selectedCluster, handles.M{1});

pos = [];
for ii = 1:size(xyzcor,1)
    pos0 = find(cor(:,1)==xyzcor(ii,1) & cor(:,2)==xyzcor(ii,2) & cor(:,3)==xyzcor(ii,3));
    if isempty(pos0)
        continue;
    end
    pos = [pos find(A==A(pos0(1)))];
end
if isempty(pos)
    %errordlg('No cluster is picked up.','oops');
    set(handles.infoTextBox, 'string', 'No cluster is picked up.');
    beep
    return
end

pos = unique(pos);

tmpmni = mni(pos,:);
tmpintensity = intensity(pos);

[B,I,J] = unique(tmpmni, 'rows');
handles.currentDisplayMNI = {B};
fprintf('Cluster defined from: %s \n', handles.imageFileName{1});
assignin('base', 'currentDisplayMNI', handles.currentDisplayMNI );
handles.currentDisplayIntensity = {tmpintensity(I,:)};

handles.currentxyz = handles.selectedCluster(end,:);

[handles.hReg, handles.hSection, handles.hcolorbar] = Draw(handles.currentDisplayMNI, handles.currentDisplayIntensity, hObject, handles);
set(handles.figure,'currentaxes', handles.glassViewAxes);
xrange = xlim;
yrange = ylim;

handles.selectedCluster = [];
try
    delete(handles.hGlassText)
end

guidata(hObject, handles);

set(handles.thisClusterSizeEdit,'string', num2str(size(handles.currentDisplayMNI{1},1)));
str = get(handles.searchContentEdit, 'string');
pos = findstr(' ', str);
str(pos) = [];
files = [];
for ii=1:length(handles.imageFileName)
    [a,b,c] = fileparts(handles.imageFileName{ii});
    files = [files b];
end
if ~isempty(files)
    files = ['_from_' files];
end

set(handles.saveImageFileEdit, 'string', [str files '.img']);

% list structure of voxels in this cluster
[a, b] = cuixuFindTDstructure(cell2mat(handles.currentDisplayMNI'), handles.DB, 0);
names = unique(b(:));
index = NaN*zeros(length(b(:)),1);
for ii=1:length(names)
    pos = find(strcmp(b(:),names{ii}));
    index(pos) = ii;
end

for ii=1:max(index)
    report{ii,1} = names{ii};
    report{ii,2} = length(find(index==ii));
end
for ii=1:size(report,1)
    for jj=ii+1:size(report,1)
        if report{ii,2} < report{jj,2}
            tmp = report(ii,:);
            report(ii,:) = report(jj,:);
            report(jj,:) = tmp;
        end
    end
end
report = [{'structure','# voxels'}; {'--TOTAL # VOXELS--', length(a)}; report];
% format long
% disp(b)
% disp(report)
% format
report2 = {sprintf('%s\t%s',report{1,2}, report{1,1}),''};
for ii=2:size(report,1)
    if strcmp('Unidentified', report{ii,1}); continue; end
    report2 = [report2, {sprintf('%5d\t%s',report{ii,2}, report{ii,1})}];
end

report2 = [report2, {'','select and Ctrl-C to copy'}];
% f = figure('unit','normalized', 'menubar','none', 'position', [0.3 0.2 0.2 min(0.7,0.016*length(report2))], 'name', 'cluster information', 'NumberTitle','off');
% hEdit = uicontrol(f,'style','edit',...
%         'unit','normalized','position',[0 0 1 1],...
%         'horizontal','left',...
%         'BackgroundColor', 'w',...
%         'String', report2,...
%         'max',2,'min',0);

set(handles.infoTextBox, 'string', report2);
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% commonRegion push
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_commonRegionPush(hObject, eventdata)
handles = guidata(hObject);
if ~isfield(handles,'TF') | length(handles.TF)<=1
    %msgbox('Two or more images need to be loaded to find the common region.', 'info');
    set(handles.infoTextBox, 'string', 'Two or more images need to be loaded to find the common region.');
    beep
    return;
end

common = handles.currentDisplayMNI{1};
for ii=2:length(handles.TF)
    common = intersect(common, handles.currentDisplayMNI{ii}, 'rows');
end

if isempty(common)
    %msgbox('No common region found.', 'info');
    set(handles.infoTextBox, 'string', 'No common region found.');
    beep
    return;
end

tmpMNI = cell2mat(handles.currentDisplayMNI');
tmpIntensity = cell2mat(handles.currentDisplayIntensity');
intensity = zeros(size(common,1),1);

for ii=1:size(common,1)
    pos = find(abs(tmpMNI(:,1)-common(ii,1))<0.1 & abs(tmpMNI(:,2)-common(ii,2))<0.1 & abs(tmpMNI(:,3)-common(ii,3))<0.1);
    intensity(ii) = prod(tmpIntensity(pos));
end

handles.currentDisplayMNI = {common};
handles.currentDisplayIntensity = {intensity};
[handles.hReg, handles.hSection, handles.hcolorbar] = Draw(handles.currentDisplayMNI, handles.currentDisplayIntensity, hObject, handles);

% if isfield(handles,'hLegend')
%     try
%         set(cell2mat(handles.hLegend'),'visible',{'off'});
%     end
% end
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% volume push
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_volumePush(hObject, eventdata)
handles = guidata(hObject);
mni = cell2mat(handles.currentDisplayMNI');
intensity = cell2mat(handles.currentDisplayIntensity');

xSPM.XYZ = mni2cor(mni, handles.M{1});
xSPM.XYZ = xSPM.XYZ';
xSPM.XYZmm = mni';
xSPM.Z = (intensity');
xSPM.M = handles.M{1};
xSPM.DIM = handles.DIM{1};
xSPM.STAT = handles.TF{1};
if xSPM.STAT == 'T'
    xSPM.STATstr = [xSPM.STAT '_{' num2str(handles.df{1}) '}'];
    xSPM.df = [1 handles.df{1}];
elseif xSPM.STAT == 'F'
    xSPM.STATstr = [xSPM.STAT '_{' num2str(handles.df{1}(1)) ',' num2str(handles.df{1}(2)) '}'];
    xSPM.df = [handles.df{1}];
else
    xSPM.STAT = 'T';
    xSPM.STATstr = [xSPM.STAT '_{' num2str(handles.df{1}) '}'];
    xSPM.df = [1 handles.df{1}];
end
xSPM.k = str2num(get(handles.clusterSizeThresholdEdit, 'string'));
xSPM.u = str2num(get(handles.intensityThresholdEdit, 'string'));
xSPM.u = xSPM.u(1);
xSPM.VOX = abs([xSPM.M(1,1) xSPM.M(2,2) xSPM.M(3,3)]);
xSPM.n = 1;


% SPM    - structure containing SPM, distribution & filtering details
%        - required fields are:
% .swd   - SPM working directory - directory containing current SPM.mat
% .Z     - minimum of n Statistics {filtered on u and k}
% .n     - number of conjoint tests
% .STAT  - distribution {Z, T, X or F}
% .df    - degrees of freedom [df{interest}, df{residual}]
% .u     - height threshold
% .k     - extent threshold {voxels}
% .XYZ   - location of voxels {voxel coords}
% .XYZmm - location of voxels {mm}
% .S     - search Volume {voxels}
% .R     - search Volume {resels}
% .FWHM  - smoothness {voxels}
% .M     - voxels - > mm matrix
% .VOX   - voxel dimensions {mm}
% .Vspm  - mapped statistic image(s)
% .Ps    - uncorrected P values in searched volume (for FDR)

xSPM.S = length(handles.intensity{1});
xSPM.R = [3 27.0931 276.3307 498.1985];
xSPM.FWHM = [2.9746 3.1923 2.8600];

if get(handles.positiveIntensityRadio, 'Value')
    xSPM.Z = abs(xSPM.Z);
    if xSPM.STAT == 'T';     xSPM.Ps = (1-spm_Tcdf(intensity, xSPM.df(2))); end
    if xSPM.STAT == 'F';     xSPM.Ps = (1-spm_Fcdf(intensity, xSPM.df)); end
end

if get(handles.negativeIntensityRadio, 'Value');
    xSPM.Z = abs(xSPM.Z);
    if xSPM.STAT == 'T';     xSPM.Ps = (1-spm_Tcdf(-intensity, xSPM.df(2))); end
    if xSPM.STAT == 'F';     xSPM.Ps = (1-spm_Fcdf(-intensity, xSPM.df)); end
end

if get(handles.allIntensityRadio, 'Value');
    if xSPM.STAT == 'T';     xSPM.Ps = (1-spm_Tcdf((intensity), xSPM.df(2))); end
    if xSPM.STAT == 'F';     xSPM.Ps = (1-spm_Fcdf((intensity), xSPM.df)); end
end

if findstr('SPM2',spm('ver'))
    P = spm_get([0 1],'SPM.mat','locate the corresponding SPM.mat');
elseif findstr('SPM5',spm('ver'))
    P = spm_select([0:1],'SPM.mat','locate the corresponding SPM.mat');
end

if ~isempty(P)
    load(P);
    xSPM.FWHM = SPM.xVol.FWHM;
    xSPM.R =  SPM.xVol.R;
    xSPM.S =  SPM.xVol.S;
else
    warndlg(['You did not input SPM.mat. The listed result may not be correct.'], 'SPM.mat missing');
end

spm_list('List',xSPM,handles.hReg);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% display
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_displayPush(hObject, eventdata)
handles = guidata(hObject);
spm_image('init', handles.imageFileName);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% all in one
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_allinonePush(hObject, eventdata)
try
    if findstr('SPM2',spm('ver'))
        P = spm_get([0:100],'*IMAGE','Select image files');
    elseif findstr('SPM5',spm('ver'))
        P = spm_select(Inf,'image','Select image files');
    end

catch
    return;
end
if isempty(P)
    return
end

handles = guidata(hObject);
%if ~isfield(handles,'hReg') | ~isfield(handles,'hSection') | ~isfield(handles,'hcolorbar')
tmp = [0 0 0];
[handles.hReg, handles.hSection, handles.hcolorbar] = Draw(tmp([],:), [], hObject, handles);
%end

colors=mycolourset;
for ii=1:size(P,1)
    thisfilename = deblank(P(ii,:));
    [handles.imageFileName, handles.M, handles.DIM, handles.TF, handles.df, handles.mni, handles.intensity] = getImageFile(thisfilename);
    cor = mni2cor(handles.mni, handles.M);
    spm_orthviews('addcolouredblobs',1,cor',handles.intensity',handles.M,colors(mod(ii,6)+1,:));
end
spm_orthviews('Redraw');

guidata(hObject, handles);

% contents = get(handles.sectionViewListbox,'String');
% currentsel = contents{get(handles.sectionViewListbox,'Value')};
% sectionViewTargetFile = getSectionViewTargetFile(handles.spmdir, currentsel);
%
% % spm_image('init', sectionViewTargetFile);
% % spm_image('addblobs');
% % return

% guidata(hObject, handles);
% load xSPM;
%         VOL.XYZ = xSPM.XYZ;
%         VOL.Z = xSPM.Z;
%         VOL.M = handles.M;

%addcolouredimage(handles.hSection, '333.img',[1 0 1]);
% uigetfiles
% nblobs = 4;
%     for i=1:nblobs,
%         %[SPM,VOL] = spm_getSPM;
%         %c = spm_input('Colour','+1','m','Red blobs|Yellow blobs|Green blobs|Cyan blobs|Blue blobs|Magenta blobs',[1 2 3 4 5 6],1);
%         c = i;
%         VOL.XYZ = ceil(rand(3,20)*20);
%         VOL.Z = randn(1,20);
%         VOL.M = handles.M;
%         colours = [1 0 0;1 1 0;0 1 0;0 1 1;0 0 1;1 0 1];
%         spm_orthviews('addcolouredblobs',1,VOL.XYZ,VOL.Z,VOL.M,colours(c,:));
%     end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% overlay a brain region Push
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_overlayPush(hObject, eventdata)
handles = guidata(hObject);

tobeoverlay = deblank(get(handles.overlayEdit, 'string'));

if isempty(tobeoverlay)
    return;
end

tobeoverlay = str2cell(tobeoverlay, ' ');
if isnumeric(tobeoverlay{1})
    if length(tobeoverlay{1})>1
        errordlg(['Your input, ' deblank(get(handles.overlayEdit, 'string')) ', seems coincide with a matlab constant.'], 'error');
        return
    end
    for ii=1:length(tobeoverlay)
        tobeoverlay{ii} = num2str(tobeoverlay{ii});
    end
end
fn = fieldnames(handles.wholeMaskMNIAll);
for ii=1:length(tobeoverlay)
    pos{ii} = [];
    for jj=1:length(fn)
        x = [];
        if ~isempty(str2num(tobeoverlay{ii}))
            y = str2cell(fn{jj},'_');
            for kk=1:length(y)
                x = isequal(tobeoverlay{ii}, y{kk});
                if x; break;end;
            end
            if x==0; x = []; end;
        else
            x = findstr(lower(tobeoverlay{ii}), lower(fn{jj}));
        end
        if ~isempty(x)
            pos{ii} = [pos{ii} jj];
        end
    end
end
common = pos{1};
for ii=2:length(pos)
    common = intersect(common, pos{ii});
end

if isempty(common)
    %warndlg(['I don'' find ' deblank(get(handles.overlayEdit, 'string')) '.'], 'oops');
    set(handles.infoTextBox, 'string', ['I don'' find ' deblank(get(handles.overlayEdit, 'string')) '.']);
    return
end

mask = [];
for ii=1:length(common)
    eval(['mask = [mask; handles.wholeMaskMNIAll.' fn{common(ii)} '];']);
end

if isempty(mask)
    %warndlg(['I don'' find ' deblank(get(handles.overlayEdit, 'string')) '.'], 'oops');
    set(handles.infoTextBox, 'string', ['I don'' find ' deblank(get(handles.overlayEdit, 'string')) '.']);
    return;
end

try
    handles.mni;
catch
    delete(gcf);
    xjview(mask);
    return;
end

handles.imageFileName = [handles.imageFileName, {deblank(get(handles.overlayEdit, 'string'))}];
handles.M = [handles.M, {handles.M{1}}];
handles.DIM = [handles.DIM, {handles.DIM{1}}];
handles.currentDisplayMNI = [handles.currentDisplayMNI, {mask}];
m = max(abs(cell2mat(handles.currentDisplayIntensity')));
if ~isempty(m)
    handles.currentDisplayIntensity = [handles.currentDisplayIntensity, {-2*m*ones(size(mask,1),1)}];
else
    handles.currentDisplayIntensity = [handles.currentDisplayIntensity, {ones(size(mask,1),1)}];
end
[handles.hReg, handles.hSection, handles.hcolorbar] = Draw(handles.currentDisplayMNI, handles.currentDisplayIntensity, hObject, handles);
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% overlay a brain region Edit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_overlayEdit(hObject, eventdata)
handles = guidata(hObject);
CallBack_overlayPush(handles.overlayPush, eventdata);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% overlay a brain region popup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_overlayPop(hObject, eventdata)
handles = guidata(hObject);
names = get(hObject, 'string');
value = get(hObject, 'value');
set(handles.overlayEdit, 'string', names{value});
CallBack_overlayEdit(handles.overlayEdit, eventdata);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% search xBrain.org and other databases
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_searchPush(hObject, eventdata)

try
    handles = guidata(hObject);
    searchContent = get(handles.searchContentEdit,'string');
    searchEngine = get(handles.searchEnginePop,'string');
    searchEngine = searchEngine{get(handles.searchEnginePop,'value')};
    
    
    xyz = str2num(searchContent);
    searchMode=get(handles.searchContentEdit,'UserData');
    
    switch searchMode
        case 'auto';
            xyz = spm_XYZreg('GetCoords',handles.hReg);
            handles.currentxyz = xyz';
            guidata(hObject, handles);
            [a,b] = cuixuFindTDstructure(xyz', handles.DB, 0);
            try
                brodmann = strmatch('Brodmann',b)
                brodmann = b{brodmann};
                brodmann = brodmann(1:end-4);
            end;
            try
                region = b{3};
                region = region(1:end-4);
            end

        case 'manual'
            if isempty(xyz)
                searchMode='text';
            elseif length(xyz)==3
                searchMode='xyz';
            end
    end
    
       
    switch searchEngine
        case 'Brede'
            switch searchMode
                case 'auto'
                    searchString = sprintf(' %0.0f',xyz')
                    set(handles.searchContentEdit,'string',searchString);                
                case 'xyz'
                    searchString = num2str(xyz');%searchContent=sprintf('+%0.0f',searchContent)
                case 'text'
            end
            urlstr = ['http://hendrix.imm.dtu.dk/cgi-bin/brede_loc_query.pl?q=' searchString ];
        case 'xBrain.org'
            switch searchMode
                case { 'auto' 'xyz'}
                    xbrainSearchField = 'mni or tal&mnidistance=20';
                    searchString = sprintf(' %0.1f',xyz')% searchString = num2str(xyz');
                case 'text'
                xbrainSearchField = 'region';
                 searchString = searchContent; 
            end
            set(handles.searchContentEdit,'string',searchString);           
            urlstr = ['http://people.hnl.bcm.tmc.edu/cuixu/cgi-bin/bmd/paper.pl?search_content=' searchString '&search_field=' xbrainSearchField];
        case 'Google Scholar'
            if isequal(searchMode,'auto' )
                searchString = { brodmann region };
                searchString(cellfun('isempty',searchString))=[];
                searchString = sprintf('%%22%s%%22|',searchString{:});
                try
                    searchString = searchString(1:end-1);
                end
                %set(handles.searchContentEdit,'string',searchString);
            end
            urlstr = ['http://scholar.google.com/scholar?q=' searchString ];
        case 'Pubmed'
            switch searchMode
                case 'auto'
                    searchString = { brodmann region };
                    searchString(cellfun('isempty',searchString))=[];
                    searchString = sprintf('%%22%s%%22 OR ',searchString{:});
                    try
                        searchString = searchString(1:end-4);
                    end
                    %searchString = brodmann;
                case 'text'
                    searchString = searchContent;
            end            
            % urlstr = ['http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?cmd=PureSearch&db=pubmed&details_term=(' searchString ')'];
            urlstr = ['http://www.ncbi.nlm.nih.gov/sites/entrez?cmd=search&db=pubmed&pubmedfilters=true&term=(' searchString ')'];
        case 'Wikipedia'
            if isequal(searchMode,'auto')
                searchString = region;
            end            
            urlstr = ['http://en.wikipedia.org/w/index.php?search=%22' searchString '%22'];
    end
    set(handles.searchContentEdit,'UserData',searchMode);
catch
    urlstr = 'http://www.google.com';
end

try
    web(urlstr,'-browser');
catch
    if exist('c:\program Files\mozilla Firefox\firefox.exe','file')
        system(['"c:\program Files\mozilla Firefox\firefox.exe" "' urlstr '"'])
    else
    web(urlstr);
    end
end
    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% control panel on or off
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function controlHide(handles, status)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% get multiple values from a string deliminated delim
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = str2cell(str, delim)
if ~exist('delim')
    delim = '; ';
end

[out{1},b] = strtok(str, delim);
ii = 2;
while ~isempty(b)
    [out{ii},b] = strtok(b, delim);
    ii = ii+1;
end

for ii=1:length(out)
    out2{ii} = str2num(out{ii});
    if isempty(out2{ii})
        return;
    end
end

for ii=1:length(out)
    out{ii} = str2num(out{ii});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% cell2str
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = cell2str(acell, delim)
if ~exist('delim')
    delim = ';';
end

str = [];

if length(acell)==1
    if isstr(acell{1})
        str = acell{1};
    else
        str = num2str(acell{1});
    end
else
    for ii=1:length(acell)
        if isstr(acell{ii})
            str = [str acell{ii}, delim ' '];
        else
            str = [str num2str(acell{ii}), delim ' '];
        end
    end
    str(end-1:end)=[];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% cellmax, find max in each element, return a cell
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function MAXX = cellmax(acell, absolute)

if ~exist('absolute')
    absolute = '';
end

MAXX = [];
for ii=1:length(acell)
    if strfind('abs',absolute)
        MAXX = [MAXX max(abs(acell{ii}))];
    else
        MAXX = [MAXX max(acell{ii})];
    end
end
MAXX = num2cell(MAXX);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% maxcell
%%% find max of all numbers in the whole cell, return a single value
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function MAXX = maxcell(acell, absolute)

if ~exist('absolute')
    absolute = '';
end
MAXX = cellmax(acell, absolute);
MAXX = max(cell2mat(MAXX));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% p2t
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function t = p2t(p, df, TF)
if ~iscell(p)
    if upper(TF)=='T' | upper(TF)=='S'
        t = spm_invTcdf(1-p,df);
    elseif upper(TF) == 'F'
        t = spm_invFcdf(1-p,df);
    end
else
    for ii=1:length(p)
        t{ii} = p2t(p{ii},df{ii},TF{ii});
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% s2t, s is defined as -log10(p)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function t = s2t(s, df, TF)

if ~iscell(s)
    p = 10^(-s);
    if upper(TF)=='T' | upper(TF)=='S'
        t = spm_invTcdf(1-p,df);
    elseif upper(TF) == 'F'
        t = spm_invFcdf(1-p,df);
    end
else
    for ii=1:length(p)
        t{ii} = s2t(s{ii},df{ii},TF{ii});
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% t2p
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function p = t2p(t, df, TF)
if ~iscell(t)
    if upper(TF)=='T' | upper(TF)=='S'
        p = 1-spm_Tcdf(t,df);
    elseif upper(TF) == 'F'
        p = 1-spm_Fcdf(t,df);
    end
else
    for ii=1:length(t)
        p{ii} = t2p(t{ii},df{ii},TF{ii});
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% t2s, s is defined as -log10(p)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s = t2s(t, df, TF)
if ~iscell(t)
    if upper(TF)=='T' | upper(TF)=='S'
        p = 1-spm_Tcdf(t,df);
    elseif upper(TF) == 'F'
        p = 1-spm_Fcdf(t,df);
    else
        p = 0.1;
    end
    s = -log10(p);
else
    for ii=1:length(t)
        s{ii} = t2s(t{ii},df{ii},TF{ii});
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% mni2mask
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mask = mni2mask(coords, targetfilename, intensity, M, DIM, templateFile, isMask)
% function mask = mni2mask(coords, targetfilename, intensity, templateFile)
% make mask from coordinates
%
% coords: a Nx3 column of 3-d coordinates in MNI
% space
% targetfilename: (optional) the image files to be written
% intensity: (optional) Nx1, the values of each coordinate.
% M: rotation matrix
% DIM: dimension
% templateFile: (optional) the templateFile from which we can get the right
% dimensions.
% isMask: if this variable exist and equal to 1, then all non-zero
% intensities will be set to 1
%
% Xu Cui
% 2004/11/18

if ~exist('intensity')
    intensity = ones(size(coords,1),1);
end
thistemplateFile = '';
if exist('templateFile')
    if ~isempty(templateFile)
        thistemplateFile = templateFile;
    end
end

if isempty(thistemplateFile)
    V.mat = [...
        -4     0     0    84; ...
        0     4     0  -116; ...
        0     0     4   -56; ...
        0     0     0     1];
    V.dim = [41 48 35 16];
    if exist('M')
        V.mat = M;
    end
    if exist('DIM')
        V.dim = DIM;
        V.dim(4) = 16;
    end
    V.fname = targetfilename;
    V.descrip = 'our own image';
else
    V = spm_vol(templateFile);
    V.fname = targetfilename;
    if isfield(V, 'descrip')
        V.descrip = ['my image from ' V.descrip];
    else
        V.descrip = 'my own image';
    end
end

thisismask = 0;
if exist('isMask')
    if isMask == 1
        thisismask = 1;
    end
end
if thisismask
    V.descrip = 'my mask';
    intensity = ones(size(intensity));
end

O = zeros(V.dim(1),V.dim(2),V.dim(3));

coords = mni2cor(coords,V.mat);


for ii=1:size(coords,1)
    O(coords(ii,1),coords(ii,2),coords(ii,3)) = intensity(ii);
end

if exist('targetfilename')
    V = spm_write_vol(V,O);
end

mask = O;

return;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% get image file information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [imageFile,M,DIM,TF,df,mni,intensity] = getImageFile(thisfilename)
% function imageFile = getImageFile(filename)
% get the information of this/these image file(s)
%
% thisfilename: (optional) if doesn't give file name, then show a open file
% dialog
% imageFile: the full name of the selected file (if user pressed cancel,
% imageFile == 0
% M: M matrix (rotation matrix)
% DIM: dimension
% TF: t test or f test? 'T' or 'F'
% df: degree of freedome
% mni: mni coord
% intensity: intensity of each mni coord
%
% Note: The returned variables are cellarrays.
%
% Xu Cui
% last revised: 2005-05-03

if nargin < 1 | isempty(thisfilename)
    if findstr('SPM2',spm('ver'))
        P0 = spm_get([0:100],'*IMAGE','Select image files');
    elseif findstr('SPM5',spm('ver'))
        P0 = spm_select(Inf,'image','Select image files');
    end

    %     try
    %         P0 = spm_get([0:100],'*IMAGE','Select image files');
    %     catch
    %         P0 = [];
    %         [FileName,PathName] = uigetfile({'*.img';'*.IMG';'*.*'},'Select image files','MultiSelect','on');
    %         if isstr(FileName)
    %             P0 = {fullfile(PathName, FileName)};
    %         elseif iscellstr(FileName)
    %             for ii=1:length(FileName)
    %                 P0{ii} = fullfile(PathName, FileName{ii});
    %             end
    %         else
    %             P0 = [];
    %         end
    %     end
    try
        if isempty(P0)
            imageFile = '';M=[];DIM=[];TF=[];df=[];mni=[];intensity=[];
            return
        end
    end
    for ii=1:size(P0,1)
        P{ii} = deblank(P0(ii,:));
    end
else
    if isstr(thisfilename)
        P = {thisfilename};
    elseif iscellstr(thisfilename)
        P = thisfilename;
    else
        disp('Error: In getImageFile: I don''t understand the input.');
        imageFile = '';M=[];DIM=[];TF=[];df=[];mni=[];intensity=[];
        return
    end
end

global LEFTRIGHTFLIP_;

for ii=1:length(P)
    imageFile{ii} = P{ii};
    [cor{ii}, intensity{ii}, tmp{ii}, M{ii}, DIM{ii}, TF{ii}, df{ii}] = mask2coord(imageFile{ii}, 0);
    if LEFTRIGHTFLIP_ == 1
        M{ii}(1,:) = -M{ii}(1,:);
    end
    mni{ii} = cor2mni(cor{ii}, M{ii});
end














%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% cuixuFindTDstructure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [onelinestructure, cellarraystructure] = cuixuFindTDstructure(pos, DB, TALMNI)
% function [onelinestructure, cellarraystructure] = cuixuFindTDstructure(pos, DB, TALMNI)
%
% this function converts Talairach Daemon coordinate or MNI coordinate to a description of
% brain structure.
%
%   pos: the coordinate (MNI or Talairach coordinate, defined by TALMNI) of the position in the brain, in mm
%   DB: the database structure (see below for detailed explanation). If you don't input this argument, there
%   should be a file called 'TDdatabase.mat' in the current directory
%   TALMNI: 1 if pos is talairach coordinate, 0 if pos is MNI coordinate. 1
%   by default.
%
%   onelinestructure: a one-line description of the returned brain
%   structure
%   cellarraystructure: a cell array of size 5, each cell contains a string
%   describing the structure of the brain in a certain level.
%
%   Example:
%       [onelinestructure, cellarraystructure] = cuixuFindTDstructure([-24 24 48], DB, 1)
%       [onelinestructure, cellarraystructure] = cuixuFindTDstructure([-24 24 48])
%       then
%       onelinestructure = // Left Cerebrum // Frontal Lobe (L) // Middle Frontal Gyrus (L) // Gray Matter (L) // Brodmann area 8 (L)
%       cellarraystructure = 'Left Cerebrum'    'Frontal Lobe (L)'    [1x24 char]    'Gray Matter (L)'    'Brodmann area 8 (L)'
%
% Xu Cui
% 2004-6-28
%

%----------------------------------------------------------------------------------
% DB strcture
%----------------------------------------------------------------------------------
%-------------------------------
% Grid specification parameters:
%-------------------------------
% minX              - min X (mm)
% maxX              - max X (mm)
% voxX              - voxel size (mm) in X direction
% minY              - min Y (mm)
% maxY              - max Y (mm)
% voxY              - voxel size (mm) in Y direction
% minZ              - min Z (mm)
% maxZ              - max Z (mm)
% voxZ              - voxel size (mm) in Z direction
% nVoxX             - number of voxels in X direction
% nVoxY             - number of voxels in Y direction
% nVoxZ             - number of voxels in Z direction
%-------------------------------
% Classification parameters:
%-------------------------------
% numClass          - number of classification types
% cNames            - cNames{i}             - cell array of class names for i-th CT
% numClassSize      - numClassSize(i)       - number of classes for i-th CT
% indUnidentified   - indUnidentified(i)    - index of "indUnidentified" class for i-th CT
% volClass          - volClass{i}(j)        - number of voxels in class j for i-th CT
%
% data              - N x numClass matrix of referencies; let
%                       x y z coordinates in mm (on the grid) and
%                       nx = (x-minX)/voxX
%                       ny = (y-minY)/voxY
%                       nz = (z-minZ)/voxZ
%                       ind = nz*nVoxX*nVoxY + ny*nVoxX + nx + 1
%                       data(ind, i) - index of the class for i-th CT in cNames{i} to
%                                      which (x y z) belongs, i.e.
%                                      cNames{i}{data(ind, i)} name of class for i-th CT
%----------------------------------------------------------------------------------

if nargin==1
    load('TDdatabase.mat');
    TALMNI = 1;
elseif nargin == 2
    TALMNI = 1;
end

if(TALMNI == 1)
    pos = tal2mni(pos);
elseif(TALMNI == 0)
    [];
else
    disp('TALMNI should be 1 or 0.');
end

pos(:,1) = DB.voxX*round(pos(:,1)/DB.voxX);
pos(:,2) = DB.voxY*round(pos(:,2)/DB.voxY);
pos(:,3) = DB.voxZ*round(pos(:,3)/DB.voxZ);

min = [];
vox = [];
for(i=1:size(pos,1))
    min = [min; DB.minX DB.minY DB.minZ];
    vox = [vox; DB.voxX DB.voxY DB.voxZ];
end
n_pos = (pos - min)./vox;

nx = n_pos(:,1);
ny = n_pos(:,2);
nz = n_pos(:,3);
index = nz*DB.nVoxX*DB.nVoxY + ny*DB.nVoxX + nx + 1;
indMax = size(DB.data, 1);

onelinestructuretmp = [];
onelinestructure = [];
for(j=1:size(pos,1))
    onelinestructuretmp = [];
    for(i=1:DB.numClass)

        if (index(j) <= 0 | index(j) > indMax)
            ind(j) = DB.indUnidentified(i);
        else
            ind(j) = DB.data(index(j), i);
        end

        cellarraystructure{j,i} = DB.cNames{i}{ind(j)};
        onelinestructuretmp = [onelinestructuretmp ' // ' cellarraystructure{j,i}];
    end
    onelinestructure{j} = onelinestructuretmp;
end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% mask2coord
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [cor, intensity, cor_singlecolumn,M,DIM,TF,df] = mask2coord(mask, checkdimension)
% [cor, intensity, cor_singlecolumn] = mask2coord(mask, checkdimension)
%
% This is to retrieve the coordinate of a mask file, or a matrix of 3-D
%
% mask: an image file or a matrix (3-D), with some of the elements are
% non-zeros
% checkdimension: check if the dimension is checkdimension, if not, return empty
% matrix
% cor: a N*3 matrix, which each row a coordinate in matrix
% intensity: a N*1 matrix, which encodes the intensity of each voxel.
% cor_singlecolumn: a N*1 matrix, each row is the index in the matrix
% M: rotation matrix
% DIM: dimension
% TF: t test or f test? 'T','F' or []
% df: degree of freedome for T/F test
%
% Example:
%   mask = zeros(4,3,2);
%   mask(1,2,1) = 1;
%   mask(3,2,2) = 1;
%   mask2coord(mask)
%
%   mask2coord('spmT_0002.img')
%   mask2coord('spmT_0002.img',[41 48 35])
%
% Xu Cui
% 2004-9-20
% last revised: 2005-04-30

if nargin < 2
    checkdimension = 0;
end

if ischar(mask)
    V = spm_vol(mask);
    mask = spm_read_vols(V);
    M = V.mat;
    DIM = V.dim;
    TF = 'T';
    T_start = strfind(V.descrip,'SPM{T_[')+length('SPM{T_[');
    if isempty(T_start); T_start = strfind(V.descrip,'SPM{F_[')+length('SPM{F_['); TF='F'; end
    if isempty(T_start)
        TF=[]; df=[];
    else
        T_end = strfind(V.descrip,']}')-1;
        df = str2num(V.descrip(T_start:T_end));
    end
else
    M = [];
    TF = [];
    df = [];
end

dim = size(mask);
if length(checkdimension)==3
    if dim(1)~= checkdimension(1) | dim(2)~= checkdimension(2) | dim(3)~= checkdimension(3)
        y = [];
        disp('dimension doesn''t match')
        return
    end
end

pos = find(mask~=0);
intensity = mask(pos);

y = zeros(length(pos),3);

y(:,3) = ceil(pos/(dim(1)*dim(2)));
pos = pos - (y(:,3)-1)*(dim(1)*dim(2));
y(:,2) = ceil(pos/dim(1));
pos = pos - (y(:,2)-1)*(dim(1));
y(:,1) = pos;

cor = y;
cor_singlecolumn = pos;
DIM = dim;
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% mni2cor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function coordinate = mni2cor(mni, T)
% function coordinate = mni2cor(mni, T)
% convert mni coordinate to matrix coordinate
%
% mni: a Nx3 matrix of mni coordinate
% T: (optional) transform matrix
% coordinate is the returned coordinate in matrix
%
% caution: if T is not specified, we use:
% T = ...
%     [-4     0     0    84;...
%      0     4     0  -116;...
%      0     0     4   -56;...
%      0     0     0     1];
%
% xu cui
% 2004-8-18
%

if isempty(mni)
    coordinate = [];
    return;
end

if ~exist('T')
    T = ...
        [-4     0     0    84;...
        0     4     0  -116;...
        0     0     4   -56;...
        0     0     0     1];
end

coordinate = [mni(:,1) mni(:,2) mni(:,3) ones(size(mni,1),1)]*(inv(T))';
coordinate(:,4) = [];
coordinate = round(coordinate);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% cor2mni
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mni = cor2mni(cor, T)
% function mni = cor2mni(cor, T)
% convert matrix coordinate to mni coordinate
%
% cor: an Nx3 matrix
% T: (optional) rotation matrix
% mni is the returned coordinate in mni space
%
% caution: if T is not given, the default T is
% T = ...
%     [-4     0     0    84;...
%      0     4     0  -116;...
%      0     0     4   -56;...
%      0     0     0     1];
%
% xu cui
% 2004-8-18
% last revised: 2005-04-30

if nargin == 1
    T = ...
        [-4     0     0    84;...
        0     4     0  -116;...
        0     0     4   -56;...
        0     0     0     1];
end

cor = round(cor);
mni = T*[cor(:,1) cor(:,2) cor(:,3) ones(size(cor,1),1)]';
mni = mni';
mni(:,4) = [];
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% draw
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [hReg, hSection, hcolorbar] = Draw(mniCoord, intensity, hObject, handles)

try
    delete(handles.hcolorbar);
end
try
    delete(handles.hReg);
end
try
    delete(handles.hSection);
end
try
    cla(handles.glassViewAxes);
end

try
    H  = findobj(get(handles.figure,'Children'),'flat','Type','axes');
    un = cellstr(get(H,'Units'));
    pos = get(H,'position');

    for ii=1:length(H)
        if findstr('pixels', un{ii})
            continue;
        end
        if pos{ii}(1)>0.4
            delete(H(ii));
        end
    end
end

sectionViewTargetFile = handles.sectionViewTargetFile;

if ~iscell(mniCoord) | (iscell(mniCoord) & length(mniCoord)==1)% multiple input? no
    if (iscell(mniCoord) & length(mniCoord)==1)
        mniCoord = mniCoord{1};
        intensity = intensity{1};
        handles.M = handles.M{1};
        handles.DIM = handles.DIM{1};
    end
    if max(intensity)*min(intensity) < 0
        [hReg, hSection, hcolorbar] = cuixuSectionView(mniCoord,intensity,sectionViewTargetFile,hObject,handles);
    else
        [hReg, hSection, hcolorbar] = cuixuSectionView(mniCoord,abs(intensity),sectionViewTargetFile,hObject,handles);
    end

    if size(mniCoord,1)>1
        pos1 = find(intensity>=0);
        pos2 = find(intensity<0);
        if ~isempty(pos1) & ~isempty(pos2)
            if get(handles.renderViewCheck, 'Value'); cuixuRenderView(mniCoord(pos1,:),intensity(pos1,:),mniCoord(pos2,:),-intensity(pos2,:)); end
        else
            if get(handles.renderViewCheck, 'Value'); cuixuRenderView(mniCoord, abs(intensity)); end
        end
    end
else % multiple input? yes
    [hReg, hSection, hcolorbar] = cuixuSectionView(mniCoord,intensity,sectionViewTargetFile,hObject,handles);

    mniCoordtmp=[];
    intensitytmp=[];
    for ii=1:length(mniCoord)
        mniCoordtmp = [mniCoordtmp; mniCoord{ii}];
        intensitytmp = [intensitytmp; intensity{ii}];
    end
    mniCoord = mniCoordtmp;
    intensity = intensitytmp;
    if size(mniCoord,1)>1
        pos1 = find(intensity>=0);
        pos2 = find(intensity<0);
        if ~isempty(pos1) & ~isempty(pos2)
            if get(handles.renderViewCheck, 'Value'); cuixuRenderView(mniCoord(pos1,:),intensity(pos1,:),mniCoord(pos2,:),-intensity(pos2,:)); end
        else
            if get(handles.renderViewCheck, 'Value'); cuixuRenderView(mniCoord, abs(intensity)); end
        end
    end

end

try
    spm_XYZreg('SetCoords',handles.currentxyz',hReg);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% cuixuSectionView
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [hReg, hSection, hcolorbar] = cuixuSectionView(mniCoord, intensity, targetFile, hObject,handles)
% function h = cuixuSectionView(mniCoord, intensity)
% This is to project your coordinate to section view
%
% mniCoord: the mni coordinate, N*3 matrix
% intensity: the plot intensity of the spots, 1*N matrix. The intensity
% could be t value, for example.
%
% a special feature of this function is: it automatically seperate the
% negative and positive intensity and use hot and cold color to represent
% them.
%
% h: the returned handle for the axes
%
% SEE ALSO: cuixuView cuixuGlassView cuixuRenderView
%
% Xu Cui
% 2004/11/11

if ~iscell(mniCoord) | (iscell(mniCoord) & length(mniCoord)==1)% multiple input? no
    multiple = 0;
    if (iscell(mniCoord) & length(mniCoord)==1)
        mniCoord = mniCoord{1};
        intensity = intensity{1};
        handles.M = handles.M{1};
        handles.DIM = handles.DIM{1};
    end
else
    multiple = 1;
    mniCoordtmp = [];
    intensitytmp = [];
    for ii=1:length(mniCoord)
        mniCoordtmp = [mniCoordtmp; mniCoord{ii}];
        intensitytmp = [intensitytmp; intensity{ii}];
        % for multiple input
        cSPM{ii}.XYZ =  mni2cor(mniCoord{ii}, handles.M{ii});
        cSPM{ii}.XYZ = cSPM{ii}.XYZ';
        cSPM{ii}.Z = abs(intensity{ii});
        cSPM{ii}.M = handles.M{ii};
        cSPM{ii}.DIM = handles.DIM{ii}';
    end
    mniCoord = mniCoordtmp;
    intensity = intensitytmp;
    handles.M = handles.M{1};
    handles.DIM = handles.DIM{1};
end

SPM.XYZ = mni2cor(mniCoord, handles.M);
SPM.XYZ = SPM.XYZ';
SPM.Z = intensity;
SPM.M = handles.M;
SPM.DIM = handles.DIM';

%%%%%%%%%%%%%%% Reg %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles.colormap = colormap;

coor = mniCoord;
xSPM = SPM;
xSPM.XYZmm = mniCoord';
axes(handles.glassViewAxes)
WS     = spm('WinScale');
FS     = spm('FontSizes');

Finter = gcf;
hReg    = uicontrol(Finter,'Style','Frame','Position',[60 100 300 300].*WS,...
    'Visible','off');
[hReg,xyz] = spm_XYZreg('InitReg',hReg,xSPM.M,xSPM.DIM,[0;0;0]);

hFxyz      = spm_results_ui('DrawXYZgui',xSPM.M,xSPM.DIM,xSPM,xyz,Finter);
spm_XYZreg('XReg',hReg,hFxyz,'spm_results_ui');

hMIPax =gca ;
setcolormap('gray');

hMIPax = spm_mip_ui(xSPM.Z,coor',xSPM.M,xSPM.DIM,hMIPax);
spm_XYZreg('XReg',hReg,hMIPax,'spm_mip_ui');

colormap(handles.colormap);
setcolormap('gray-hot');

if isempty(handles.M)
    spm_XYZreg('SetReg',handles.structureEdit,hReg);
else
    set(handles.structureEdit, 'UserData', struct('hReg',hReg,'M',handles.M,'D', handles.DIM,'xyx',[0 0 0]));
end

spm_XYZreg('Add2Reg',hReg,handles.structureEdit,@CallBack_structureEdit);

%%%%%%%%%%%%%%% Reg end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if multiple == 0
    [hgraph, hSection, hcolorbar] = spm_sections(SPM,hReg,targetFile,handles.sectionViewPosition);
else
    [hgraph, hSection, hcolorbar] = spm_sections(cSPM,hReg,targetFile,handles.sectionViewPosition);
end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% spm_sections
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Fgraph, hMe, hcolorbar] = spm_sections(SPM,hReg,targetFile,sectionViewPosition)
% rendering of regional effects [SPM{Z}] on orthogonal sections
% FORMAT spm_sections(SPM,hReg)
%
% SPM  - xSPM structure containing details of excursion set
% hReg - handle of MIP register
%
% see spm_getSPM for details
%_______________________________________________________________________
%
% spm_sections is called by spm_results and uses variables in SPM and
% VOL to create three orthogonal sections though a background image.
% Regional foci from the selected SPM are rendered on this image.
%
%_______________________________________________________________________
% @(#)spm_sections.m    2.14    John Ashburner 02/09/05

Fgraph = gcf;

spms = fullfile(spm('dir'),'canonical', 'single_subj_T1.mnc');
if exist('targetFile')
    spms = targetFile;
end

spm_orthviews('Reset');
global st
st.fig = Fgraph;
st.Space = spm_matrix([0 0 0  0 0 -pi/2])*st.Space;

spm_orthviews('Image',spms,sectionViewPosition); % position
spm_orthviews('MaxBB');
spm_orthviews('register',hReg);
if ~iscell(SPM)
    spm_orthviews('addblobs',1,SPM.XYZ,SPM.Z,SPM.M);
elseif length(SPM) == 1
    SPM = SPM{1};
    spm_orthviews('addblobs',1,SPM.XYZ,SPM.Z,SPM.M);
else
    colors = mycolourset;
    for ii=1:length(SPM)
        spm_orthviews('addcolouredblobs',1,SPM{ii}.XYZ, SPM{ii}.Z, SPM{ii}.M, colors(ii,:));
    end
end
spm_orthviews('Redraw');

hMe = st.registry.hMe;
try
    hcolorbar = st.vols{1}.blobs{1}.cbar;
catch
    hcolorbar = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% cuixuRenderView
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h = cuixuRenderView(mniCoord, intensity, varargin)
% function h = cuixuRenderView(mniCoord1, intensity1, mniCoord2, intensity2, mniCoord3, intensity3)
% This is to project your coordinate to render view
%
% mniCoord: the mni coordinate, N*3 matrix
% intensity: the plot intensity of the spots, 1*N matrix. The intensity
% could be t value, for example.
%
% You can input 1, 2, or 3 pairs of coordinates and intensity.
%
% h: the returned handle for the figure
%
% Xu Cui
% 2004/11/11

global M_;
global DIM_;

if nargin < 3
    dat.XYZ = mni2cor(mniCoord, M_);
    dat.XYZ = dat.XYZ';
    if nargin < 2
        dat.t = ones(size(mniCoord,1),1);
    else
        dat.t = intensity;
    end
    dat.mat = M_;
    dat.dim = DIM_;
else
    if mod(nargin,2) ~=0
        disp('You should put even number of parameters.')
        return;
    end
    for ii=1:(2+length(varargin))/2
        if ii==1
            dat(ii).XYZ = mni2cor(mniCoord, M_);
            dat(ii).t = intensity;
        else
            dat(ii).XYZ = mni2cor(varargin{2*(ii-1)-1}, M_);
            dat(ii).t = varargin{2*(ii-1)};
        end
        dat(ii).XYZ = dat(ii).XYZ';
        dat(ii).mat = M_;
        dat(ii).dim = DIM_;
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% spm_render
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h = spm_render(dat,1,fullfile(spm('dir'), 'rend', 'render_single_subj.mat'));
return

function Fgraph = spm_render(dat,brt,rendfile)
% Render blobs on surface of a 'standard' brain
% FORMAT spm_render(dat,brt,rendfile)
%
% dat - a vertical cell array of length 1 to 3
%       - each element is a structure containing:
%         - XYZ - the x, y & z coordinates of the transformed t values.
%                 in units of voxels.
%         - t   - the SPM{.} values
%         - mat - affine matrix mapping from XYZ voxels to Talairach.
%         - dim - dimensions of volume from which XYZ is drawn.
% brt - brightness control:
%            If NaN, then displays using the old style with hot
%            metal for the blobs, and grey for the brain.
%            Otherwise, it is used as a ``gamma correction'' to
%            optionally brighten the blobs up a little.
% rendfile - the file containing the images to render on to. See also
%            spm_xbrain.m.
%
% Without arguments, spm_render acts as its own UI.
%_______________________________________________________________________
%
% spm_render prompts for details of up to three SPM{Z}s or SPM{t}s that
% are then displayed superimposed on the surface of a standard brain.
%
% The first is shown in red, then green then blue.
%
% The blobs which are displayed are the integral of all transformed t
% values, exponentially decayed according to their depth. Voxels that
% are 10mm behind the surface have half the intensity of ones at the
% surface.
%_______________________________________________________________________
% @(#)spm_render.m    2.19 John Ashburner FIL 02/10/29

%-Parse arguments, get data if not passed as parameters
%=======================================================================
if nargin < 1
    SPMid = spm('FnBanner',mfilename,'2.19');
    [Finter,Fgraph,CmdLine] = spm('FnUIsetup','Results: render',0);

    num   = spm_input('Number of sets',1,'1 set|2 sets|3 sets',[1 2 3]);

    for i = 1:num,
        [SPM,VOL] = spm_getSPM;
        dat(i)    = struct(    'XYZ',    VOL.XYZ,...
            't',    VOL.Z',...
            'mat',    VOL.M,...
            'dim',    VOL.DIM);
    end;
    showbar = 1;
else,
    num     = length(dat);
    showbar = 0;
end;

% get surface
%-----------------------------------------------------------------------
if nargin < 3,
    rendfile = spm_get(1,'render*.mat','Render file',fullfile(spm('Dir'),'rend'));
end;

% get brightness
%-----------------------------------------------------------------------
if nargin < 2,
    brt = 1;
    if num==1,
        brt = spm_input('Style',1,'new|old',[1 NaN], 1);
    end;
    if finite(brt),
        brt = spm_input('Brighten blobs',1,'none|slightly|more|lots',[1 0.75 0.5 0.25], 1);
    end;
end;



% Perform the rendering
%=======================================================================
spm('Pointer','Watch')

load(rendfile);

if (exist('rend') ~= 1), % Assume old format...
    rend = cell(size(Matrixes,1),1);
    for i=1:size(Matrixes,1),
        rend{i}=struct('M',eval(Matrixes(i,:)),...
            'ren',eval(Rens(i,:)),...
            'dep',eval(Depths(i,:)));
        rend{i}.ren = rend{i}.ren/max(max(rend{i}.ren));
    end;
end;

if showbar, spm_progress_bar('Init', size(dat,1)*length(rend),...
        'Formatting Renderings', 'Number completed'); end;
for i=1:length(rend),
    rend{i}.max=0;
    rend{i}.data = cell(size(dat,1),1);
    if issparse(rend{i}.ren),
        % Assume that images have been DCT compressed
        % - the SPM99 distribution was originally too big.
        d = size(rend{i}.ren);
        B1 = spm_dctmtx(d(1),d(1));
        B2 = spm_dctmtx(d(2),d(2));
        rend{i}.ren = B1*rend{i}.ren*B2';
        % the depths did not compress so well with
        % a straight DCT - therefore it was modified slightly
        rend{i}.dep = exp(B1*rend{i}.dep*B2')-1;
    end;
    msk = find(rend{i}.ren>1);rend{i}.ren(msk)=1;
    msk = find(rend{i}.ren<0);rend{i}.ren(msk)=0;
    if showbar, spm_progress_bar('Set', i); end;
end;
if showbar, spm_progress_bar('Clear'); end;

if showbar, spm_progress_bar('Init', length(dat)*length(rend),...
        'Making pictures', 'Number completed'); end;

mx = zeros(length(rend),1)+eps;
mn = zeros(length(rend),1);

for j=1:length(dat),
    XYZ = dat(j).XYZ;
    t   = dat(j).t;
    dim = dat(j).dim;
    mat = dat(j).mat;

    for i=1:length(rend),

        % transform from Taliarach space to space of the rendered image
        %-------------------------------------------------------
        M1  = rend{i}.M*dat(j).mat;
        zm  = sum(M1(1:2,1:3).^2,2).^(-1/2);
        M2  = diag([zm' 1 1]);
        M  = M2*M1;
        cor = [1 1 1 ; dim(1) 1 1 ; 1 dim(2) 1; dim(1) dim(2) 1 ;
            1 1 dim(3) ; dim(1) 1 dim(3) ; 1 dim(2) dim(3); dim(1) dim(2) dim(3)]';
        tcor= M(1:3,1:3)*cor + M(1:3,4)*ones(1,8);
        off = min(tcor(1:2,:)');
        M2  = spm_matrix(-off+1)*M2;
        M  = M2*M1;
        xyz = (M(1:3,1:3)*XYZ + M(1:3,4)*ones(1,size(XYZ,2)));
        d2  = ceil(max(xyz(1:2,:)'));

        % calculate 'depth' of values
        %-------------------------------------------------------
        dep = spm_slice_vol(rend{i}.dep,spm_matrix([0 0 1])*inv(M2),d2,1);
        z1  = dep(round(xyz(1,:))+round(xyz(2,:)-1)*size(dep,1));

        if ~finite(brt), msk = find(xyz(3,:) < (z1+20) & xyz(3,:) > (z1-5));
        else,      msk = find(xyz(3,:) < (z1+60) & xyz(3,:) > (z1-5)); end;

        if ~isempty(msk),

            % generate an image of the integral of the blob values.
            %-----------------------------------------------
            xyz = xyz(:,msk);
            if ~finite(brt), t0  = t(msk);
            else,    dst = xyz(3,:) - z1(msk);
                dst = max(dst,0);
                t0  = t(msk).*exp((log(0.5)/10)*dst)';
            end;
            X0  = full(sparse(round(xyz(1,:)), round(xyz(2,:)), t0, d2(1), d2(2)));
            hld = 1; if ~finite(brt), hld = 0; end;
            X   = spm_slice_vol(X0,spm_matrix([0 0 1])*M2,size(rend{i}.dep),hld);
            msk = find(X<0);
            X(msk) = 0;
        else,
            X = zeros(size(rend{i}.dep));
        end;

        % Brighten the blobs
        if finite(brt), X = X.^brt; end;

        mx(j) = max([mx(j) max(max(X))]);
        mn(j) = min([mn(j) min(min(X))]);

        rend{i}.data{j} = X;

        if showbar, spm_progress_bar('Set', i+(j-1)*length(rend)); end;
    end;
end;

mxmx = max(mx);
mnmn = min(mn);

if showbar, spm_progress_bar('Clear'); end;
Fgraph = gcf;%spm_figure('GetWin','Graphics');
%spm_results_ui('Clear',Fgraph);

nrow = ceil(length(rend)/2);
hght = 0.25;
width = 0.25;
x0 = 0.5;
y0 = 0.01;
% subplot('Position',[0, 0, 1, hght]);
ax=axes('Parent',Fgraph,'units','normalized','Position',[0, 0, 0.5, hght],'Visible','off');
%ax=axes;
%image(0,'Parent',ax);
set(ax,'YTick',[],'XTick',[]);

if ~finite(brt),
    % Old style split colourmap display.
    %---------------------------------------------------------------
    load Split;
    colormap(split);
    for i=1:length(rend),
        ren = rend{i}.ren;
        X   = (rend{i}.data{1}-mnmn)/(mxmx-mnmn);
        msk = find(X);
        ren(msk) = X(msk)+(1+1.51/64);
        ax=axes('Parent',Fgraph,'units','normalized',...
            'Position',[x0+rem(i-1,2)*width, y0+floor((i-1)/2)*hght/nrow, width, hght/nrow],...
            'Visible','off');
        image(ren*64,'Parent',ax);
        set(ax,'DataAspectRatio',[1 1 1], ...
            'PlotBoxAspectRatioMode','auto',...
            'YTick',[],'XTick',[],'XDir','normal','YDir','normal');
    end;
else,
    % Combine the brain surface renderings with the blobs, and display using
    % 24 bit colour.
    %---------------------------------------------------------------
    for i=1:length(rend),
        ren = rend{i}.ren;
        X = cell(3,1);
        for j=1:length(rend{i}.data),
            X{j} = rend{i}.data{j}/(mxmx-mnmn)-mnmn;
        end
        for j=(length(rend{i}.data)+1):3
            X{j}=zeros(size(X{1}));
        end

        rgb = zeros([size(ren) 3]);
        tmp = ren.*max(1-X{1}-X{2}-X{3},0);
        rgb(:,:,1) = tmp + X{1};
        rgb(:,:,2) = tmp + X{2};
        rgb(:,:,3) = tmp + X{3};

        ax=axes('Parent',Fgraph,'units','normalized',...
            'Position',[x0+rem(i-1,2)*width, y0+floor((i-1)/2)*hght/nrow*2, width, hght/nrow*2],...
            'Visible','off');
        image(rgb,'Parent',ax);
        set(ax,'DataAspectRatio',[1 1 1], ...
            'PlotBoxAspectRatioMode','auto',...
            'YTick',[],'XTick',[],...
            'XDir','normal','YDir','normal');
    end;
end;

spm('Pointer')
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% spm_list
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = spm_list(varargin)
% Display and analysis of SPM{.}
% FORMAT TabDat = spm_list('List',SPM,hReg,[Num,Dis,Str])
% Summary list of local maxima for entire volume of interest
% FORMAT TabDat = spm_list('ListCluster',SPM,hReg,[Num,Dis,Str])
% List of local maxima for a single suprathreshold cluster
%
% SPM    - structure containing SPM, distribution & filtering details
%        - required fields are:
% .swd   - SPM working directory - directory containing current SPM.mat
% .Z     - minimum of n Statistics {filtered on u and k}
% .n     - number of conjoint tests
% .STAT  - distribution {Z, T, X or F}
% .df    - degrees of freedom [df{interest}, df{residual}]
% .u     - height threshold
% .k     - extent threshold {voxels}
% .XYZ   - location of voxels {voxel coords}
% .XYZmm - location of voxels {mm}
% .S     - search Volume {voxels}
% .R     - search Volume {resels}
% .FWHM  - smoothness {voxels}
% .M     - voxels - > mm matrix
% .VOX   - voxel dimensions {mm}
% .Vspm  - mapped statistic image(s)
% .Ps    - uncorrected P values in searched volume (for FDR)
%
% (see spm_getSPM for further details of xSPM structures)
%
% hReg   - Handle of results section XYZ registry (see spm_results_ui.m)
%
% Num    - number of maxima per cluster
% Dis    - distance among clusters (mm)
% Str    - header string
%
% TabDat - Structure containing table data
%        - fields are
% .tit   - table Title (string)
% .hdr   - table header (2x11 cell array)
% .fmt   - fprintf format strings for table data (1x11 cell array)
% .str   - table filtering note (string)
% .ftr   - table footnote information (4x2 cell array)
% .dat   - table data (Nx11 cell array)
%
%                           ----------------
%
% FORMAT spm_list('TxtList',TabDat,c)
% Prints a tab-delimited text version of the table
% TabDat - Structure containing table data (format as above)
% c      - Column of table data to start text table at
%          (E.g. c=3 doesn't print set-level results contained in columns 1 & 2)
%                           ----------------
%
% FORMAT spm_list('SetCoords',xyz,hAx,hC)
% Highlighting of table co-ordinates (used by results section registry)
% xyz    - 3-vector of new co-ordinate
% hAx    - table axis (the registry object for tables)
% hReg   - Handle of caller (not used)
%_______________________________________________________________________
%
% spm_list characterizes SPMs (thresholded at u and k) in terms of
% excursion sets (a collection of face, edge and vertex connected
% subsets or clusters).  The currected significance of the results are
% based on set, cluster and voxel-level inferences using distributional
% approximations from the Theory of Gaussian Fields.  These
% distributions assume that the SPM is a reasonable lattice
% approximation of a continuous random field with known component field
% smoothness.
%
% The p values are based on the probability of obtaining c, or more,
% clusters of k, or more, resels above u, in the volume S analysed =
% P(u,k,c).  For specified thresholds u, k, the set-level inference is
% based on the observed number of clusters C, = P(u,k,C).  For each
% cluster of size K the cluster-level inference is based on P(u,K,1)
% and for each voxel (or selected maxima) of height U, in that cluster,
% the voxel-level inference is based on P(U,0,1).  All three levels of
% inference are supported with a tabular presentation of the p values
% and the underlying statistic:
%
% Set-level     - c    = number of suprathreshold clusters
%               - P    = prob(c or more clusters in the search volume)
%
% Cluster-level - k    = number of voxels in this cluster
%               - Pc   = prob(k or more voxels in the search volume)
%               - Pu   = prob(k or more voxels in a cluster)
%
% Voxel-level   - T/F  = Statistic upon which the SPM is based
%               - Ze   = The eqivalent Z score - prob(Z > Ze) = prob(t > T)
%               - Pc   = prob(Ze or higher in the search volume)
%               - Qu   = Expd(Prop of false positives among voxels >= Ze)
%               - Pu   = prob(Ze or higher at that voxel)
%
% x,y,z (mm)    - Coordinates of the voxel
%
% The table is grouped by regions and sorted on the Ze-variate of the
% primary maxima.  Ze-variates (based on the uncorrected p value) are the
% Z score equivalent of the statistic. Volumes are expressed in voxels.
%
% Clicking on values in the table returns the value to the Matlab
% workspace. In addition, clicking on the co-ordinates jumps the
% results section cursor to that location. The table has a context menu
% (obtained by right-clicking in the background of the table),
% providing options to print the current table as a text table, or to
% extract the table data to the Matlab workspace.
%
%_______________________________________________________________________
% @(#)spm_list.m    2.43 Karl Friston, Andrew Holmes 02/10/31


% satellite figure global variable
%-----------------------------------------------------------------------
global SatWindow

%=======================================================================
switch lower(varargin{1}), case 'list'                            %-List
    %=======================================================================
    % FORMAT TabDat = spm_list('list',SPM,hReg)

    %-Tolerance for p-value underflow, when computing equivalent Z's
    %-----------------------------------------------------------------------
    tol = eps*10;

    %-Parse arguments and set maxima number and separation
    %-----------------------------------------------------------------------
    if nargin < 2,    error('insufficient arguments'),     end
    if nargin < 3,    hReg = []; else, hReg = varargin{3}; end


    %-Get current location (to highlight selected voxel in table)
    %-----------------------------------------------------------------------
    %xyzmm     = spm_results_ui('GetCoords');
    xyzmm = [0 0 0]';

    %-Extract data from xSPM
    %-----------------------------------------------------------------------
    S     = varargin{2}.S;
    R     = varargin{2}.R;
    FWHM  = varargin{2}.FWHM;
    VOX   = varargin{2}.VOX;
    n     = varargin{2}.n;
    STAT  = varargin{2}.STAT;
    df    = varargin{2}.df;
    u     = varargin{2}.u;
    M     = varargin{2}.M;
    v2r   = 1/prod(FWHM(~isinf(FWHM)));            %-voxels to resels
    k     = varargin{2}.k*v2r;
    QPs   = varargin{2}.Ps;                    % Needed for FDR
    QPs   = sort(QPs(:));

    %-get number and separation for maxima to be reported
    %-----------------------------------------------------------------------
    if length(varargin) > 3

        Num    = varargin{4};        % number of maxima per cluster
        Dis    = varargin{5};        % distance among clusters (mm)
    else
        Num    = 3;
        Dis    = 8;
    end
    if length(varargin) > 5

        Title  = varargin{6};
    else
        Title  = 'p-values adjusted for search volume';
    end


    %-Setup graphics panel
    %-----------------------------------------------------------------------
    spm('Pointer','Watch')
    if SatWindow
        Fgraph = SatWindow;
        figure(Fgraph);
    else
        Fgraph = figure('unit','normalized','position',[0.5,0.1,0.55,0.5],'Color','w',...
            'Name','volume', 'NumberTitle','off','resize','off','MenuBar','none');
        Fgraph = gcf;
    end
    %spm_results_ui('Clear',Fgraph)
    FS    = spm('FontSizes');            %-Scaled font sizes
    PF    = spm_platform('fonts');            %-Font names (for this platform)


    %-Table header & footer
    %=======================================================================

    %-Table axes & Title
    %----------------------------------------------------------------------
    if SatWindow, ht = 0.85; bot = .14; else, ht = 0.8; bot = 0.15; end;

    if STAT == 'P'
        Title = 'Posterior Probabilities';
    end

    hAx   = axes('Position',[0.025 bot 0.9 ht],...
        'DefaultTextFontSize',FS(8),...
        'DefaultTextInterpreter','Tex',...
        'DefaultTextVerticalAlignment','Baseline',...
        'Units','points',...
        'Visible','off');

    AxPos = get(hAx,'Position'); set(hAx,'YLim',[0,AxPos(4)])
    dy    = FS(9);
    y     = floor(AxPos(4)) - dy;

    text(0,y,['Statistics:  \it\fontsize{',num2str(FS(9)),'}',Title],...
        'FontSize',FS(11),'FontWeight','Bold');    y = y - dy/2;
    line([0 1],[y y],'LineWidth',3,'Color','r'),    y = y - 9*dy/8;


    %-Construct table header
    %-----------------------------------------------------------------------
    set(gca,'DefaultTextFontName',PF.helvetica,'DefaultTextFontSize',FS(8))

    Hc = [];
    Hp = [];
    h  = text(0.01,y,    'set-level','FontSize',FS(9));        Hc = [Hc,h];
    h  = line([0,0.11],[1,1]*(y-dy/4),'LineWidth',0.5,'Color','r');    Hc = [Hc,h];
    h  = text(0.08,y-9*dy/8,    '\itc ');            Hc = [Hc,h];
    h  = text(0.02,y-9*dy/8,    '\itp ');            Hc = [Hc,h];
    Hp = [Hp,h];
    text(0.22,y,        'cluster-level','FontSize',FS(9));
    line([0.15,0.41],[1,1]*(y-dy/4),'LineWidth',0.5,'Color','r');
    h  = text(0.16,y-9*dy/8,    '\itp \rm_{corrected}');    Hp = [Hp,h];
    h  = text(0.33,y-9*dy/8,    '\itp \rm_{uncorrected}');    Hp = [Hp,h];
    h  = text(0.26,y-9*dy/8,    '\itk \rm_E');

    text(0.60,y,        'voxel-level','FontSize',FS(9));
    line([0.46,0.86],[1,1]*(y-dy/4),'LineWidth',0.5,'Color','r');
    h  = text(0.46,y-9*dy/8,    '\itp \rm_{FWE-corr}');        Hp = [Hp,h];
    h  = text(0.55,y-9*dy/8,        '\itp \rm_{FDR-corr}');        Hp = [Hp,h];
    h  = text(0.79,y-9*dy/8,    '\itp \rm_{uncorrected}');    Hp = [Hp,h];
    h  = text(0.64,y-9*dy/8,     sprintf('\\it%c',STAT));
    h  = text(0.72,y-9*dy/8,    '(\itZ\rm_\equiv)');

    text(0.93,y - dy/2,['x,y,z \fontsize{',num2str(FS(8)),'}\{mm\}']);


    %-Headers for text table...
    %-----------------------------------------------------------------------
    TabDat.tit = Title;
    TabDat.hdr = {    'set',        'c';...
        'set',        'p';...
        'cluster',    'p(cor)';...
        'cluster',    'equivk';...
        'cluster',    'p(unc)';...
        'voxel',    'p(FWE-cor)';...
        'voxel',    'p(FDR-cor)';...
        'voxel',     STAT;...
        'voxel',    'equivZ';...
        'voxel',    'p(unc)';...
        '',        'x,y,z {mm}'}';...

    TabDat.fmt = {    '%-0.3f','%g',...                %-Set
        '%0.3f', '%0.0f', '%0.3f',...            %-Cluster
        '%0.3f', '%0.3f', '%6.2f', '%5.2f', '%0.3f',...    %-Voxel
        '%3.0f %3.0f %3.0f'};                %-XYZ

    %-Column Locations
    %-----------------------------------------------------------------------
    tCol       = [  0.00      0.07 ...                %-Set
        0.16      0.26      0.34 ...            %-Cluster
        0.46      0.55      0.62      0.71      0.80 ...%-Voxel
        0.92];                        %-XYZ

    % move to next vertial postion marker
    %-----------------------------------------------------------------------
    y     = y - 7*dy/4;
    line([0 1],[y y],'LineWidth',1,'Color','r')
    y     = y - 5*dy/4;
    y0    = y;


    %-Table filtering note
    %-----------------------------------------------------------------------
    if isinf(Num)
        TabDat.str = sprintf('table shows all local maxima > %.1fmm apart',Dis);
    else
        TabDat.str = sprintf(['table shows %d local maxima ',...
            'more than %.1fmm apart'],Num,Dis);
    end
    text(0.5,4,TabDat.str,'HorizontalAlignment','Center','FontName',PF.helvetica,...
        'FontSize',FS(8),'FontAngle','Italic')


    %-Volume, resels and smoothness (if classical inference)
    %-----------------------------------------------------------------------
    line([0 1],[0 0],'LineWidth',1,'Color','r')
    if STAT ~= 'P'
        %-----------------------------------------------------------------------
        FWHMmm          = FWHM.*VOX;                 % FWHM {mm}
        Pz              = spm_P(1,0,u,df,STAT,1,n,S);
        Pu              = spm_P(1,0,u,df,STAT,R,n,S);
        Qu              = spm_P_FDR(u,df,STAT,n,QPs);
        [P Pn Em En EN] = spm_P(1,k,u,df,STAT,R,n,S);


        %-Footnote with SPM parameters
        %-----------------------------------------------------------------------
        set(gca,'DefaultTextFontName',PF.helvetica,...
            'DefaultTextInterpreter','None','DefaultTextFontSize',FS(8))
        TabDat.ftr    = cell(5,2);
        TabDat.ftr{1} = ...
            sprintf('Height threshold: %c = %0.2f, p = %0.3f (%0.3f)',...
            STAT,u,Pz,Pu);
        TabDat.ftr{2} = ...
            sprintf('Extent threshold: k = %0.0f voxels, p = %0.3f (%0.3f)',...
            k/v2r,Pn,P);
        TabDat.ftr{3} = ...
            sprintf('Expected voxels per cluster, <k> = %0.3f',En/v2r);
        TabDat.ftr{4} = ...
            sprintf('Expected number of clusters, <c> = %0.2f',Em*Pn);
        TabDat.ftr{5} = ...
            sprintf('Expected false discovery rate, <= %0.2f',Qu);
        TabDat.ftr{6} = ...
            sprintf('Degrees of freedom = [%0.1f, %0.1f]',df);
        TabDat.ftr{7} = ...
            sprintf(['Smoothness FWHM = %0.1f %0.1f %0.1f {mm} ',...
            ' = %0.1f %0.1f %0.1f {voxels}'],FWHMmm,FWHM);
        TabDat.ftr{8} = ...
            sprintf('Search vol: %0.0f cmm; %0.0f voxels; %0.1f resels',S*prod(VOX),S,R(end));
        TabDat.ftr{9} = ...
            sprintf(['Voxel size: [%0.1f, %0.1f, %0.1f] mm ',...
            ' (1 resel = %0.2f voxels)'],VOX,prod(FWHM));

        text(0.0,-1*dy,TabDat.ftr{1},...
            'UserData',[u,Pz,Pu,Qu],'ButtonDownFcn','get(gcbo,''UserData'')')
        text(0.0,-2*dy,TabDat.ftr{2},...
            'UserData',[k/v2r,Pn,P],'ButtonDownFcn','get(gcbo,''UserData'')')
        text(0.0,-3*dy,TabDat.ftr{3},...
            'UserData',En/v2r,'ButtonDownFcn','get(gcbo,''UserData'')')
        text(0.0,-4*dy,TabDat.ftr{4},...
            'UserData',Em*Pn,'ButtonDownFcn','get(gcbo,''UserData'')')
        text(0.0,-5*dy,TabDat.ftr{5},...
            'UserData',Qu,'ButtonDownFcn','get(gcbo,''UserData'')')
        text(0.5,-1*dy,TabDat.ftr{6},...
            'UserData',df,'ButtonDownFcn','get(gcbo,''UserData'')')
        text(0.5,-2*dy,TabDat.ftr{7},...
            'UserData',FWHMmm,'ButtonDownFcn','get(gcbo,''UserData'')')
        text(0.5,-3*dy,TabDat.ftr{8},...
            'UserData',[S*prod(VOX),S,R(end)],...
            'ButtonDownFcn','get(gcbo,''UserData'')')
        text(0.5,-4*dy,TabDat.ftr{9},...
            'UserData',[VOX,prod(FWHM)],...
            'ButtonDownFcn','get(gcbo,''UserData'')')

    end % Classical


    %-Characterize excursion set in terms of maxima
    % (sorted on Z values and grouped by regions)
    %=======================================================================
    if ~length(varargin{2}.Z)
        text(0.5,y-6*dy,'no suprathreshold clusters',...
            'HorizontalAlignment','Center',...
            'FontAngle','Italic','FontWeight','Bold',...
            'FontSize',FS(16),'Color',[1,1,1]*.5);
        TabDat.dat = cell(0,11);
        varargout  = {TabDat};
        spm('Pointer','Arrow')
        return
    end

    % Includes Darren Gitelman's code for working around
    % spm_max for conjunctions with negative thresholds
    %-----------------------------------------------------------------------
    minz        = abs(min(min(varargin{2}.Z)));
    zscores     = 1 + minz + varargin{2}.Z;
    [N Z XYZ A] = spm_max(zscores,varargin{2}.XYZ);
    Z           = Z - minz - 1;

    %-Convert cluster sizes from voxels to resels
    %-----------------------------------------------------------------------
    if isfield(varargin{2},'VRvp')
        V2R = spm_get_data(varargin{2}.VRvp,XYZ);
    else
        V2R = v2r;
    end
    N           = N.*V2R;

    %-Convert maxima locations from voxels to mm
    %-----------------------------------------------------------------------
    XYZmm = M(1:3,:)*[XYZ; ones(1,size(XYZ,2))];



    %-Table proper (& note all data in cell array)
    %=======================================================================

    %-Pagination variables
    %-----------------------------------------------------------------------
    hPage = [];
    set(gca,'DefaultTextFontName',PF.courier,'DefaultTextFontSize',FS(7))


    %-Set-level p values {c} - do not display if reporting a single cluster
    %-----------------------------------------------------------------------
    c     = max(A);                    %-Number of clusters
    if STAT ~= 'P'
        Pc    = spm_P(c,k,u,df,STAT,R,n,S);    %-Set-level p-value
    else
        Pc    = [];
        set(Hp,'Visible','off')
    end

    if c > 1;
        h     = text(tCol(1),y,sprintf(TabDat.fmt{1},Pc),'FontWeight','Bold',...
            'UserData',Pc,'ButtonDownFcn','get(gcbo,''UserData'')');
        hPage = [hPage, h];
        h     = text(tCol(2),y,sprintf(TabDat.fmt{2},c),'FontWeight','Bold',...
            'UserData',c,'ButtonDownFcn','get(gcbo,''UserData'')');
        hPage = [hPage, h];
    else
        set(Hc,'Visible','off')
    end

    TabDat.dat = {Pc,c};                %-Table data
    TabLin     = 1;                    %-Table data line


    %-Local maxima p-values & statistics
    %-----------------------------------------------------------------------
    HlistXYZ = [];
    while prod(size(find(finite(Z))))

        % Paginate if necessary
        %---------------------------------------------------------------
        if y < min(Num + 1,3)*dy

            % added Fgraph term to paginate on Satellite window
            %-------------------------------------------------------
            h     = text(0.5,-5*dy,...
                sprintf('Page %d',spm_figure('#page',Fgraph)),...
                'FontName',PF.helvetica,'FontAngle','Italic',...
                'FontSize',FS(8));

            spm_figure('NewPage',[hPage,h])
            hPage = [];
            y     = y0;
        end

        %-Find largest remaining local maximum
        %---------------------------------------------------------------
        [U,i]   = max(Z);            % largest maxima
        j       = find(A == A(i));        % maxima in cluster


        %-Compute cluster {k} and voxel-level {u} p values for this cluster
        %---------------------------------------------------------------
        Nv      = N(i)/v2r;            % extent        {voxels}


        if STAT ~= 'P'
            Pz      = spm_P(1,0,   U,df,STAT,1,n,S);% uncorrected p value
            Pu      = spm_P(1,0,   U,df,STAT,R,n,S);% FWE-corrected {based on Z)
            Qu      = spm_P_FDR(   U,df,STAT,n,QPs);% FDR-corrected {based on Z)
            [Pk Pn] = spm_P(1,N(i),u,df,STAT,R,n,S);% [un]corrected {based on k)

            if Pz < tol                % Equivalent Z-variate
                Ze  = Inf;                 % (underflow => can't compute)
            else
                Ze  = spm_invNcdf(1 - Pz);
            end
        else
            Pz    = [];
            Pu      = [];
            Qu      = [];
            Pk    = [];
            Pn    = [];
            Ze      = spm_invNcdf(U);
        end


        %-Print cluster and maximum voxel-level p values {Z}
        %---------------------------------------------------------------
        h     = text(tCol(3),y,sprintf(TabDat.fmt{3},Pk),'FontWeight','Bold',...
            'UserData',Pk,'ButtonDownFcn','get(gcbo,''UserData'')');
        hPage = [hPage, h];

        h     = text(tCol(4),y,sprintf(TabDat.fmt{4},Nv),'FontWeight','Bold',...
            'UserData',Nv,'ButtonDownFcn','get(gcbo,''UserData'')');
        hPage = [hPage, h];
        h     = text(tCol(5),y,sprintf(TabDat.fmt{5},Pn),'FontWeight','Bold',...
            'UserData',Pn,'ButtonDownFcn','get(gcbo,''UserData'')');
        hPage = [hPage, h];

        h     = text(tCol(6),y,sprintf(TabDat.fmt{6},Pu),'FontWeight','Bold',...
            'UserData',Pu,'ButtonDownFcn','get(gcbo,''UserData'')');
        hPage = [hPage, h];
        h     = text(tCol(7),y,sprintf(TabDat.fmt{7},Qu),'FontWeight','Bold',...
            'UserData',Qu,'ButtonDownFcn','get(gcbo,''UserData'')');
        hPage = [hPage, h];
        h     = text(tCol(8),y,sprintf(TabDat.fmt{8},U),'FontWeight','Bold',...
            'UserData',U,'ButtonDownFcn','get(gcbo,''UserData'')');
        hPage = [hPage, h];
        h     = text(tCol(9),y,sprintf(TabDat.fmt{9},Ze),'FontWeight','Bold',...
            'UserData',Ze,'ButtonDownFcn','get(gcbo,''UserData'')');
        hPage = [hPage, h];
        h     = ...
            text(tCol(10),y,sprintf(TabDat.fmt{10},Pz),'FontWeight','Bold',...
            'UserData',Pz,'ButtonDownFcn','get(gcbo,''UserData'')');
        hPage = [hPage, h];

        % Specifically changed so it properly finds hMIPax
        %---------------------------------------------------------------------
        h     = text(tCol(11),y,sprintf(TabDat.fmt{11},XYZmm(:,i)),...
            'FontWeight','Bold',...
            'Tag','ListXYZ',...
            'ButtonDownFcn',[...
            'hMIPax = findobj(''tag'',''hMIPax'');',...
            'spm_mip_ui(''SetCoords'',get(gcbo,''UserData''),hMIPax);'],...
            'Interruptible','off','BusyAction','Cancel',...
            'UserData',XYZmm(:,i));

        HlistXYZ = [HlistXYZ, h];
        if spm_XYZreg('Edist',xyzmm,XYZmm(:,i))<tol & ~isempty(hReg)
            set(h,'Color','r')
        end
        hPage  = [hPage, h];

        y      = y - dy;

        [TabDat.dat{TabLin,3:11}] = deal(Pk,Nv,Pn,Pu,Qu,U,Ze,Pz,XYZmm(:,i));
        TabLin = TabLin + 1;

        %-Print Num secondary maxima (> Dis mm apart)
        %---------------------------------------------------------------
        [l q] = sort(-Z(j));                % sort on Z value
        D     = i;
        for i = 1:length(q)
            d = j(q(i));
            if min(sqrt(sum((XYZmm(:,D)-XYZmm(:,d)*ones(1,size(D,2))).^2)))>Dis;

                if length(D) < Num

                    % Paginate if necessary
                    %-----------------------------------------------
                    if y < dy
                        h = text(0.5,-5*dy,sprintf('Page %d',...
                            spm_figure('#page',Fgraph)),...
                            'FontName',PF.helvetica,...
                            'FontAngle','Italic',...
                            'FontSize',FS(8));

                        spm_figure('NewPage',[hPage,h])
                        hPage = [];
                        y     = y0;
                    end

                    % voxel-level p values {Z}
                    %-----------------------------------------------
                    if STAT ~= 'P'
                        Pz    = spm_P(1,0,Z(d),df,STAT,1,n,S);
                        Pu    = spm_P(1,0,Z(d),df,STAT,R,n,S);
                        Qu    = spm_P_FDR(Z(d),df,STAT,n,QPs);
                        if Pz < tol
                            Ze = Inf;
                        else,   Ze = spm_invNcdf(1 - Pz); end
                    else
                        Pz    = [];
                        Pu    = [];
                        Qu    = [];
                        Ze    = spm_invNcdf(Z(d));
                    end

                    h     = text(tCol(6),y,sprintf(TabDat.fmt{6},Pu),...
                        'UserData',Pu,...
                        'ButtonDownFcn','get(gcbo,''UserData'')');
                    hPage = [hPage, h];

                    h     = text(tCol(7),y,sprintf(TabDat.fmt{7},Qu),...
                        'UserData',Qu,...
                        'ButtonDownFcn','get(gcbo,''UserData'')');
                    hPage = [hPage, h];
                    h     = text(tCol(8),y,sprintf(TabDat.fmt{8},Z(d)),...
                        'UserData',Z(d),...
                        'ButtonDownFcn','get(gcbo,''UserData'')');
                    hPage = [hPage, h];
                    h     = text(tCol(9),y,sprintf(TabDat.fmt{9},Ze),...
                        'UserData',Ze,...
                        'ButtonDownFcn','get(gcbo,''UserData'')');
                    hPage = [hPage, h];
                    h     = text(tCol(10),y,sprintf(TabDat.fmt{10},Pz),...
                        'UserData',Pz,...
                        'ButtonDownFcn','get(gcbo,''UserData'')');
                    hPage = [hPage, h];

                    % specifically modified line to use hMIPax
                    %-----------------------------------------------
                    h     = text(tCol(11),y,...
                        sprintf(TabDat.fmt{11},XYZmm(:,d)),...
                        'Tag','ListXYZ',...
                        'ButtonDownFcn',[...
                        'hMIPax = findobj(''tag'',''hMIPax'');',...
                        'spm_mip_ui(''SetCoords'',',...
                        'get(gcbo,''UserData''),hMIPax);'],...
                        'Interruptible','off','BusyAction','Cancel',...
                        'UserData',XYZmm(:,d));

                    HlistXYZ = [HlistXYZ, h];
                    if spm_XYZreg('Edist',xyzmm,XYZmm(:,d))<tol & ...
                            ~isempty(hReg)
                        set(h,'Color','r')
                    end
                    hPage = [hPage, h];
                    D     = [D d];
                    y     = y - dy;
                    [TabDat.dat{TabLin,6:11}] = ...
                        deal(Pu,Qu,Z(d),Ze,Pz,XYZmm(:,d));
                    TabLin = TabLin+1;
                end
            end
        end
        Z(j) = NaN;        % Set local maxima to NaN
    end                % end region


    %-Number and register last page (if paginated)
    %-Changed to use Fgraph for numbering
    %-----------------------------------------------------------------------
    if spm_figure('#page',Fgraph)>1
        h = text(0.5,-5*dy,sprintf('Page %d/%d',spm_figure('#page',Fgraph)*[1,1]),...
            'FontName',PF.helvetica,'FontSize',FS(8),'FontAngle','Italic');
        spm_figure('NewPage',[hPage,h])
    end

    %-End: Store TabDat in UserData of axes & reset pointer
    %=======================================================================
    h      = uicontextmenu('Tag','TabDat',...
        'UserData',TabDat);
    set(gca,'UIContextMenu',h,...
        'Visible','on',...
        'XColor','w','YColor','w')
    uimenu(h,'Label','Table')
    uimenu(h,'Separator','on','Label','Print text table',...
        'Tag','TD_TxtTab',...
        'CallBack',...
        'spm_list(''txtlist'',get(get(gcbo,''Parent''),''UserData''),3)',...
        'Interruptible','off','BusyAction','Cancel');
    uimenu(h,'Separator','off','Label','Extract table data structure',...
        'Tag','TD_Xdat',...
        'CallBack','get(get(gcbo,''Parent''),''UserData'')',...
        'Interruptible','off','BusyAction','Cancel');
    uimenu(h,'Separator','on','Label','help',...
        'Tag','TD_Xdat',...
        'CallBack','spm_help(''spm_list'')',...
        'Interruptible','off','BusyAction','Cancel');

    %-Setup registry
    %-----------------------------------------------------------------------
    set(hAx,'UserData',struct('hReg',hReg,'HlistXYZ',HlistXYZ))
    spm_XYZreg('Add2Reg',hReg,hAx,'spm_list');

    %-Return TabDat structure & reset pointer
    %-----------------------------------------------------------------------
    varargout = {TabDat};
    spm('Pointer','Arrow')





    %=======================================================================
    case 'listcluster'                       %-List for current cluster only
        %=======================================================================
        % FORMAT TabDat = spm_list('listcluster',SPM,hReg)

        spm('Pointer','Watch')

        %-Parse arguments
        %-----------------------------------------------------------------------
        if nargin < 2,    error('insufficient arguments'),     end
        if nargin < 3,    hReg = []; else, hReg = varargin{3}; end
        SPM    = varargin{2};

        %-get number and separation for maxima to be reported
        %-----------------------------------------------------------------------
        if length(varargin) > 3

            Num    = varargin{4};        % number of maxima per cluster
            Dis    = varargin{5};        % distance among clusters (mm)
        else
            Num    = 32;
            Dis    = 4;
        end


        %-if there are suprathreshold voxels, filter out all but current cluster
        %-----------------------------------------------------------------------
        if length(SPM.Z)

            %-Jump to voxel nearest current location
            %--------------------------------------------------------------
            [xyzmm,i] = spm_XYZreg('NearestXYZ',...
                spm_results_ui('GetCoords'),SPM.XYZmm);
            spm_results_ui('SetCoords',SPM.XYZmm(:,i));

            %-Find selected cluster
            %--------------------------------------------------------------
            A         = spm_clusters(SPM.XYZ);
            j         = find(A == A(i));
            SPM.Z     = SPM.Z(j);
            SPM.XYZ   = SPM.XYZ(:,j);
            SPM.XYZmm = SPM.XYZmm(:,j);
            if isfield(SPM,'Rd'), SPM.Rd = SPM.Rd(:,j); end
        end

        %-Call 'list' functionality to produce table
        %-----------------------------------------------------------------------
        varargout = {spm_list('list',SPM,hReg,Num,Dis)};





        %=======================================================================
    case 'txtlist'                                  %-Print ASCII text table
        %=======================================================================
        % FORMAT spm_list('TxtList',TabDat,c)

        if nargin<2, error('Insufficient arguments'), end
        if nargin<3, c=1; else, c=varargin{3}; end
        TabDat = varargin{2};

        %-Table Title
        %-----------------------------------------------------------------------
        fprintf('\n\nSTATISTICS: %s\n',TabDat.tit)
        fprintf('%c','='*ones(1,80)), fprintf('\n')

        %-Table header
        %-----------------------------------------------------------------------
        fprintf('%s\t',TabDat.hdr{1,c:end-1}), fprintf('%s\n',TabDat.hdr{1,end})
        fprintf('%s\t',TabDat.hdr{2,c:end-1}), fprintf('%s\n',TabDat.hdr{2,end})
        fprintf('%c','-'*ones(1,80)), fprintf('\n')

        %-Table data
        %-----------------------------------------------------------------------
        for i = 1:size(TabDat.dat,1)
            for j=c:size(TabDat.dat,2)
                fprintf(TabDat.fmt{j},TabDat.dat{i,j})
                fprintf('\t')
            end
            fprintf('\n')
        end
        for i=1:max(1,11-size(TabDat.dat,1)), fprintf('\n'), end
        fprintf('%s\n',TabDat.str)
        fprintf('%c','-'*ones(1,80)), fprintf('\n')

        %-Table footer
        %-----------------------------------------------------------------------
        fprintf('%s\n',TabDat.ftr{:})
        fprintf('%c','='*ones(1,80)), fprintf('\n\n')



        %=======================================================================
    case 'setcoords'                                    %-Co-ordinate change
        %=======================================================================
        % FORMAT spm_list('SetCoords',xyz,hAx,hReg)
        if nargin<3, error('Insufficient arguments'), end
        hAx      = varargin{3};
        xyz      = varargin{2};
        UD       = get(hAx,'UserData');
        HlistXYZ = UD.HlistXYZ(ishandle(UD.HlistXYZ));

        %-Set all co-ord strings to black
        %-----------------------------------------------------------------------
        set(HlistXYZ,'Color','k')

        %-If co-ord matches a string, highlight it in red
        %-----------------------------------------------------------------------
        XYZ      = get(HlistXYZ,'UserData');
        if iscell(XYZ), XYZ = cat(2,XYZ{:}); end
        [null,i,d] = spm_XYZreg('NearestXYZ',xyz,XYZ);
        if d<eps
            set(HlistXYZ(i),'Color','r')
        end


        %=======================================================================
    otherwise                                        %-Unknown action string
        %=======================================================================
        error('Unknown action string')


        %=======================================================================
end
%=======================================================================



function []=setcolormap(what)

switch lower(what), case 'gray'
    colormap(gray(64))
    case 'hot'
        colormap(hot(64))
    case 'pink'
        colormap(pink(64))
    case 'gray-hot'
        tmp = hot(64 + 16);  tmp = tmp([1:64] + 16,:);
        colormap([gray(64); tmp])
    case 'gray-cold'
        tmp = jet(64 + 48);  tmp = tmp([1:64] + 16,:);
        colormap([gray(64); tmp])
    case 'gray-hot-cold'
        tmp = jet(64 + 16);  tmp = tmp([1:64] + 16,:);
        colormap([gray(64); tmp])
    case 'gray-pink'
        tmp = pink(64 + 16); tmp = tmp([1:64] + 16,:);
        colormap([gray(64); tmp])
    case 'invert'
        colormap(flipud(colormap))
    case 'brighten'
        colormap(brighten(colormap, 0.2))
    case 'darken'
        colormap(brighten(colormap, -0.2))
    otherwise
        error('Illegal ColAction specification')
end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% spm_orthviews
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = spm_orthviews(action,varargin)
% Display Orthogonal Views of a Normalized Image
% FORMAT H = spm_orthviews('Image',filename[,position])
% filename - name of image to display
% area     - position of image
%            -  area(1) - position x
%            -  area(2) - position y
%            -  area(3) - size x
%            -  area(4) - size y
% H        - handle for ortho sections
% FORMAT spm_orthviews('BB',bb)
% bb       - bounding box
%            [loX loY loZ
%             hiX hiY hiZ]
%
% FORMAT spm_orthviews('Redraw')
% Redraws the images
%
% FORMAT spm_orthviews('Reposition',centre)
% centre   - X, Y & Z coordinates of centre voxel
%
% FORMAT spm_orthviews('Space'[,handle])
% handle   - the view to define the space by
% with no arguments - puts things into mm space
%
% FORMAT spm_orthviews('MaxBB')
% sets the bounding box big enough display the whole of all images
%
% FORMAT spm_orthviews('Resolution',res)
% res      - resolution (mm)
%
% FORMAT spm_orthviews('Delete', handle)
% handle   - image number to delete
%
% FORMAT spm_orthviews('Reset')
% clears the orthogonal views
%
% FORMAT spm_orthviews('Pos')
% returns the co-ordinate of the crosshairs in millimetres in the
% standard space.
%
% FORMAT spm_orthviews('Pos', i)
% returns the voxel co-ordinate of the crosshairs in the image in the
% ith orthogonal section.
%
% FORMAT spm_orthviews('Xhairs','off') OR spm_orthviews('Xhairs')
% disables the cross-hairs on the display.
%
% FORMAT spm_orthviews('Xhairs','on')
% enables the cross-hairs.
%
% FORMAT spm_orthviews('Interp',hld)
% sets the hold value to hld (see spm_slice_vol).
%
% FORMAT spm_orthviews('AddBlobs',handle,XYZ,Z,mat)
% Adds blobs from a pointlist to the image specified by the handle(s).
% handle   - image number to add blobs to
% XYZ      - blob voxel locations (currently in millimeters)
% Z        - blob voxel intensities
% mat      - matrix from millimeters to voxels of blob.
% This method only adds one set of blobs, and displays them using a
% split colour table.
%
% FORMAT spm_orthviews('AddColouredBlobs',handle,XYZ,Z,mat,colour)
% Adds blobs from a pointlist to the image specified by the handle(s).
% handle   - image number to add blobs to
% XYZ      - blob voxel locations (currently in millimeters)
% Z        - blob voxel intensities
% mat      - matrix from millimeters to voxels of blob.
% colour   - the 3 vector containing the colour that the blobs should be
% Several sets of blobs can be added in this way, and it uses full colour.
% Although it may not be particularly attractive on the screen, the colour
% blobs print well.
%
% FORMAT spm_orthviews('AddColourBar',handle,blobno)
% Adds colourbar for a specified blob set
% handle   - image number
% blobno   - blob number
%
% FORMAT spm_orthviews('Register',hReg)
% See spm_XYZreg for more information.
%
% FORMAT spm_orthviews('RemoveBlobs',handle)
% Removes all blobs from the image specified by the handle(s).
%
% spm_orthviews('Register',hReg)
% hReg      - Handle of HandleGraphics object to build registry in.
% See spm_XYZreg for more information.
%
% spm_orthviews('AddContext',handle)
% handle   - image number to add context menu to
%
% spm_orthviews('RemoveContext',handle)
% handle   - image number to remove context menu from
%
% CONTEXT MENU
% spm_orthviews offers many of its features in a context menu, which is
% accessible via the right mouse button in each displayed image.
%
% PLUGINS
% The display capabilities of spm_orthviews can be extended with
% plugins. These are located in the spm_orthviews subdirectory of the SPM
% distribution. Currently there are 3 plugins available:
% quiver    Add Quiver plots to a displayed image
% quiver3d  Add 3D Quiver plots to a displayed image
% roi       ROI creation and modification
% The functionality of plugins can be accessed via calls to
% spm_orthviews('plugin_name', plugin_arguments). For detailed descriptions
% of each plugin see help spm_orthviews/spm_ov_'plugin_name'.
%
%_______________________________________________________________________
% Copyright (C) 2005 Wellcome Department of Imaging Neuroscience

% John Ashburner, Matthew Brett, Tom Nichols and Volkmar Glauche
% $Id: spm_orthviews.m 601 2006-08-22 08:34:24Z volkmar $



% The basic fields of st are:
%         n        - the number of images currently being displayed
%         vols     - a cell array containing the data on each of the
%                    displayed images.
%         Space    - a mapping between the displayed images and the
%                    mm space of each image.
%         bb       - the bounding box of the displayed images.
%         centre   - the current centre of the orthogonal views
%         callback - a callback to be evaluated on a button-click.
%         xhairs   - crosshairs off/on
%         hld      - the interpolation method
%         fig      - the figure that everything is displayed in
%         mode     - the position/orientation of the sagittal view.
%                    - currently always 1
%
%         st.registry.hReg \_ See spm_XYZreg for documentation
%         st.registry.hMe  /
%
% For each of the displayed images, there is a non-empty entry in the
% vols cell array.  Handles returned by "spm_orthviews('Image',.....)"
% indicate the position in the cell array of the newly created ortho-view.
% Operations on each ortho-view require the handle to be passed.
%
% When a new image is displayed, the cell entry contains the information
% returned by spm_vol (type help spm_vol for more info).  In addition,
% there are a few other fields, some of which I will document here:
%
%         premul - a matrix to premultiply the .mat field by.  Useful
%                  for re-orienting images.
%         window - either 'auto' or an intensity range to display the
%                  image with.
%         mapping- Mapping of image intensities to grey values. Currently
%                  one of 'linear', 'histeq', loghisteq',
%                  'quadhisteq'. Default is 'linear'.
%                  Histogram equalisation depends on the image toolbox
%                  and is only available if there is a license available
%                  for it.
%         ax     - a cell array containing an element for the three
%                  views.  The fields of each element are handles for
%                  the axis, image and crosshairs.
%
%         blobs - optional.  Is there for using to superimpose blobs.
%                 vol     - 3D array of image data
%                 mat     - a mapping from vox-to-mm (see spm_vol, or
%                           help on image formats).
%                 max     - maximum intensity for scaling to.  If it
%                           does not exist, then images are auto-scaled.
%
%                 There are two colouring modes: full colour, and split
%                 colour.  When using full colour, there should be a
%                 'colour' field for each cell element.  When using
%                 split colourscale, there is a handle for the colorbar
%                 axis.
%
%                 colour  - if it exists it contains the
%                           red,green,blue that the blobs should be
%                           displayed in.
%                 cbar    - handle for colorbar (for split colourscale).
%
% PLUGINS
% The plugin concept has been developed to extend the display capabilities
% of spm_orthviews without the need to rewrite parts of it. Interaction
% between spm_orthviews and plugins takes place
% a) at startup: The subfunction 'reset_st' looks for files with a name
%                spm_ov_PLUGINNAME.m in the directory 'SWD/spm_orthviews'.
%                For each such file, PLUGINNAME will be added to the list
%                st.plugins{:}.
%                The subfunction 'add_context' calls each plugin with
%                feval(['spm_ov_', st.plugins{k}], ...
%              'context_menu', i, parent_menu)
%                Each plugin may add its own submenu to the context
%                menu.
% b) at redraw:  After images and blobs of st.vols{i} are drawn, the
%                struct st.vols{i} is checked for field names that occur in
%                the plugin list st.plugins{:}. For each matching entry, the
%                corresponding plugin is called with the command 'redraw':
%                feval(['spm_ov_', st.plugins{k}], ...
%              'redraw', i, TM0, TD, CM0, CD, SM0, SD);
%                The values of TM0, TD, CM0, CD, SM0, SD are defined in the
%                same way as in the redraw subfunction of spm_orthviews.
%                It is up to the plugin to do all necessary redraw
%                operations for its display contents. Each displayed item
%                must have set its property 'HitTest' to 'off' to let events
%                go through to the underlying axis, which is responsible for
%                callback handling. The order in which plugins are called is
%                undefined.

global st;

if isempty(st), reset_st; end;

spm('Pointer','watch');

if nargin == 0, action = ''; end;
action = lower(action);

switch lower(action),
    case 'image',
        H = specify_image(varargin{1});
        if ~isempty(H)
            st.vols{H}.area = [0 0 1 1];
            if length(varargin)>=2, st.vols{H}.area = varargin{2}; end;
            if isempty(st.bb), st.bb = maxbb; end;
            bbox;
            cm_pos;
        end;
        varargout{1} = H;
        st.centre    = mean(maxbb);
        redraw_all

    case 'bb',
        if length(varargin)> 0 & all(size(varargin{1})==[2 3]), st.bb = varargin{1}; end;
        bbox;
        redraw_all;

    case 'redraw',
        redraw_all;
        eval(st.callback);
        if isfield(st,'registry'),
            spm_XYZreg('SetCoords',st.centre,st.registry.hReg,st.registry.hMe);
        end;

    case 'reposition',
        if length(varargin)<1, tmp = findcent;
        else, tmp = varargin{1}; end;
        if length(tmp)==3
            h = valid_handles(st.snap);
            if ~isempty(h)
                tmp=st.vols{h(1)}.mat*...
                    round(inv(st.vols{h(1)}.mat)*[tmp; ...
                    1]);
            end;
            st.centre = tmp(1:3);
        end;
        redraw_all;
        eval(st.callback);
        if isfield(st,'registry'),
            spm_XYZreg('SetCoords',st.centre,st.registry.hReg,st.registry.hMe);
        end;
        cm_pos;

    case 'setcoords',
        st.centre = varargin{1};
        st.centre = st.centre(:);
        redraw_all;
        eval(st.callback);
        cm_pos;

    case 'space',
        if length(varargin)<1,
            st.Space = eye(4);
            st.bb = maxbb;
            bbox;
            redraw_all;
        else,
            space(varargin{1});
            bbox;
            redraw_all;
        end;

    case 'maxbb',
        st.bb = maxbb;
        bbox;
        redraw_all;

    case 'resolution',
        resolution(varargin{1});
        bbox;
        redraw_all;

    case 'window',
        if length(varargin)<2,
            win = 'auto';
        elseif length(varargin{2})==2,
            win = varargin{2};
        end;
        for i=valid_handles(varargin{1}),
            st.vols{i}.window = win;
        end;
        redraw(varargin{1});

    case 'delete',
        my_delete(varargin{1});

    case 'move',
        move(varargin{1},varargin{2});
        % redraw_all;

    case 'reset',
        my_reset;

    case 'pos',
        if isempty(varargin),
            H = st.centre(:);
        else,
            H = pos(varargin{1});
        end;
        varargout{1} = H;

    case 'interp',
        st.hld = varargin{1};
        redraw_all;

    case 'xhairs',
        xhairs(varargin{1});

    case 'register',
        register(varargin{1});

    case 'addblobs',
        addblobs(varargin{1}, varargin{2},varargin{3},varargin{4});
        % redraw(varargin{1});

    case 'addcolouredblobs',
        addcolouredblobs(varargin{1}, varargin{2},varargin{3},varargin{4},varargin{5});
        % redraw(varargin{1});

    case 'addimage',
        addimage(varargin{1}, varargin{2});
        % redraw(varargin{1});

    case 'addcolouredimage',
        addcolouredimage(varargin{1}, varargin{2},varargin{3});
        % redraw(varargin{1});

    case 'addtruecolourimage',
        % spm_orthviews('Addtruecolourimage',handle,filename,colourmap,prop,mx,mn)
        % Adds blobs from an image in true colour
        % handle   - image number to add blobs to [default 1]
        % filename of image containing blob data [default - request via GUI]
        % colourmap - colormap to display blobs in [GUI input]
        % prop - intensity proportion of activation cf grayscale [0.4]
        % mx   - maximum intensity to scale to [maximum value in activation image]
        % mn   - minimum intensity to scale to [minimum value in activation image]
        %
        if nargin < 2
            varargin(1) = {1};
        end
        if nargin < 3
            varargin(2) = {spm_select(1, 'image', 'Image with activation signal')};
        end
        if nargin < 4
            actc = [];
            while isempty(actc)
                actc = getcmap(spm_input('Colourmap for activation image', '+1','s'));
            end
            varargin(3) = {actc};
        end
        if nargin < 5
            varargin(4) = {0.4};
        end
        if nargin < 6
            actv = spm_vol(varargin{2});
            varargin(5) = {max([eps maxval(actv)])};
        end
        if nargin < 7
            varargin(6) = {min([0 minval(actv)])};
        end

        addtruecolourimage(varargin{1}, varargin{2},varargin{3}, varargin{4}, ...
            varargin{5}, varargin{6});
        % redraw(varargin{1});

    case 'addcolourbar',
        addcolourbar(varargin{1}, varargin{2});

    case 'rmblobs',
        rmblobs(varargin{1});
        % redraw(varargin{1});

    case 'addcontext',
        if nargin == 1,
            handles = 1:24;
        else,
            handles = varargin{1};
        end;
        addcontexts(handles);

    case 'rmcontext',
        if nargin == 1,
            handles = 1:24;
        else,
            handles = varargin{1};
        end;
        rmcontexts(handles);

    case 'context_menu',
        c_menu(varargin{:});

    case 'valid_handles',
        if nargin == 1
            handles = 1:24;
        else,
            handles = varargin{1};
        end;
        varargout{1} = valid_handles(handles);

    otherwise,
        addonaction = strcmp(st.plugins,action);
        if any(addonaction)
            feval(['spm_ov_' st.plugins{addonaction}],varargin{:});
        else
            warning('Unknown action string')
        end;
end;

spm('Pointer');
return;


%_______________________________________________________________________
%_______________________________________________________________________
function addblobs(handle, xyz, t, mat)
global st
global TMAX_
for i=valid_handles(handle),
    if ~isempty(xyz),
        rcp      = round(xyz);
        dim      = max(rcp,[],2)';
        off      = rcp(1,:) + dim(1)*(rcp(2,:)-1 + dim(2)*(rcp(3,:)-1));
        vol      = zeros(dim)+NaN;
        vol(off) = t;
        vol      = reshape(vol,dim);
        st.vols{i}.blobs=cell(1,1);
        if st.mode == 0,
            axpos = get(st.vols{i}.ax{2}.ax,'Position');
        else,
            axpos = get(st.vols{i}.ax{1}.ax,'Position');
        end;
        mx = max([eps max(t)]);
        mn = min([0 min(t)]);
        if ~strcmp(TMAX_, 'auto')
            mx = str2num(TMAX_);
        end
        %KND:
        if numel(mx)==2
            mn=mx(1);
            mx=mx(2);
        end
        st.vols{i}.blobs{1} = struct('vol',vol,'mat',mat,'max',mx, 'min',mn);
        addcolourbar(handle,1);
    end;
end;
return;
%_______________________________________________________________________
%_______________________________________________________________________
function addimage(handle, fname)
global st
for i=valid_handles(handle),
    if isstruct(fname),
        vol = fname(1);
    else,
        vol = spm_vol(fname);
    end;
    mat = vol.mat;
    st.vols{i}.blobs=cell(1,1);
    mx = max([eps maxval(vol)]);
    mn = min([0 minval(vol)]);
    st.vols{i}.blobs{1} = struct('vol',vol,'mat',mat,'max',mx,'min',mn);
    addcolourbar(handle,1);
end;
return;
%_______________________________________________________________________
%_______________________________________________________________________
function addcolouredblobs(handle, xyz, t, mat,colour)
global st
for i=valid_handles(handle),
    if ~isempty(xyz),
        rcp      = round(xyz);
        dim      = max(rcp,[],2)';
        off      = rcp(1,:) + dim(1)*(rcp(2,:)-1 + dim(2)*(rcp(3,:)-1));
        vol      = zeros(dim)+NaN;
        vol(off) = t;
        vol      = reshape(vol,dim);
        if ~isfield(st.vols{i},'blobs'),
            st.vols{i}.blobs=cell(1,1);
            bset = 1;
        else,
            bset = length(st.vols{i}.blobs)+1;
        end;
        mx = max([eps maxval(vol)]);
        mn = min([0 minval(vol)]);
        st.vols{i}.blobs{bset} = struct('vol',vol,'mat',mat,'max',mx,'min',mn,'colour',colour);
    end;
end;
return;
%_______________________________________________________________________
%_______________________________________________________________________
function addcolouredimage(handle, fname,colour)
global st
for i=valid_handles(handle),
    if isstruct(fname),
        vol = fname(1);
    else,
        vol = spm_vol(fname);
    end;
    mat = vol.mat;
    if ~isfield(st.vols{i},'blobs'),
        st.vols{i}.blobs=cell(1,1);
        bset = 1;
    else,
        bset = length(st.vols{i}.blobs)+1;
    end;
    mx = max([eps maxval(vol)]);
    mn = min([0 minval(vol)]);
    st.vols{i}.blobs{bset} = struct('vol',vol,'mat',mat,'max',mx,'min',mn,'colour',colour);
end;
return;
%_______________________________________________________________________
%_______________________________________________________________________
function addtruecolourimage(handle,fname,colourmap,prop,mx,mn)
% adds true colour image to current displayed image
global st
for i=valid_handles(handle),
    if isstruct(fname),
        vol = fname(1);
    else,
        vol = spm_vol(fname);
    end;
    mat = vol.mat;
    if ~isfield(st.vols{i},'blobs'),
        st.vols{i}.blobs=cell(1,1);
        bset = 1;
    else,
        bset = length(st.vols{i}.blobs)+1;
    end;
    c = struct('cmap', colourmap,'prop',prop);
    st.vols{i}.blobs{bset} = struct('vol',vol,'mat',mat,'max',mx, ...
        'min',mn,'colour',c);
    addcolourbar(handle,bset);
end;
return;
%_______________________________________________________________________
%_______________________________________________________________________
function addcolourbar(vh,bh)
global st
if st.mode == 0,
    axpos = get(st.vols{vh}.ax{2}.ax,'Position');
else,
    axpos = get(st.vols{vh}.ax{1}.ax,'Position');
end;
st.vols{vh}.blobs{bh}.cbar = axes('Parent',st.fig,...
    'Position',[(axpos(1)+axpos(3)+0.05+(bh-1)*.1) (axpos(2)+0.005) 0.05 (axpos(4)-0.01)],...
    'Box','on', 'YDir','normal', 'XTickLabel',[], 'XTick',[]);
return;
%_______________________________________________________________________
%_______________________________________________________________________
function rmblobs(handle)
global st
for i=valid_handles(handle),
    if isfield(st.vols{i},'blobs'),
        for j=1:length(st.vols{i}.blobs),
            if isfield(st.vols{i}.blobs{j},'cbar') & ishandle(st.vols{i}.blobs{j}.cbar),
                delete(st.vols{i}.blobs{j}.cbar);
            end;
        end;
        st.vols{i} = rmfield(st.vols{i},'blobs');
    end;
end;
return;
%_______________________________________________________________________
%_______________________________________________________________________
function register(hreg)
global st
tmp = uicontrol('Position',[0 0 1 1],'Visible','off','Parent',st.fig);
h   = valid_handles(1:24);
if ~isempty(h),
    tmp = st.vols{h(1)}.ax{1}.ax;
    st.registry = struct('hReg',hreg,'hMe', tmp);
    spm_XYZreg('Add2Reg',st.registry.hReg,st.registry.hMe, 'spm_orthviews');
else,
    warning('Nothing to register with');
end;
st.centre = spm_XYZreg('GetCoords',st.registry.hReg);
st.centre = st.centre(:);
return;
%_______________________________________________________________________
%_______________________________________________________________________
function xhairs(arg1),
global st
st.xhairs = 0;
opt = 'on';
if ~strcmp(arg1,'on'),
    opt = 'off';
else,
    st.xhairs = 1;
end;
for i=valid_handles(1:24),
    for j=1:3,
        set(st.vols{i}.ax{j}.lx,'Visible',opt);
        set(st.vols{i}.ax{j}.ly,'Visible',opt);
    end;
end;
return;
%_______________________________________________________________________
%_______________________________________________________________________
function H = pos(arg1)
global st
H = [];
for arg1=valid_handles(arg1),
    is = inv(st.vols{arg1}.premul*st.vols{arg1}.mat);
    H = is(1:3,1:3)*st.centre(:) + is(1:3,4);
end;
return;
%_______________________________________________________________________
%_______________________________________________________________________
function my_reset
global st
if ~isempty(st) & isfield(st,'registry') & ishandle(st.registry.hMe),
    delete(st.registry.hMe); st = rmfield(st,'registry');
end;
my_delete(1:24);
reset_st;
return;
%_______________________________________________________________________
%_______________________________________________________________________
function my_delete(arg1)
global st
for i=valid_handles(arg1),
    kids = get(st.fig,'Children');
    for j=1:3,
        if any(kids == st.vols{i}.ax{j}.ax),
            set(get(st.vols{i}.ax{j}.ax,'Children'),'DeleteFcn','');
            delete(st.vols{i}.ax{j}.ax);
        end;
    end;
    st.vols{i} = [];
end;
return;
%_______________________________________________________________________
%_______________________________________________________________________
function resolution(arg1)
global st
res      = arg1/mean(svd(st.Space(1:3,1:3)));
Mat      = diag([res res res 1]);
st.Space = st.Space*Mat;
st.bb    = st.bb/res;
return;
%_______________________________________________________________________
%_______________________________________________________________________
function move(handle,pos)
global st
for handle = valid_handles(handle),
    st.vols{handle}.area = pos;
end;
bbox;
% redraw(valid_handles(handle));
return;
%_______________________________________________________________________
%_______________________________________________________________________
function bb = maxbb
global st
mn = [Inf Inf Inf];
mx = -mn;
for i=valid_handles(1:24),
    bb = [[1 1 1];st.vols{i}.dim(1:3)];
    c = [    bb(1,1) bb(1,2) bb(1,3) 1
        bb(1,1) bb(1,2) bb(2,3) 1
        bb(1,1) bb(2,2) bb(1,3) 1
        bb(1,1) bb(2,2) bb(2,3) 1
        bb(2,1) bb(1,2) bb(1,3) 1
        bb(2,1) bb(1,2) bb(2,3) 1
        bb(2,1) bb(2,2) bb(1,3) 1
        bb(2,1) bb(2,2) bb(2,3) 1]';
    tc = st.Space\(st.vols{i}.premul*st.vols{i}.mat)*c;
    tc = tc(1:3,:)';
    mx = max([tc ; mx]);
    mn = min([tc ; mn]);
end;
bb = [mn ; mx];
return;
%_______________________________________________________________________
%_______________________________________________________________________
function space(arg1)
global st
if ~isempty(st.vols{arg1})
    num = arg1;
    Mat = st.vols{num}.premul(1:3,1:3)*st.vols{num}.mat(1:3,1:3);
    vox = sqrt(sum(Mat.^2));
    if det(Mat(1:3,1:3))<0, vox(1) = -vox(1); end;
    Mat = diag([vox 1]);
    Space = (st.vols{num}.mat)/Mat;
    bb = [1 1 1;st.vols{num}.dim(1:3)];
    bb = [bb [1;1]];
    bb=bb*Mat';
    bb=bb(:,1:3);
    bb=sort(bb);
    st.Space  = Space;
    st.bb = bb;
end;
return;
%_______________________________________________________________________
%_______________________________________________________________________
function H = specify_image(arg1, arg2)
global st
H=[];
ok = 1;
if isstruct(arg1),
    V = arg1(1);
else,
    try,
        V = spm_vol(arg1);
    catch,
        fprintf('Can not use image "%s"\n', arg1);
        return;
    end;
end;

ii = 1;
while ~isempty(st.vols{ii}), ii = ii + 1; end;

DeleteFcn = ['spm_orthviews(''Delete'',' num2str(ii) ');'];
V.ax = cell(3,1);
for i=1:3,
    ax = axes('Visible','off','DrawMode','fast','Parent',st.fig,'DeleteFcn',DeleteFcn,...
        'YDir','normal','ButtonDownFcn',...
        ['if strcmp(get(gcf,''SelectionType''),''normal''),spm_orthviews(''Reposition'');',...
        'elseif strcmp(get(gcf,''SelectionType''),''extend''),spm_orthviews(''Reposition'');',...
        'spm_orthviews(''context_menu'',''ts'',1);end;']);
    d  = image(0,'Tag','Transverse','Parent',ax,...
        'DeleteFcn',DeleteFcn);
    set(ax,'Ydir','normal','ButtonDownFcn',...
        ['if strcmp(get(gcf,''SelectionType''),''normal''),spm_orthviews(''Reposition'');',...
        'elseif strcmp(get(gcf,''SelectionType''),''extend''),spm_orthviews(''reposition'');',...
        'spm_orthviews(''context_menu'',''ts'',1);end;']);

    lx = line(0,0,'Parent',ax,'DeleteFcn',DeleteFcn);
    ly = line(0,0,'Parent',ax,'DeleteFcn',DeleteFcn);
    if ~st.xhairs,
        set(lx,'Visible','off');
        set(ly,'Visible','off');
    end;
    V.ax{i} = struct('ax',ax,'d',d,'lx',lx,'ly',ly);
end;
V.premul    = eye(4);
V.window    = 'auto';
V.mapping   = 'linear';
st.vols{ii} = V;

H = ii;
return;
%_______________________________________________________________________
%_______________________________________________________________________
function addcontexts(handles)
global st
for ii = valid_handles(handles),
    cm_handle = addcontext(ii);
    for i=1:3,
        set(st.vols{ii}.ax{i}.ax,'UIcontextmenu',cm_handle);
        st.vols{ii}.ax{i}.cm = cm_handle;
    end;
end;
spm_orthviews('reposition',spm_orthviews('pos'));
return;
%_______________________________________________________________________
%_______________________________________________________________________
function rmcontexts(handles)
global st
for ii = valid_handles(handles),
    for i=1:3,
        set(st.vols{ii}.ax{i}.ax,'UIcontextmenu',[]);
        st.vols{ii}.ax{i} = rmfield(st.vols{ii}.ax{i},'cm');
    end;
end;
return;
%_______________________________________________________________________
%_______________________________________________________________________
function bbox
global st
Dims = diff(st.bb)'+1;

TD = Dims([1 2])';
CD = Dims([1 3])';
if st.mode == 0, SD = Dims([3 2])'; else, SD = Dims([2 3])'; end;

un    = get(st.fig,'Units');set(st.fig,'Units','Pixels');
sz    = get(st.fig,'Position');set(st.fig,'Units',un);
sz    = sz(3:4);
sz(2) = sz(2)-40;

for i=valid_handles(1:24),
    area = st.vols{i}.area(:);
    area = [area(1)*sz(1) area(2)*sz(2) area(3)*sz(1) area(4)*sz(2)];
    if st.mode == 0,
        sx   = area(3)/(Dims(1)+Dims(3))/1.02;
    else,
        sx   = area(3)/(Dims(1)+Dims(2))/1.02;
    end;
    sy   = area(4)/(Dims(2)+Dims(3))/1.02;
    s    = min([sx sy]);

    offy = (area(4)-(Dims(2)+Dims(3))*1.02*s)/2 + area(2);
    sky = s*(Dims(2)+Dims(3))*0.02;
    if st.mode == 0,
        offx = (area(3)-(Dims(1)+Dims(3))*1.02*s)/2 + area(1);
        skx = s*(Dims(1)+Dims(3))*0.02;
    else,
        offx = (area(3)-(Dims(1)+Dims(2))*1.02*s)/2 + area(1);
        skx = s*(Dims(1)+Dims(2))*0.02;
    end;

    DeleteFcn = ['spm_orthviews(''Delete'',' num2str(i) ');'];

    % Transverse
    set(st.vols{i}.ax{1}.ax,'Units','pixels', ...
        'Position',[offx offy s*Dims(1) s*Dims(2)],...
        'Units','normalized','Xlim',[0 TD(1)]+0.5,'Ylim',[0 TD(2)]+0.5,...
        'Visible','on','XTick',[],'YTick',[]);

    % Coronal
    set(st.vols{i}.ax{2}.ax,'Units','Pixels',...
        'Position',[offx offy+s*Dims(2)+sky s*Dims(1) s*Dims(3)],...
        'Units','normalized','Xlim',[0 CD(1)]+0.5,'Ylim',[0 CD(2)]+0.5,...
        'Visible','on','XTick',[],'YTick',[]);

    % Sagittal
    if st.mode == 0,
        set(st.vols{i}.ax{3}.ax,'Units','Pixels', 'Box','on',...
            'Position',[offx+s*Dims(1)+skx offy s*Dims(3) s*Dims(2)],...
            'Units','normalized','Xlim',[0 SD(1)]+0.5,'Ylim',[0 SD(2)]+0.5,...
            'Visible','on','XTick',[],'YTick',[]);
    else,
        set(st.vols{i}.ax{3}.ax,'Units','Pixels', 'Box','on',...
            'Position',[offx+s*Dims(1)+skx offy+s*Dims(2)+sky s*Dims(2) s*Dims(3)],...
            'Units','normalized','Xlim',[0 SD(1)]+0.5,'Ylim',[0 SD(2)]+0.5,...
            'Visible','on','XTick',[],'YTick',[]);
    end;
end;
return;
%_______________________________________________________________________
%_______________________________________________________________________
function redraw_all
global st
redraw(1:24);
return;
%_______________________________________________________________________
function mx = maxval(vol)
if isstruct(vol),
    mx = -Inf;
    for i=1:vol.dim(3),
        tmp = spm_slice_vol(vol,spm_matrix([0 0 i]),vol.dim(1:2),0);
        imx = max(tmp(find(finite(tmp))));
        if ~isempty(imx),mx = max(mx,imx);end
    end;
else,
    mx = max(vol(find(finite(vol))));
end;
%_______________________________________________________________________
function mn = minval(vol)
if isstruct(vol),
    mn = Inf;
    for i=1:vol.dim(3),
        tmp = spm_slice_vol(vol,spm_matrix([0 0 i]),vol.dim(1:2),0);
        imn = min(tmp(find(finite(tmp))));
        if ~isempty(imn),mn = min(mn,imn);end
    end;
else,
    mn = min(vol(find(finite(vol))));
end;

%_______________________________________________________________________
%_______________________________________________________________________
function redraw(arg1)
global st
bb   = st.bb;
Dims = round(diff(bb)'+1);
is   = inv(st.Space);
cent = is(1:3,1:3)*st.centre(:) + is(1:3,4);

for i = valid_handles(arg1),
    M = st.vols{i}.premul*st.vols{i}.mat;
    TM0 = [    1 0 0 -bb(1,1)+1
        0 1 0 -bb(1,2)+1
        0 0 1 -cent(3)
        0 0 0 1];
    TM = inv(TM0*(st.Space\M));
    TD = Dims([1 2]);

    CM0 = [    1 0 0 -bb(1,1)+1
        0 0 1 -bb(1,3)+1
        0 1 0 -cent(2)
        0 0 0 1];
    CM = inv(CM0*(st.Space\M));
    CD = Dims([1 3]);

    if st.mode ==0,
        SM0 = [    0 0 1 -bb(1,3)+1
            0 1 0 -bb(1,2)+1
            1 0 0 -cent(1)
            0 0 0 1];
        SM = inv(SM0*(st.Space\M)); SD = Dims([3 2]);
    else,
        SM0 = [    0  1 0 -bb(1,2)+1
            0  0 1 -bb(1,3)+1
            1  0 0 -cent(1)
            0  0 0 1];
        SM0 = [    0 -1 0 +bb(2,2)+1
            0  0 1 -bb(1,3)+1
            1  0 0 -cent(1)
            0  0 0 1];
        SM = inv(SM0*(st.Space\M));
        SD = Dims([2 3]);
    end;

    ok=1;
    eval('imgt  = (spm_slice_vol(st.vols{i},TM,TD,st.hld))'';','ok=0;');
    eval('imgc  = (spm_slice_vol(st.vols{i},CM,CD,st.hld))'';','ok=0;');
    eval('imgs  = (spm_slice_vol(st.vols{i},SM,SD,st.hld))'';','ok=0;');
    if (ok==0), fprintf('Image "%s" can not be resampled\n', st.vols{i}.fname);
    else,
        % get min/max threshold
        if strcmp(st.vols{i}.window,'auto')
            mn = -Inf;
            mx = Inf;
        else
            mn = min(st.vols{i}.window);
            mx = max(st.vols{i}.window);
        end;
        % threshold images
        imgt = max(imgt,mn); imgt = min(imgt,mx);
        imgc = max(imgc,mn); imgc = min(imgc,mx);
        imgs = max(imgs,mn); imgs = min(imgs,mx);
        % compute intensity mapping, if histeq is available
        if license('test','image_toolbox') == 0
            st.vols{i}.mapping = 'linear';
        end;
        switch st.vols{i}.mapping,
            case 'linear',
            case 'histeq',
                % scale images to a range between 0 and 1
                imgt1=(imgt-min(imgt(:)))/(max(imgt(:)-min(imgt(:)))+eps);
                imgc1=(imgc-min(imgc(:)))/(max(imgc(:)-min(imgc(:)))+eps);
                imgs1=(imgs-min(imgs(:)))/(max(imgs(:)-min(imgs(:)))+eps);
                img  = histeq([imgt1(:); imgc1(:); imgs1(:)],1024);
                imgt = reshape(img(1:numel(imgt1)),size(imgt1));
                imgc = reshape(img(numel(imgt1)+[1:numel(imgc1)]),size(imgc1));
                imgs = reshape(img(numel(imgt1)+numel(imgc1)+[1:numel(imgs1)]),size(imgs1));
                mn = 0;
                mx = 1;
            case 'quadhisteq',
                % scale images to a range between 0 and 1
                imgt1=(imgt-min(imgt(:)))/(max(imgt(:)-min(imgt(:)))+eps);
                imgc1=(imgc-min(imgc(:)))/(max(imgc(:)-min(imgc(:)))+eps);
                imgs1=(imgs-min(imgs(:)))/(max(imgs(:)-min(imgs(:)))+eps);
                img  = histeq([imgt1(:).^2; imgc1(:).^2; imgs1(:).^2],1024);
                imgt = reshape(img(1:numel(imgt1)),size(imgt1));
                imgc = reshape(img(numel(imgt1)+[1:numel(imgc1)]),size(imgc1));
                imgs = reshape(img(numel(imgt1)+numel(imgc1)+[1:numel(imgs1)]),size(imgs1));
                mn = 0;
                mx = 1;
            case 'loghisteq',
                warning off % messy - but it may avoid extra queries
                imgt = log(imgt-min(imgt(:)));
                imgc = log(imgc-min(imgc(:)));
                imgs = log(imgs-min(imgs(:)));
                warning on
                imgt(~isfinite(imgt)) = 0;
                imgc(~isfinite(imgc)) = 0;
                imgs(~isfinite(imgs)) = 0;
                % scale log images to a range between 0 and 1
                imgt1=(imgt-min(imgt(:)))/(max(imgt(:)-min(imgt(:)))+eps);
                imgc1=(imgc-min(imgc(:)))/(max(imgc(:)-min(imgc(:)))+eps);
                imgs1=(imgs-min(imgs(:)))/(max(imgs(:)-min(imgs(:)))+eps);
                img  = histeq([imgt1(:); imgc1(:); imgs1(:)],1024);
                imgt = reshape(img(1:numel(imgt1)),size(imgt1));
                imgc = reshape(img(numel(imgt1)+[1:numel(imgc1)]),size(imgc1));
                imgs = reshape(img(numel(imgt1)+numel(imgc1)+[1:numel(imgs1)]),size(imgs1));
                mn = 0;
                mx = 1;
        end;
        % recompute min/max for display
        if strcmp(st.vols{i}.window,'auto')
            mx = -inf; mn = inf;
        end;
        if ~isempty(imgt),
            tmp = imgt(finite(imgt));
            mx = max([mx max(max(tmp))]);
            mn = min([mn min(min(tmp))]);
        end;
        if ~isempty(imgc),
            tmp = imgc(finite(imgc));
            mx = max([mx max(max(tmp))]);
            mn = min([mn min(min(tmp))]);
        end;
        if ~isempty(imgs),
            tmp = imgs(finite(imgs));
            mx = max([mx max(max(tmp))]);
            mn = min([mn min(min(tmp))]);
        end;
        if mx==mn, mx=mn+eps; end;

        if isfield(st.vols{i},'blobs'),
            if ~isfield(st.vols{i}.blobs{1},'colour'),
                % Add blobs for display using the split colourmap
                scal = 64/(mx-mn);
                dcoff = -mn*scal;
                imgt = imgt*scal+dcoff;
                imgc = imgc*scal+dcoff;
                imgs = imgs*scal+dcoff;

                if isfield(st.vols{i}.blobs{1},'max'),
                    mx = st.vols{i}.blobs{1}.max;
                else,
                    mx = max([eps maxval(st.vols{i}.blobs{1}.vol)]);
                    st.vols{i}.blobs{1}.max = mx;
                end;
                if isfield(st.vols{i}.blobs{1},'min'),
                    mn = st.vols{i}.blobs{1}.min;
                else,
                    mn = min([0 minval(st.vols{i}.blobs{1}.vol)]);
                    st.vols{i}.blobs{1}.min = mn;
                end;

                vol  = st.vols{i}.blobs{1}.vol;
                M    = st.vols{i}.premul*st.vols{i}.blobs{1}.mat;
                tmpt = spm_slice_vol(vol,inv(TM0*(st.Space\M)),TD,[0 NaN])';
                tmpc = spm_slice_vol(vol,inv(CM0*(st.Space\M)),CD,[0 NaN])';
                tmps = spm_slice_vol(vol,inv(SM0*(st.Space\M)),SD,[0 NaN])';

                %tmpt_z = find(tmpt==0);tmpt(tmpt_z) = NaN;
                %tmpc_z = find(tmpc==0);tmpc(tmpc_z) = NaN;
                %tmps_z = find(tmps==0);tmps(tmps_z) = NaN;

                sc   = 64/(mx-mn);
                off  = 65.51-mn*sc;
                msk  = find(finite(tmpt)); imgt(msk) = off+tmpt(msk)*sc;
                msk  = find(finite(tmpc)); imgc(msk) = off+tmpc(msk)*sc;
                msk  = find(finite(tmps)); imgs(msk) = off+tmps(msk)*sc;

                cmap = get(st.fig,'Colormap');

                figure(st.fig)
                if mn*mx < 0
                    setcolormap('gray-hot-cold')
                elseif mx > 0
                    setcolormap('gray-hot');
                else
                    setcolormap('gray-cold')
                end
                redraw_colourbar(i,1,[mn mx],[1:64]'+64);
            elseif isstruct(st.vols{i}.blobs{1}.colour),
                % Add blobs for display using a defined
                % colourmap

                % colourmaps
                gryc = [0:63]'*ones(1,3)/63;
                actc = ...
                    st.vols{1}.blobs{1}.colour.cmap;
                actp = ...
                    st.vols{1}.blobs{1}.colour.prop;

                % scale grayscale image, not finite -> black
                imgt = scaletocmap(imgt,mn,mx,gryc,65);
                imgc = scaletocmap(imgc,mn,mx,gryc,65);
                imgs = scaletocmap(imgs,mn,mx,gryc,65);
                gryc = [gryc; 0 0 0];

                % get max for blob image
                vol = st.vols{i}.blobs{1}.vol;
                mat = st.vols{i}.premul*st.vols{i}.blobs{1}.mat;
                if isfield(st.vols{i}.blobs{1},'max'),
                    cmx = st.vols{i}.blobs{1}.max;
                else,
                    cmx = max([eps maxval(st.vols{i}.blobs{1}.vol)]);
                end;
                if isfield(st.vols{i}.blobs{1},'min'),
                    cmn = st.vols{i}.blobs{1}.min;
                else,
                    cmn = -cmx;
                end;

                % get blob data
                vol  = st.vols{i}.blobs{1}.vol;
                M    = st.vols{i}.premul*st.vols{i}.blobs{1}.mat;
                tmpt = spm_slice_vol(vol,inv(TM0*(st.Space\M)),TD,[0 NaN])';
                tmpc = spm_slice_vol(vol,inv(CM0*(st.Space\M)),CD,[0 NaN])';
                tmps = spm_slice_vol(vol,inv(SM0*(st.Space\M)),SD,[0 NaN])';

                % actimg scaled round 0, black NaNs
                topc = size(actc,1)+1;
                tmpt = scaletocmap(tmpt,cmn,cmx,actc,topc);
                tmpc = scaletocmap(tmpc,cmn,cmx,actc,topc);
                tmps = scaletocmap(tmps,cmn,cmx,actc,topc);
                actc = [actc; 0 0 0];

                % combine gray and blob data to
                % truecolour
                imgt = reshape(actc(tmpt(:),:)*actp+ ...
                    gryc(imgt(:),:)*(1-actp), ...
                    [size(imgt) 3]);
                imgc = reshape(actc(tmpc(:),:)*actp+ ...
                    gryc(imgc(:),:)*(1-actp), ...
                    [size(imgc) 3]);
                imgs = reshape(actc(tmps(:),:)*actp+ ...
                    gryc(imgs(:),:)*(1-actp), ...
                    [size(imgs) 3]);

                redraw_colourbar(i,1,[cmn cmx],[1:64]'+64);

            else,
                % Add full colour blobs - several sets at once
                scal  = 1/(mx-mn);
                dcoff = -mn*scal;

                wt = zeros(size(imgt));
                wc = zeros(size(imgc));
                ws = zeros(size(imgs));

                imgt  = repmat(imgt*scal+dcoff,[1,1,3]);
                imgc  = repmat(imgc*scal+dcoff,[1,1,3]);
                imgs  = repmat(imgs*scal+dcoff,[1,1,3]);

                cimgt = zeros(size(imgt));
                cimgc = zeros(size(imgc));
                cimgs = zeros(size(imgs));

                for j=1:length(st.vols{i}.blobs), % get colours of all images first
                    if isfield(st.vols{i}.blobs{j},'colour'),
                        colour(j,:) = reshape(st.vols{i}.blobs{j}.colour, [1 3]);
                    else,
                        colour(j,:) = [1 0 0];
                    end;
                end;
                %colour = colour/max(sum(colour));

                for j=1:length(st.vols{i}.blobs),
                    if isfield(st.vols{i}.blobs{j},'max'),
                        mx = st.vols{i}.blobs{j}.max;
                    else,
                        mx = max([eps max(st.vols{i}.blobs{j}.vol(:))]);
                        st.vols{i}.blobs{j}.max = mx;
                    end;
                    if isfield(st.vols{i}.blobs{j},'min'),
                        mn = st.vols{i}.blobs{j}.min;
                    else,
                        mn = min([0 min(st.vols{i}.blobs{j}.vol(:))]);
                        st.vols{i}.blobs{j}.min = mn;
                    end;

                    vol  = st.vols{i}.blobs{j}.vol;
                    M    = st.Space\st.vols{i}.premul*st.vols{i}.blobs{j}.mat;
                    tmpt = spm_slice_vol(vol,inv(TM0*M),TD,[0 NaN])';
                    tmpc = spm_slice_vol(vol,inv(CM0*M),CD,[0 NaN])';
                    tmps = spm_slice_vol(vol,inv(SM0*M),SD,[0 NaN])';
                    % check min/max of sampled image
                    % against mn/mx as given in st
                    tmpt(tmpt(:)<mn) = mn;
                    tmpc(tmpc(:)<mn) = mn;
                    tmps(tmps(:)<mn) = mn;
                    tmpt(tmpt(:)>mx) = mx;
                    tmpc(tmpc(:)>mx) = mx;
                    tmps(tmps(:)>mx) = mx;
                    tmpt = (tmpt-mn)/(mx-mn);
                    tmpc = (tmpc-mn)/(mx-mn);
                    tmps = (tmps-mn)/(mx-mn);
                    tmpt(~finite(tmpt)) = 0;
                    tmpc(~finite(tmpc)) = 0;
                    tmps(~finite(tmps)) = 0;

                    cimgt = cimgt + cat(3,tmpt*colour(j,1),tmpt*colour(j,2),tmpt*colour(j,3));
                    cimgc = cimgc + cat(3,tmpc*colour(j,1),tmpc*colour(j,2),tmpc*colour(j,3));
                    cimgs = cimgs + cat(3,tmps*colour(j,1),tmps*colour(j,2),tmps*colour(j,3));

                    wt = wt + tmpt;
                    wc = wc + tmpc;
                    ws = ws + tmps;
                    cdata=permute(shiftdim([1/64:1/64:1]'* ...
                        colour(j,:),-1),[2 1 3]);
                    redraw_colourbar(i,j,[mn mx],cdata);
                end;

                imgt = repmat(1-wt,[1 1 3]).*imgt+cimgt;
                imgc = repmat(1-wc,[1 1 3]).*imgc+cimgc;
                imgs = repmat(1-ws,[1 1 3]).*imgs+cimgs;

                imgt(imgt<0)=0; imgt(imgt>1)=1;
                imgc(imgc<0)=0; imgc(imgc>1)=1;
                imgs(imgs<0)=0; imgs(imgs>1)=1;
            end;
        else,
            scal = 64/(mx-mn);
            dcoff = -mn*scal;
            imgt = imgt*scal+dcoff;
            imgc = imgc*scal+dcoff;
            imgs = imgs*scal+dcoff;
        end;

        set(st.vols{i}.ax{1}.d,'HitTest','off', 'Cdata',imgt);
        set(st.vols{i}.ax{1}.lx,'HitTest','off',...
            'Xdata',[0 TD(1)]+0.5,'Ydata',[1 1]*(cent(2)-bb(1,2)+1));
        set(st.vols{i}.ax{1}.ly,'HitTest','off',...
            'Ydata',[0 TD(2)]+0.5,'Xdata',[1 1]*(cent(1)-bb(1,1)+1));

        set(st.vols{i}.ax{2}.d,'HitTest','off', 'Cdata',imgc);
        set(st.vols{i}.ax{2}.lx,'HitTest','off',...
            'Xdata',[0 CD(1)]+0.5,'Ydata',[1 1]*(cent(3)-bb(1,3)+1));
        set(st.vols{i}.ax{2}.ly,'HitTest','off',...
            'Ydata',[0 CD(2)]+0.5,'Xdata',[1 1]*(cent(1)-bb(1,1)+1));

        set(st.vols{i}.ax{3}.d,'HitTest','off','Cdata',imgs);
        if st.mode ==0,
            set(st.vols{i}.ax{3}.lx,'HitTest','off',...
                'Xdata',[0 SD(1)]+0.5,'Ydata',[1 1]*(cent(2)-bb(1,2)+1));
            set(st.vols{i}.ax{3}.ly,'HitTest','off',...
                'Ydata',[0 SD(2)]+0.5,'Xdata',[1 1]*(cent(3)-bb(1,3)+1));
        else,
            set(st.vols{i}.ax{3}.lx,'HitTest','off',...
                'Xdata',[0 SD(1)]+0.5,'Ydata',[1 1]*(cent(3)-bb(1,3)+1));
            set(st.vols{i}.ax{3}.ly,'HitTest','off',...
                'Ydata',[0 SD(2)]+0.5,'Xdata',[1 1]*(bb(2,2)+1-cent(2)));
        end;

        if ~isempty(st.plugins) % process any addons
            for k = 1:prod(size(st.plugins))
                if isfield(st.vols{i},st.plugins{k})
                    feval(['spm_ov_', st.plugins{k}], ...
                        'redraw', i, TM0, TD, CM0, CD, SM0, SD);
                end;
            end;
        end;
    end;
end;
drawnow;
return;
%_______________________________________________________________________
%_______________________________________________________________________
function redraw_colourbar(vh,bh,interval,cdata)
global st
if isfield(st.vols{vh}.blobs{bh},'cbar')
    if st.mode == 0,
        axpos = get(st.vols{vh}.ax{2}.ax,'Position');
    else,
        axpos = get(st.vols{vh}.ax{1}.ax,'Position');
    end;
    % only scale cdata if we have out-of-range truecolour values
    if ndims(cdata)==3 && max(cdata(:))>1
        cdata=cdata./max(cdata(:));
    end;
    image([0 1],interval,cdata,'Parent',st.vols{vh}.blobs{bh}.cbar);
    set(st.vols{vh}.blobs{bh}.cbar, ...
        'Position',[(axpos(1)+axpos(3)+0.05+(bh-1)*.1)...
        (axpos(2)+0.005) 0.05 (axpos(4)-0.01)],...
        'YDir','normal','XTickLabel',[],'XTick',[]);
end;
%_______________________________________________________________________
%_______________________________________________________________________
function centre = findcent
global st
obj    = get(st.fig,'CurrentObject');
centre = [];
cent   = [];
cp     = [];
for i=valid_handles(1:24),
    for j=1:3,
        if ~isempty(obj),
            if (st.vols{i}.ax{j}.ax == obj),
                cp = get(obj,'CurrentPoint');
            end;
        end;
        if ~isempty(cp),
            cp   = cp(1,1:2);
            is   = inv(st.Space);
            cent = is(1:3,1:3)*st.centre(:) + is(1:3,4);
            switch j,
                case 1,
                    cent([1 2])=[cp(1)+st.bb(1,1)-1 cp(2)+st.bb(1,2)-1];
                case 2,
                    cent([1 3])=[cp(1)+st.bb(1,1)-1 cp(2)+st.bb(1,3)-1];
                case 3,
                    if st.mode ==0,
                        cent([3 2])=[cp(1)+st.bb(1,3)-1 cp(2)+st.bb(1,2)-1];
                    else,
                        cent([2 3])=[st.bb(2,2)+1-cp(1) cp(2)+st.bb(1,3)-1];
                    end;
            end;
            break;
        end;
    end;
    if ~isempty(cent), break; end;
end;
if ~isempty(cent), centre = st.Space(1:3,1:3)*cent(:) + st.Space(1:3,4); end;
return;
%_______________________________________________________________________
%_______________________________________________________________________
function handles = valid_handles(handles)
global st;
handles = handles(:)';
handles = handles(find(handles<=24 & handles>=1 & ~rem(handles,1)));
for h=handles,
    if isempty(st.vols{h}), handles(find(handles==h))=[]; end;
end;
return;
%_______________________________________________________________________
%_______________________________________________________________________
function reset_st
global st
fig     = spm_figure('FindWin','Graphics');
bb      = []; %[ [-78 78]' [-112 76]' [-50 85]' ];
st      = struct('n', 0, 'vols',[], 'bb',bb,'Space',eye(4),'centre',[0 0 0],'callback',';','xhairs',1,'hld',1,'fig',fig,'mode',1,'plugins',[],'snap',[]);
st.vols = cell(24,1);

pluginpath = fullfile(spm('Dir'),'spm_orthviews');
if isdir(pluginpath)
    pluginfiles = dir(fullfile(pluginpath,'spm_ov_*.m'));
    if ~isempty(pluginfiles)
        addpath(pluginpath);
        % fprintf('spm_orthviews: Using Plugins in %s\n', pluginpath);
        for k = 1:length(pluginfiles)
            [p pluginname e v] = fileparts(pluginfiles(k).name);
            st.plugins{k} = strrep(pluginname, 'spm_ov_','');
            % fprintf('%s\n',st.plugins{k});
        end;
    end;
end;
return;
%_______________________________________________________________________
%_______________________________________________________________________
function img = scaletocmap(inpimg,mn,mx,cmap,miscol)
if nargin < 5, miscol=1;end
cml = size(cmap,1);
scf = (cml-1)/(mx-mn);
img = round((inpimg-mn)*scf)+1;
img(find(img<1))   = 1;
img(find(img>cml)) = cml;
img(~finite(img))  = miscol;
return;
%_______________________________________________________________________
%_______________________________________________________________________
function cmap = getcmap(acmapname)
% get colormap of name acmapname
if ~isempty(acmapname),
    cmap = evalin('base',acmapname,'[]');
    if isempty(cmap), % not a matrix, is .mat file?
        [p f e] = fileparts(acmapname);
        acmat   = fullfile(p, [f '.mat']);
        if exist(acmat, 'file'),
            s    = struct2cell(load(acmat));
            cmap = s{1};
        end;
    end;
end;
if size(cmap, 2)~=3,
    warning('Colormap was not an N by 3 matrix')
    cmap = [];
end;
return;
%_______________________________________________________________________
%_______________________________________________________________________
function item_parent = addcontext(volhandle)
global st;
%create context menu
fg = spm_figure('Findwin','Graphics');set(0,'CurrentFigure',fg);
%contextmenu
item_parent = uicontextmenu;

%contextsubmenu 0
item00  = uimenu(item_parent, 'Label','unknown image', 'Separator','on');
spm_orthviews('context_menu','image_info',item00,volhandle);
item0a    = uimenu(item_parent, 'UserData','pos_mm',     'Callback','spm_orthviews(''context_menu'',''repos_mm'');','Separator','on');
item0b    = uimenu(item_parent, 'UserData','pos_vx',     'Callback','spm_orthviews(''context_menu'',''repos_vx'');');
item0c    = uimenu(item_parent, 'UserData','v_value');

%contextsubmenu 1
item1     = uimenu(item_parent,'Label','Zoom');
item1_1   = uimenu(item1,      'Label','Full Volume',   'Callback','spm_orthviews(''context_menu'',''zoom'',6);', 'Checked','on');
item1_2   = uimenu(item1,      'Label','160x160x160mm', 'Callback','spm_orthviews(''context_menu'',''zoom'',5);');
item1_3   = uimenu(item1,      'Label','80x80x80mm',    'Callback','spm_orthviews(''context_menu'',''zoom'',4);');
item1_4   = uimenu(item1,      'Label','40x40x40mm',    'Callback','spm_orthviews(''context_menu'',''zoom'',3);');
item1_5   = uimenu(item1,      'Label','20x20x20mm',    'Callback','spm_orthviews(''context_menu'',''zoom'',2);');
item1_6   = uimenu(item1,      'Label','10x10x10mm',    'Callback','spm_orthviews(''context_menu'',''zoom'',1);');

%contextsubmenu 2
checked={'off','off'};
checked{st.xhairs+1} = 'on';
item2     = uimenu(item_parent,'Label','Crosshairs');
item2_1   = uimenu(item2,      'Label','on',  'Callback','spm_orthviews(''context_menu'',''Xhair'',''on'');','Checked',checked{2});
item2_2   = uimenu(item2,      'Label','off', 'Callback','spm_orthviews(''context_menu'',''Xhair'',''off'');','Checked',checked{1});

%contextsubmenu 3
if st.Space == eye(4)
    checked = {'off', 'on'};
else
    checked = {'on', 'off'};
end;
item3     = uimenu(item_parent,'Label','Orientation');
item3_1   = uimenu(item3,      'Label','World space', 'Callback','spm_orthviews(''context_menu'',''orientation'',3);','Checked',checked{2});
item3_2   = uimenu(item3,      'Label','Voxel space (1st image)', 'Callback','spm_orthviews(''context_menu'',''orientation'',2);','Checked',checked{1});
item3_3   = uimenu(item3,      'Label','Voxel space (this image)', 'Callback','spm_orthviews(''context_menu'',''orientation'',1);','Checked','off');

%contextsubmenu 3
if isempty(st.snap)
    checked = {'off', 'on'};
else
    checked = {'on', 'off'};
end;
item3     = uimenu(item_parent,'Label','Snap to Grid');
item3_1   = uimenu(item3,      'Label','Don''t snap', 'Callback','spm_orthviews(''context_menu'',''snap'',3);','Checked',checked{2});
item3_2   = uimenu(item3,      'Label','Snap to 1st image', 'Callback','spm_orthviews(''context_menu'',''snap'',2);','Checked',checked{1});
item3_3   = uimenu(item3,      'Label','Snap to this image', 'Callback','spm_orthviews(''context_menu'',''snap'',1);','Checked','off');

%contextsubmenu 4
if st.hld == 0,
    checked = {'off', 'off', 'on'};
elseif st.hld > 0,
    checked = {'off', 'on', 'off'};
else,
    checked = {'on', 'off', 'off'};
end;
item4     = uimenu(item_parent,'Label','Interpolation');
item4_1   = uimenu(item4,      'Label','NN',    'Callback','spm_orthviews(''context_menu'',''interpolation'',3);', 'Checked',checked{3});
item4_2   = uimenu(item4,      'Label','Bilin', 'Callback','spm_orthviews(''context_menu'',''interpolation'',2);','Checked',checked{2});
item4_3   = uimenu(item4,      'Label','Sinc',  'Callback','spm_orthviews(''context_menu'',''interpolation'',1);','Checked',checked{1});

%contextsubmenu 5
% item5     = uimenu(item_parent,'Label','Position', 'Callback','spm_orthviews(''context_menu'',''position'');');

%contextsubmenu 6
item6       = uimenu(item_parent,'Label','Image','Separator','on');
item6_1     = uimenu(item6,      'Label','Window');
item6_1_1   = uimenu(item6_1,    'Label','local');
item6_1_1_1 = uimenu(item6_1_1,  'Label','auto',       'Callback','spm_orthviews(''context_menu'',''window'',2);');
item6_1_1_2 = uimenu(item6_1_1,  'Label','manual',     'Callback','spm_orthviews(''context_menu'',''window'',1);');
item6_1_2   = uimenu(item6_1,    'Label','global');
item6_1_2_1 = uimenu(item6_1_2,  'Label','auto',       'Callback','spm_orthviews(''context_menu'',''window_gl'',2);');
item6_1_2_2 = uimenu(item6_1_2,  'Label','manual',     'Callback','spm_orthviews(''context_menu'',''window_gl'',1);');
if license('test','image_toolbox') == 1
    offon = {'off', 'on'};
    checked = offon(strcmp(st.vols{volhandle}.mapping, ...
        {'linear', 'histeq', 'loghisteq', 'quadhisteq'})+1);
    item6_2     = uimenu(item6,      'Label','Intensity mapping');
    item6_2_1   = uimenu(item6_2,    'Label','local');
    item6_2_1_1 = uimenu(item6_2_1,  'Label','Linear', 'Checked',checked{1}, ...
        'Callback','spm_orthviews(''context_menu'',''mapping'',''linear'');');
    item6_2_1_2 = uimenu(item6_2_1,  'Label','Equalised histogram', 'Checked',checked{2}, ...
        'Callback','spm_orthviews(''context_menu'',''mapping'',''histeq'');');
    item6_2_1_3 = uimenu(item6_2_1,  'Label','Equalised log-histogram', 'Checked',checked{3}, ...
        'Callback','spm_orthviews(''context_menu'',''mapping'',''loghisteq'');');
    item6_2_1_4 = uimenu(item6_2_1,  'Label','Equalised squared-histogram', 'Checked',checked{4}, ...
        'Callback','spm_orthviews(''context_menu'',''mapping'',''quadhisteq'');');
    item6_2_2   = uimenu(item6_2,    'Label','global');
    item6_2_2_1 = uimenu(item6_2_2,  'Label','Linear', 'Checked',checked{1}, ...
        'Callback','spm_orthviews(''context_menu'',''mapping_gl'',''linear'');');
    item6_2_2_2 = uimenu(item6_2_2,  'Label','Equalised histogram', 'Checked',checked{2}, ...
        'Callback','spm_orthviews(''context_menu'',''mapping_gl'',''histeq'');');
    item6_2_2_3 = uimenu(item6_2_2,  'Label','Equalised log-histogram', 'Checked',checked{3}, ...
        'Callback','spm_orthviews(''context_menu'',''mapping_gl'',''loghisteq'');');
    item6_2_2_4 = uimenu(item6_2_2,  'Label','Equalised squared-histogram', 'Checked',checked{4}, ...
        'Callback','spm_orthviews(''context_menu'',''mapping_gl'',''quadhisteq'');');
end;
%contextsubmenu 7
item7     = uimenu(item_parent,'Label','Blobs');
item7_1   = uimenu(item7,      'Label','Add blobs');
item7_1_1 = uimenu(item7_1,    'Label','local',  'Callback','spm_orthviews(''context_menu'',''add_blobs'',2);');
item7_1_2 = uimenu(item7_1,    'Label','global', 'Callback','spm_orthviews(''context_menu'',''add_blobs'',1);');
item7_2   = uimenu(item7,      'Label','Add image');
item7_2_1 = uimenu(item7_2,    'Label','local',  'Callback','spm_orthviews(''context_menu'',''add_image'',2);');
item7_2_2 = uimenu(item7_2,    'Label','global', 'Callback','spm_orthviews(''context_menu'',''add_image'',1);');
item7_3   = uimenu(item7,      'Label','Add colored blobs','Separator','on');
item7_3_1 = uimenu(item7_3,    'Label','local',  'Callback','spm_orthviews(''context_menu'',''add_c_blobs'',2);');
item7_3_2 = uimenu(item7_3,    'Label','global', 'Callback','spm_orthviews(''context_menu'',''add_c_blobs'',1);');
item7_4   = uimenu(item7,      'Label','Add colored image');
item7_4_1 = uimenu(item7_4,    'Label','local',  'Callback','spm_orthviews(''context_menu'',''add_c_image'',2);');
item7_4_2 = uimenu(item7_4,    'Label','global', 'Callback','spm_orthviews(''context_menu'',''add_c_image'',1);');
item7_5   = uimenu(item7,      'Label','Remove blobs',        'Visible','off','Separator','on');
item7_6   = uimenu(item7,      'Label','Remove colored blobs','Visible','off');
item7_6_1 = uimenu(item7_6,    'Label','local', 'Visible','on');
item7_6_2 = uimenu(item7_6,    'Label','global','Visible','on');

if ~isempty(st.plugins) % process any plugins
    for k = 1:prod(size(st.plugins)),
        feval(['spm_ov_', st.plugins{k}], ...
            'context_menu', volhandle, item_parent);
    end;
end;
return;
%_______________________________________________________________________
%_______________________________________________________________________
function c_menu(varargin)
global st

switch lower(varargin{1}),
    case 'image_info',
        if nargin <3,
            current_handle = get_current_handle;
        else
            current_handle = varargin{3};
        end;
        if isfield(st.vols{current_handle},'fname'),
            [p,n,e,v] = spm_fileparts(st.vols{current_handle}.fname);
            if isfield(st.vols{current_handle},'n')
                v = sprintf(',%d',st.vols{current_handle}.n);
            end;
            set(varargin{2}, 'Label',[n e v]);
        end;
        delete(get(varargin{2},'children'));
        if exist('p','var')
            item1 = uimenu(varargin{2}, 'Label', p);
        end;
        if isfield(st.vols{current_handle},'descrip'),
            item2 = uimenu(varargin{2}, 'Label',...
                st.vols{current_handle}.descrip);
        end;
        dt = st.vols{current_handle}.dt(1);
        item3 = uimenu(varargin{2}, 'Label', sprintf('Data type: %s', spm_type(dt)));
        str   = 'Intensity: varied';
        if size(st.vols{current_handle}.pinfo,2) == 1,
            if st.vols{current_handle}.pinfo(2),
                str = sprintf('Intensity: Y = %g X + %g',...
                    st.vols{current_handle}.pinfo(1:2)');
            else,
                str = sprintf('Intensity: Y = %g X', st.vols{current_handle}.pinfo(1)');
            end;
        end;
        item4  = uimenu(varargin{2}, 'Label',str);
        item5  = uimenu(varargin{2}, 'Label', 'Image dims', 'Separator','on');
        item51 = uimenu(varargin{2}, 'Label',...
            sprintf('%dx%dx%d', st.vols{current_handle}.dim(1:3)));
        prms   = spm_imatrix(st.vols{current_handle}.mat);
        item6  = uimenu(varargin{2}, 'Label','Voxel size', 'Separator','on');
        item61 = uimenu(varargin{2}, 'Label', sprintf('%.2f %.2f %.2f', prms(7:9)));
        item7  = uimenu(varargin{2}, 'Label','Origin', 'Separator','on');
        item71 = uimenu(varargin{2}, 'Label',...
            sprintf('%.2f %.2f %.2f', prms(1:3)));
        R      = spm_matrix([0 0 0 prms(4:6)]);
        item8  = uimenu(varargin{2}, 'Label','Rotations', 'Separator','on');
        item81 = uimenu(varargin{2}, 'Label', sprintf('%.2f %.2f %.2f', R(1,1:3)));
        item82 = uimenu(varargin{2}, 'Label', sprintf('%.2f %.2f %.2f', R(2,1:3)));
        item83 = uimenu(varargin{2}, 'Label', sprintf('%.2f %.2f %.2f', R(3,1:3)));
        item9  = uimenu(varargin{2},...
            'Label','Specify other image...',...
            'Callback','spm_orthviews(''context_menu'',''swap_img'');',...
            'Separator','on');

    case 'repos_mm',
        oldpos_mm = spm_orthviews('pos');
        newpos_mm = spm_input('New Position (mm)','+1','r',sprintf('%.2f %.2f %.2f',oldpos_mm),3);
        spm_orthviews('reposition',newpos_mm);

    case 'repos_vx'
        current_handle = get_current_handle;
        oldpos_vx = spm_orthviews('pos', current_handle);
        newpos_vx = spm_input('New Position (voxels)','+1','r',sprintf('%.2f %.2f %.2f',oldpos_vx),3);
        newpos_mm = st.vols{current_handle}.mat*[newpos_vx;1];
        spm_orthviews('reposition',newpos_mm(1:3));

    case 'zoom'
        zoom_all(varargin{2});
        bbox;
        redraw_all;

    case 'xhair',
        spm_orthviews('Xhairs',varargin{2});
        cm_handles = get_cm_handles;
        for i = 1:length(cm_handles),
            z_handle = get(findobj(cm_handles(i),'label','Crosshairs'),'Children');
            set(z_handle,'Checked','off'); %reset check
            if strcmp(varargin{2},'off'), op = 1; else op = 2; end
            set(z_handle(op),'Checked','on');
        end;

    case 'orientation',
        cm_handles = get_cm_handles;
        for i = 1:length(cm_handles),
            z_handle = get(findobj(cm_handles(i),'label','Orientation'),'Children');
            set(z_handle,'Checked','off');
        end;
        if varargin{2} == 3,
            spm_orthviews('Space');
        elseif varargin{2} == 2,
            spm_orthviews('Space',1);
        else,
            spm_orthviews('Space',get_current_handle);
            z_handle = get(findobj(st.vols{get_current_handle}.ax{1}.cm,'label','Orientation'),'Children');
            set(z_handle(1),'Checked','on');
            return;
        end;
        for i = 1:length(cm_handles),
            z_handle = get(findobj(cm_handles(i),'label','Orientation'),'Children');
            set(z_handle(varargin{2}),'Checked','on');
        end;

    case 'snap',
        cm_handles = get_cm_handles;
        for i = 1:length(cm_handles),
            z_handle = get(findobj(cm_handles(i),'label','Snap to Grid'),'Children');
            set(z_handle,'Checked','off');
        end;
        if varargin{2} == 3,
            st.snap = [];
        elseif varargin{2} == 2,
            st.snap = 1;
        else,
            st.snap = get_current_handle;
            z_handle = get(findobj(st.vols{get_current_handle}.ax{1}.cm,'label','Snap to Grid'),'Children');
            set(z_handle(1),'Checked','on');
            return;
        end;
        for i = 1:length(cm_handles),
            z_handle = get(findobj(cm_handles(i),'label','Snap to Grid'),'Children');
            set(z_handle(varargin{2}),'Checked','on');
        end;

    case 'interpolation',
        tmp        = [-4 1 0];
        st.hld     = tmp(varargin{2});
        cm_handles = get_cm_handles;
        for i = 1:length(cm_handles),
            z_handle = get(findobj(cm_handles(i),'label','Interpolation'),'Children');
            set(z_handle,'Checked','off');
            set(z_handle(varargin{2}),'Checked','on');
        end;
        redraw_all;

    case 'window',
        current_handle = get_current_handle;
        if varargin{2} == 2,
            spm_orthviews('window',current_handle);
        else
            if isnumeric(st.vols{current_handle}.window)
                defstr = sprintf('%.2f %.2f', st.vols{current_handle}.window);
            else
                defstr = '';
            end;
            spm_orthviews('window',current_handle,spm_input('Range','+1','e',defstr,2));
        end;

    case 'window_gl',
        if varargin{2} == 2,
            for i = 1:length(get_cm_handles),
                st.vols{i}.window = 'auto';
            end;
        else,
            current_handle = get_current_handle;
            if isnumeric(st.vols{current_handle}.window)
                defstr = sprintf('%d %d', st.vols{current_handle}.window);
            else
                defstr = '';
            end;
            data = spm_input('Range','+1','e',defstr,2);

            for i = 1:length(get_cm_handles),
                st.vols{i}.window = data;
            end;
        end;
        redraw_all;

    case 'mapping',
        checked = strcmp(varargin{2}, ...
            {'linear', 'histeq', 'loghisteq', ...
            'quadhisteq'});
        checked = checked(end:-1:1); % Handles are stored in inverse order
        current_handle = get_current_handle;
        cm_handles = get_cm_handles;
        st.vols{current_handle}.mapping = varargin{2};
        z_handle = get(findobj(cm_handles(current_handle), ...
            'label','Intensity mapping'),'Children');
        for k = 1:numel(z_handle)
            c_handle = get(z_handle(k), 'Children');
            set(c_handle, 'checked', 'off');
            set(c_handle(checked), 'checked', 'on');
        end;
        redraw_all;

    case 'mapping_gl',
        checked = strcmp(varargin{2}, ...
            {'linear', 'histeq', 'loghisteq', 'quadhisteq'});
        checked = checked(end:-1:1); % Handles are stored in inverse order
        cm_handles = get_cm_handles;
        for k = valid_handles(1:24),
            st.vols{k}.mapping = varargin{2};
            z_handle = get(findobj(cm_handles(k), ...
                'label','Intensity mapping'),'Children');
            for l = 1:numel(z_handle)
                c_handle = get(z_handle(l), 'Children');
                set(c_handle, 'checked', 'off');
                set(c_handle(checked), 'checked', 'on');
            end;
        end;
        redraw_all;

    case 'swap_img',
        current_handle = get_current_handle;
        new_info = spm_vol(spm_select(1,'image','select new image'));
        fn = fieldnames(new_info);
        for k=1:numel(fn)
            st.vols{current_handle}.(fn{k}) = new_info.(fn{k});
        end;
        spm_orthviews('context_menu','image_info',get(gcbo, 'parent'));
        redraw_all;

    case 'add_blobs',
        % Add blobs to the image - in split colortable
        cm_handles = valid_handles(1:24);
        if varargin{2} == 2, cm_handles = get_current_handle; end;
        spm_figure('Clear','Interactive');
        [SPM,VOL] = spm_getSPM;
        for i = 1:length(cm_handles),
            addblobs(cm_handles(i),VOL.XYZ,VOL.Z,VOL.M);
            c_handle = findobj(findobj(st.vols{cm_handles(i)}.ax{1}.cm,'label','Blobs'),'Label','Remove blobs');
            set(c_handle,'Visible','on');
            delete(get(c_handle,'Children'));
            item7_3_1 = uimenu(c_handle,'Label','local','Callback','spm_orthviews(''context_menu'',''remove_blobs'',2);');
            if varargin{2} == 1,
                item7_3_2 = uimenu(c_handle,'Label','global','Callback','spm_orthviews(''context_menu'',''remove_blobs'',1);');
            end;
        end;
        redraw_all;

    case 'remove_blobs',
        cm_handles = valid_handles(1:24);
        if varargin{2} == 2, cm_handles = get_current_handle; end;
        for i = 1:length(cm_handles),
            rmblobs(cm_handles(i));
            c_handle = findobj(findobj(st.vols{cm_handles(i)}.ax{1}.cm,'label','Blobs'),'Label','Remove blobs');
            delete(get(c_handle,'Children'));
            set(c_handle,'Visible','off');
        end;
        redraw_all;

    case 'add_image',
        % Add blobs to the image - in split colortable
        cm_handles = valid_handles(1:24);
        if varargin{2} == 2, cm_handles = get_current_handle; end;
        spm_figure('Clear','Interactive');
        fname = spm_select(1,'image','select image');
        for i = 1:length(cm_handles),
            addimage(cm_handles(i),fname);
            c_handle = findobj(findobj(st.vols{cm_handles(i)}.ax{1}.cm,'label','Blobs'),'Label','Remove blobs');
            set(c_handle,'Visible','on');
            delete(get(c_handle,'Children'));
            item7_3_1 = uimenu(c_handle,'Label','local','Callback','spm_orthviews(''context_menu'',''remove_blobs'',2);');
            if varargin{2} == 1,
                item7_3_2 = uimenu(c_handle,'Label','global','Callback','spm_orthviews(''context_menu'',''remove_blobs'',1);');
            end;
        end;
        redraw_all;

    case 'add_c_blobs',
        % Add blobs to the image - in full colour
        cm_handles = valid_handles(1:24);
        if varargin{2} == 2, cm_handles = get_current_handle; end;
        spm_figure('Clear','Interactive');
        [SPM,VOL] = spm_getSPM;
        c         = spm_input('Colour','+1','m',...
            'Red blobs|Green blobs|Yellow blobs|Cyan blobs|Blue blobs|Magenta blobs',[1 2 3 4 5 6],1);
        colours   = [1 0 0;0 1 0;1 1 0;0 0 1;0 1 1;1 0 1];
        c_names   = {'red';'green';'yellow';'blue';'cyan';'magenta'};
        hlabel = sprintf('%s (%s)',VOL.title,c_names{c});
        for i = 1:length(cm_handles),
            addcolouredblobs(cm_handles(i),VOL.XYZ,VOL.Z,VOL.M,colours(c,:));
            addcolourbar(cm_handles(i),numel(st.vols{cm_handles(i)}.blobs));
            c_handle    = findobj(findobj(st.vols{cm_handles(i)}.ax{1}.cm,'label','Blobs'),'Label','Remove colored blobs');
            ch_c_handle = get(c_handle,'Children');
            set(c_handle,'Visible','on');
            %set(ch_c_handle,'Visible',on');
            item7_4_1   = uimenu(ch_c_handle(2),'Label',hlabel,'ForegroundColor',colours(c,:),...
                'Callback','c = get(gcbo,''UserData'');spm_orthviews(''context_menu'',''remove_c_blobs'',2,c);',...
                'UserData',c);
            if varargin{2} == 1,
                item7_4_2 = uimenu(ch_c_handle(1),'Label',hlabel,'ForegroundColor',colours(c,:),...
                    'Callback','c = get(gcbo,''UserData'');spm_orthviews(''context_menu'',''remove_c_blobs'',1,c);',...
                    'UserData',c);
            end;
        end;
        redraw_all;

    case 'remove_c_blobs',
        cm_handles = valid_handles(1:24);
        if varargin{2} == 2, cm_handles = get_current_handle; end;
        colours = [1 0 0;1 1 0;0 1 0;0 1 1;0 0 1;1 0 1];
        c_names = {'red';'yellow';'green';'cyan';'blue';'magenta'};
        for i = 1:length(cm_handles),
            if isfield(st.vols{cm_handles(i)},'blobs'),
                for j = 1:length(st.vols{cm_handles(i)}.blobs),
                    if st.vols{cm_handles(i)}.blobs{j}.colour == colours(varargin{3},:);
                        if isfield(st.vols{cm_handles(i)}.blobs{j},'cbar')
                            delete(st.vols{cm_handles(i)}.blobs{j}.cbar);
                        end
                        st.vols{cm_handles(i)}.blobs(j) = [];
                        break;
                    end;
                end;
                rm_c_menu = findobj(st.vols{cm_handles(i)}.ax{1}.cm,'Label','Remove colored blobs');
                delete(findobj(rm_c_menu,'Label',c_names{varargin{3}}));
                if isempty(st.vols{cm_handles(i)}.blobs),
                    st.vols{cm_handles(i)} = rmfield(st.vols{cm_handles(i)},'blobs');
                    set(rm_c_menu, 'Visible', 'off');
                end;
            end;
        end;
        redraw_all;

    case 'add_c_image',
        % Add truecolored image
        cm_handles = valid_handles(1:24);
        if varargin{2} == 2, cm_handles = get_current_handle;end;
        spm_figure('Clear','Interactive');
        fname   = spm_select(1,'image','select image');
        c       = spm_input('Colour','+1','m','Red blobs|Yellow blobs|Green blobs|Cyan blobs|Blue blobs|Magenta blobs',[1 2 3 4 5 6],1);
        colours = [1 0 0;1 1 0;0 1 0;0 1 1;0 0 1;1 0 1];
        c_names = {'red';'yellow';'green';'cyan';'blue';'magenta'};
        hlabel = sprintf('%s (%s)',fname,c_names{c});
        for i = 1:length(cm_handles),
            addcolouredimage(cm_handles(i),fname,colours(c,:));
            addcolourbar(cm_handles(i),numel(st.vols{cm_handles(i)}.blobs));
            c_handle    = findobj(findobj(st.vols{cm_handles(i)}.ax{1}.cm,'label','Blobs'),'Label','Remove colored blobs');
            ch_c_handle = get(c_handle,'Children');
            set(c_handle,'Visible','on');
            %set(ch_c_handle,'Visible',on');
            item7_4_1 = uimenu(ch_c_handle(2),'Label',hlabel,'ForegroundColor',colours(c,:),...
                'Callback','c = get(gcbo,''UserData'');spm_orthviews(''context_menu'',''remove_c_blobs'',2,c);','UserData',c);
            if varargin{2} == 1
                item7_4_2 = uimenu(ch_c_handle(1),'Label',hlabel,'ForegroundColor',colours(c,:),...
                    'Callback','c = get(gcbo,''UserData'');spm_orthviews(''context_menu'',''remove_c_blobs'',1,c);',...
                    'UserData',c);
            end
        end
        redraw_all;
end;
%_______________________________________________________________________
%_______________________________________________________________________
function current_handle = get_current_handle
global st
cm_handle      = get(gca,'UIContextMenu');
cm_handles     = get_cm_handles;
current_handle = find(cm_handles==cm_handle);
return;
%_______________________________________________________________________
%_______________________________________________________________________
function cm_pos
global st
for i = 1:length(valid_handles(1:24)),
    if isfield(st.vols{i}.ax{1},'cm')
        set(findobj(st.vols{i}.ax{1}.cm,'UserData','pos_mm'),...
            'Label',sprintf('mm:  %.1f %.1f %.1f',spm_orthviews('pos')));
        pos = spm_orthviews('pos',i);
        set(findobj(st.vols{i}.ax{1}.cm,'UserData','pos_vx'),...
            'Label',sprintf('vx:  %.1f %.1f %.1f',pos));
        set(findobj(st.vols{i}.ax{1}.cm,'UserData','v_value'),...
            'Label',sprintf('Y = %g',spm_sample_vol(st.vols{i},pos(1),pos(2),pos(3),st.hld)));
    end
end;
return;
%_______________________________________________________________________
%_______________________________________________________________________
function cm_handles = get_cm_handles
global st
cm_handles = [];
for i=valid_handles(1:24),
    cm_handles = [cm_handles st.vols{i}.ax{1}.cm];
end
return;
%_______________________________________________________________________
%_______________________________________________________________________
function zoom_all(op)
global st
cm_handles = get_cm_handles;
res = [.125 .125 .25 .5 1 1];
if op==6,
    st.bb = maxbb;
else,
    vx = sqrt(sum(st.Space(1:3,1:3).^2));
    vx = vx.^(-1);
    pos = spm_orthviews('pos');
    pos = st.Space\[pos ; 1];
    pos = pos(1:3)';
    if     op == 5, st.bb = [pos-80*vx ; pos+80*vx] ;
    elseif op == 4, st.bb = [pos-40*vx ; pos+40*vx] ;
    elseif op == 3, st.bb = [pos-20*vx ; pos+20*vx] ;
    elseif op == 2, st.bb = [pos-10*vx ; pos+10*vx] ;
    elseif op == 1; st.bb = [pos- 5*vx ; pos+ 5*vx] ;
    else disp('no Zoom possible');
    end;
end
resolution(res(op));
redraw_all;
for i = 1:length(cm_handles)
    z_handle = get(findobj(cm_handles(i),'label','Zoom'),'Children');
    set(z_handle,'Checked','off');
    set(z_handle(op),'Checked','on');
end
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% ROI: TimeSeries
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_searchContentEdit(hObject, eventdata)
handles = guidata(hObject);
set(handles.searchContentEdit,'UserData', 'manual');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% click load SPM file button
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_loadSPMmat(hObject, eventdata, spmfile)
handles = guidata(hObject);
if nargin < 3 | isempty(spmfile)
    %if exist(fullfile(pwd,'SPM.mat'), 'file')
    if findstr('SPM2',spm('ver'))
        spmfile = spm_get([1],'SPM.mat','Select a SPM file');
    elseif findstr('SPM5',spm('ver'))
        spmfile = spm_select(1,'SPM.mat','Select a SPM file');
    end
end
xSPM=load(spmfile);
if isfield(xSPM.SPM, 'xCon')
    numc=listdlg('ListString' , {xSPM.SPM.xCon.name}, 'SelectionMode' , 'single', 'InitialValue', 2);%length(xSPM.SPM.xCon));
    if ~exist(fullfile(xSPM.SPM.swd,xSPM.SPM.xCon(numc).Vspm.fname)) & ...
            exist(subarray(fullfile(xSPM.SPM.swd,xSPM.SPM.xCon(numc).Vspm.fname),1:2,-2))
        warning('Changing path')
        xSPM.SPM.swd=xSPM.SPM.swd(3:end);
    end
    if ~isempty(numc)
        if exist(xSPM.SPM.swd, 'dir')
            CallBack_loadImagePush(handles.loadImagePush, [],...
                {fullfile(xSPM.SPM.swd,xSPM.SPM.xCon(numc).Vspm.fname)},...
                {xSPM.SPM.xCon(numc).name});
        else
            CallBack_loadImagePush(handles.loadImagePush, [],...
                {fullfile(fileparts(spmfile),xSPM.SPM.xCon(numc).Vspm.fname)},...
                {xSPM.SPM.xCon(numc).name});
        end
    end    
else
    msgbox('No contrast in this file')
end
return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% paramest push (Parameter estimates)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_indivResultsListPush(hObject, eventdata)
handles = guidata(hObject);
if ischar(handles.imageFileName)
    handles.imageFileName={handles.imageFileName};
end
[datadir,condir]=fileparts(handles.imageFileName{1});

%MG 15.09.2008 if datadir(2)==':'
%     datadir=datadir(3:end);
% end
%--MG
[datadir,subdir]=fileparts(datadir);
if isempty(findstr('indiv/', datadir))
elseif isempty(findstr('rfx/', datadir))
    xSPM=load(fullfile(datadir,'SPM.mat'));
    indivdir=xSPM.xY.P;
else
    return
end

req = get(handles.indivResultsListPush,'String');
req = req{get(handles.indivResultsListPush, 'value')};

if isequal(req,'Group')
    datadir=fileparts(datadir);
    condir=handles.imageContrastName{1};
    condir=strrep(condir, '>', 'vs');
    condir=strrep(condir, '<', 'vs');
    condir=strrep(condir, '+', '_');
    condir=strrep(condir, ':', ' at');
    condir=deblank(condir);    
    condir=fullfile(datadir,'rfx',condir);
    if ~exist(condir,'dir')       
        return
    end
    xSPM=load(fullfile(condir,'SPM.mat'));
    numc=2;    
    CallBack_loadImagePush(handles.loadImagePush, [],...
        {fullfile(datadir,req,xSPM.SPM.xCon(numc).Vspm.fname)},...%MG:02.04.2008{fullfile(xSPM.SPM.swd,xSPM.SPM.xCon(numc).Vspm.fname)},...
        {xSPM.SPM.xCon(numc).name});
    return
elseif exist('swds','var')
    CallBack_loadImagePush(handles.loadImagePush, [],...
        swds(get(gcbo, 'value'),:),...
        handles.imageContrastName);
else

    %MG 15.09.2008
    if strmatch('.',req,'exact')>0
        return
    elseif strmatch('..', req,'exact')>0 
        newdir=spm_select(1,'dir','...Select directory containing the new SPM.mat!',''); newdir=fileparts(newdir)
        eval(['cd ' newdir])
        xSPM=load(spm_select('List',newdir,'SPM.mat'))
        [newdatadir,newreq]=fileparts(newdir);
        datadir=newdatadir; 
        req=newreq;
        newnumc=length(xSPM.SPM.xCon);
        numc=newnumc;
    elseif strmatch('GROUP',req)>0
        newdir=spm_select(1,'dir','...Select directory containing the new SPM.mat!',''); newdir=fileparts(newdir)
        eval(['cd ' newdir])
        xSPM=load(spm_select('List',newdir,'SPM.mat'))
        [newdatadir,newreq]=fileparts(newdir);
        datadir=newdatadir; 
        req=newreq;
        newnumc=length(xSPM.SPM.xCon);
        numc=newnumc;
        
%         xSPM=load(spm_select(1,'any','select SPM.mat!','',datadir,'SPM.mat'))
%         [newdatadir,newreq]=fileparts(xSPM.SPM.swd);
%         datadir=newdatadir;
%         req=newreq;
%         newnumc=length(xSPM.SPM.xCon);
%         numc=newnumc;
%         cd([datadir '\' req])
    else
        cd([datadir '\' req])
        xSPM=load(fullfile(datadir,req,'SPM.mat'));
    end
    %--MG
    
    if ~isfield(handles,'imageContrastName')
        return
    end    
    % numc=strmatch(handles.imageContrastName{1},{xSPM.SPM.xCon.name},'exact');   
    [datadir1,req1]=fileparts(datadir);
    if strfind('GROUP',req1)>0
        numc=2;
    else
    numc=get(handles.contrastListPush, 'Value');
    end
    %%MG 02.04.2008 filename=fullfile(xSPM.SPM.swd,xSPM.SPM.xCon(numc).Vspm.fname);
    filename=fullfile(datadir,req,xSPM.SPM.xCon(numc).Vspm.fname)
    %--MG
    
    if filename(2)==':'
        filename=filename(3:end);
    end
    set(handles.sectionViewListbox, 'Value', [1]);
    % handles.sectionViewTargetFile = fullfile('\ndiayek\data\gazemo\rawdata\',req,'anat','wf_0001.img');
    guidata(hObject, handles);
    CallBack_loadImagePush(handles.loadImagePush, [],...
        {filename},...
        {xSPM.SPM.xCon(numc).name});
    
%    CallBack_allIntensityRadio(hObject, eventdata, 'c');
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% paramest push (Parameter estimates)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CallBack_paramestRegionPush(hObject, eventdata, roi,readdata)
if nargin<4 
    readdata=1;
end
roi=struct('type', roi);
handles = guidata(hObject);
roi.name=get(handles.structureEdit, 'String');

[img.p, img.fname, img.ext]=fileparts(handles.imageFileName{1});
spmfile=fullfile(img.p,'SPM.mat');

if exist(spmfile(3:end), 'file')
    warning('Possible disk swapping in xjview.m');
    spmfile=spmfile(3:end);
end
if ~exist(spmfile)
    if findstr('SPM2',spm('ver'))
        spmfile = spm_get([0 1],'SPM.mat','locate the RFX SPM.mat');
    elseif findstr('SPM5',spm('ver'))
        spmfile = spm_select([0:1],'SPM.mat','locate the RFX SPM.mat');
    end
end
if ~exist(spmfile)
    return
end
xSPM=load(spmfile, 'SPM');


[glmpath, glmpath]=fileparts(fileparts(fileparts(xSPM.SPM.swd)));

%[xyzmm,i] = spm_XYZreg('NearestXYZ',...
%    spm_results_ui('GetCoords'),handles.currentxyz);
%spm_results_ui('SetCoords',xSPM.XYZmm(:,i));
switch roi.type
    case 'vox'
        if not(isfield(handles,'currentxyz')) %%%
            error('Wrong selection')
            return
        end
        xyz = handles.currentxyz;
    case 'clu'
        if  not(isfield(handles,'selectedCluster')) | not(isempty(handles.selectedCluster))
             switch questdlg('Load from workspace','cluster?', 'currentDisplayMNI{1}','...','Cancel','currentDisplayMNI{1}')
                case 'currentDisplayMNI{1}'
                    xyz=evalin('base', 'currentDisplayMNI{1}');
                 case '...'
                 case 'Cancel'
                    return
             end
             delete(findobj('Tag', 'paramest'))
             
        else
            delete(findobj('Tag', 'paramest'))
            xyz =handles.currentDisplayMNI{1};
        end
    case 'sph'
        if not(isfield(handles,'currentxyz')) %%%
            error('Wrong selection')
            return
        end
        delete(findobj('Tag', 'paramest'))
        xyz = handles.currentxyz;
        roi.radius=inputdlg('Radius of the sphere?');
        if isempty(roi.radius)
            return
        end
        roi.radius=str2num(roi.radius{1})
        %         XYZmm = xSPM.SPM.xVol.M(1:3,:)*[xSPM.SPM.xVol.XYZ; ones(1,size(xSPM.SPM.xVol.XYZ,2))];
        %         xyz = sqrt( XYZmm-repmat(xyz,[1 size(XYZmm,2)]) )
        %         xyz = XYZmm(:, xyz < roi.radius)

end
% handles.currentDisplayMNI{1}
% ha=axes('Tag', 'paramest', 'Parent',gcf,'units','normalized','Position',[0.55, 0.05, 0.4, 0.4]);
if isequal(roi.type, 'sph')
    if roi.radius > 20
        if not(spm_input({'Many many voxels may be retrieve','Radius of the sphere (in mm):',...
                num2str(roi.radius),...
                'Continue anyway?'},...
                1,'bd',{'OK','NO'},[1,0]))
            return
        end
    end

end
if size(xyz,1)>20
    if not(spm_input({'Many many voxels to retrieve','Number of voxel:',...
            num2str(size(xyz,1)),...
            'Continue anyway?'},...
            1,'bd',{'OK','NO'},[1,0]))
        return
    end
end

allbetas= [];
allxyz = [];
roi.nvox = []; 
hwait = waitbar(0,'Reading 1st level data');
lcd=cd;
handles.currentxyz
if isfield(handles, 'paramest')
    handles.paramest=[];
end

roi.stat.TF=handles.TF;
roi.stat.pValue=handles.pValue;
roi.stat.df=handles.df;
% roi.stat.Intensity =
% handles.currentDisplayIntensity{1}(find(all(handles.currentDisplayMNI{1}==repmat(handles.currentxyz, 3,1),2)));
[i,j]=ismember(handles.mni{1}, flipud(xyz), 'rows');
roi.stat.intensity(j(i)) = handles.intensity{1}(i);

if  isstruct(xSPM.SPM.xX.K) | ~readdata
    n=1;
    %     Ic=strmatch('F Task',{xSPM.SPM.xCon.name})
    %
    %     allbetas=[]
    %     vcon=
    %     XYZ  = SPM.xVol.XYZ;
    %     XYZmm = SPM.xVol.M(1:3,:)*[XYZ; ones(1,size(XYZ,2))];
    %     tmpallbetas= [];
    %     [nxyz,i] = spm_XYZreg('NearestXYZ',xyz(cluvox,:),XYZmm);
    %     allbetas = [allbetas;(mean(tmpallbetas,1))];
    %     allxyz= [allxyz;mean(tmpallxyz,1)];

else
    n= length(xSPM.SPM.xY.P)
end

for sub = 1:n

    waitbar(sub/n,hwait);
    if n>1
        subdir = fileparts(xSPM.SPM.xY.P{sub});
    else
        subdir = xSPM.SPM.swd;
    end
    try
        if ~exist(fullfile(subdir, 'SPM.mat'), 'file') & ...
                exist(subarray(fullfile(subdir, 'SPM.mat'),1:2,-2),'file')
            subdir = subdir(3:end);
        end
        load(fullfile(subdir, 'SPM.mat'));
        fprintf('Retrieving betas from: %s\n', fullfile(subdir, 'SPM.mat'))

        if sub==1
            %  [cn.path cn.fname cn.ext]=fileparts(char(xSPM.SPM.xY.P(sub,:)));
            % consfiles=[SPM.xCon.Vcon];
            Ic = [strmatch('f anim', lower({SPM.xCon.name})) strmatch('f task', lower({SPM.xCon.name})) strmatch('f map', lower({SPM.xCon.name}))];
            if isempty(Ic)
                Ic = listdlg('ListString',{SPM.xCon.name},'InitialValue',Ic);
            end
            Ic=Ic(end);
            conname=SPM.xCon(Ic).name;
        end

        %-------
        Ic    = strmatch(conname,{SPM.xCon.name}, 'exact') ; %contrast number
        if isempty(Ic)
            Ic = listdlg('ListString',{SPM.xCon.name});
        end
        %-------

        XYZ  = SPM.xVol.XYZ;
        XYZmm = SPM.xVol.M(1:3,:)*[XYZ; ones(1,size(XYZ,2))];
        tmpallbetas= [];
        tmpallxyz = [];
        cd(subdir)
        for cluvox = 1:size(xyz,1)
            switch (roi.type)
                case 'sph'
                    [d] = spm_XYZreg('Edist',xyz(cluvox,:),XYZmm);
                    i=find(d<=roi.radius);
                    govox = ~isempty(i);
                    nxyz=XYZmm(:,i);
                case {'vox', 'clu'}
                    govox = 1;
                    [nxyz,i] = spm_XYZreg('NearestXYZ',xyz(cluvox,:),XYZmm);
                    if sqrt(sum((nxyz'-xyz(cluvox,:)).^2))>=sqrt(3) %one voxel in each dimZ
                        govox= spm_input({'No data stored for this voxel','Closest voxels with data are:',...
                            num2str(xyz(cluvox,:)),...
                            'Continue anyway?'},...
                            1,'bd',{'OK','NO'},[1,0]);
                    end
            end
            if govox==1
                vXYZ     = XYZ(:,i)  ;        % coordinates in voxels
                %-Get parameter and hyperparameter estimates
                %=======================================================================
                beta  = spm_get_data(SPM.Vbeta, vXYZ);
                % ResMS = spm_get_data(SPM.VResMS,vXYZ);
                % Bcov  = ResMS*SPM.xX.Bcov;
                CI    = 1.6449;                                       % = spm_invNcdf(1 - 0.05);
                % compute contrast of parameter estimates and 90% C.I.
                %--------------------------------------------------------------
                tmpallbetas  = [tmpallbetas; (SPM.xCon(Ic).c'*beta)'];
                tmpallxyz = [tmpallxyz; nxyz'];
            end
        end
        allbetas = [allbetas;(mean(tmpallbetas,1))];
        allxyz= [allxyz;mean(tmpallxyz,1)];
        roi.nvox = [ roi.nvox; size(tmpallbetas,1)];        
        tmp = mean(tmpallxyz);
        %     disp(['meancluster = ' num2str(mean(tmpallxyz,1))]);
    catch
        warning('Error with data from: %s', subdir)
    end
end
close(hwait)
cd(lcd);
%
regnames=cellstr(subarray(strvcat(strrep(SPM.xX.name(any(SPM.xCon(Ic).c )),'*bf(1)', '')'), 1:6, -2));
regnames=cellstr(subarray(strvcat(strrep(SPM.xX.name(any(SPM.xCon(Ic).c')),'*bf(1)', '')'), 1:6, -2));
[regnames, ireg,ireg2]=unique(regnames);
a=[ repmat(' ',length(regnames),1) strvcat(strrep(regnames, '_', ' '))];
a=dataread('string',a', '%s');
leg=a(isort(ireg));
%a=reshape(a, [],108])';
%
% n=factor(size(allbetas,2));
% n=sort([n(end) prod(n(1:end-1))]);
%
% prompt={'Enter the matrix size for x^2:','Enter the colormap name:'};
% def={'20','hsv'};
% dlgTitle='Input for Peaks function';
% lineNo=1;
% answer=inputdlg(prompt,dlgTitle,lineNo,def);
%
% AddOpts.Resize='on';
% AddOpts.WindowStyle='normal';
% AddOpts.Interpreter='tex';
% answer=inputdlg(prompt,dlgTitle,lineNo,def,AddOpts);
%
assignin('base', 'allbetas', allbetas)
ReshapeData = [];
xbars=[];
fxorder=[2 3 1];
switch size(allbetas,2)
    case 8
        ReshapeData = [4 2];
    case 4
        if all(ismember(a,{'Neutral'    'Fearful'    'Angry'    'Happy'}))
            ReshapeData = [4 1];
        end
    case 18
        ReshapeData = [18 1];
    case 16
        %         ReshapeData = [2 8];
        %         xtick=[1  3 4 5  7 8 9  11];
        %         fxorder=[3 2 1];
        ReshapeData = [16 1];
end
if isempty(ReshapeData)
    ReshapeData = [fliplr(factor(size(allbetas,2))) 1];
    ReshapeData = [ ReshapeData(1) prod(ReshapeData(2:end))]
end
allbetas=reshape(allbetas, [],ReshapeData(1),ReshapeData(2));
allbetas = permute(allbetas,fxorder);
% allxyz=reshape(allxyz, [], 1, 3);
% allxyz=permute(allxyz, [3 2 1]);

%assignin('base', 'allbetas', allbetas)
%assignin('base', 'allxyz', xyz)
roi.allbetas=allbetas;
roi.allxyz=allxyz';
roi.XYZmm=xyz';
roi.xyz=mean(allxyz,1)';
assignin('base', 'roi', roi)

%%%%%%%%%%%%%%%%%%%%%%%%
% Plot betas in figures >> EDIT MG:
try    
    plot_betas(roi,glmpath,handles)
catch
    if n>1
        figure;barerrorbar(1:size(roi.allbetas,1),mean(roi.allbetas, ndims(roi.allbetas)),stderrw(roi.allbetas, 1:2, ndims(roi.allbetas)),NaN)
    else
         figure;bar(roi.allbetas)
    end
    mytitle=([roi.xyz(1,:) roi.xyz(2,:) roi.xyz(3,:)]);
    title(['Coordinates (',num2str(mytitle),')'])
    set(gca, 'XTickLabel', {'FULL_R' 'FULL_L' 'CHIM_b' 'CHIM_R' 'CHIM_L' 'DJ_b' 'DJ_R' 'DJ_L' 'UR' 'URx' 'UL' 'ULx' 'Rest'})
    xlabel('Condition')
    ylabel('beta parameter')
    legend({'Session1' 'Session2' 'Session3'},'Location', 'Best')
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% paramest push (Parameter estimates)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [c_num, c_let, c_word]=mycolourset
c_num = [1 0 0;0 1 0;1 1 0;0 1 1;0 0 1;1 0 1];
c_let = {'r';'g';'y';'c';'b';'m'};
c_word= {'red';'green';'yellow';'cyan';'blue';'magenta'};