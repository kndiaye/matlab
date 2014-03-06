function [varargout] = cellfun2(varargin)
% cellfun2() - Cap funtion for cellfun which accepts any function call
%
% D = CELLFUN2(FUN, C) applies function FUN to the cells of C
%
% D = CELLFUN2(FUN, C, P,...) applies function FUN to the cells of C using
% parameters P in the call of FUN
%
%See also: cellfun

try
    if nargout == 0
        builtin('cellfun', varargin{:});
    else
        [varargout{1:nargout}] = builtin('cellfun', varargin{:});
    end
catch
    if nargout > 1
        error('cellfun2 cannot handle more than one output')
    end
    if iscell(varargin{1}) || ~iscell(varargin{2})
        error('cellfun2 input format is: cellfun2(function, cell array, ...)')
    end
    fname = varargin{1};
    x = varargin{2};
    y = cell(size(x));
    for i=1:numel(x)
        y{i} = feval(fname, x{i},varargin{3:end});
    end
    varargout{1} = y;
end
