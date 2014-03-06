function  [W,Z,P]=ztransform(X,N)
% ztransform - compute the Fisher's Z-transfom
%   [W] = ztransform(X)
%   [W,Z,P] = ztransform(X,N) may use Hotelling correction for small
%   (N<=25) samples and also compute the corresponding Z-value and
%   probability.
%
%
%   Example
%       >> load carsmall
%       >> [w,z]=ztransform(corrcoef(Horsepower(1:30), Weight(1:30)),30);
%   Since z > 1.96 we can conclude that the correlation is significant
%
% See also: zscore(), tcdf()
% Ref: http://fedc.wiwi.hu-berlin.de/xplore/tutorials/mvahtmlnode23.html

W = log((1+X)./(1-X))./2;
if nargin<2    
    return
end

if N <= 25
    %Apply Hotelling correction
    W= W - ((3*W)+tanh(W))/4/(N-1);
    iV=sqrt(N-1);        
else
    iV=sqrt(N-3);        
end
Z=iV*W;
P = 0.5 * erfc(Z ./ sqrt(2));