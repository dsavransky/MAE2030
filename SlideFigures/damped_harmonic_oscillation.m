

w0 = 1;    %rad/s natural frequency
t = linspace(0,2*pi/w0*5, 1000); %seconds (5 periods)

zeta = 1;
A = -zeta*1i/2/sqrt(1-zeta^2) + 1/2;
B = zeta*1i/2/sqrt(1-zeta^2) + 1/2;

z = exp(-omega0*t*zeta).*(A*exp(1i*w0*t*sqrt(1-zeta^2)) + B*exp(-1i*w0*t*sqrt(1-zeta^2)))
figure(1)
clf
plot(t,z)