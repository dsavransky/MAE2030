function [t,z] = roberts_linkage()

omega = 1;
tspan = linspace(0, 2*pi/omega, 100);

% link lengths
l1 = 3.5;
l2 = 2;

% Triangle BCP
alpha = acos(1 - l2^2/2/l1^2);
beta = asin(l1*sin(alpha)/l2);
assert(abs(alpha + 2*beta - pi) < 1e-12)

% Initial conditions
th10 = (pi-alpha)/2;
th20 = 0;
th30 = pi/2-th10;

% theta1 limits 
th1min = asin((l1 - l2.*sin(2*atan((2*l1 + sqrt(4*l1.^2 - 9*l2.^2))./(9*l2))))./l1);
th1max = pi/2;

tmp = [2*atan((2*l1.^2 - l2.*sqrt(4*l1.^2 + 9*l2.^2))./(2*l1.^2 + 4*l1.*l2 + 3*l2.^2)),...
    2*atan((2*l1.^2 + l2.*sqrt(4*l1.^2 - 9*l2.^2))./(2*l1.^2 + 4*l1.*l2 + 3*l2.^2))];
th2_th30_1 = @(th1) asin(1-sin(th1)*l2/l1);
th2_th30_2 = @(th1) acos((2*l2 - l1*cos(th1))/l2);

ths = [2.22771005890025, 0.372783068732394;
    2.61781524903608, 1.06487693051085;
    0.913882594689540, 0.372783068732394;
    0.523777404553709, 1.06487693051085];


for j = 1:4
    figure(j)
    th1 = ths(j,1);
    th2 = ths(j,2);
    th3 = 0;
    B = l1*[cos(th1), sin(th1)];
    C = B + l2*[cos(th2), sin(th2)];
    D = C + l1*[sin(th3), -cos(th3)];
    plot([0, B(1)], [0, B(2)], 'r', 'LineWidth',10);
    hold on
    plot([B(1), C(1)], [B(2), C(2)], 'g', 'LineWidth',10);
    plot([C(1), D(1)], [C(2), D(2)], 'b', 'LineWidth',10);
    plot([0, 2*l2], [0,0], 'k','LineWidth',10)
end


end