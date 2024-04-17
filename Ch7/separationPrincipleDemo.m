
[x, y, z] = ellipsoid(0,5,0,2,1,1,20);
c1 = 10;
x = x+randn(size(x))/c1;
y = y+randn(size(y))/c1;
z = z+randn(size(z))/c1;
figure(1)
clf
%set(1,'Position', [100,265,560,420])
set(1,'Position', [24,124,1140, 970])
e1 = surf(x, y, z,'FaceLighting','phong','LineStyle','none','SpecularExponent',2);
axis equal
axlim = [-1,1,-1,1,-1,1]*8;
axis(axlim)
hold on
plot3(0,0,0,'ko','MarkerSize',10)
l1 = light('Position',[0 0 0],'Style','local');
hold off

figure(2)
clf
%set(2,'Position', [661,265,560,420])
set(2,'Position', [1170,124,1140, 970])
e2 = surf(x, y, z,'FaceLighting','phong','LineStyle','none','SpecularExponent',2);
axis equal
hold on
l1 = light('Position',[0 0 0],'Style','local');
hold off
axis([-3,3,2,8,-3,3])

for j = 1:360*30
    rotate(e1,[30,0],1,[0,0,0])
    rotate(e2,[30,60],1,[0,5,0])
    pause(0.01)
    
end