function accelPendulumAnimation(stationary,t,y0)
% accelPendulumAnimation calculates and animates the trajectories of a 
% stationary simple pendulum and a simple pendulum in an accelerating box.
%
% accelPendulumAnimation(true) sets the initial conditions for the
% accelerating pendulum such that it is stationary in the accelerating
% reference frame.
%
% accelPendulumAnimation([],t,y0) calculates the trajectories for time
% array t and initial conditions y0 ([theta(t0),\dot\theta(t0)]). See ode45
% for details.

% Copyright (c) 2015 Dmitry Savransky (ds264@cornell.edu)

g = 9.81;   %m/s^2  acceleration due to graivty
l = 1;      %m      length of pendulum arm
a = 15;     %m/s^2  acceleration of the pendulum frame

if ~exist('t','var') || isempty(t)
    t = 0:1/40:60; %seconds
end
if ~exist('stationary','var') || isempty(stationary)
    stationary = false;
end
if ~exist('y0','var') || isempty(y0)
    y0 = [pi/3,0];  %initial conditions
end
if stationary
    y0 = [-atan(a/g),0];
end

    %simple pendulume ODE function
    function dy = simplePendulumODE(t,y)
        dy = [y(2);...
            -g/l*sin(y(1))];
    end

    %simple pendulume ODE function
    function dy = accelPendulumODE(t,y)
        dy = [y(2);...
            -g/l*sin(y(1)) - a/l*cos(y(1))];
    end

[~,res_simp] = ode45(@simplePendulumODE,t,y0);
[~,res_accel] = ode45(@accelPendulumODE,t,y0);

theta_simp = res_simp(:,1);
x_simp = l*sin(theta_simp);
y_simp = l*cos(theta_simp);

theta_accel = res_accel(:,1);
x_accel = l*sin(theta_accel);
y_accel = l*cos(theta_accel);

f = figure(1);
clf
set(f,'Position',[1,1,1200,700])
s1 = subplot(1,2,1);
s2 = subplot(1,2,2);
   
%set up animation
ac = 0:pi/100:2*pi;
circrad = l/15;
xcirc = circrad*sin(ac);
ycirc = circrad*cos(ac);

axes(s1)
m_simp = fill(xcirc+x_simp(1),ycirc+y_simp(1),'b');
hold on
link_simp = plot([0,x_simp(1)],[0,y_simp(1)]);
hold off
axis equal
s1lim = [min([0;x_simp-circrad]),max([0;x_simp+circrad]),...
    min([0;y_simp-circrad]),max([0;y_simp+circrad])];
axis(s1lim)
set(s1,'FontName','Times','FontSize',18,'YDir','Reverse',...
    'XAxisLocation','Top')
ylabel('$\leftarrow \mathbf{e}_1 $','Interpreter','Latex')
xlabel('$\mathbf{e}_2 \rightarrow$','Interpreter','Latex')
title('Stationary','Interpreter','Latex')

axes(s2)
m_accel = fill(xcirc+x_accel(1),ycirc+y_accel(1),'b');
hold on
link_accel = plot([0,x_accel(1)],[0,y_accel(1)]);
hold off
axis equal
s2lim = [min([0;x_accel-circrad]),max([0;x_accel+circrad]),...
    min([0;y_accel-circrad]),max([0;y_accel+circrad])];
axis(s2lim)
set(s2,'FontName','Times','FontSize',18,'YDir','Reverse',...
    'XAxisLocation','Top')
ylabel('$\leftarrow \mathbf{b}_1 $','Interpreter','Latex')
xlabel('$\mathbf{b}_2 \rightarrow$','Interpreter','Latex')
title('Accelerating','Interpreter','Latex')

%animate
for j = 2:length(t)
    pause(t(j)-t(j-1))
    set(m_simp,'XData',get(m_simp,'XData')+(x_simp(j) - x_simp(j-1)),...
        'YData',get(m_simp,'YData')+(y_simp(j) - y_simp(j-1)));
    set(link_simp,'XData',[0,x_simp(j)],'YData',[0,y_simp(j)]);
    set(m_accel,'XData',get(m_accel,'XData')+(x_accel(j) - x_accel(j-1)),...
        'YData',get(m_accel,'YData')+(y_accel(j) - y_accel(j-1)));
    set(link_accel,'XData',[0,x_accel(j)],'YData',[0,y_accel(j)]);
end

end