function [pdffit,offset,A,B,resnorm,h] = distributionfit(data,distribution,nbins)
%function [pdffit,offset,A,B,resnorm,h] = distributionfit(data,distribution,nbins)
%PURPOSE                                                             jdc  rev. 06-jun-05
%   Fit one of three probability distributions (normal, lognormal, weibull)
%   to input data vector. If the distribution is specified as 'best' the dis-
%   tribution that best fits the data is selected automatically.
%INPUT
%   If nargin==1, "distribution" is prompted for and entered interactively
%
%   data         - n x 1 or 1 x n  input data vector 
%   distribution - probability distribution to fit to "data". Can
%                  be 'normal', 'lognormal', 'weibull', or 'best' ... default: 'best'
%   nbins        - number of bar-chart bins ......................... default: sqrt(length(data))
%OUTPUT
%   pdffit       - fitted probability density function - n x 2 matrix with column 1 the
%                  x-values, column 2 the y values
%   offset       - amount by which the data was offset for lognormal or weibull fits 
%                  (to satisfy the positive-definite requirements for these distributions).
%                  Note: this is roughly equivalent to fitting a 3- rather than a 2-parameter
%                  distribution.
%   A,B          - distribution parameters - mu and sigma for normal and lognormal distributions,
%                  scale and shape parameters for weibull distribution
%   h            - handles to the bar chart and probability density curve
%
%TYPICAL FUNCTION CALLS
%  distributionfit(randn(10000,1));
%  distributionfit(wblrnd(2,3,10000,1));
%  distributionfit(wblrnd(2,3,10000,1),'weibull');
%  distributionfit(lognrnd(1.5,.5,10000,1),'lognormal');
%  distributionfit(lognrnd(1.5,.5,10000,1),'best');
%  distributionfit(lognrnd(1.5,.5,10000,1),'lognormal');
%
%REFERENCE
%  Statistics Toolbox Version 3.0.2, function HISTFIT.M 

data = data(~isnan(data));
data = data(:);
ndata = length(data);
if nargin<3 | isempty(nbins), nbins = ceil(sqrt(ndata)); end
if nargin==1,
   distID = menu('Choose a Distribution','Normal','Lognormal','Weibull','best');
else
   if     strfind(lower(distribution),'lognormal'), distID = 2;
   elseif strfind(lower(distribution),'normal'   ), distID = 1;
   elseif strfind(lower(distribution),'weibull'  ), distID = 3;
   elseif strfind(lower(distribution),'best'     ), distID = 4;
   elseif isempty(distribution),                    distID = 4;
   end
end   
switch distID
   case 1, distribution = 'Normal';
   case 2, distribution = 'Lognormal';
   case 3, distribution = 'Weibull';
   case 4
      data = sort(data);
      cdfe = (1:ndata)'/ndata;                      % experimental cdf
      phat = mle(data,'distribution','Normal');
      A = phat(1);   % for normal & lognormal, phat = [mu std], for weibull, = [A B]
      B = phat(2);
      cdft = cdf('Normal',data,A,B);             % best-fit cdf
      residuals = cdfe-cdft;
      resnormNormal = residuals'*residuals;
      %-------------------------------------      
      offset = -min(data)+10*eps;
      offsetdata = data+offset; % zero-shift data so smallest value is 0+
      phat = mle(offsetdata,'distribution','Lognormal');
      A = phat(1);   % for normal & lognormal, phat = [mu std], for weibull, = [A B]
      B = phat(2);
      cdft = cdf('Lognormal',offsetdata,A,B);             % best-fit cdf
      residuals = cdfe-cdft;
      resnormLognormal = residuals'*residuals;
      %-------------------------------------      
      phat = mle(offsetdata,'distribution','Weibull');
      A = phat(1);   % for normal & lognormal, phat = [mu std], for weibull, = [A B]
      B = phat(2);
      cdft = cdf('Weibull',offsetdata,A,B);             % best-fit cdf
      residuals = cdfe-cdft;
      resnormWeibull = residuals'*residuals;
      %-------------------------------------    
      resnorms = [resnormNormal resnormLognormal resnormWeibull];
      distID = find(resnorms==min(resnorms));
      switch distID
         case 1, distribution = 'Normal';
         case 2, distribution = 'Lognormal';
         case 3, distribution = 'Weibull';
      end      
end 
if distID==2 | distID==3, 
   offset = -min(data)+10*eps;
   data = data+offset; % zero-shift data for lognormal and weibull fits so smallest value is 0+
elseif distID==1,
   offset = 0;   
end   
%----------------------------------------------------------------------
figure
[n,xbin]=hist(data,nbins);
hh = bar(xbin,n,1); % get number of counts per bin and bin width
xd = get(hh,'Xdata'); % retrieve the x-coordinates of the bins.
rangex = max(xd(:)) - min(xd(:)); % find the bin range
binwidth = rangex/nbins;    % find the width of each bin.
close(gcf);   % close figure (will replot on probability scale)
%----------------------------------------------------------------------
ch = get(0,'children');
if isempty(ch),
   figure(1);
else   
   figure(max(ch)+1);
end
set(0,'Units','inches');
ss = get(0,'ScreenSize');
set(0,'Units','pixels');
width = 3;
height = 3;
edge = 0.25;
set(gcf,'Units','inches','Position',[ss(3)-width-edge ss(4)-height-edge width height],...
        'Color',[.8 .8 .8],'InvertHardCopy','off','PaperPosition',[1 1 width height]);
nscaled = n/(ndata*binwidth);   % convert bin counts to probabilities
hh = bar(xbin,nscaled,1);       % draw the probability-scaled bars
set(hh,'EdgeColor',[.6 .6 .6],'FaceColor',[.9 .9 .9]);
set(gca,'FontSize',8);
xlabel('Data');
ylabel('Probability Density');
%----------------------------------------------------------------------
phat = mle(data,'distribution',distribution); % probability distribution parameter estimation
A = phat(1);   % for normal & lognormal, phat = [mu std], for weibull, = [A B]
B = phat(2);
switch distID  % get limits for plotting the best-fit pdf curve
   case 1,
      lolim = norminv(0.0001,A,B);
      hilim = norminv(0.9999,A,B); 
   case 2,
      lolim = logninv(0.0001,A,B);
      hilim = logninv(0.9999,A,B);
   case 3,
      lolim = wblinv(0.0001,A,B);
      hilim = wblinv(0.9999,A,B);
end      
xpdf = (lolim:(hilim-lolim)/100:hilim); % construct the x-vector for the pdf curve
ypdf = pdf(distribution,xpdf,A,B);    
hh1 = line(xpdf,ypdf,'Color','r','LineWidth',2); % overplot the histogram with the best-fit pdf curve
pdffit = [xpdf(:) ypdf(:)];
%----------------------------------------------------------------------
data = sort(data);                           % compute resnorm
cdfe = (1:ndata)'/ndata;                      % experimental cdf
cdft = cdf(distribution,data,A,B);             % best-fit cdf
residuals = cdfe-cdft;
resnorm = residuals'*residuals;
%----------------------------------------------------------------------
xlim = get(gca,'Xlim');
ylim = get(gca,'Ylim');
trd = text(xlim(2),ylim(2),distribution,'FontSize',8,'HorizontalAlignment','right','VerticalAlignment','bottom'); 
ext = extent(trd);
tld = text(ext(1),ylim(2),'Distribution: ',       'FontSize',8,'HorizontalAlignment','right','VerticalAlignment','bottom');

trr = text(xlim(2),ylim(2)-ext(4),sprintf('%8.1e ',resnorm),'FontSize',8,'HorizontalAlignment','right','VerticalAlignment','middle');
ext = extent(trr);
tll = text(ext(1),ylim(2)-ext(4),'Resnorm: ','FontSize',8,'HorizontalAlignment','right','VerticalAlignment','middle');

tt =    text(xlim(2),ylim(2)-ext(4),sprintf('%4.2f   ',A),'FontSize',8,'HorizontalAlignment','right','Visible','off');
ext = extent(tt);

i = 1;
switch distID
   case {1,2} 
      if distID==2,
         tl(i) = text(ext(1),ylim(2)-(i+1)*ext(4),'Zero Shift: ');
         tr(i) = text(ext(1),ylim(2)-(i+1)*ext(4),sprintf('%+5.2f',offset));
         i = i+1;
      end   
      tl(i) =    text(ext(1),ylim(2)-(i+1)*ext(4),'Sigma: ');
      tr(i) =    text(ext(1),ylim(2)-(i+1)*ext(4),sprintf('%4.2f',B));
      i = i+1;
      tl(i) =    text(ext(1),ylim(2)-(i+1)*ext(4),'Mu: ');
      tr(i) =    text(ext(1),ylim(2)-(i+1)*ext(4),sprintf('%4.2f',A));
   case 3   
      tl(i) =    text(ext(1),ylim(2)-(i+1)*ext(4),'Zero Shift: ');
      tr(i) =    text(ext(1),ylim(2)-(i+1)*ext(4),sprintf('%+5.2f',offset));
      i = i+1;
      tl(i) =    text(ext(1),ylim(2)-(i+1)*ext(4),'scale: ');
      tr(i) =    text(ext(1),ylim(2)-(i+1)*ext(4),sprintf('%4.2f',A));
      i = i+1;
      tl(i) =    text(ext(1),ylim(2)-(i+1)*ext(4),'shape: ');
      tr(i) =    text(ext(1),ylim(2)-(i+1)*ext(4),sprintf('%4.2f',B));
end
set(tl,'Color','k','FontSize',8,'HorizontalAlignment','right','VerticalAlignment','middle'); 
set(tr,'Color','k','FontSize',8,'HorizontalAlignment','left', 'VerticalAlignment','middle'); 
%----------------------------------------------------------------------
h = [hh; hh1];
