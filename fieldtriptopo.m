function fieldtriptopo(Channel,data)
xyz=getChannelLoc(Channel);
labels={Channel.Name};
cfg.zlim='absmax';
cfg.colorbar='yes';
cfg.showlabels='no';
cfg.showzlim='yes';
cfg.fontsize=8;
topoplot(cfg,xyz(:,1),xyz(:,2),data,labels);
return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is a subfunction for topoplotTFR and topoplotER that takes care of 
% the actual interpolation and plotting.
%
% It is a modified version from the topoplot function of EEGLAB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Copyright (C) Andy Spydell, Colin Humphries & Arnaud Delorme 
% CNL / Salk Institute, Aug, 1996
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function topoplot(cfg,X,Y,Values,Labels)

% User Defined Defaults:
MAXCHANS = 256;
INTERPLIMITS = 'head';  % head, electrodes
GRID_SCALE = 67;  % 67 in original
CONTOURNUM = 6;
STYLE = 'both';       % both,straight,fill,contour,blank
HCOLOR = [0 0 0];
ECOLOR = [0 0 0];
CONTCOLOR = [0 0 0];
EMARKERSIZE = 8;
EFSIZE = get(0,'DefaultAxesFontSize');
HLINEWIDTH = 2;
EMARKER = '.';
SHADING = 'flat';     % flat or interp
INTERPOLATION = 'v4';

Ypos = -0.45+0.9*(X - min(X)) /(max(X) - min(X));
Xpos = -0.45+0.9*(Y - min(Y)) /(max(Y) - min(Y));

rmax = .5;

ha = gca;
cla
hold on

if ~strcmp(STYLE,'blank')
  % find limits for interpolation
  if strcmp(INTERPLIMITS,'head')
    xmin = min(-.5,min(Xpos)); xmax = max(0.5,max(Xpos));
    ymin = min(-.5,min(Ypos)); ymax = max(0.5,max(Ypos));
  else
    xmin = max(-.5,min(Xpos)); xmax = min(0.5,max(Xpos));
    ymin = max(-.5,min(Ypos)); ymax = min(0.5,max(Ypos));
  end
  
  xi = linspace(xmin,xmax,GRID_SCALE);   % x-axis description (row vector)
  yi = linspace(ymin,ymax,GRID_SCALE);   % y-axis description (row vector)
  
  [Xi,Yi,Zi] = griddata(Ypos,Xpos,Values,yi',xi,INTERPOLATION); % Interpolate data
  
  % Take data within head
  mask = (sqrt(Xi.^2+Yi.^2) <= rmax);
  ii = find(mask == 0);
  Zi(ii) = NaN;
  
  % calculate colormap limits
  m = size(colormap,1);
  if isstr(cfg.zlim)
    if strcmp(cfg.zlim,'absmax')
      amin = -max(max(abs(Zi)));
      amax = max(max(abs(Zi)));
    elseif strcmp(cfg.zlim,'maxmin')
      amin = min(min(Zi));
      amax = max(max(Zi));
    end
  else
    amin = cfg.zlim(1);
    amax = cfg.zlim(2);
  end
  delta = xi(2)-xi(1); % length of grid entry
  
  % Draw topoplot on head
  if strcmp(STYLE,'contour')
    contour(Xi,Yi,Zi,CONTOURNUM,'k');
  elseif strcmp(STYLE,'both')
    surface(Xi-delta/2,Yi-delta/2,zeros(size(Zi)),Zi,'EdgeColor','none',...
      'FaceColor',SHADING);
    contour(Xi,Yi,Zi,CONTOURNUM,'k');
  elseif strcmp(STYLE,'straight')
    surface(Xi-delta/2,Yi-delta/2,zeros(size(Zi)),Zi,'EdgeColor','none',...
      'FaceColor',SHADING);
  elseif strcmp(STYLE,'fill')
    contourf(Xi,Yi,Zi,CONTOURNUM,'k');
  else
    error('Invalid style')
  end
  caxis([amin amax]) % set coloraxis
end

set(ha,'Xlim',[-rmax*1.3 rmax*1.3],'Ylim',[-rmax*1.3 rmax*1.3])

% Define the contours of the head
l = 0:2*pi/100:2*pi;
basex = .18*rmax;  
tip = rmax*1.15; base = rmax-.004;
EarX = [.497 .510 .518 .5299 .5419 .54 .547 .532 .510 .489];
EarY = [.0555 .0775 .0783 .0746 .0555 -.0055 -.0932 -.1313 -.1384 -.1199];

% Plot Electrodes
if strcmp(cfg.showlabels,'markers') 
  hp2 = plot(Ypos,Xpos,EMARKER,'Color',ECOLOR,'markersize',EMARKERSIZE);
elseif strcmp(cfg.showlabels,'yes')
  for i = 1:length(Xpos)
    text(Ypos(i),Xpos(i),Labels(i),'HorizontalAlignment','center',...
      'VerticalAlignment','middle','Color',ECOLOR,...
      'FontSize',EFSIZE)
  end
elseif strcmp(cfg.showlabels,'numbers')
  for i = 1:length(Xpos)             
    text(Ypos(i),Xpos(i),int2str(i),'HorizontalAlignment','center',...
      'VerticalAlignment','middle','Color',ECOLOR,...
      'FontSize',EFSIZE)
  end
end

% Plot Head, Ears, Nose
plot(cos(l).*rmax,sin(l).*rmax,...
  'color',HCOLOR,'Linestyle','-','LineWidth',HLINEWIDTH);
plot([.18*rmax;0;-.18*rmax],[base;tip;base],...
  'Color',HCOLOR,'LineWidth',HLINEWIDTH);

plot(EarX,EarY,'color',HCOLOR,'LineWidth',HLINEWIDTH)
plot(-EarX,EarY,'color',HCOLOR,'LineWidth',HLINEWIDTH)   

if strcmp(cfg.colorbar,'yes')
  colorbar
end

if strcmp(cfg.showzlim,'yes')
  text(0,-0.6,sprintf('Color limits:\n %.2e to %.2e ',amin,amax),'fontsize',cfg.fontsize,'HorizontalAlignment','center')
end

hold off
axis off
