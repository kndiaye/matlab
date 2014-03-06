function p = cdf(name,x,a1,a2,a3)
%CDF    Computes a chosen cumulative distribution function.
%   P = CDF(NAME,X,A1) returns the named cumulative distribution
%   function, which uses parameter A, at the the values in X.
%   P = CDF(NAME,X,A1,A2) returns the named cumulative distribution
%   function, which uses parameters a and b, at the the values in X.
%   Similarly for P = CDF(NAME,X,A1,A2,A3).
%
%   The name can be: 'beta' or 'Beta', 'bino' or 'Binomial',
%   'chi2' or 'Chisquare','exp' or 'Exponential', 'f' or 'F', 
%   'gam' or 'Gamma','geo' or 'Geometric','hyge' or 'Hypergeometric',
%   'logn' or 'Lognormal','nbin' or 'Negative Binomial',
%   'ncf' or 'Noncentral F','nct' or 'Noncentral t',
%   'ncx2' or 'Noncentral Chi-square'
%   'norm' or 'Normal','poiss' or 'Poisson','rayl' or 'Rayleigh',
%   't' or 'T','unif' or 'Uniform','unid' or 'Discrete Uniform',
%   'weib' or 'Weibull'.
% 
%   CDF calls many specialized routines that do the calculations. 
 
if nargin<2, error('Not enough input arguments'); end

if ~isstr(name), error('First argument must be distribution name'); end

if nargin<5, 
    a3=0; 
end 
if nargin<4, 
    a2=0; 
end 
if nargin<3, 
    a1=0; 
end 

if     strcmp(name,'beta') | strcmp(name,'Beta'),  
    p = betacdf(x,a1,a2);
elseif strcmp(name,'bino') | strcmp(name,'Binomial'),  
    p = binocdf(x,a1,a2);
elseif strcmp(name,'chi2') | strcmp(name,'Chisquare'), 
 p = chi2cdf(x,a1);
elseif strcmp(name,'exp') | strcmp(name,'Exponential'),   
    p = expcdf(x,a1);
elseif strcmp(name,'f') | strcmp(name,'F'),     
    p = fcdf(x,a1,a2);
elseif strcmp(name,'gam') | strcmp(name,'Gamma'),   
    p = gamcdf(x,a1,a2);
elseif strcmp(name,'geo') | strcmp(name,'Geometric'),   
    p = geocdf(x,a1);
elseif strcmp(name,'hyge') | strcmp(name,'Hypergeometric'),  
    p = hygecdf(x,a1,a2,a3);
elseif strcmp(name,'logn') | strcmp(name,'Lognormal'),
    p = logncdf(x,a1,a2);
elseif strcmp(name,'nbin') | strcmp(name,'Negative Binomial'), 
   p = nbincdf(x,a1,a2);    
elseif strcmp(name,'ncf') | strcmp(name,'Noncentral F'),
    p = ncfcdf(x,a1,a2,a3);
elseif strcmp(name,'nct') | strcmp(name,'Noncentral T'), 
    p = nctcdf(x,a1,a2);
elseif strcmp(name,'ncx2') | strcmp(name,'Noncentral Chi-square'), 
    p = ncx2cdf(x,a1,a2);
elseif strcmp(name,'norm') | strcmp(name,'Normal'), 
    p = normcdf(x,a1,a2);
elseif strcmp(name,'poiss') | strcmp(name,'Poisson'),
    p = poisscdf(x,a1);
elseif strcmp(name,'rayl') | strcmp(name,'Rayleigh'),
    p = raylcdf(x,a1);
elseif strcmp(name,'t') | strcmp(name,'T'),     
    p = tcdf(x,a1);
elseif strcmp(name,'unid') | strcmp(name,'Discrete Uniform'),  
    p = unidcdf(x,a1);
elseif strcmp(name,'unif')  | strcmp(name,'Uniform'),  
    p = unifcdf(x,a1,a2);
elseif strcmp(name,'weib') | strcmp(name,'Weibull'),  
    p = weibcdf(x,a1,a2);
else   
    error('Sorry, the statistics toolbox does not support this distribution.'); 
end 
