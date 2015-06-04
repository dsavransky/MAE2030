function res = simplePendulumAnimation(t,y0,doanim)
% simplePendulumAnimation numerically integrates the equations of motion of
% a simple pendulum and optionally animates the results.
%
% res = simplePendulumAnimation(t,y0,doanim) performs the integration for
% time array t, with initial conditions y0 ([theta(t0),\dot\theta(t0)]) and
% animates if doanim is true. res contains the results of the numerical 
% integration See ode45 for details.
%
% See Example 3.11

% Copyright (c) 2015 Dmitry Savransky (ds264@cornell.edu)

g = 9.81;   %m/s^2  acceleration due to graivty
l = 1;      %m      length of pendulum arm

if ~exist('t','var') || isempty(t)
    t = 0:1/40:60; %seconds
end
if ~exist('y0','var') || isempty(y0)
    y0 = [pi/3,0];  %initial conditions
end
if ~exist('doanim','var') || isempty(doanim)
    doanim = true;
end

%simple pendulume ODE function
    function dy = simplePendulumODE(t,y)
        dy = [y(2);...
            -g/l*sin(y(1))];
    end

[~,res] = ode45(@simplePendulumODE,t,y0);

if doanim
    theta = res(:,1);
    thetad = res(:,2);
    x = l*sin(theta);
    y = l*cos(theta);
    
    f = figure(1);
    clf
    set(f,'Position',[1,1,1200,700])
    s1 = subplot(2,2,1);
    s2 = subplot(2,2,3);
    s3 = subplot(2,2,[2,4]);
    
    %set up animation
    axes(s3)
    a = [0:pi/100:2*pi];
    circrad = l/15;
    xcirc = circrad*sin(a);
    ycirc = circrad*cos(a);
    m = fill(xcirc+x(1),ycirc+y(1),'b');
    hold on
    link = plot([0,x(1)],[0,y(1)]);
    hold off
    axis equal
    s3lim = [min(x-circrad),max(x+circrad),...
        min([0;y-circrad]),max([0;y+circrad])];
    axis(s3lim)
    
    set(s3,'FontName','Times','FontSize',18,'YDir','Reverse')
    ylabel('$\leftarrow \mathbf{e}_1 $','Interpreter','Latex')
    xlabel('$\mathbf{e}_2 \rightarrow$','Interpreter','Latex')
    
    %set up plots
    axes(s1)
    pos = plot(t(1),theta(1),'Linewidth',2);
    set(s1,'FontName','Times','FontSize',18)
    xlabel('Time (s)','Interpreter','Latex')
    ylabel('$\theta$ (rad)','Interpreter','Latex')
    axes(s2)
    vel = plot(t(1),thetad(1),'Linewidth',2);
    set(s2,'FontName','Times','FontSize',18)
    xlabel('Time (s)','Interpreter','Latex')
    ylabel('$\dot\theta$ (rad/s)','Interpreter','Latex')
    
    
    %animate
    for j = 2:length(t)
        pause(t(j)-t(j-1))
        set(m,'XData',get(m,'XData')+(x(j) - x(j-1)),...
            'YData',get(m,'YData')+(y(j) - y(j-1)));
        set(link,'XData',[0,x(j)],'YData',[0,y(j)]);
        set(pos,'XData',t(1:j),'YData',theta(1:j));
        set(vel,'XData',t(1:j),'YData',thetad(1:j));
        if t(j) < 5
            set(s1,'Xlim',[0,5])
            set(s2,'Xlim',[0,5])
        else
            set(s1,'XLimMode','auto')
            set(s2,'XLimMode','auto')
        end
    end
end

end