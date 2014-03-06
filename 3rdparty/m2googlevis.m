function htmlStr  =  m2googlevis(varargin)
%M2GOOGLEVIS creates html code for Google's visualization API
%
%  htmlstr  =  m2googlevis('style','parm1',data1,...,'parmn',datan [,opts])
%
%  Inputs:
%  -------
%  'style' is a string from the following list which will choose the Google
%     Visualization API package to use
%       'lineChart'
%       'scatterChart'
%
%  'parm' is a string giving the name of the variable to be plotted
%
%  data is a vector (either a cell array of strings or a double) giving the
%    corresponding data to be plotted
%
%  opts is an optional structure with the following fields:
%    legendLocn  =  location of the legend 
%                                    ('bottom','left','top','right','none')
%    title  =  The title of the plot
%
%  Outputs:
%  --------
%  htmlStr is a a character string which can be saved directly to an HTML
%    file for web display

%  title - m2googlevis.m     author - Adam Leadbetter (alead@bodc.ac.uk)
%  version - 0.2             date - 2008Dec18
%
%  Revisions
%  ---------
%  0.2   2008Dec22 Adam Leadbetter - Added scatterChart
%
  a = ['''' repmat('%s ', 1, 5) ''''];
%
%  Check the invocation
%   TODO: Check that all the inputs are of the same length
%
  if(isstruct(varargin{end}))
    opts  =  varargin{end};
    varargin(end)  =  [];
  else
    opts.legendLocn  =  'right';
    opts.title  =  '';
  end
  htmlStr  =  ['<html><head><script type="text/javascript" ' ...
    'src="http://www.google.com/jsapi"></script><script ' ...
    'type="text/javascript">'];
%
%  Pick the package that we're plotting to...
%
  switch varargin{1}(:)'
    case 'lineChart'
      vizPack.name  =  'linechart';
      vizPack.chart  =  'LineChart';
    case 'scatterChart'
      vizPack.name  =  'scatterchart';
      vizPack.chart  =  'ScatterChart';
    otherwise
      error('Error: Unrecognised M2GOOGLEVIS style...');
  end
  htmlStr  =  [htmlStr  'google.load("visualization", "1",'...
    '{packages:["' vizPack.name '"]});'];
  htmlStr  =  [htmlStr 'google.setOnLoadCallback(drawChart);'];
  htmlStr  =  [htmlStr 'function drawChart() {'];
  htmlStr  =  [htmlStr 'var data = new google.visualization.DataTable();'];
%
%  Add the columns and their names
%
  ii  =  2;
  nParms  =  0;
  while(ii  <  nargin)
    htmlStr  =  [htmlStr 'data.addColumn(' a(1) 'number' a(1) ',' ...
      a(1) varargin{ii} a(1) ');'];
    ii  =  ii + 2;
    nParms  =  nParms + 1;
  end
%
%  Add the data rows
%
  htmlStr  ...
    =  [htmlStr 'data.addRows(' num2str(length(varargin{3}(:)))  ');'];
  ii  =  1;
  while(ii  <=  length(varargin{3}(:)))
    jj  =  1;
    while(jj  <=  nParms)
      htmlStr  =  [htmlStr 'data.setValue(' num2str(ii - 1) ','  ...
        num2str(jj - 1) ','  num2str(varargin{((jj * 2) + 1)}(ii)) ');'];
                                        %TODO: Add in handling of string
                                        %data
      jj  =  jj + 1;
    end
    ii  =  ii + 1;
  end
%
%  Close the html
%
  htmlStr  =  [htmlStr ...
    'var chart = new google.visualization.' vizPack.chart '(document.' ...
    'getElementById(' a(1) 'chart_div' a(1) '));chart.draw(data, '...
    '{width: 800, height: 480, legend: ' a(1) opts.legendLocn a(1) ...
    ', title: ' a(1) opts.title a(1) '});'];
  htmlStr  =  [htmlStr '}</script></head>'];
  htmlStr  =  [htmlStr '<body><div id="chart_div"></div></body></html>'];