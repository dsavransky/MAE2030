function [t,z] = four_bar_linkage()

omega = 1; % rad/s
lA = 1; %m
lB = 1; %m
th10 = pi/4; %rad
th20 = 0.1; %rad
th30 = pi/6; %rad
lC = (lA*sin(th10)+lB*sin(th20))/sin(th30); %m
lD = lA*cos(th10) + lB*cos(th20)-lC*cos(th30); %m

assert(lD+lC < lA + lB) %continuous motion condition

% initial conditions and plot
A0 = [0,0];
B0 = A0 + lA*[cos(th10), sin(th10)];
C0 = B0 + lB*[cos(th20), sin(th20)];
D0 = C0 - lC*[cos(th30), sin(th30)];

% create figure and subplots
fnum = sum(double('fourbar')); % somewhat unique fig number
if ishandle(fnum)
    close(fnum)
end
f = figure(fnum);
f.Position = f.Position.*[1,1,1,1.5];

ax1 = subplot(2,1,1);
ax2 = subplot(2,1,2);
ax1.Position = [0.05   0.35    0.9    0.6];
ax2.Position = [0.125 0.075, 0.8, 0.25];

axes(ax1)
linkA = plot([A0(1), B0(1)], [A0(2), B0(2)], 'r', 'LineWidth',10);
hold on;
linkB = plot([B0(1), C0(1)], [B0(2), C0(2)], 'g', 'LineWidth', 10);
linkC = plot([C0(1), D0(1)], [C0(2), D0(2)], 'b', 'LineWidth', 10);
plot([D0(1), A0(1)], [D0(2), A0(2)], 'k', 'LineWidth', 10);
axis equal;
plot(A0(1), A0(2), 'c.',D0(1), D0(2), 'c.', 'MarkerSize', 30)
Bpoint = plot(B0(1), B0(2), 'k.', 'MarkerSize', 30);
Cpoint = plot(C0(1), C0(2), 'k.', 'MarkerSize', 30);
hold off
axis equal 

%do a full revolution:
tspan = linspace(0, 2*pi/omega, 100);
[t,z] = ode45(@four_bar_linkage_eom, tspan, [th10, th20, th30].', ...
    odeset('RelTol', 1e-12, 'AbsTol', 1e-14));

%extract angles
th1s = z(:,1);
th2s = z(:,2);
th3s = z(:,3);

% compute point locations for all times
A = zeros(length(t),2);
B = A + lA*[cos(th1s), sin(th1s)];
C = B + lB*[cos(th2s), sin(th2s)];
D = C - lC*[cos(th3s), sin(th3s)];

% find axis limits
tmp = [min([A;B;C;D]);max([A;B;C;D])];
axis(tmp(:))

% remove axis labels
set(ax1,'XTick',[], 'YTick',[])

% now set up angle vs time plot
axes(ax2)
th1trace = plot(t(1), th1s(1), 'r', 'LineWidth',2);
hold on
th2trace = plot(t(1), th2s(1), 'g--', 'LineWidth',2);
th3trace = plot(t(1), th3s(1), 'b.-', 'LineWidth',2);
xlabel('Time (s)', 'Interpreter','LaTex')
ylabel('Angle (rad)', 'Interpreter','LaTex')
set(ax2, 'FontSize',18, 'FontName','Times');
xlim([0, max(t)])
ylim([min(z(:)), max(mod(z(:),2*pi))])
hold off
legend({"$\theta_1$","$\theta_2$","$\theta_3$"}, 'Interpreter','LaTeX',...
    'Location', 'NorthWest')

% animate
for j = 2:length(t)
    set(linkA,'XData',[A0(1), B(j,1)], 'YData',[A0(2), B(j,2)])
    set(linkB, 'XData', [B(j,1), C(j,1)], 'YData', [B(j,2), C(j,2)]);
    set(linkC, 'XData', [C(j,1), D(j,1)], 'YData', [C(j,2), D(j,2)]);
    set(Bpoint, 'XData', B(j,1), 'YData', B(j,2));
    set(Cpoint, 'XData', C(j,1), 'YData', C(j,2));
    set(th1trace, 'XData', t(1:j), 'YData', mod(th1s(1:j),2*pi));
    set(th2trace, 'XData', t(1:j), 'YData', mod(th2s(1:j),2*pi));
    set(th3trace, 'XData', t(1:j), 'YData', mod(th3s(1:j),2*pi));
    pause(t(j) - t(j-1))
end

    function dz = four_bar_linkage_eom(~,z)
        %z = [th1, th2, th3] 
        th1 = mod(z(1),2*pi);
        th2 = mod(z(2),2*pi);
        th3 = mod(z(3),2*pi);
        dz = [omega;...
            -lA.*omega.*sin(th1 - th3)./(lB.*sin(th2 - th3));...
            -lA.*omega.*sin(th1 - th2)./(lC.*sin(th2 - th3))];
    end
end