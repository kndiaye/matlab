function a = krippendorff_alpha(R)
%KRIPPENDORFF_ALPHA - Krippendorff’s Alpha-Reliability between raters
%   [] = krippendorff_alpha(input)
%
%   Example
%       >> krippendorff_alpha
%
%   See also:

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2010
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2010-09-23 Creation
%
% ----------------------------- Script History ---------------------------------


R = [ 'a     a     b     b     d     c     c     c     e     d     d     a   ' ...
    '  b     a     b     b     b     c     c     c     e     d     d     d     ']
R = reshape(R(R~=' '),12,2)' - 'a'


R= [1     2     3     3     2     1     4     1     2     NaN   NaN   NaN
    1     2     3     3     2     2     4     1     2     5     NaN   NaN
    NaN   3     3     3     2     3     4     2     2     5     1     3
    1     2     3     3     2     4     4     1     2     5     1     NaN ];


[no , nm] = size(R);
if no==2
    if ~any(isnan(R))
        r = (unique(R(~isnan(R))));        
        nr = numel(r);
        P = nchoosek(r,2);
        P = [ P  ; fliplr(P) ];
        P = sortrows([ [r(:) r(:)] ; P ]);
        np = size(P,1);
        %Coincidence values
        C = repmat(R, [ 1 1 np]) == permute(repmat(P',[1 1 nm ]), [1 3 2]);
        C = squeeze(sum(all(C),2))
        % ... into matrix
        C = reshape(C,[nr nr]);
        C = C' + C;
        n = 2*nm;
        nc = sum(C);
        sc = sum(nc.*(nc-1))
        a = (n-1)*sum(diag(C)) - sc;
        a = a / (n*(n-1)-sc)
    else
        mu = no - sum(isnan(R));

    end

end
return
%%
