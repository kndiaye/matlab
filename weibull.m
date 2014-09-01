function y = weibull(t,gamma,alpha)
%   y = weibull(t,gamma,alpha) evaluates the parametrized Weibull function 
%       at x=t, with 
%   alpha: Scale Pparameter (the Characteristic Life)
%   gamma: Shape Parameter
%
y = gamma./t.*(t./alpha).^gamma.*exp(-(t./alpha).^gamma);





function y = Weibull1(x,beta,threshold,chance)
%   y = Weibull(p,x) evaluates the parametrized Weibull function at x
% which is the solution of the differential equation
%       
% with:
%   p.b : slope
%   p.t : threshold yeilding ~80% correct
%   x   : intensity values.

if nargin<4
    chance = .5;
end

g = chance;  %chance performance
e = (.5)^(1/3);  %threshold performance ( ~80%)

%here it is.
k = (-log((1-e)./(1-g))).^(1/beta);
y = 1 - (1-g).*exp(-(k.*x/threshold).^beta);
