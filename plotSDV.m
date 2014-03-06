function [p] = plotSDV(x, y, sdv, varargin)
%PLOTSDV : [plots()] = plotSDV(x,y, sdv, varargin)
%  Plot standard deviation around a value 'moustache' like
for k=1:length(x)
    z=y(k) + [-sdv(k) sdv(k)];
    p(k)=plot([x(k) x(k)], z, varargin{:})
    set(p(k), 'Marker', '+')
end
    

