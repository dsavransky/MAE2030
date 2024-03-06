% generate a plot of kinetic energy as a function of coefficient of
% restitution in a head-on collision

% create array of e values
e = linspace(0, 1,100);

% compute KE(t_2)/KE(t_1)
KEratio = ((1 - e)/2).^2 + ((1 + e)/2).^2;

% plot
figure()
plot(e, KEratio, 'k', 'Linewidth',2)

% set the axis font and font size
set(gca,'FontName','Times','FontSize',18)
% label axes and add title
xlabel('Coefficient of Restitution','Interpreter', 'Latex')
ylabel('KE($t_2$)/KE($t_1$)','Interpreter', 'Latex')
