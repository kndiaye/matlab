function [m]=mycolormap(seuil,varargin)
% mycolormap - custom the jet colormap to display X% of the data
%   [m]=mycolormap(X)
%   [m]=mycolormap(X,CM)  CM is a colormap

if nargin==1

    m=ones(100-seuil,3)*[.2 .7 1;0 0 0;0 0 0];
    m= [m ; ones(2*seuil,3)*.5];
    m= [m ; ones(100-seuil,3)*[1 .4 .2;0 0 0;0 0 0]];
    
    l=.3;
    m=hot(110);
    m= [m(1:100,:)*(1-l)+ones(100,3)*l];
    m= [fliplr(flipud(m)) ; ones(2*seuil,3)*l ; m];
    
else
    n=varargin{1};
    m=[ n(1:ceil(length(n)/2),:); ones(2*seuil/100*length(n),3)*.5 ; n(ceil(length(n)/2):end,:)];
    
end
