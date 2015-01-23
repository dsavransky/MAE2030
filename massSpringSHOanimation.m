% Spring-Mass System/Simple Harmonic Oscillator Animation

% Copyright (c) 2015 Dmitry Savransky (ds264@cornell.edu)

w0 = 10;    %rad/s natural frequency
x0 = 1;     %m spring rest length
p0 = 1.5;   %m initial position
v0 = 0;     %m/s initial velocity

t = 0:1/40:60; %seconds

x = x0 + (p0 - x0)*cos(w0*t) + v0/w0*sin(w0*t); %position trajectory
xd = -(x0 - p0)*w0*sin(w0*t)+v0*cos(w0*t); %velocity trajectory

f = figure(1);
clf
set(f,'Position',[1,1,1200,700])
s1 = subplot(2,2,1);
s2 = subplot(2,2,3);
s3 = subplot(2,2,[2,4]);

%set up animation
axes(s3)
bx = fill([0,2,2,0,0]/10+x(1),[1,1,-1,-1,1]/10,'b');
hold on
tbl = fill([0,max(x)+0.5,max(x)+0.5,0,0],[-0.1,-0.1,-1,-1,-0.1],'k');
sprng = drawSpring([0,0],[x(1),0],10,0.05);
sprng = plot(sprng(1,:),sprng(2,:));
hold off
axis equal
axis([0,max(x)+0.5,-0.5,0.5])
set(s3,'FontName','Times','FontSize',18)
xlabel('$\mathbf{e}_1 \rightarrow$','Interpreter','Latex')
ylabel('$\mathbf{e}_2 \rightarrow$','Interpreter','Latex')

%set up plots
axes(s1)
pos = plot(t(1),x(1),'Linewidth',2);
set(s1,'FontName','Times','FontSize',18)
xlabel('Time (s)','Interpreter','Latex')
ylabel('Position (m)','Interpreter','Latex')
axes(s2)
vel = plot(t(1),xd(1),'Linewidth',2);
set(s2,'FontName','Times','FontSize',18)
xlabel('Time (s)','Interpreter','Latex')
ylabel('Velocity (m/s)','Interpreter','Latex')


%animate
for j = 2:length(t)
    pause(t(j)-t(j-1))
    set(bx,'XData',get(bx,'XData')+(x(j) - x(j-1)));
    tmp = drawSpring([0,0],[x(j),0],10,0.05);
    set(sprng,'XData',tmp(1,:),'YData',tmp(2,:));
    set(pos,'XData',t(1:j),'YData',x(1:j));
    set(vel,'XData',t(1:j),'YData',xd(1:j));
    if t(j) < 5
        set(s1,'Xlim',[0,5])
        set(s2,'Xlim',[0,5])
    else
        set(s1,'XLimMode','auto')
        set(s2,'XLimMode','auto')
    end
end