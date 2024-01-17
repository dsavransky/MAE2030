% create impulse position/velocity trajectories

% create a figure
f = figure('Position',[500,400, 1120, 420]);
% create the first (of two) horizontal subplots
subplot(1,2,1);
% plot the velocity trajectory
plot([0,0.5,0.5,1],[0,0,1,1],'k','LineWidth',2)
% set the axis font and font size
set(gca,'FontName','Times','FontSize',18)
% modify axis ticks and labels
set(gca,'XTick',0.5, 'XTickLabel',{'$t_1 \approx t_2$'},...
    'YTick', [0,1], 'YTickLabel', {'0','$\mathbf{\overline{F}}_P(t_1,t_2)/m_P$'},...
    'TickLabelInterpreter', 'Latex')
% label axes and add title
xlabel('Time','Interpreter', 'Latex')
tmp = ylabel(['$\newcommand{\leftexp}[2]{{\vphantom{#2}}^{#1}\!{#2}} ',...
    '\Vert \leftexp{\mathcal{I}}{\mathbf{v}_{P/O}}\Vert$'],...
    'Interpreter', 'Latex');
tmp.Position = [-0.01,0.5,-1];
title('Velocity')

% create second horizontal subplot
subplot(1,2,2);
% plot the position trajectory
plot([0,0.5,1],[0,0,1],'k','LineWidth',2)
% set the axis font and font size
set(gca,'FontName','Times','FontSize',18)
% modify axis ticks and labels
set(gca,'XTick',0.5, 'XTickLabel',{'$t_1 \approx t_2$'},...
    'YTick', [], 'YTickLabel', {},...
    'TickLabelInterpreter', 'Latex')

% label axes
xlabel('Time','Interpreter', 'Latex')
ylabel('$\Vert \mathbf r_{P/O}\Vert$','Interpreter', 'Latex')
title('Position')
