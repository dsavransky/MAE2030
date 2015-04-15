function [t,res] = sphericalPendulumAnimation(staticic)

% sphericalPendulumAnimation numerically integrates the equations of motion 
% of a spherical pendulum and animates the results.
% sphericalPendulumAnimation(true) will do the animation with initial
% conditions producing circular motion about the vertical axis.

% Copyright (c) 2015 Dmitry Savransky (ds264@cornell.edu)


if ~exist('staticic','var') || isempty(staticic)
   staticic = false;
end

%constants and initial conditions
g = 9.81; %m/s
l = 1; %m

phi0 = 120*pi/180;
if staticic
    thd0 = sqrt(-g/l/cos(phi0));
else
    thd0 = 3;
end


[t,res] = ode45(@sphericalPendulum_eq,linspace(0,30,1000),[phi0,0,0,thd0]);

    function dz = sphericalPendulum_eq(~,z)
        
        %z = [phi, phidot, theta, thetadot]
        ph = z(1);
        phd = z(2);
        thd = z(4);
        
        dz = [phd;
            thd^2*sin(ph)*cos(ph) + g/l*sin(ph);
            thd;
            -2*thd*phd/tan(ph)];
    end

%figure out particle trajectory in inertial frame
ph = res(:,1);
th = res(:,3);
x = l*cos(th).*sin(ph);
y = l*sin(th).*sin(ph);
z = l*cos(ph);

%bounds of animation
cr = l/20;
axlim = [min(x)-cr,max(x)+cr,min(y)-cr,max(y)+cr,min(z)-cr,...
    max([z+cr;0.1])]*1.1;

%create and clear figure
h = figure(1);
clf(h);

% create the pendulum
[xs,ys,zs] = sphere(50);
sp = surface(xs*cr+x(1),ys*cr+y(1),zs*cr+z(1),...
    'FaceColor','b','EdgeColor','None');
hold on
arm = plot3([0,x(1)],[0,y(1)],[0,z(1)],'k','LineWidth',3);
trk = plot3([x(1),x(1)],[y(1),y(1)],[z(1),z(1)],'k--');
hold off

axis equal
axis(axlim)
grid on
view(-50,10)

%step in time and animate:
for i=2:length(t)
    set(sp,'XData',xs*cr+x(i),'YData',ys*cr+y(i),'ZData',zs*cr+z(i))
    set(arm,'XData',[0,x(i)],'YData',[0,y(i)],'ZData',[0,z(i)])
    set(trk,'XData',x(1:i),'YData',y(1:i),'ZData',z(1:i))
   
    %pause for length of time step
    if i < length(t)
        pause(t(i+1)-t(i));
    end
end


end