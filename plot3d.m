function [p]=plot3d(xyz, varargin);
% plot in 3 dimension
% [p]=plot3d(xyz, varargin);
if size(xyz, 2) ~= 3 && size(xyz, 1) == 3 
    xyz=xyz';
end
if nargin<2
    varargin={'.'};
end
if size(xyz,2)==2
    xyz(:,3)=0.*xyz(:,1);
end
% varargin{1}=['.' varargin{1}];
% , 'LineStyle', 'None', 'Marker', '.'
p=plot3(xyz(:,1),xyz(:,2),xyz(:,3),varargin{:} );
if all(xyz(:,3)==0)
    view(2)
end