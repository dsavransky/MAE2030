function [t,res] = sphericalGyroPendulumAnimation(staticic,nospin)

% sphericalGyroPendulumAnimation numerically integrates the equations of 
% motion of a spherical gryopendulum and animates the results.
%
% sphericalGyroPendulumAnimation(true) will do the animation with initial
% conditions producing circular motion about the vertical axis.
%
% sphericalGyroPendulumAnimation([],true) will do the animation with the
% angular momentum of the rotor set to zero (i.e., the system will behave
% as a normal spherical pendulum).
%
% Setting both conditions to true will animate the static spherical
% pendulum solution with ciruclar motion about the vertical axis.

% Copyright (c) 2015 Dmitry Savransky (ds264@cornell.edu)


if ~exist('staticic','var') || isempty(staticic)
   staticic = false;
end
if ~exist('nospin','var') || isempty(nospin)
   nospin = false;
end


%constants and initial conditions
g = 9.81; %m/s
l = 1; %m
m = 10; %kg
if nospin
    h = 0;
else
    h = 55;
end

thd0 = 3;
if staticic
    if nospin
        phi0 = 120*pi/180;
        thd0 = sqrt(-g/l/cos(phi0));
    else
        phi0 = acos(h/m/l^2/thd0 - g/l/thd0^2);
    end
else
    phi0 = 60*pi/180;
end

[t,res] = ode45(@sphericalGyroPendulum_eq,linspace(0,30,1000),...
    [phi0,0,0,thd0]);

    function dz = sphericalGyroPendulum_eq(~,z)
        
        %z = [phi, phidot, theta, thetadot]
        phi = z(1);
        phid = z(2);
        thd = z(4);
        
        dz = [phid;
            thd^2*sin(phi)*cos(phi) + g/l*sin(phi) - h*thd*sin(phi)/m/l^2;
            thd;
            -2*thd*phid/tan(phi) + h*phid/m/l^2/sin(phi)];
    end

%figure out particle trajectory in inertial frame
ph = res(:,1);
th = res(:,3);
x = l*cos(th).*sin(ph);
y = l*sin(th).*sin(ph);
z = l*cos(ph);

%bounds of animation
cr = l/5;
axlim = [min(x)-cr,max(x)+cr,min(y)-cr,max(y)+cr,min([z;0])-cr,...
    max([z+cr;0.1])]*1.1;

%create and clear figure
f = figure(1);
clf(f);
hold on

% create the pendulum
cs = colormap('Gray');
inds = round(linspace(length(cs)*0.3,length(cs)/1.5,4));
cs = cs(inds,:);

[xt,yt,zt] = cylinder(1,100);

xt = xt*l/5;
yt = yt*l/5;
zt = zt*l/10+1;

trk = plot3([x(1),x(1)],[y(1),y(1)],[z(1),z(1)],'k--');
arm = plot3([0,x(1)],[0,y(1)],[0,z(1)],'k','LineWidth',3);
rotorc = cs(4,:);
rotor(1) = surface(xt,yt,zt,'FaceColor',rotorc,'FaceAlpha',0.75);
rotor(2) = fill3(xt(1,:),yt(1,:),zt(1,:),rotorc,'FaceAlpha',0.75);
rotor(3) = fill3(xt(1,:),yt(1,:),zt(2,:),rotorc,'FaceAlpha',0.75);
rotate(rotor,[0 1 0],ph(1)*180/pi,[0,0,0])
rotate(rotor,[0 0 1],th(1)*180/pi,[0,0,0])

hold off
axis equal
axis(axlim)
grid on
view(-50,10)

%step in time and animate:
for i=2:length(t)
    
    set(trk,'XData',x(1:i),'YData',y(1:i),'ZData',z(1:i))
    set(arm,'XData',[0,x(i)],'YData',[0,y(i)],'ZData',[0,z(i)])

    set(rotor(1),'XData',xt,'YData',yt,'ZData',zt)
    set(rotor(2),'XData',xt(1,:),'YData',yt(1,:),'ZData',zt(1,:))
    set(rotor(3),'XData',xt(1,:),'YData',yt(1,:),'ZData',zt(2,:))
    
    rotate(rotor,[0 1 0],ph(i)*180/pi,[0,0,0])
    rotate(rotor,[0 0 1],th(i)*180/pi,[0,0,0])

    %pause for length of time step
    if i < length(t)
        pause(t(i+1)-t(i));
    end
end


end