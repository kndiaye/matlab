function [XYZ,labels,R]=read_xyz(xyzfile)
%read_xyz() - reads XYZ electrode coordinates file (Cartool)
%   [XYZ,labels,R]=read_xyz(xyzfile)
[ne,R]=textread(xyzfile,'%d %f',1);

[XYZ(:,1) XYZ(:,2) XYZ(:,3), labels]=textread(xyzfile,'%f %f %f %s', ne, 'headerlines',1);