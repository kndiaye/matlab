function [beta]=power_ttest(X1,X2,alpha)
% [beta]=power_ttest(X1,X2,alpha)


error

if size(X1)==2
    mX = X1(:);
    if numel(X2)==1
        X2=[X2;X2];
    end
    if numel(X2)~=2
        error
    end
    sX=X2(:);
else
    mX = [ mean(X1) ; mean(X2)];
    sX = [ std(X1)  ;  std(X2)];
    
end



function power=powerfunT(mu0,mu1,sig,alpha,tail,n)
%POWERFUNT T power calculation
    S = sig ./ sqrt(n);       % std dev of mean
    ncp = (mu1-mu0) ./ S;     % noncentrality parameter

    if tail==0
        critL = tinv(alpha/2,n-1);   % note tinv() is negative
        critU = -critL;
        power = nctcdf(critL,n-1,ncp) + nctcdf(-critU,n-1,-ncp); % P(t < critL) + P(t > critU)
    elseif tail==1
        crit = tinv(1-alpha,n-1);
        power = nctcdf(-crit,n-1,-ncp); % 1-nctcdf(crit,n-1,ncp), P(t > crit)
    else % tail==-1
        crit = tinv(alpha,n-1);
        power = nctcdf(crit,n-1,ncp); % P(t < crit)
    end 