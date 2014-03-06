%How to deal with MEX files in a toolbox shared by multiple OS and matlab
%versions...
%
% I wanted to know whether someone would have a solution to manage multiple
% matlab versions (and thus multiple complied form of a given mex files) :
% the problem that I have is that we have different versions of matlab
% using a common home-made toolbox which contains some mex files. And since
% mex file extension is the same independently of the matlab version that
% has created it and there is no backward compatibility, each time one uses
% a different matlab version, one needs to recompile those mex file to use
% the toolbox.
% What would be your advice to allow these various matlab versions to use
% that toolbox whithout conflicting ? Does anyone have a working solution
% (e.g. having subdirectories named after the matlab version/release
% number/date and put mex files in it ...) ?
%
% See: http://www.mathworks.com/matlabcentral/newsreader/view_thread/263301


function varargout = genericname(varargin)
comp = computer;
mext = mexext;

switch [computer version mexext ]
    
    [varargout{:}] = genericname_decoration1(varargin{:});
elseif( comp and mexext match __2__ )
   [varargout{:}] = genericname_decoration2(varargin{:});
elseif( etc. etc. )

end
return
end