function [t,res] = demoGyroAnimation(balanced,psid0)

% demoGyroAnimation numerically integrates the equations of 
% motion of the demo gryoscope (Kasdin & Paley Ex. 11.13) and animates the
% results.
%
% demoGyroAnimation(true) will perform the integration with the gyroscope
% exactly balanced between the rotor and counterweight.
%
% demoGyroAnimation([],psid0) will perform the integration with an initial
% psi dot (azimuthal rate of change) value of psid0.

% Copyright (c) 2015 Dmitry Savransky (ds264@cornell.edu)

if ~exist('balanced','var') || isempty(balanced)
   balanced = false;
end
if ~exist('psid0','var') || isempty(psid0)
   psid0 = 0;
end


%constants and initial conditions
g = 9.81;       %m/s
m = 1;          %kg counterweight mass
M = 3;          %kg rotor mass
lt = 48/100;    %cm->m total arm length

if balanced
    l = lt/(1 + M/m);  %balance the rotor
else
    l = lt/(1 + M/m)*1.05;
end
lp = lt - l;

%l = 24/100;     %cm->m  rotor to axis distance
%lp = 24/100;    %cm->m  counterweight to axis distance

R = 25/2/100;   %cm->m rotor radius
I1 = M*R^2/4;   %rotor moment of inertia about b_1,b_3
I2 = 2*I1;      %rotor moment of inertia about b_2
Omega = 4*2*pi; %rotor spin rate 240 rpm-> rad/s

I1p = I1 +M*l^2 + m*lp^2;  %moment of inertia about Q
mG = m+M;                  %total mass
lG = (M*l - m*lp)/mG;      %distance between axle and com
h0 = I2*Omega;             %rotor initial angular momentum magnitude

z0 = [0,psid0,pi/6,0,h0];  %initial conditions
C = I2*z0(2)*sin(z0(3)) + h0; %conserved quantity

[t,res] = ode45(@demoGyro_eq,linspace(0,30,1000),...
    z0,odeset('RelTol',1e-12,'AbsTol',1e-12));

    function dz = demoGyro_eq(~,z)
        
        %z = [psi, psidot, theta, thetadot, h]
        psid = z(2);
        th = z(3);
        thd = z(4);
        
        thdd = (C.*psid - I1p.*psid.^2.*sin(th) - mG.*g.*lG).*cos(th)./I1p;
        psidd = thd.*(-C./cos(th) + 2*I1p.*psid.*tan(th))./I1p;
        hd = -I2*(psidd.*sin(th) + psid.*thd.*cos(th));

        dz = [psid;psidd;thd;thdd;hd];

    end

%grab the angle histories
psi = res(:,1);
th = res(:,3);

%bounds of animation
maxp = max([l,lp])*1.15;
axlim = [-maxp,maxp,-maxp,maxp,-maxp,maxp];

%create and clear figure
f = figure(1);
clf(f);
hold on

% create the pendulum
cs = colormap('Gray');
inds = round(linspace(length(cs)*0.3,length(cs)/1.5,4));
cs = cs(inds,:);
rotorc = cs(4,:);

[xt,yt,zt] = cylinder(1,100);

%build rotor
rotor(1) = surface(xt*R,yt*R+l,(zt-0.5)*l/10,'FaceColor',rotorc,'FaceAlpha',0.75);
rotor(2) = fill3(xt(1,:)*R,yt(1,:)*R+l,(zt(1,:)-0.5)*l/10,rotorc,'FaceAlpha',0.75);
rotor(3) = fill3(xt(1,:)*R,yt(1,:)*R+l,(zt(2,:)-0.5)*l/10,rotorc,'FaceAlpha',0.75);
rotate(rotor,[1 0 0],90,[0,l,0])

%build counterweight
ballast(1) = surface(xt*R/3,yt*R/3-lp,(zt-0.5)*l/10,'FaceColor',rotorc,'FaceAlpha',0.75);
ballast(2) = fill3(xt(1,:)*R/3,yt(1,:)*R/3-lp,(zt(1,:)-0.5)*l/10,rotorc,'FaceAlpha',0.75);
ballast(3) = fill3(xt(1,:)*R/3,yt(1,:)*R/3-lp,(zt(2,:)-0.5)*l/10,rotorc,'FaceAlpha',0.75);
rotate(ballast,[1 0 0],90,[0,-lp,0])

%build gyro axle
rod = surface(xt*R/20,yt*R/20,zt*(l+lp)*1.1 - lp*1.1,'FaceColor','k');
rotate(rod,[1 0 0],-90,[0,0,0])

%assemble the whole gyro
gyro = [rotor,ballast,rod];
rotate(gyro,[0,0,1],psi(1)*180/pi,[0,0,0])
rotate(gyro,[cos(psi(1)),sin(psi(1)),0],th(1)*180/pi,[0,0,0])

%mount on post
post = surface(xt*R/20,yt*R/20,(zt-1)*max([l,lp])*1.1,'FaceColor','k');

%add a spot to indicate rotor rotation
spot = plot3(-l*cos(th(1))*sin(psi(1))+R*0.9*cos(psi(1)),...
             l*cos(th(1))*cos(psi(1))+R*0.9*sin(psi(1)),...
             l*sin(th(1)),'k.','MarkerSize',20);
trk = plot3([1,1]*(-l*cos(th(1))*sin(psi(1))),...
            [1,1]*l*cos(th(1))*cos(psi(1)),...
            [1,1]*l*sin(th(1))+0.3,'k');

hold off
axis equal
%axis([-1,1,-1,1,-1,1]*0.5)
axis(axlim)
grid on
view(150,10)

%step in time and animate:
for i=2:length(t)      
    %update rotor orientation
    rotate(gyro,[cos(psi(i-1)),sin(psi(i-1)),0],-th(i-1)*180/pi,[0,0,0])
    rotate(gyro,[0,0,1],-psi(i-1)*180/pi,[0,0,0]) 
    
    rotate(gyro,[0,0,1],psi(i)*180/pi,[0,0,0])
    rotate(gyro,[cos(psi(i)),sin(psi(i)),0],th(i)*180/pi,[0,0,0])
    
    %current rotation matrix
    rm = [cos(psi(i)) -sin(psi(i)) 0;sin(psi(i)) cos(psi(i)) 0;0 0 1]*...
         [1 0 0;0 cos(th(i)) -sin(th(i));0 sin(th(i)) cos(th(i))];
    rotc = rm*[0;l;0];
    
    %spin rotor
    rotate(rotor,rm*[0;1;0],Omega*(t(i) - t(i-1)),rotc)
    
    %update spot position
    sc = rm*[R*0.9*cos(Omega*t(i));l;R*0.9*sin(Omega*t(i))];
    set(spot,'XData',sc(1),'YData',sc(2),'ZData',sc(3))
    
    set(trk,'XData',[get(trk,'XData'),rotc(1)],...
            'YData',[get(trk,'YData'),rotc(2)],...
            'ZData',[get(trk,'ZData'),rotc(3)+0.3])
    
    %pause for length of time step
    if i < length(t)
        pause(t(i+1)-t(i));
    end
end


end