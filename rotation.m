function [xyz2,rot]=rotation(xyz, origin, azel, alpha)
% [xyz2,rot]=rotation(xyz, origin, azel, angle)
%   azel define the axis of the rotation either 
%        [theta , phi] : spherical angles (in degres)
%        [ux,uy,uz] : 3x1 vector of cartesian 
%   angle : angle of the rotation in *degrees*
% cf. ROTATE

if prod(size(azel)) == 2 
  % theta & phi spherical angles are given
    theta = pi*azel(1)/180;
    phi   = pi*azel(2)/180;
    u = [cos(phi)*cos(theta); cos(phi)*sin(theta); sin(phi)];
elseif prod(size(azel)) == 3 
  % XYZ-cartesian direction vector
    u = azel(:)/norm(azel);
end

alph = alpha*pi/180;
cosa = cos(alph);
sina = sin(alph);
vera = 1 - cosa;
x = u(1);
y = u(2);
z = u(3);
rot = [cosa+x^2*vera   , x*y*vera-z*sina , x*z*vera+y*sina; ...
       x*y*vera+z*sina , cosa+y^2*vera   , y*z*vera-x*sina; ...
       x*z*vera-y*sina , y*z*vera+x*sina , cosa+z^2*vera];

xyz2 = [xyz(:,1)-origin(1), xyz(:,2)-origin(2), xyz(:,3)-origin(3)];
xyz2 = (rot*xyz2')'; % i.e. Y = R*X with xyz2=Y' R=rot X=xyz'
xyz2 = [ origin(1) + xyz2(:,1) , origin(2) + xyz2(:,2) , origin(3) + xyz2(:,3)];

