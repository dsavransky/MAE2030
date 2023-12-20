% Frequency response of a forced damped SHO

% set some constants
omega0 = 1;    %rad/s natural frequency
m = 1; %kg mass
k = omega0^2*m;
Fd = 1; %driving amplitude

% cover range of forcing frequencies from w0/10 to 10w0
w = logspace(log10(omega0/10),log10(omega0*10),1000);

% pick a few damping coefficients
zetas =  [0.05, 0.1, 0.2, 0.4];

% allocate arrays to store outputs
As = zeros(length(w), length(zetas));
phis = zeros(length(w), length(zetas));

% compute amplitudes and phases
counter = 1;
for zeta = zetas
b = zeta*2*m*omega0;
As(:,counter) = Fd./sqrt(m^2*(omega0^2 - w.^2).^2 + (b*w).^2);
phis(:,counter) = atan(b*w./(k - m*w.^2));
counter = counter+1;
end

% generate legend text
lgtxt = cell(length(zetas),1);
for j = 1:length(zetas), lgtxt{j} = sprintf('$\\zeta = %0.2f$', zetas(j));end

% plot the results
% set default line and color styles
set(0,'DefaultAxesLineStyleOrder',{'-','--','-.',':'});
set(0,'DefaultAxesColorOrder',[0,0,0]);
% create a figure
f = figure('Position',[500,400, 1120, 420]);
% create the first (of two) vertical subplots
subplot(2,1,1);
% plot the amplitudes 
semilogx(w,As/Fd,'LineWidth',2)
grid on
% set the axis font and font size
set(gca,'FontName','Times','FontSize',18)
% label axes 
ylabel('$A_{\mathrm{response}}/F_{\mathrm{drive}}$','Interpreter', 'Latex')
set(gca, 'XTick',[0.1,1,10],'XTickLabel',{}, 'YTick',[0,1,5,10])
% add legend
legend(lgtxt,'Interpreter','latex','FontSize',18)
% create the second (of two) vertical subplots
subplot(2,1,2);
% plot phase lags (force to 0,\pi range)
semilogx(w,mod(phis,pi),'LineWidth',2)
grid on
set(gca,'FontName','Times','FontSize',18)
% label axes 
ylabel('$\phi$ (rad)','Interpreter', 'Latex')
xlabel('Driving Frequency')
set(gca, 'XTick',[0.1,1,10],'XTickLabel',...
    {'$\omega/10$', '$\omega_0$', '$10\omega_0$'},...
    'YTick', [0, pi/2, pi], 'YTickLabel', ...
    {'$0$', '$\pi/2$', '$\pi$'},...
    'TickLabelInterpreter', 'Latex')
ylim([0,pi])