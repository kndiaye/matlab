function [varargout]=struct2minf(x,minfname)
% struct2minf - converts a matlab struct into Brainvisa minf info
% 
%  [s]=struct2minf(x,minfname)
% 
% Input:
%       x : matlab structure
%       [optional] fname: filename for output (e.g. 'toto.tex.minf')
%
% Output:
%       [optional] s : character array


s=['attributes = {\n' ];
ff=fieldnames(x);
nff=length(ff);
for iff=1:nff
  f=getfield(x,ff{iff});
  s=[ s '    ''' ff{iff} ''' : '];
  if iscell(f) 
    s= [ s '[' ];
    for i=1:length(f)
      if not(ischar(f{i}))
	error(sprintf('%s: cannot print non character cell array!', mfilename));
      end
      s=[ s '"' f{i} '" ' ];
    end
    s= [ s ']' ];
  elseif ischar(f)
    s=[ s '''' f ''''];
  elseif isnumeric(f)
    if length(f)>1
      s= [ s '[ ' ];
      for i=1:length(f)
	s=[ s ''''  num2str(f(i)) '''' ];
	if i<length(f)
	  s=[ s ', '];
	end
      end
      s= [ s ' ]' ];
    else
      s=[ s '[''' num2str(f) ''']' ];
    end
  end
  if iff<nff
    s= [ s ', \n'];
  end
end
 s= [ s '\n  }'];

if nargin>1
  fid=fopen(minfname, 'wt');
  fprintf(fid,s);
  fclose(fid);
end
if nargout>0
  varargout(1)={s};  
end
if nargout == 0 & nargin==1
    fprintf('%s\n', s)
end
return 
% attributes = {'MinT': ['-0.256000'], 'MaxT': ['0.752000'], 'Trial': ['1']}
