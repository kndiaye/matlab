function p = weibull_cdf(t,gamma,alpha)
%   p = weibull_cdf(t,gamma,alpha)
%   Weibull Cumulative Distribution Function
p = 1 - exp(-(t./alpha).^gamma);

