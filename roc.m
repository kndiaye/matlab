function [auc] = roc(s,r,c,varargin)
%ROC - Receiver-Operating Characteristics (ROC) curve and the area under it
%   [AUC] = roc(S,A,C) compute area under the ROC curve
%   S: N-by-1 binary vector of signal
%   R: N-by-1 binary vector of responses
%   C: Classes of responses, default: one class so A = d' (d-prime)
%   
%   Example
%       >> roc
%
%   See also:

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2009
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2009-04-07 Creation
%
% ----------------------------- Script History ---------------------------------
if nargin<2 && size(s,2)==2
    r = s(:,2);
    s = s(:,1);
end
s=logical(s);
r=logical(r);
if nargin<3
    nc=1;
else
    [uc,ic,jc]=unique(c);
    nc=length(uc);
end

if nc>1
    for i=1:nc
        hr(i)=mean(r( s(jc==i)));
        fa(i)=mean(r(~s(jc==i)));
    end
else
    hr=mean(r( s));
    fa=mean(r(~s));
end
hr 
fa

plot(hr,fa, 'o')
return
if nargout==0
    plot_roc(hr,fa)
end
return


function [] = plot_roc(x,y)
NL=8;
[z,c,b] =  histfun(x(:),y(:),NL, 'mean'); 
plot(1:NL,z, 'o-')


