function sc=run
set(0,'DefaultFigureWindowStyle','docked')
%addpath('/Users/ndiaye/mtoolbox/matlab-washington')
p.t = .5;
p.b = 2;
example(p)
coh = @(x)10.^-x;
ptarget = .7;

xstart=-log10(0.3);
sstart = .1;
dstart = 4; 
chancefloor = 1;

%sc= CreateStaircase(.7,[[0.1;10;4],[0.02;2;Inf]],x,-1);
sc=  CreateStaircase(ptarget,xstart,sstart,dstart,chancefloor)

Weibull(p,xstart)
n=300;
for i=1:n;
    x=GetStaircaseVariable(sc);
    r = rand<Weibull(p,coh(x));
    sc = SetStaircaseResponse(sc,x,r)
    sc=UpdateStaircase(sc);
end

sc.x=sc.x(1:n);
sc.r=sc.r(1:n);
ShowStaircaseResults(GetStaircaseResults(sc))

function y = Weibull(p,x,e,g)
%y = Weibull(p,x)
%
%Parameters:  p.b slope
%             p.t threshold yeilding ~80% correct
%             x   intensity values.
%
%y = Weibull(p,x,[,e,g])
%


if nargin<3
    e = (.5)^(1/3);  %threshold performance ( ~80%)
end
if nargin<4
    g = 0.5;  %chance performance
end

%here it is.
k = (-log( (1-e)/(1-g)))^(1/p.b);
y = 1- (1-g)*exp(- (k*x/p.t).^p.b);




function example(p)


x = linspace(.05,1,101);
%p.t = .5;
bList = p.b;% 1:4;
figure(1)
clf
%subplot(1,2,1)
y = zeros(length(bList),length(x));
for i=1:length(bList)
    p.b = bList(i);
    y(i,:) = Weibull(p,x);
end
plot(log(x),y')
set(gca,'XTick',log([.1,.2,.4,.8]));
logx2raw;
legend(num2str(bList'),'Location','NorthWest');
xlabel('Intensity');
ylabel('Proportion Correct');
title('Varying b with t=0.3');