function res = springPendulumAnimation(t,y0,doanim)
% springPendulumAnimation numerically integrates the equations of motion of
% a spring pendulum and optionally animates the results.
%
% res = springPendulumAnimation(t,y0,doanim) performs the integration for
% time array t, with initial conditions y0 ([r(t0),\dot{r}(t0),theta(t0),
% \dot\theta(t0)]) and animates if doanim is true. res contains the results
% of the numerical integration See ode45 for details.

% Copyright (c) 2015 Dmitry Savransky (ds264@cornell.edu)

%spring pendulum Animation
%state y = [r, rd, th,thd]
g = 9.81;   %m/s^2  acceleration due to graivty
x0 = 0.1;   %m      spring rest length
m = 0.1;      %kg     pendulum mass
k = 2;      %N/m    spring constant

if ~exist('t','var') || isempty(t)
    t = 0:1/40:60; %seconds
end
if ~exist('y0','var') || isempty(y0)
    y0 = [0.5,0,pi/3,0];  %initial conditions
end
if ~exist('doanim','var') || isempty(doanim)
    doanim = true;
end

%spring pendulume ODE function
    function dy = springPendulumODE(t,y)
        %y = [r, rd, th,thd]
        r   = y(1);
        rd  = y(2);
        th  = y(3);
        thd = y(4);
        
        dy = [rd;
            r*thd^2 + g*cos(th) - k/m*(r-x0);
            thd;
            -2*rd*thd/r - g*sin(th)/r];
    end

[~,res] = ode45(@springPendulumODE,t,y0,odeset('RelTol',1e-12,'AbsTol',1e-14));

if doanim
    r = res(:,1);
    theta = res(:,3);
    x = r.*sin(theta);
    y = r.*cos(theta);
    
    f = figure(1);
    clf
    
    set(f,'Position',[1,1,1200,700])
    s1 = subplot(2,2,1);
    s2 = subplot(2,2,3);
    s3 = subplot(2,2,[2,4]);
    
    %set up animation
    axes(s3)
    a = 0:pi/100:2*pi;
    circrad = max(r)/20;
    xcirc = circrad*sin(a);
    ycirc = circrad*cos(a);
    mp = fill(xcirc+x(1),ycirc+y(1),'b');
    hold on
    tmp = drawSpring([0,0],[x(1),y(1)],10,0.05);
    sprng = plot(tmp(1,:),tmp(2,:));
    hold off
    axis equal
    axlim = [min(x-circrad),max(x+circrad),...
        min([0;y-circrad]),max([0;y+circrad])];
    axis(axlim)
    
    set(s3,'FontName','Times','FontSize',18,'YDir','Reverse',...
        'XAxisLocation','Top')
    ylabel('$\leftarrow \mathbf{e}_1 $','Interpreter','Latex')
    xlabel('$\mathbf{e}_2 \rightarrow$','Interpreter','Latex')
    
    %set up plots
    axes(s1)
    rplot = plot(t(1),r(1),'Linewidth',2);
    set(s1,'FontName','Times','FontSize',18)
    xlabel('Time (s)','Interpreter','Latex')
    ylabel('$r$ (m)','Interpreter','Latex')
    axes(s2)
    thplot = plot(t(1),theta(1),'Linewidth',2);
    set(s2,'FontName','Times','FontSize',18)
    xlabel('Time (s)','Interpreter','Latex')
    ylabel('$\theta$ (rad)','Interpreter','Latex')
    
    %animate
    for j = 2:length(t)
        pause(t(j)-t(j-1))
        set(mp,'XData',get(mp,'XData')+(x(j) - x(j-1)),...
            'YData',get(mp,'YData')+(y(j) - y(j-1)));
        tmp = drawSpring([0,0],[x(j),y(j)],10,0.05);
        set(sprng,'XData',tmp(1,:),'YData',tmp(2,:));
        
        set(rplot,'XData',t(1:j),'YData',r(1:j));
        set(thplot,'XData',t(1:j),'YData',theta(1:j));
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