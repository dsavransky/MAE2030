function [t,res] = demoGyro()

% demoGyroAnimation numerically integrates the equations of 
% motion of the demo gryoscope (Kasdin & Paley Ex. 11.13) and plots the
% conserved quantity.

% Copyright (c) 2017 Dmitry Savransky (ds264@cornell.edu)

%constants and initial conditions
g = 9.81;       %m/s
m = 1;          %kg counterweight mass
M = 3;          %kg rotor mass
lt = 48/100;    %cm->m total arm length

l = lt/(1 + M/m)*1.05;
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
h0 = I2*Omega;              %rotor initial angular momentum magnitude

psid0 = 0;
z0 = [0,psid0,pi/6,0,h0];
C = I2*z0(2)*sin(z0(3)) + h0;

[t,res] = ode45(@demoGyro_eq,linspace(0,30,1000),...
    z0,odeset('RelTol',1e-12,'AbsTol',1e-12));

    function dz = demoGyro_eq(~,z)
        
        %z = [psi, psid, th, thd,h]
        psid = z(2);
        th = z(3);
        thd = z(4);
        
        thdd = (C.*psid - I1p.*psid.^2.*sin(th) - mG.*g.*lG).*cos(th)./I1p;
        psidd = thd.*(-C./cos(th) + 2*I1p.*psid.*tan(th))./I1p;
        hd = -I2*(psidd.*sin(th) + psid.*thd.*cos(th));

        dz = [psid;psidd;thd;thdd;hd];
    end


Chist =  I2*res(:,2).*sin(res(:,3))+ res(:,5);

figure(1)
clf
plot(t,Chist);

end