% Cinématique du solide avec frottements

% conditions initiales

% solide
m=5; % Kg
V=0.1; % m^3
alpha=0; % angle z par rapport à x (degrés)
betha=0; % angle x par rapport à y (degrés)
v0=40000; % Km/h; ratio pour exprimer en m/s= 10/36
p=[0 0 500000]; % position du solide en metres
pinit=p;

% environnement
 w=[0 0 0]; % vitessse du vent
 c=0;%10^-3; % coefficient de frottement de l'air

% constantes
G=6.670*10^-11; % Gravitation universelle
M=6*10^24; % masse de la Terre (Kg)
R=6378*1000; % rayon de la Terre (m)

% parametres d'intégration
dt=1; % secondes
Time=100000; % Temps total (secondes)
n_i=Time/dt; % Nombre d'itérations

alpha=(alpha/360)*(2*pi);
betha=(betha/360)*(2*pi);
r=sqrt((R+p(3))^2+p(1)^2+p(2)^2);
g=G*M/r^2;
v0=sqrt(2*(R+p(3))*g);
v_v=[v0*cos(alpha)*(10/36) v0*sin(betha)*(10/36) v0*sin(alpha)*(10/36)];
v_v_ref=v_v*Time;
Einit=m*g*(r-R)+0.5*m*sum((v_v+w).^2); % Energie totale du system à t0


figure
[X,Y,Z]=sphere(100);surf(R*X,R*Y,R*Z-R)
shading interp
colormap(1-gray)
axis equal
%axis([-max(pinit) max(pinit) -max(pinit) max(pinit) -max(pinit) max(pinit)])
%axis([0 v0*2*(10/36) 0 v0*(10/36) -5 v0*(10/36)])
%view(0,0);
hold on

for s_i=1:n_i
r=sqrt((R+p(3))^2+p(1)^2+p(2)^2);        
% Accélération
% gravitationnelle                                    
g=G*M/r^2;
v_g=[-g*p(1)/r -g*p(2)/r -g*(p(3)+R)/r];
% frottements de l'air
v_c=-c*(v_v.^2)/m;               
% if p(3)<=0
% v_c(3)=-v_c(3);    
% end
% Totale
v_a=v_g+v_c;

% Energie mécanique    
Ep=m*g*(r-R); % energie potentielle
Ec=0.5*m*sum(v_v.^2); % energie cinétique
E=Ep+Ec; % energie mécanique
T=Einit-E; % energie thermique dégagée

% Vitesse
if r<R
break
v_v(3)=-v_v(3);
else
v_v=v_v+v_a*dt+w*dt;    
end
% Position
p=p+v_v*dt;   
% if p(3)<=0
% p(3)=0;    
% end

plot3(p(1),p(2),p(3),'o');
hold on
title(strcat('time=',num2str(s_i*dt),'; Einit=',num2str(Einit),'; Ep=',num2str(Ep),'; Ec=',num2str(Ec),'; T=',num2str(T)));
axis equal
%axis([-max(pinit) max(pinit) -max(pinit) max(pinit) -max(pinit) max(pinit)])
%axis([0 v0*2*(10/36) 0 v0*(10/36) -5 v0*(10/36)])
%view(0,0);

pause(0.001)
end
