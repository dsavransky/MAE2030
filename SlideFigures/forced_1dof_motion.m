% define some arbitrary constants
t = linspace(0,1,100);
x0 = 1;
xd0 = 0.25;
Fmp = 10;

% compute position and velocity trajectories
xd = xd0 + Fmp*t;
x = x0 + xd0*t + Fmp*t.^2/2;

% plot the results
% create a figure
f = figure('Position',[500,400, 1120, 420]);
% create the first (of two) horizontal subplots
subplot(1,2,1);
% plot the velocity trajectory
plot(t,xd,'k','LineWidth',2)
% set the axis font and font size
set(gca,'FontName','Times','FontSize',18)
ylim([0,max(xd)]) %force axes to full range
% modify axis ticks and labels
set(gca,'XTick',[min(t), max(t)], 'XTickLabel',{'$t_0$', '$t_f$'},...
    'YTick', xd0, 'YTickLabel', '$\dot{x}(t_0)$',...
    'TickLabelInterpreter', 'Latex')
% label axes and add title
xlabel('Time','Interpreter', 'Latex')
ylabel('$\dot{x}(t)$','Interpreter', 'Latex')
title('Velocity')

% create second horizontal subplot
subplot(1,2,2);
% plot the velocity trajectory
plot(t,x,'k','LineWidth',2)
% set the axis font and font size
set(gca,'FontName','Times','FontSize',18)
ylim([0,max(x)]) %force axes to full range
% modify axis ticks and labels
set(gca,'XTick',[min(t), max(t)], 'XTickLabel',{'$t_0$', '$t_f$'},...
    'YTick', x0, 'YTickLabel', '$x(t_0)$',...
    'TickLabelInterpreter', 'Latex')
% label axes
xlabel('Time','Interpreter', 'Latex')
ylabel('$x(t)$','Interpreter', 'Latex')
title('Position')
