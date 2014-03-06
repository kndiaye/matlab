function [z]=rectpix(fg, bgz, angle)
angle=-angle;
bgz = bgz-1;
[x,y]=meshgrid(-bgz(1)/2:bgz(1)/2 , -bgz(2)/2:bgz(2)/2);
ca=cos(angle);
sa=sin(angle);

ca(abs(ca)<eps)=0;
sa(abs(sa)<eps)=0;
ca(abs(ca-1)<eps)=1;
sa(abs(sa-1)<eps)=1;

rx= ca*x + sa*y;
ry=-sa*x + ca*y;
z=double(abs(rx)<fg(1)/2 & abs(ry)<fg(2)/2);

return

