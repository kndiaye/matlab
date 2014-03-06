function [x]=nth(a,varargin)
%Nth : N-th element in an array
%
%    [x]=nth(a,varargin)
%
% Useful for 'pipeing' i.e. input-output redirection.
% e.g. fun1() returns an array, but you want fun2() to use the k-th value
% returned by fun1() : disp(fun2(nth(fun1(x), k)))
if nargin<2
    error(('no'))
end
if all(cellfun('isreal',varargin)) 
    x=a(varargin{:});
else
    x=eval(['a(' varargin{:} ')']);
end