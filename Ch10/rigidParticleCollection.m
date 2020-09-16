%visualization of rigid body constraints for a particle system
figure(1)
clf
plot3([-1,-1,1,1,-1,1,1,-1],[-1,1,1,-1,-1,1,-1,1],[0,0,0,0,0,0,0,0],...
    '.-','MarkerSize',40)
axis equal
axis([-1,1,-1,1,-1,1]*1.1)

hold on
p3 = plot3(0,0,1,'.','MarkerSize',40);
view(-65,10)
grid on

pause

l1 = plot3([-1,0],[-1,0,],[0,1]);
pause 

th = linspace(0,2*pi,100);
for j=1:length(th)
    set(p3,'YData',sin(th(j)),'ZData',cos(th(j)))
    set(l1,'YData',[-1,sin(th(j))],'ZData',[0,cos(th(j))])
    pause(0.02)
end

pause

l2 = plot3([-1,0],[1,0,],[0,1]);

pause 

for j=[1:length(th)/2,length(th)/2:-1:1]
    set(p3,'YData',sin(th(j)),'ZData',cos(th(j)))
    set(l1,'YData',[-1,sin(th(j))],'ZData',[0,cos(th(j))])
    set(l2,'YData',[1,sin(th(j))],'ZData',[0,cos(th(j))])
    pause(0.02)
end

pause

l3 = plot3([1,0],[1,0,],[0,1]);