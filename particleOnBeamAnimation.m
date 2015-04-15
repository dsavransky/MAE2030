function [t,y] = particleOnBeamAnimation(y0)
% particleOnBeamAnimation numerically integrates the equations of 
% motion of a particle sliding on a rigid beam and animates the results.
%
% [t,y] = particleOnBeamAnimation() will return the output of ode45 for
% initial conditions selected to produce harmonic motion of
% the particle.  
% 
% [t,y] = particleOnBeamAnimation(y0) will use initial conditions y0 of the
% form [x0,dx0,theta0,dtheta0].
% 
% Example (mismatched ICs):
%  [t,y] = particleOnBeamAnimation([1+200*eps,0,pi/6,0]);
%
% Copyright (c) 2015 Dmitry Savransky (ds264@cornell.edu)

% default constants and initial conditions
g=9.81; %m/s^2  acceleration due to gravity
IOm = 3.166672765988175; %I_O/m - joint mass characteristic of system
tspan = linspace(0,14.0894,200);

if ~exist('y0','var'), y0 = [1,0,pi/6,0]; end

[t,y] = ode45(@particleOnBeam_eom,tspan,y0);

    % integrator function
    function dy = particleOnBeam_eom(t,y)
        %y = [x,dx,theta,dtheta]
        x=y(1);dx=y(2);th=y(3);dth=y(4);
        dy = [dx; ...
              x*dth.^2 - g*sin(th); ...
              dth; ...
              -(g*x.*cos(th) + 2*x.*dx.*dth)/(x.^2 + IOm)];
    end

%figure out particle trajectory in inertial frame
x = y(:,1);
th = y(:,3);
xi = x.*cos(th);
yi = x.*sin(th);

%bounds of animation
xmx = abs(x(1))*1.1;
circrad = xmx/20;
beamh = xmx/20;
ymx = abs(max(yi)) + circrad + beamh;
axlim = [-xmx,xmx,-ymx,ymx]*1.1;

%create and clear figure
h = figure(1);
clf(h);

% create the particle and beam:
a = 0:pi/100:2*pi;
xscirc = circrad*sin(a);
yscirc = circrad*cos(a);
xsbeam = [-xmx,xmx,xmx,-xmx,-xmx];
ysbeam = [0,0,-beamh,-beamh,0];

b = fill(xsbeam,ysbeam,'k');
rotate(b,[0,0,1],th(1)*180/pi,[0,0,0])
hold on
p = fill(xscirc+xi(1)-beamh*sin(th(1)),yscirc+yi(1)+beamh*cos(th(1)),'b');
%draw static pivot
fill([0,beamh,-beamh,0],[-beamh,-3*beamh,-3*beamh,-beamh],'k');
hold off
axis equal
axis(axlim)

%step in time and animate:
for i=2:length(t)
    set(p,'XData',xscirc+xi(i)-beamh*sin(th(i)),...
        'YData',yscirc+yi(i)+beamh*cos(th(i)))
    rotate(b,[0,0,1],(th(i) - th(i-1))*180/pi,[0,0,0])
   
    %pause for length of time step
    if i < length(t)
        pause(t(i+1)-t(i));
    end
end



end
