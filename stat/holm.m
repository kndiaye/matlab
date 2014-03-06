function [sig,alpha]=holm(alpha,n)
% HOLM - Holm adjustment of alpha level for multiple comparisons
%
%   alpha2=holm(alpha1, n) computes the new alpha2 to use when running
%   n tests with a familywise error rate of alpha
%   
%   [sig,alphas]=holm(alpha,p) assess the significance of the p-values
%   coming from multiple tests according to the Holm's procedure yielding a
%   familywise error rate of alpha. p being a vector of p-values, sig will
%   be a logical vector of the same size.
%
% See also: dunnsidak, hochberg

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2007 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2007-11-05 Creation
%                   
% ----------------------------- Script History ---------------------------------

% Ref:
% http://www.unc.edu/courses/2007spring/biol/145/001/docs/lectures/Oct6.html
%

if numel(n)==1 & n>=1
    alpha=alpha.*(1./(n-(0:n-1)));
    sig=alpha;
    return
end
p=n;
sz=size(p);
[p,ip]=sort(p(:));
n=numel(p);
% alpha=holm(alpha,n);
alpha=alpha.*(1./(n-(tiedrank(p)-1)));
sig=logical(p.*0+1);
i=find(p>alpha(:));
if ~isempty(i)
    sig(i(1):end)=0;
end
sig(ip)=sig;
sig=reshape(sig,sz);