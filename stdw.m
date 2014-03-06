function Y = stdw(X,dimF,dimS)
%STDW - Standard deviation for repated measure
%
%   Y=stdw(X,dimF)
%   Y=stdw(X,dimF,dimS)
%   Computes unbiased standard deviation in fully repeated design.
%       dimF indicates the dimension(s) of repeated factors/treatment
%       dimS indicates the observations/subjects dimension
%            (default: the first non-singleton dimension beside factors)
%
%   Example:
%   5 different measures in 2 tasks by 3 condition for 10 subjects in a
%   within subject design giving the data matrix X such as:
%       size(X)==[ 2 3 5 10 ] 
%       >> Y=stdw(X,1:2,4);
%          Y is thus of size [2 3 5 1]
%
%   See also: stderrw, std, stderr

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2006 
% This program isfree software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2006-01-05 Creation
%                   
% ----------------------------- Script History ---------------------------------


sX=size(X);
ndX=ndims(X);
if nargin<3
    sY=sX;
    sY(dimF)=0;
    dimS = min(find(sY>1));
    if isempty(dimS), error('Not enough '); end
end
sY=sX;
sY(dimS)=1;
Y=zeros(sY);
sF=sX(dimF);
NL=prod(sX(dimF));
NS=sX(dimS);
NX=[sX(setdiff(1:ndX,[dimS dimF])) 1];

% for each subject center X and compute stderr
pX=[dimF dimS setdiff(1:ndX,[dimS dimF])];
X=permute(X,pX);
X=reshape(X,[NL,NS,NX]);
X=X-repmat(mean(X,1),[NL 1]);
Y=std(X,[],2);
Y=reshape(Y,[sX(dimF),1,NX]); 
Y=ipermute(Y,pX);
return



