function [t,y] = doubleSimplePendulumAnimation(tspan,y0,mp,mq,l1,l2)
%[t2,y2] = doubleSimplePendulumAnimation([0,10],[pi/2+0.1,-3,pi/2,0]);

if ~exist('mp','var'), mp = 4; end
if ~exist('mq','var'), mq = 4; end
if ~exist('l1','var'), l1 = 1; end
if ~exist('l2','var'), l2 = 0.75; end

g=9.81; %m/s^2
mup = mp/(mq+mp);
muq = mq/(mq+mp);

[t,y] = ode45(@double_pendulum_eq,tspan,y0);

%figure out trajectories
th1 = y(:,1);
th2 = y(:,3);

r_poprime = [ l2*sin(th2),-l2*cos(th2)];
r_oprimeo = [ l1*sin(th1),-l1*cos(th1)];
r_po = r_poprime+r_oprimeo;

maxr = max(sum(r_po.^2,2));
xmin = min([r_po(:,1);0])-maxr/10;
xmax = max(r_po(:,1))+maxr/10;
ymin = min(r_po(:,2))-maxr/10;
ymax = max([0,max(r_po(:,2))])+maxr/10;

%create and clear figure
h = figure(1);
clf(h);

% create a circle and a square:
a = 0:pi/100:2*pi;

xscirc = maxr/50*sin(a);
yscirc = maxr/50*cos(a);

%step in time:
for i=1:length(t)
    %plot track so far:
    plot(r_po(max([i-Inf,1]):i,1),r_po(max([i-Inf,1]):i,2),'b--');
    hold on
    plot(r_oprimeo(max([i-Inf,1]):i,1),r_oprimeo(max([i-Inf,1]):i,2),'r--');

    %connect pivots:
    plot([0,r_oprimeo(i,1)],[0,r_oprimeo(i,2)],'r','LineWidth',7)
    plot([r_oprimeo(i,1),r_po(i,1)],[r_oprimeo(i,2),r_po(i,2)],'b','LineWidth',7)

    %draw the the mass:
    fill(xscirc+r_po(i,1),yscirc+r_po(i,2),'g');

    %set axes to proper values:
    axis equal;
    grid on;
    axis([xmin xmax ymin ymax]);
    hold off;
    %pause for length of time step
    if i < length(t)
        pause(t(i+1)-t(i));
    end
end


    function yprime = double_pendulum_eq(t,y)
        th1=y(1);dth1=y(2);th2=y(3);dth2=y(4);
        beta=th2-th1;
        den1 = mup + muq*sin(beta)^2;
        yprime = [dth1; ...
                  (muq*l1*sin(beta)*cos(beta)*dth1^2 + ....
                   muq*sin(beta)*l2*dth2^2 + g*(muq*cos(beta)*sin(th2) -...
                    sin(th1)))/(l1*den1);...
                  dth2;...
                  -(g*cos(th1)*sin(beta) + l1*sin(beta)*dth1^2 + ...
                    l2*muq*cos(beta)*sin(beta)*dth2^2)/(l2*den1)];
    end

end