% define some arbitrary constants
w0 = 10;    %rad/s natural frequency
x0 = 1;     %m spring rest length
p0 = 1.5;   %m initial position
v0 = 0;     %m/s initial velocity
t = linspace(0,2*pi/w0*5, 1000); %seconds (5 periods)

x = x0 + (p0 - x0)*cos(w0*t) + v0/w0*sin(w0*t); %position trajectory
xd = -(x0 - p0)*w0*sin(w0*t)+v0*cos(w0*t); %velocity trajectory

% plot the results
% create a figure
f = figure('Position',[500,400, 1120, 420]);
% create the first (of two) horizontal subplots
subplot(1,2,1);
% plot the position trajectory
plot(t,x,'k','LineWidth',2)
% set the axis font and font size
set(gca,'FontName','Times','FontSize',18)
% label axes and add title
xlabel('Time (s)','Interpreter', 'Latex')
ylabel('${x}(t)$ (m)','Interpreter', 'Latex')
title('Position')

% create second horizontal subplot
subplot(1,2,2);
% plot the velocity trajectory
plot(t,xd,'k','LineWidth',2)
% set the axis font and font size
set(gca,'FontName','Times','FontSize',18)
% label axes
xlabel('Time (s)','Interpreter', 'Latex')
ylabel('$\dot{x}(t)$ (m/s)','Interpreter', 'Latex')
title('Velocity')