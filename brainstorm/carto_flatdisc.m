function h = carto_flatdisc(Channel, data, Contours, DrawLines,DrawNose,BackgroundColor)
%CARTO_DISC - Display M/EEG scalp data on a 2D disc
%   [] = carto_flatdisc(input)
%
%Syntax:
%   [sensors] = carto_flatdisc(Channel,data)
%   [sensors] = carto_flatdisc(Channel,data,Contours,DrawLines,DrawNose,BackgroundColor)
%


% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2006
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2006-02-21 Creation
% KND  2010-03-25 +contours
% ----------------------------- Script History ---------------------------------

if nargin<6
    BackgroundColor = [ 1 1 1 ];
end
if nargin<5
    DrawNose=1;
end
if nargin<4
    DrawLines=0;
end
if nargin<3
    Contours=6;
end
% Guess that inputs may have been inverted:
if isfield(data, 'Loc') || (~isvector(data) && isvector(Channel)) 
    tmp = data;
    data = Channel;
    Channel = tmp;
    clear tmp;
end

if prod(size(data))>max(size(data)) && ~isvector(data)
    error('Data must be 1-D')
end

% I'm tricky, i draw the line in white on white background!
set(gcf, 'color',BackgroundColor)

data=data(:);
isens=1:min(size(data,1),length(Channel));
if isfield(Channel, 'Loc')
   for i=1:length(isens)
        sensloc(i,1:3)=Channel(isens(i)).Loc(:,1)';
    end
    Channel=Channel(isens);
else
    sensloc=Channel(isens,:);
    Channel=[];
end
CONTOURNUM = 0;


%% Some Geometry...

% [TH,PHI,R] = cart2sph(sensloc(:,1),sensloc(:,2),sensloc(:,3)-max(sensloc(:,3)));
% R2 = R./cos(PHI).^.2;
% [Y,X] = pol2cart(TH,R2);
% tri = delaunay(Y,X);
% % h=patch('faces',tri,'vertices',[Y,X,0.*X],'CData',cdata,'edgecolor','none','FaceColor','interp');
% 

center=[0 0 0];

nans=find(isnan(data));
sensloc(nans,:)=[];
data(nans)=[];
nmes = size(sensloc,1);


[teta,phi,R] = cart2sph(sensloc(:,1)-center(1),sensloc(:,2)-center(2),sensloc(:,3)-center(3));
R = mean(R);
phimin = min(phi);
phimax = max(phi);
tetamin = min(teta);
tetamax = max(teta);
[x y z] = sph2cart(teta,phi,R*ones(size(phi)));
[xt yt zt] = sph2cart(teta,phi,R*1.0*ones(size(phi)));
N = 25;
phi = (phimin:(pi/2 - phimin)/N:pi/2)'*ones(1,N+1);
teta= (0: 2*pi/N : 2*pi )'*ones(1,N+1);
xs = cos(teta').*cos(phi);
ys = sin(teta').*cos(phi);
zs = sin(phi);
xs=xs(:)*R;
ys=ys(:)*R;
zs=zs(:)*R;

[TH,PHI,R] = cart2sph(xs,ys,zs-max(zs));
R2 = R./cos(PHI).^.2;
[Y,X] = pol2cart(TH,R2);

%% Surface
tri = delaunay(Y,X);
cdata = griddata(xt,yt,data,X,Y,'invdist');
hp=patch('faces',tri,'vertices',[Y,X,0.*X],'CData',cdata,'edgecolor','none','FaceColor','interp');

axis image
hold on

set(hp,'ButtonDownFcn','subarray(get(gcbo,''CData''),imax(-edist(mean(get(get(gcbo,''Parent''),''CurrentPoint'')),nd2array(cat(3,get(gcbo,''Xdata''),get(gcbo,''Ydata''),get(gcbo,''Zdata'')),3)'')),Inf)')

[TH,PHI,R] = cart2sph(sensloc(:,1),sensloc(:,2),sensloc(:,3)-max(sensloc(:,3)));
R2 = R./cos(PHI).^.2;
[Y,X] = pol2cart(TH,R2);
tri = delaunay(Y,X);
xmax=max(X);
xmin=min(X);
ymax=max(Y);
ymin=min(Y);
rmax2=max(xmax,abs(xmin)).^2 + max(ymax,abs(ymin)).^2;


%% UI menu
cmenu = uicontextmenu;
set(hp, 'uiContextMenu', cmenu)
uimenu(cmenu,'Label', 'Show markers of sensors', 'callback', 'set(findobj(gcbf,''tag'',''sensor''),''Visible'',''on'')')
uimenu(cmenu,'Label', 'Hide markers of sensors', 'callback', 'set(findobj(gcbf,''tag'',''sensor''),''Visible'',''off'')')
uimenu(cmenu,'Label', 'Show name of sensors', 'callback', 'set(findobj(gcbf,''tag'',''sensorlabel''),''Visible'',''on'')')
uimenu(cmenu,'Label', 'Hide name of sensors', 'callback', 'set(findobj(gcbf,''tag'',''sensorlabel''),''Visible'',''off'')')
uimenu(cmenu,'Label', 'Sensors value (sorted)', 'callback', 'for i=findobj(gcbf,''tag'',''sensor''); end;')
%% Sensors
for i=1:length(data)
    hs(i)=plot3(Y(i),X(i),min(abs(sensloc(:,3))),'o');
    set(hs(i),'markerfacecolor',[.2 1 .2],'markersize',3,'Tag','sensor');
    if isfield(Channel, 'Name')
        ch=setdiff(1:length(Channel), nans);
        %set(hs(i), 'ButtonDownFcn', sprintf('fprintf(''%s (%d)'');try;fprintf('' = '');end;fprintf(''\\n'');', Channel(ch(i)).Name,i));        
        set(hs(i), 'ButtonDownFcn', 'fprintf(''%s (%d)'', getappdata(gcbo,''Label''), getappdata(gcbo,''Index''));try;fprintf('' = '');end;fprintf(''\n'');');        
        setappdata(hs(i), 'Label', Channel(ch(i)).Name);
        setappdata(hs(i), 'Index', i);        
        h = text(Y(i),X(i), Channel(ch(i)).Name, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
        set(h, 'tag', 'sensorlabel', 'visible', 'off')        
    end
end


%% Nose & Ears
if DrawNose
    rmax=max(X);
    headl = 0:2*pi/100:2*pi;
    basex = .18*rmax;
    tip = rmax*1.15;
    base = rmax-.004*rmax/.1;
    HLINEWIDTH = 2;
    HCOLOR = [1 1 1]- get(gcf, 'color');
    z_level = -min(abs(sensloc(:,3)));
    hold on
    hn=plot3([base;tip;base],[.18*rmax;0;-.18*rmax],[base;tip;base].*0+z_level); % plot nose    
    LE = [
        0.0216    0.1455
        0.0368    0.1523
        0.0368    0.1565 
        0.0334    0.1622
        0.0271    0.1633
        0.0123    0.1565
        0.0040    0.1535
        -0.0063    0.1548
        -0.0164    0.1582
        -0.0249    0.1607
        -0.0294    0.1575
        -0.0308    0.1514        
        -0.0247    0.1441
        -0.0139    0.1422
        -0.0029    0.1422
        ]./.15;
    LE(end+1,:)=LE(1,:);
    LE = LE*rmax;
    hn(2) = plot3(LE(:,1), LE(:,2), LE(:,1).*0+z_level);
    hn(3) = plot3(LE(:,1), -LE(:,2), LE(:,1).*0+z_level);
    set(hn, 'Color',HCOLOR,'LineWidth',HLINEWIDTH)
end


%% Contours
if length(Contours)>0
    GRID_SCALE = 100;  % 67 in original
    xi = linspace(xmin,xmax,GRID_SCALE);   % x-axis description (row vector)
    yi = linspace(xmin,ymax,GRID_SCALE);   % y-axis description (row vector)
    INTERPOLATION = 'v4';
    [Xi,Yi,Zi] = griddata(Y,X,data,yi',xi,INTERPOLATION); % Interpolate data
   % remove points which fall out of the head plot
    for i=1:length(Zi)
        if rmax2<(Xi(i)^2+Yi(i)^2)
            Zi(i)=NaN;
            i
        end
    end

    if length(Contours)>1  || isequal(Contours,0)
        CONTOURLEVELS = Contours;
        CONTOURNUM = length(CONTOURLEVELS);
    else
        CONTOURNUM = Contours;
        CONTOURLEVELS=max(abs(data))/(CONTOURNUM/2+1);
        if mod(CONTOURNUM,2)
            CONTOURLEVELS=CONTOURLEVELS.*[ceil(-CONTOURNUM/2):floor(CONTOURNUM/2)];
        else
            CONTOURLEVELS=CONTOURLEVELS.*[setdiff((-CONTOURNUM/2):(CONTOURNUM/2),0)];
        end
    end
    [c,hc]=contour(Xi,Yi,Zi,CONTOURLEVELS,'w');
    set(hc, 'tag', mfilename, 'color', get(gcf, 'color'))
    colorbar
    hold off
end

%% Colors
colorbar

view(-90,90);
hold off
axis tight
axis off
% Believe it or not the scribe code for colorbar is buggy when used with
% contour plots in the picture... See line 228, in scribe.colorbar
caxis(max(abs(data))*[-1 1])
ha=colorbar;
% KND 2009-11-12 changed child=get(ha,'children');
child=findobj(get(ha,'children'), 'Type', 'image');
set(ha, 'YLim', caxis);
set(child, 'ydata', caxis);
axes(ha)
if DrawLines & CONTOURNUM>0
    hl=line((get(ha,'Xlim'))'*ones(1,CONTOURNUM),ones(2,1)*get(hc, 'LevelList'));
    set(hl,'LineStyle', '-')
    set(hl,'Color', get(hc(1),'color'))
end
axes(get(hp, 'Parent'))
hold off

return


%% 

isens=isens(:);
if nargin==2
    data=isens;
    isens=1:size(data,1);
end
if size(data,1)~=length(isens) %& all(ismember(isens, 1:size(data,1)))
    data=data(isens);
end
if isfield(Channel, 'Loc')
    for i=1:length(isens)
        sensloc(i,1:3)=Channel(isens(i)).Loc(:,1)';
    end
    Channel=Channel(isens);
else
    sensloc=Channel(isens,:);
    Channel=[];
end

center=[0 0 0];


nans=find(isnan(data));
sensloc(nans,:)=[];
data(nans)=[];
nmes = size(sensloc,1);
% CTF xyz system is not classical
sensloc=sensloc(:,[2 1 3]);
[teta,phi,R] = cart2sph(sensloc(:,1)-center(1),sensloc(:,2)-center(2),sensloc(:,3)-center(3));
R = mean(R);
phimin = min(phi);
phimax = max(phi);
tetamin = min(teta);
tetamax = max(teta);
[x y z] = sph2cart(teta,phi,R*ones(size(phi)));
[xt yt zt] = sph2cart(teta,phi,R*1.0*ones(size(phi)));
N = 25;
phi = (phimin:(pi/2 - phimin)/N:pi/2)'*ones(1,N+1);
teta= (0: 2*pi/N : 2*pi )'*ones(1,N+1);
xs = cos(teta').*cos(phi);
ys = sin(teta').*cos(phi);
zs = sin(phi);
xs=xs(:)*R;
ys=ys(:)*R;
zs=zs(:)*R;
[TH,PHI,R] = cart2sph(xs,ys,zs-max(zs));
R2 = R./cos(PHI).^.2;
[Y,X] = pol2cart(TH,R2);

tri = delaunay(Y,X);
cdata = griddata(xt,yt,data,X,Y,'invdist');
h=patch('faces',tri,'vertices',[Y,X,0.*X],'CData',cdata,'edgecolor','none','FaceColor','interp');

return

if OPTIONS.ShowContours % Add contour plot
    n = sqrt(size(PlotHandles.TopoPlot(mod).Yo{iSet},1));
    PlotHandles.TopoPlot(mod).Yo{iSet} = reshape(PlotHandles.TopoPlot(mod).Yo{iSet},n,n);
    PlotHandles.TopoPlot(mod).Xo{iSet} = reshape(PlotHandles.TopoPlot(mod).Xo{iSet},n,n);
    [PlotHandles.TopoPlot(mod).Contour{iSet}.C,PlotHandles.TopoPlot(mod).Contour{iSet}.H] = contour(PlotHandles.TopoPlot(mod).Yo{iSet},...
        PlotHandles.TopoPlot(mod).Xo{iSet},...
        CData,'w-');
end


return

if datatype == 1
    CData = DisplayStruct.TopoPlot(k).Wmat{iSet} * Disp.TimeSeries{iSet}(data.Measures.Display.SelectedChannels{k},tindx);
    CData = reshape(CData,sqrt(length(CData)),sqrt(length(CData)));
    CData = CData * max(abs(Disp.TimeSeries{iSet}(data.Measures.Display.SelectedChannels{k},tindx)))/max(abs(CData(:))); % properly rescale to data amplitude
elseif datatype == 2
    F = data.Results.IndepTopo(:,iSet)*data.Results.TimeSeries(:,iSet)';
    CData = DisplayStruct.TopoPlot(k).Wmat{iSet} * F(:,tindx);
    CData = reshape(CData,sqrt(length(CData)),sqrt(length(CData)));
    CData = CData * max(abs(F(:,tindx)))/max(abs(CData(:))); % properly rescale to data amplitude
end

set(DisplayStruct.TopoPlot(k).surf{iSet},'CData',CData)

if data.Measures.Display.Flags.ShowContours %& ishandle(DisplayStruct.TopoPlot(k).Contour{iSet}.H) % Add contour plot

    axes(DisplayStruct.TopoPlot(k).axes{iSet});
    %hc=findobj(gcf,'type','hggroup');%DisplayStruct.TopoPlot(k).Contour{iSet}.H;%;(ishandle(DisplayStruct.TopoPlot(k).Contour{iSet}.H)); % Contour handle
    try
        delete(DisplayStruct.TopoPlot(k).Contour{iSet}.H);
        waitfor(DisplayStruct.TopoPlot(k).Contour{iSet}.H); % Make sure the (deletion) work is done                                    catch
        [DisplayStruct.TopoPlot(k).Contour{iSet}.C,DisplayStruct.TopoPlot(k).Contour{iSet}.H] = contour(DisplayStruct.TopoPlot(k).Yo{iSet},DisplayStruct.TopoPlot(k).Xo{iSet},CData,'w-');
    catch % an error can occur when user keeps pressing the time slider; contour cannot follow at the required pace and finally that produces an error
        % doing nothing while user is
        % holding the mouse button is just
        % ensuring that contours will be
        % updated only when button is
        % released and no error is shown in
        % command window.
        bst_message_window('wrap','Contour map cannot be refreshed at that pace; please release the mouse button and do several mouse clicks instead')
    end

    drawnow

end