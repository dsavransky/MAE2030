% Demonstration of motion of the center of mass of a collection of 
% particles in the case where there is and is not motion of particles 
% relative to the center of mass. 
%
% See Ch. 6.1.3

% Copyright (c) 2015 Dmitry Savransky (ds264@cornell.edu)

N = 300;
th = acos(rand(1,N)*2 - 1);
phi = rand(1,N)*2*pi;
r = rand(1,N);
r0 = [r.*sin(th).*cos(phi);r.*sin(th).*sin(phi);r.*cos(th)];
rG = sum(r0,2)/N;

figure(1)
clf
set(1,'Position', [24,124,1140, 970])
p1 = scatter3(r0(1,:),r0(2,:),r0(3,:),30,'MarkerFaceColor','b');
p1.MarkerFaceAlpha=0.25;
hold on
G1 = plot3(rG(1),rG(2),rG(3),'k.','MarkerSize',60);
tr1 = plot3(rG(1),rG(2),rG(3),'k--');
hold off
axis equal
axis([-1,4,-1,4,-1,4])
grid on

figure(2)
clf
set(2,'Position', [1170,124,1140, 970])
p2 = scatter3(r0(1,:),r0(2,:),r0(3,:),30,'MarkerFaceColor','b');
p2.MarkerFaceAlpha=0.25;
hold on
G2 = plot3(rG(1),rG(2),rG(3),'k.','MarkerSize',60);
tr2 = plot3(rG(1),rG(2),rG(3),'k--');
hold off
axis equal
axis([-2,2,-2,2,-2,2])
grid on

v1 = repmat([1;1;1],1,N);
th = linspace(0,2*pi,151);
r2 = r0+repmat([cos(th(1));sin(th(1));0],1,N);
%%
for j = 1:150
    r1 = r0+v1*(j/45);
    rG1 = sum(r1,2)/N;
    set(p1,'XData',r1(1,:),'YData',r1(2,:),'ZData',r1(3,:))
    set(G1,'XData',rG1(1),'YData',rG1(2),'ZData',rG1(3))
    set(tr1,'XData',[get(tr1,'XData'),rG1(1)],...
        'YData',[get(tr1,'YData'),rG1(2)],...
        'ZData',[get(tr1,'ZData'),rG1(3)])
    
    v2 = randn(3,N);
    r2 = r2+v2/30+repmat([cos(th(j+1))-cos(th(j));sin(th(j+1))-sin(th(j));0],1,N);
    rG2 = sum(r2,2)/N;
    set(p2,'XData',r2(1,:),'YData',r2(2,:),'ZData',r2(3,:))
    set(G2,'XData',rG2(1),'YData',rG2(2),'ZData',rG2(3))
    if j == 1, set(tr2,'XData',rG2(1),'YData',rG2(2),'ZData',rG2(3)); end
    set(tr2,'XData',[get(tr2,'XData'),rG2(1)],...
        'YData',[get(tr2,'YData'),rG2(2)],...
        'ZData',[get(tr2,'ZData'),rG2(3)])
    
    pause(0.1)
end