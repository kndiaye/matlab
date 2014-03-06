function [y]=chi2_cdf(x,dof,invcdf)
%chi2_cdf -  Cumulative Distribution Function (CDF) of Chi² (Chi square) distribution
%    [P]=chi2_cdf(chi2,dof)
% To get the Chi2 from the p-value (i.e. inverse cdf):
%   Chi2 = chi2_cdf(P,-dof,1)
%
% KND, 2011

if nargin<3
    invcdf=0;
end
if dof<0
    dof=-dof;
    invcdf=1;
end
if invcdf
    y=ones(size(x));
    y(x==0)=0;
    y(x==1)=Inf;
    y(x<0)=NaN;
    for i=find(y==1);        
        fun = @(y)(abs(chi2_cdf(y,dof)-x(i)));
        % Guess starting point from normal approximation
        y0 = dof+2*sqrt(dof)*erfcinv(2*x(i));
        y0 = max(0,y0);
        [y(i),fval,flag,o]=fminsearch(fun,y0);
    end
else
    y = gammainc(x/2,dof/2);    
    y(x<0)=NaN;
end
return