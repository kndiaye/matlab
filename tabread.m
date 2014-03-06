function [A,B,N]=tabread(file,varargin)
% tabread - reads tabulated data NOT IMPLEMENTED YET


% [X,N]=tabread(file)
% [X,N]=tabread(file,'headerlines', ... , 'delimiter', ...)
% 
% Reads tabultaed data, where the field names are in the first
% column. N is a cell of field names, X is the rest of the
% (numerical) values

% error('NOT IMPLEMENTED YET')

if nargin>2
  Options=struct(varargin{:});
else 
  Options=[];
end

if not(isfield(Options, 'skiplines'))
  Options.skiplines=0;
end

if not(isfield(Options, 'headerlines'))
  Options.headerlines=false;
end

if not(isfield(Options, 'delimiters'))
  Options.delimiter='\t ';
end
% Options.delimiter=[Options.delimiters{:}];

if not(isfield(Options, 'deblank'))
  Options.deblank=1;
end

fid=fopen(file, 'rt');
for i=1:Options.skiplines
  fgetl(fid);
end
ok = 1;
i=1;
N={};
X=[];
sx=0;
while not(feof(fid)) && ok
  t=fgetl(fid);
  if not(isempty(t))
    t=strread(t, '%s', 'delimiter', Options.delimiter);
    N{i,1}=t{1};
    sx=size(X,2);
    X(i,:)=str2num(strvcat(t(2:end)))';
    if sx>0 & size(X,2)>sx
      warning('Zero-padding due to non rectangular data!')
      
    end
    i=i+1;
  end

end
  