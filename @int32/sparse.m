function [varargout]=sparse(varargin)
switch nargin
    case 1
        varargout={sparse(double(varargin{1}))};
    case 2
        varargout{1}=sparse(double(varargin{1}),double(varargin{2}));
    case 3
        varargout{1}=sparse(double(varargin{1}),double(varargin{2}),double(varargin{3}));
    case 5
        varargout{1}=sparse(double(varargin{1}),double(varargin{2}),double(varargin{3}),double(varargin{4}),double(varargin{5}));
end
