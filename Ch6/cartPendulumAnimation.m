function [T,Y] = cartPendulumAnimation(t,y0,doanim)
% cartPendulumAnimation numerically integrates the equations of motion of
% an inverted simple pendulum on a sliding cart and optionally animates the
% results. 
%
% res = cartPendulumAnimation(t,y0,doanim) performs the integration for
% time array t, with initial conditions y0 = 
% [x(t0),\dot{x}(t0),theta(t0),\dot\theta(t0)]
% and animates if doanim is true. res contains the results of the numerical
% integration. See ode45 for details.
%
% See Example 6.2 and Problem 6.12 
%
% Examples:
%   %Cart starts at rest, pendulum inverted at 45 degrees:
%   [T,Y] = cartPendulumAnimation([0,15],[0,0,pi/4,0],true);
%   %Cart starts at rest, pendulum hanging down at 45 degrees:
%   [T,Y] = cartPendulumAnimation([0,15],[0,0,-pi/4,0],true);
%   %Cart starts at rest, pendulum pointing straight up:
%   [T,Y] = cartPendulumAnimation([0,15],[0,0,pi/2,0],true);



% Copyright (c) 2015 Dmitry Savransky (ds264@cornell.edu)

g = 9.81;   %m/s^2  acceleration due to graivty
l = 1;      %m      length of pendulum arm
M = 2;      %kg     mass of cart
m = 1;      %kg     mass of pendulum bob

if ~exist('t','var') || isempty(t)
    t = 0:1/40:60; %seconds
end
if ~exist('y0','var') || isempty(y0)
    y0 = [0,0,pi/3,0];  %initial conditions
end
if ~exist('doanim','var') || isempty(doanim)
    doanim = true;
end

    %cart pendulume ODE function
    function dy = cartPendulumODE(t,y)
        %y = [x,xdot,theta,thetadot]
        x = y(1);
        xd = y(2);
        th = y(3);
        thd = y(4);
        xdd = (m*l*thd^2*cos(th) - m*g*sin(th)*cos(th))/(M+m*cos(th)^2);
        dy = [xd;...
              xdd;...
              thd;...
              -g/l*cos(th) + xdd*sin(th)/l];
              
    end

[T,Y] = ode45(@cartPendulumODE,t,y0,odeset('RelTol',1e-6,'AbsTol',1e-9));

if doanim
    x = Y(:,1);
    th = Y(:,3);
    %pendulum e_1 and e_2 positions
    mx = x + l*cos(th);
    my = l*sin(th);
  
    %create a circle and a rectangle for the cart and pendulum
    a = 0:pi/100:2*pi;
    circrad = l/10;
    xcirc = circrad*sin(a);
    ycirc = circrad*cos(a);
    
    %create figure and find axis limits
    figure(1);
    clf
    
    axlim = [min([x-l/2;mx-circrad]),max([x+l/2;mx+circrad]),...
        min([-l/2;my-circrad]),max([l/2;my+circrad])];
    
    %draw shapes
    mp = fill(xcirc+mx(1),ycirc+my(1),'b');
    hold on
    trk = plot([axlim(1),axlim(2)],[-l/4,-l/4],'k','Linewidth',7);
    bx = fill([x(1)-l/2,x(1)+l/2,x(1)+l/2,x(1)-l/2,x(1)-l/2],[0,0,-l/2,-l/2,0],'b');
    link = plot([x(1),mx(1)],[0,my(1)],'r','Linewidth',2);
    hold off
    axis equal
    axis(axlim)
    
    set(gca,'FontName','Times','FontSize',18)
    xlabel('$\mathbf{e}_1 \rightarrow$','Interpreter','Latex')
    ylabel('$\mathbf{e}_2 \rightarrow$','Interpreter','Latex')
    
    %animate
    for j = 2:length(T)
        pause(T(j)-T(j-1))
        set(mp,'XData',get(mp,'XData')+(mx(j) - mx(j-1)),...
            'YData',get(mp,'YData')+(my(j) - my(j-1)));
        set(link,'XData',[x(j),mx(j)],'YData',[0,my(j)]);
        set(bx,'XData',get(bx,'XData')+(x(j) - x(j-1)));
    end
end

end