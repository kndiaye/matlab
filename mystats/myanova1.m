function [p,F]=anova1(X)
% Row-by-row One-way ANOVA
% X = [groups x replicates x ...]

sX=size(X);
% Number of groups
ng=sX(1);
% Number of replicates, ie. samples in each group
nr=sX(2);

% Within group stats
dfw=ng*(nr-1);
mXw=mean(X,2);
SSw=sum(sum((X-repmat(mXw,[1 nr])).^2,2),1);
MSw=SSw/dfw;

% Population stats
dft=ng*nr-1;
mX=mean(mXw,1);
SSt=sum(sum((X-repmat(mX,[ng nr])).^2));
MSt=SSt/dft;

% Between group stats
dfb=ng-1;
mXb=mean(X,1);
SSb=nr*sum(sum((mXw-repmat(mX,[ng 1])).^2,2),1);
MSb=SSb/dfb;

% SSb=SSt-SSw;
% MSb=SSb/dfb;

% Test whether F [ dfbetween , dfwithin ] < x
F=MSb./MSw;
p=1-f_cdf(F,dfb,dfw);
    
return