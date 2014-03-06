function bads = artifacts(X,varargin)
if nargin==0
    f=[];
    try        
        f=evalin('base', 'f');
        h=evalin('base', 'h');
    end
    if isempty(f)
        if ispc
            [h,f,Time]=read_lena('\\Serveur_meg\homes\CONFINUM\data\S27\run1_feedback.lena');
        else
            [h,f,Time]=read_lena('/pclxserver/raid9/data/CONFINUM/data/S16/run1_feedback.lena');
        end
    end
    X=permute(f,[2 3 1]);
    %Time=[0:size(X,2)-1]./1024-str2num(h.description.time_range.pre_trigger)
end
if abs(log10(var(X(1,:), [], 2)) - 8) < 1
    X=X*1e-9;
end

ich = 76;
thd = -75e-6;
IW = 1:718;


%% Figure
close(figure_call(mfilename))
hf = figure('name',mfilename);
setappdata(hf,'X',X)

ha = subplot(2,6,2:6);
hp = pcolor(Time, 1:size(X,3),squeeze((X(ich,:,:)))');
set(hp,'EdgeColor', 'none')
caxis([-100 100]*1e-6);
hcb = colorbar('peer',ha, 'EastOutside');
h = colorbar_slider(hcb);
hcbs=h(1);
set(hcbs, 'Callback', '')
hb = list_badtrials(hf);
set(hcbs, 'Value', thd)

%% detect on MOV
bad = any(X(ich,IW,:)<thd, 2);
axes(ha)
line([Time(IW(end)) Time(IW(end))], [1 size(X,3)], 'Color', 'k')
set(hb, 'String', num2str(find(bad)))
X(:,:,bad)=NaN;
set(hp, 'CData', squeeze((X(ich,:,:)))')


%% GFP
ha = subplot(2,6,6+[2:6]);
z=rootmeansquare(X(1:74,:,:));
hp = pcolor(Time, 1:size(X,3),squeeze(z)');
set(hp,'EdgeColor', 'none')
line([Time(IW(end)) Time(IW(end))], [1 size(X,3)], 'Color', 'k')
caxis([0 100]*1e-6);
hcb = colorbar('peer',ha, 'EastOutside');   
h = colorbar_slider(hcb);
hcbs=h(1);
set(hcbs, 'Callback', '')
hb = list_badtrials(hf);
set(hcbs, 'Value', thd)
set(hp, 'ButtonDownFcn', 'x=get(gcbo,''CData''); figure;plotnd(X(1:74,:,subarray(round(get(get(gcbo,''parent''), ''CurrentPoint'')),3,Inf)));  ')


return
%% fig 2
hf = figure('name',mfilename);





return

% -------------------------------------------------------------------------
hf=figure('name', mfilename)
set(hf,'pointer','fullcrosshair')
%% IMAGE
subplot(2,2,1)
ho=imagesc(squeeze((X(76,:,:)))');
caxis([-100 100]*1e3);
set(ho, 'ButtonDownFcn','axes;plot(x(subarray(round(get(get(gcbo,''parent''), ''CurrentPoint'')),3,Inf),:));  ')


function [h] = list_badtrials(hf)
ha = subplot(1,6,1);
set(ha, 'units', 'normalized')
pos = get(ha, 'position');
delete(ha)
h = uicontrol('style', 'list', 'units', 'normalized', 'tag', 'list_badtrials');
set(h, 'position', pos*[1 0 -0.75 0;0 1 0 0; 0 0 1.25 0; 0 0 0 1]')







function [h] = colorbar_slider(ha)
pos=get(ha, 'Position');
h=uicontrol('style', 'slider', 'units', get(ha,'units'),'tag', mfilename);
% Check orientation of colorbar
if isempty(get(ha, 'Xtick'))
    % vertical colorbar
    if strmatch('right',get(ha, 'YAxisLocation'))
        set(h(1), 'Position',pos*[1 0 -0.5 0;0 1 0 0; 0 0 .5 0; 0 0 0 1]')
    else
        set(h(1), 'Position',pos*[1 0 +1.5 0;0 1 0 0; 0 0 .5 0; 0 0 0 1]')

    end
    set(h(1), 'Min',min(get(ha, 'YLim')), 'max',max(get(ha, 'YLim')),'value',min(get(ha, 'YLim')))

else
    % horizontal colorbar
    if strmatch('top',get(ha, 'XAxisLocation'))
        set(h, 'Position',pos*[1 0 0 0;0 1 0 -0.5; 0 0 1 0; 0 0 0 .5]')
    else
        set(h, 'Position',pos*[1 0 0 0;0 1 0 +1.5; 0 0 1 0; 0 0 0 .5]')
    end
    set(h, 'Min',min(get(ha, 'XLim')), 'max',max(get(ha, 'XLim')),'value',min(get(ha, 'XLim')))
end
% set(h, 'SliderStep', (get(h,'Max')-get(h,'Min')).*[1/100 1/10]);
set(h, 'UserData', ha);
setappdata(h(1), 'Colorbar', ha);
setappdata(h, 'Figure', get(ha,'Parent'));
setappdata(h, 'BaseColormap', colormap);
setappdata(h, 'BaseColor', [.6 .6 .6]);
setappdata(h, 'CurrentColormap', colormap);
set(h, 'Callback', sprintf('%s(''slide'', gcbo);', mfilename));



return