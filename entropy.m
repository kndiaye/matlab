function H = entropy(X,varargin)
%ENTROPY - Entropy in bits
%   [H] = entropy(X,b)
%       Computes Shannon's entropy (column-wise) in bits
%
%   See also: 

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2006 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2006-10-24 Creation
%                   
% ----------------------------- Script History ---------------------------------
[e,n,f]=histk(X,varargin{:});
if ~iscell(e)
    e={e};
    n={n};
end
for i=1:numel(e)
    N=sum(n{i});
    % Trick:
    % We replace 0 by -1 which has imaginary log
    n{i}=numrep(n{i}./N,0,-1);
    H(i)=-sum(nonzeros(n{i}).*log(nonzeros(n{i})))./log(2);
    % Now we discard the imaginary part
    H(i)=real(H(i));
end