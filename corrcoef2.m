function [r,p,t,z,p_yy,z_yy,r_yy]=corrcoef2(X,Y,sp)
%CORRCOEF2 - Iterative cap function for CORRCOEF
%   [r,p,t,z]=corrcoef2(X,Y) computes the Pearson's correlation
%   coefficients between the columns of X (a M-by-N matrix) and columns of
%   Y (a M-by-P one) leading to a N-by-P matrix.
%   r and p have the same size as the rest of Y.
%   T-value t is computed as: t = r.*sqrt((n-2)./(1-r.^2));
%   Z-score z is : z = log(abs((r+1)./(r-1)))/2
%   [ref: http://faculty.chass.ncsu.edu/garson/PA765/correl.htm#faq]
%
%   [r,p,t,z,p_yy,z_yy,r_yy]=corrcoef2(X,Y) also reports significant
%   difference between correlations coefficients derived from Y columns.
%   This requires that X is a M-by-1 vector.
%   Ref: Comparing correlated correlation coefficients, Meng, 1992
%
%   [...] = corrcoef2(X,Y,sp) draws scatterplots (if sp==true)
%See also: corrcoef

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2010
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2010-02-04 Creation
%
% ----------------------------- Script History
% ---------------------------------

sX=size(X);
sY=size(Y);
Y=Y(:,:);
if isvector(X)
    X=X(:);
    sX=size(X);
    if numel(X)~=sY(1)
        error('KND:corrcoef2:XYmismatch', 'The length of X and the number of lines in Y must match.');
    end
else
    if ~isequal(sX(3:end),sY(3:end))
        error('KND:corrcoef2:XYmismatch', 'The remaining dimensions of X and Y must match.');
    end
    X=X(:,:);
end
r=NaN*zeros([sX(2) sY(2:end)]);
p=r;
for ix=1:sX(2)
    for iy=1:sY(2)
        [r2,p2]=corrcoef(X(:,ix),Y(:,iy));
        r(ix,iy)=r2(2);
        p(ix,iy)=p2(2);
    end
end

if nargout>2
    n=sX(1);
    t = r.*sqrt((n-2)./(1-r.^2));
    if nargout>3
        z = log(abs((r+1)./(r-1)))/2;
    end
end

if nargout > 4
    if sX(2) > 1
        error('KND:corrcoef2:Xvectorfor', 'X must be a vector of observations for comparing regressors in Y.');
    end
    nY=prod(sY(2:end));

    % pairs of Y's
    yy = nchoosek(1:nY,2);
    % indices of the yy
    idx = find(tril(ones(nY),-1));
    % cross-correlations in Y
    r_yy = corrcoef(Y);
    r_yy = r_yy(idx);

    r2 = sum(r(yy).^2')'/2;
    f = (1-r_yy)./2./(1-r2);
    f(f>1)=1;
    h = 1 +  r2./(1-r2).*(1-f);

    z_yy=diag(Inf*ones(nY,1));

    z_yy(idx) = diff(z(yy)')'.*sqrt((n-3)./2./(1-r_yy)./h);
    z_yy = z_yy + -z_yy';

    %z_yy(z_yy<0)=-Inf;
    p_yy = 0.5 * erfc(z_yy ./ sqrt(2));

end
if nargin<3
    return
end
% Scatterplots
nx=size(X,2);
ny=size(Y,2);
for i=1:nx
    for j=1:ny
        subplot(nx,ny,(j-1)*nx+i)
        plot(Y(:,j),X(:,i),'x')
        axis square
    end
end


return

%% avoid using corrcoef

% ToDO: Implement directly corrcoef code down here.

t = isnan(x);
% Compute correlation for each pair
r = eye(m,class(x));
n = diag(sum(t,1));
jk = 1:2;
for j = 2:m
    jk(1) = j;
    for k=1:j-1
        jk(2) = k;
        tjk = ~any(t(:,jk),2);
        njk = sum(tjk);
        if njk<=1
            rjk = NaN;
        else
            rjk = correl(x(tjk,jk));
            rjk = rjk(1,2);
        end
        r(j,k) = rjk;
        n(j,k) = njk;
    end
end
r = r + tril(r,-1)';
n = n + tril(n,-1)';

% ------------------------------------------------
function [r,n] = correl(x)
%CORREL Compute correlation matrix without error checking.

[n,m] = size(x);
c = cov(x);
d = sqrt(diag(c)); % sqrt first to avoid under/overflow
dd = d*d'; dd(1:m+1:end) = diag(c); % remove roundoff on diag
r = c ./ dd;

