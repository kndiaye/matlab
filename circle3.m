function [h]=circle3(X,R, varargin)
% CIRCLE3: draw an circle in 3D
% h = circle3(x,y,z,r) or circle3(xyz,r)
if prod(size(R))=prod(size(X))/3
    X(:,2)=varargin{1};
    X(:,3)=varargin{2};
    varargin=varargin{3:end};
end
        
h = circle(X,Y,R)
rotate(


function circle(C,r,npts);
if nargin<3
 npts = 50;
end
theta=0:2*pi/(npts-1):2*pi;
plot(C(1)+r*cos(theta),C(2)+r*sin(theta),'w');