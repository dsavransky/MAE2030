function [t,z] = sliding_contact_linkage()

omega = 1; % rad/s
l = 1; %m
d = 0.75; %m
th20 = 0; %rad
th10 = atan(l/d);
r0 = sqrt(l^2+d^2);

tspan = linspace(0, 2*pi/omega, 150);
[t,z] = ode45(@sliding_contact_linkage_eom, tspan, [th10, r0, th20].', ...
    odeset('RelTol', 1e-12, 'AbsTol', 1e-14));

%extract values
th1s = z(:,1);
rs = z(:,2);
th2s = z(:,3);

% compute point locations for all times
O = zeros(length(t),2);
Op = O;
Op(:,1) = d;
P = O + rs.*[cos(th1s), sin(th1s)];
P2 = Op + l*[-sin(th2s), cos(th2s)];
%consistency check
assert(max(max(abs(P - P2)))<1e-11)

% figure out range of r and slot location for all time
slota = (l-d)*[cos(th1s), sin(th1s)];
slotb = (l+d)*[cos(th1s), sin(th1s)];
A = (l+d+0.1)*[cos(th1s), sin(th1s)];

figure(1)
clf
set(1, 'Position', [1000, 581, 560, 630])
ax1 = subplot(2,1,1);
ax2 = subplot(2,1,2);

ax1.Position = [0.05   0.35    0.9    0.6];
ax2.Position = [0.125 0.075, 0.8, 0.25];

% set up animation
axes(ax1)
plot(ax1, [O(1,1), Op(1,1)], [O(1,2), Op(1,2)], 'k', 'LineWidth',5);
hold on;
linkA = plot([O(1,1), A(1,1)], [O(1,2), A(1,2)], 'r', 'LineWidth',25);
slot = plot([slota(1,1), slotb(1,1)], [slota(1,2), slotb(1,2)], 'w', 'LineWidth',10);
linkB = plot([Op(1,1), P(1,1)], [Op(1,2), P(1,2)], 'b', 'LineWidth', 10);
Ppoint = plot(P(1,1), P(1,2), 'k.', 'MarkerSize', 50);
plot(O(1,1), O(1,2), 'k.',Op(1,1), Op(1,2), 'k.', 'MarkerSize', 50);

% find axis limits
tmp = [min([O;Op;P;A]);max([O;Op;P;A])];
axis(tmp(:))
set(ax1,'XTick',[], 'YTick',[])

% now set up r vs time plot
axes(ax2)
rtrace = plot(t(1), rs(1), 'k', 'LineWidth',2);
xlabel('Time (s)', 'Interpreter','LaTex')
ylabel('$r$ (m)', 'Interpreter','LaTex')
set(ax2, 'FontSize',18, 'FontName','Times');
xlim([0, max(t)])
ylim([min(rs), max(rs)])

% animate
for j = 2:length(t)
    set(linkA,'XData',[O(j,1), A(j,1)], 'YData',[O(1,2), A(j,2)]);
    set(linkB,'XData',[Op(j,1), P(j,1)], 'YData',[Op(1,2), P(j,2)]);
    set(slot,'XData',[slota(j,1), slotb(j,1)], 'YData',[slota(j,2), slotb(j,2)]);
    set(Ppoint, 'XData', P(j,1), 'YData', P(j,2));
    set(rtrace, 'XData', t(1:j), 'YData', rs(1:j));
    pause(t(j) - t(j-1))
end

    function dz = sliding_contact_linkage_eom(~,z)
        %z = [th1, r, th2] 
        th1 = mod(z(1),2*pi);
        r = z(2);
        th2 = mod(z(3),2*pi);

        dz = [omega;... 
             -omega.*r./tan(th1 - th2);...
              omega.*r./(l.*sin(th1 - th2))];
    end
end