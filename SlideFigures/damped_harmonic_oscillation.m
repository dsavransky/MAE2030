omega = 10;    %rad/s natural frequency
t = linspace(0,2*pi/omega*5, 1000); %seconds (5 periods)
%initial conditions
z0 = 1; %m 
zdot0 = 0; %m/s
zeta = [.1 5 1]; %damping coefficient

% underdamped
omegad = omega*sqrt(1-zeta(1)^2);
r1 = exp(-zeta(1)*omega*t).*(z0.*cos(omegad*t)+ ...
    (zdot0+z0*zeta(1)*omega)/(omega*sqrt(1-zeta(1)^2))*sin(omegad*t));

% overdamped
A = -(zdot0+z0*omega*(zeta(2)-sqrt(zeta(2)^2-1)))/...
    (2*omega*sqrt(zeta(2)^2-1));
B = (zdot0+z0*omega*(zeta(2)+sqrt(zeta(2)^2-1)))/...
    (2*omega*sqrt(zeta(2)^2-1));
r2 = A*exp(-omega*(zeta(2)+sqrt(zeta(2)^2-1))*t) + ...
     B*exp(-omega*(zeta(2)-sqrt(zeta(2)^2-1))*t);

% critically damped
r3 = z0*exp(-zeta(3)*omega*t)+(zdot0+z0*zeta(3)*omega)*t.*...
    exp(-zeta(3)*omega*t);

% plot
f = figure('Position',[500,400, 840, 420]);
plot(t,r1,t,r2,'--',t,r3,'-.','linewidth',3)
xlim([0, max(t)])
ylim([-z0, z0])
set(gca,'FontSize',16,'FontName','Times')

% modify axis ticks and labels
xticklabels = cell(1,5);
for j=1:5, xticklabels{j} = sprintf('$\\frac{%d \\pi}{\\omega_0}$', j*2); end
set(gca,'XTick',(1:5)*2*pi/omega, 'XTickLabel',xticklabels,...
    'YTick', [-z0, 0, z0], 'YTickLabel', {'$-z(t_0)$','0', '$z(t_0)$'},...
    'TickLabelInterpreter', 'Latex','FontSize',21)

xlabel('Time t (s)','FontSize',18, 'Interpreter','latex')
ylabel('$z(t)=x(t)-x_0$ (m)','FontSize',18, 'Interpreter','latex')
legend({'Underdamped $\zeta=0.1$','Overdamped $\zeta=5$',...
    'Critically damped $\zeta=1$'}, 'Interpreter','latex')

grid on