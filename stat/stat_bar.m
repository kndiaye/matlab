function  [s] = stat_bar(X,varargin)
%STAT_BAR - Bar plot with elementary statistics
%   [s] = stat_bar(X,dimS,dimG)
%       Display a bar plot with elementary statistics computed over
%       population in dimS, grouped with dimG
%
%   Example
%       >> stat_bar
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
% KND  2006-03-13 Creation
%
% ----------------------------- Script History ---------------------------------
sX=size(X);
if nargin<2
    dimS=find(sX>1);
    sX(dimS)=-sX(dimS);
else
    dimS=varargin{1};
end
if nargin<3
    dimG=find(sX>1);
else
    dimG=varargin{2};
end

paired=1;
if dimS<0
    paired=0;
    dimS=-dimS;
end
X=permute2(X, [dimS dimG]);
s.mX=mean(X,1);
if paired
    s.semX=stderrw(X,2,1);
    [s.p,s.T]=myttest(X,2,1,'pttest');
else
    s.semX=stderr(X,1);
    [s.p,s.T]=myttest(X,2,1,'ttest');
end
s.mX=shiftdim(s.mX,1);
s.semX=shiftdim(s.semX,1);
s.h=barerrorbar(1:prod(sX)./sX(dimG)./sX(dimS),s.mX(:,:)', s.semX(:,:)')
