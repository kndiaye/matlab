function [ hh th ] = e2pie(varargin)
%PIE    Pie chart.
%   E2PIE(X) draws a pie plot of the data in the vector X.  The values in X
%   are normalized via X/SUM(X) to determine the area of each slice of pie.
%   If SUM(X) <= 1.0, the values in X directly specify the area of the pie
%   slices.  Only a partial pie will be drawn if SUM(X) < 1.
%
%   E2PIE(X,EXPLODE) is used to specify slices that should be pulled out from
%   the pie.  The vector EXPLODE must be the same size as X. The slices
%   where EXPLODE is non-zero will be pulled out.
%
%   E2PIE(...,LABELS) is used to label each pie slice with cell array LABELS.
%   LABELS must be the same size as X and can only contain strings.
%
%   E2PIE(AX,...) plots into AX instead of GCA.
%
%   H = E2PIE(...) returns a vector containing patch and text handles.
%
%   E2PIE is different from the MATLAB version in that labels have
%   line segments indicating which slice they belong to, and are
%   spaced more rationally.
%
%   Example
%      e2pie([2 4 3 5],{'North','South','East','West'})
%
%   See also PIE.

%   Clay M. Thompson 3-3-94
%   Updated Eric M. Ludlam 2005
%   Copyright 1984-2006 The MathWorks, Inc.

% Parse possible Axes input
[cax,args,nargs] = axescheck(varargin{:});

if nargs==0, error('Not enough input arguments.'); end %#ok

x = args{1}(:); % Make sure it is a vector
args = args(2:end);

if nargs>3, error('Too many input arguments.'); end %#ok

nonpositive = (x <= 0);
if any(nonpositive)
  warning('MATLAB:pie:NonPositiveData',...
          'Ignoring non-positive data in pie chart.');
  x(nonpositive) = [];
end
xsum = sum(x);
if xsum > 1+sqrt(eps), x = x/xsum; end

% Look for labels
if nargs>1 && iscell(args{end})
  txtlabels = args{end};
  if any(nonpositive)
    txtlabels(nonpositive) = [];
  end
  args(end) = [];
else
  for i=1:length(x)
    if x(i)<.01,
      txtlabels{i} = '< 1%'; %#ok
    else
      txtlabels{i} = sprintf('%d%%',round(x(i)*100)); %#ok
    end
  end
end

% Look for explode
if isempty(args),
   explode = zeros(size(x)); 
else
   explode = args{1};
   if any(nonpositive)
     explode(nonpositive) = [];
   end
end

explode = explode(:); % Make sure it is a vector

if ~isempty(txtlabels) && length(x)~=length(txtlabels),
  error('Cell array of strings must be the same length as X.'); %#ok
end

if length(x) ~= length(explode),
  error('X and EXPLODE must be the same length.'); %#ok
end

cax = newplot(cax);
next = lower(get(cax,'NextPlot'));
hold_state = ishold(cax);

theta0 = pi/2;
maxpts = 100;
inside = 0;

h = [];
ytextmidlast = nan;
xtextlast = nan;
for i=1:length(x)
  n = max(1,ceil(maxpts*x(i)));
  r = [0;ones(n+1,1);0];
  theta = theta0 + [0;x(i)*(0:n)'/n;0]*2*pi;
  txttheta = theta0 + x(i)*pi;
  
  if inside,
    [xtext,ytext] = pol2cart(txttheta,.5);
  else
    [xtext,ytext] = pol2cart(txttheta,1.05);
  end
  
  [xx,yy] = pol2cart(theta,r);
  if explode(i),
    [xexplode,yexplode] = pol2cart(theta0 + x(i)*pi,.1);
    xtext = xtext + xexplode;
    ytext = ytext + yexplode;
    xx = xx + xexplode;
    yy = yy + yexplode;
  end
  theta0 = max(theta);
  h(i) = patch('XData',xx,'YData',yy,'CData',i*ones(size(xx)), ...
               'FaceColor','Flat','parent',cax);
  
  %% ERIC HACK
  if ~isempty(txtlabels)
      if ytext > .7
          ytextmid = ytext+.1;
      elseif ytext < -.7
          ytextmid = ytext-.1;
      else
          ytextmid = ytext;
      end

      if xtext > 0
          % We are slices on the right side of the chart
          ha = 'left';
          xtextend = xtext+.2;
          xtextmid = xtext+.1;
          
          if ~isnan(ytextmidlast) && xtextlast > 0 
              if ytextmidlast >= ytextmid-.05
                  ytextmid = ytextmidlast + .05;
              end
          else
              %% First label.  Use a flat line if > .7
              if ytext > -.7
                  ytextmid = ytext;
              end
          end
          
      else
          ha = 'right';
          xtextend = xtext-.2;
          xtextmid = xtext-.1;
          
          if ~isnan(ytextmidlast) && xtextlast > 0 && ytextmidlast >= ytextmid+.05
              ytextmid = ytextmidlast - .05;
          end
      end

      if ~isempty(txtlabels{i})
          
          xdata = [ xtext xtextmid xtextend ];
          ydata = [ ytext ytextmid ytextmid ];
          line(xdata, ydata, [ 0 0 0 ], 'color','k',...
               'clipping','off');
          
          t(i) = text(xtextend,ytextmid,txtlabels{i},...
                      'parent',cax,...
                      'horizontalalign',ha); %#ok
          ytextmidlast = ytextmid;
          xtextlast = xtext;
      end
  end
  %% END ERIC HACK
end

if ~hold_state, 
  view(cax,2); set(cax,'NextPlot',next); 
  axis(cax,'equal','off',[-1.2 1.2 -1.2 1.2])
end

if nargout>0, hh = h; end
if nargout>1, th = t; end
