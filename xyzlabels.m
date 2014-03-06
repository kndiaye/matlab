function []=xyzlabels(xl,yl,zl)
% xyzlabels - add labels to each axis
if nargin<3
    zl='z axis';
end
if nargin<2
    yl='y axis'
end
if nargin<3
    xl='x axis'
end
axis on
xlabel(xl)
ylabel(yl)
zlabel(zl)
