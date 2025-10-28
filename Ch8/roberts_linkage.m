l1 = 3.5;
l2 = 2;

alpha = acos(1 - l2^2/2/l1^2);
beta = asin(l1*sin(alpha)/l2);

assert(abs(alpha + 2*beta - pi) < 1e-12)

th10 = (pi-alpha)/2;
th30 = pi/2-th10;

tmp = [2*atan((2*l1.^2 - l2.*sqrt(4*l1.^2 + 9*l2.^2))./(2*l1.^2 + 4*l1.*l2 + 3*l2.^2)),...
    2*atan((2*l1.^2 + l2.*sqrt(4*l1.^2 - 9*l2.^2))./(2*l1.^2 + 4*l1.*l2 + 3*l2.^2))];
th2_th30_1 = @(th1) (1-sin(th1))*l1/l2;
th2_th30_2 = @(th1) acos((2*l2 - l1*cos(th1))/l2);