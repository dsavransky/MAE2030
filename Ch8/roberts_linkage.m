function [t,z] = roberts_linkage()

omega = 1; %rad/s
tspan = linspace(0, 2*pi/omega, 200);

% link lengths
l1 = 5;
l2 = 2;

% Triangle BCP
alpha = acos(1 - l2^2/2/l1^2);
beta = asin(l1*sin(alpha)/l2);
assert(abs(alpha + 2*beta - pi) < 1e-12)

% Initial conditions
th10 = (pi-alpha)/2;
th20 = 0;
th30 = pi/2-th10;

% theta1 limits - varies between value for th3 = 0 and pi/2
th1min = asin((l1 - l2.*sin(2*atan((2*l1 - sqrt(4*l1.^2 - 9*l2.^2))./(9*l2))))./l1);
th1max = pi/2;

% assuming theta1 is sinusoidally driven, find phase at initial time
phi = asin(2*(th10 - th1min)/(th1max-th1min) - 1);

% define th1 and its derivative 
th1fun = @(t) (1+sin(t+phi))/2*(th1max-th1min)+th1min;
th1dfun = @(t) (th1max-th1min)*cos(t+phi)/2;

[t,z] = ode45(@roberts_linkage_eom, tspan, [th20, th30].', ...
    odeset('RelTol', 1e-12, 'AbsTol', 1e-14));

%extract angles
th1s = th1fun(t);
th2s = z(:,1);
th3s = z(:,2);

% compute point locations for all times
A = zeros(length(t),2);
B = A + l1*[cos(th1s), sin(th1s)];
C = B + l2*[cos(th2s), sin(th2s)];
D = C + l1*[sin(th3s), -cos(th3s)];
% consistency check
assert(max(max(abs(D - [2*l2,0]))) < 1e-11)
P = B + [l1.*(sin(beta).*sin(th2s) + cos(beta).*cos(th2s)),...
    l1.*(-sin(beta).*cos(th2s) + sin(th2s).*cos(beta))];


% create figure and subplots
fnum = sum(double('roberts')); % somewhat unique fig number
if ishandle(fnum)
    close(fnum)
end
f = figure(fnum);
f.Position = f.Position.*[1,1,1,1.5];

ax1 = subplot(2,1,1);
ax2 = subplot(2,1,2);
ax1.Position = [0.05   0.35    0.9    0.6];
ax2.Position = [0.125 0.075, 0.8, 0.25];

% set up animation
axes(ax1)
linkA = plot([A(1,1), B(1,1)], [A(1,2), B(1,2)], 'r', 'LineWidth',10);
hold on;
linkB = plot([B(1,1), C(1,1)], [B(1,2), C(1,2)], 'g', 'LineWidth', 10);
linkC = plot([C(1,1), D(1,1)], [C(1,2), D(1,2)], 'b', 'LineWidth', 10);
plot([A(1,1), D(1,1)], [A(1,2), D(1,2)], 'k', 'LineWidth', 10);
rPB = plot([B(1,1), P(1,1)], [B(1,2), P(1,2)], 'm', 'LineWidth', 2);
rPC = plot([C(1,1), P(1,1)], [C(1,2), P(1,2)], 'm', 'LineWidth', 2);

plot(A(1,1), A(1,2), 'c.',D(1,1), D(1,2), 'c.', 'MarkerSize', 30)
Bpoint = plot(B(1,1), B(1,2), 'k.', 'MarkerSize', 30);
Cpoint = plot(C(1,1), C(1,2), 'k.', 'MarkerSize', 30);
Ppoint = plot(P(1,1), P(1,2), 'y.', 'MarkerSize', 30);

hold off
axis equal 

% find axis limits
tmp = [min([A;B;C;D;P]);max([A;B;C;D;P])];
axis(tmp(:))

% remove axis labels
set(ax1,'XTick',[], 'YTick',[])

% now set up height of P vs time plot
axes(ax2)
ptrace = plot(t(1), P(1,2), 'k', 'LineWidth',2);
xlabel('Time (s)', 'Interpreter','LaTex')
ylabel('$\mathbf{r}_{P/A}\cdot \mathbf{\hat{e}}_2$ (m)', 'Interpreter','LaTex')
set(ax2, 'FontSize',18, 'FontName','Times');
xlim([0, max(t)])
ylim([min(P(:,2)), max(P(:,2))])

% animate
for j = 2:length(t)
    set(linkA,'XData',[A(j,1), B(j,1)], 'YData',[A(j,2), B(j,2)])
    set(linkB, 'XData', [B(j,1), C(j,1)], 'YData', [B(j,2), C(j,2)]);
    set(rPB, 'XData', [B(j,1), P(j,1)], 'YData', [B(j,2), P(j,2)]);
    set(linkC, 'XData', [C(j,1), D(j,1)], 'YData', [C(j,2), D(j,2)]);
    set(rPC, 'XData', [C(j,1), P(j,1)], 'YData', [C(j,2), P(j,2)]);
    set(Bpoint, 'XData', B(j,1), 'YData', B(j,2));
    set(Cpoint, 'XData', C(j,1), 'YData', C(j,2));
    set(Ppoint, 'XData', P(j,1), 'YData', P(j,2));
    set(ptrace, 'XData', t(1:j), 'YData', P(1:j,2));
    pause(t(j) - t(j-1))
end



    function dz = roberts_linkage_eom(t,z)
        %z = [th2, th3] 
        th2 = mod(z(1),2*pi);
        th3 = mod(z(2),2*pi);
        th1 = th1fun(t);
        th1d = th1dfun(t);
        dz = [-l1.*th1d.*cos(th1 - th3)./(l2.*cos(th2 - th3));...
            th1d.*sin(th1 - th2)./cos(th2 - th3)];
    end




end