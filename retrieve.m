function  [Y,I] = retrieve(X,varargin)
%RETRIEVE - Find and elements according to the result of a logical test
%   [Y,I] = retrieve(X,test)
%
%   Example
%       >> retrieve(randn(1,100), @(a)a>2)
%
%   See also: find, nonzeros, nonnans()

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2009
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2009-08-11 Creation
%
% ----------------------------- Script History ---------------------------------
if nargin<2
    I=logical(X);
else
    test=varargin{1};
    if isa(test, 'function_handle')
        [I]=feval(test,X);
    end
end
Y=X(I);