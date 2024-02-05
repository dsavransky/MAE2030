% generate a plot of critical friction coefficient to
% get mechanical advantage >= 1 as a function of ramp angle

% create array of angle values
alpha = linspace(0, pi/2,100);

% compute corresponding critical friction coefficients
muc = (1 - sin(alpha))./(cos(alpha));

% plot
figure()
plot(alpha, muc, 'Linewidth',2)

% set the axis font and font size
set(gca,'FontName','Times','FontSize',18)
% label axes and add title
xlabel('Ramp Angle ($\alpha$) (rad)','Interpreter', 'Latex')
ylabel('Limiting Friction Coefficient ($\mu_c$)','Interpreter', 'Latex')
set(gca,'XTick',(0:3)*pi/6, 'XTickLabel',...
    {'0', '$\frac{\pi}{6}$', '$\frac{\pi}{3}$', '$\frac{\pi}{2}$'},...
    'TickLabelInterpreter', 'Latex','FontSize',21)