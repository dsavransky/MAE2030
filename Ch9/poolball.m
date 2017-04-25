% Script that animates a solid ball hit dead center up until it achieves
% pure rolling without slip

% Copyright (c) 2017 Dmitry Savransky (ds264@cornell.edu)

%state z = [x,dx,th,dth]

mu = 0.02;
g = 9.81;
r = 0.1;
v0 = 2;
2*v0/7/mu/g
v0/mu/g

sphereeq = @(t,z) [z(2);-mu*g;z(4);5/2*mu/r*g];


[t,z] = ode45(sphereeq,linspace(0,2*v0/7/mu/g,500),[0,v0,0,0]);

[X,Y,Z] = sphere(50);

% set up figure
figure(1)
clf
s = surface(r*X,r*Y,r*Z,'FaceAlpha',0.8,'SpecularExponent',10,'SpecularStrength',0.3);
l(1) = light('Position',[0 -100 1]);
%l(2) = light('Position',[1.5 0.5 -0.5]);
lighting gouraud
shading interp
view(3)
axis equal
axis([z(1,1)-3*r,z(1,1)+3*r,-r,r,-r,r])
%axis([-r,z(end,1)+r,-r,r,-r,r])

%% aninmate

for j = 2:length(t)
    axis([z(j,1)-3*r,z(j,1)+3*r,-r,r,-r,r])
    rotate(s,[0,1,0],(z(j,3)-z(j-1,3))*180/pi,[z(j-1,1),0,0]);
    s.XData = s.XData + (z(j,1)-z(j-1,1));
    pause(t(j) - t(j-1));
end
