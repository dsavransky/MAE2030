function rotatingFrameAnimation()
% rotatingFrameAnimation draws a rigid body fixed with a rotating frame and
% animates its rotation in the inertial frame.
% See Ch. 3.4.2

% Copyright (c) 2015 Dmitry Savransky (ds264@cornell.edu)

figure(1)
clf
set(1,'Position',[1,1,850,700])

%create reference frames
a3 = plot3([0,0],[0,0],[0,1],'linewidth',2);
hold on
a2 = plot3([0,0],[0,0],[0,1],'linewidth',2);
a1 = plot3([0,0],[0,0],[0,1],'linewidth',2);
rotate(a2,[1 0 0],-90,[0,0,0])
rotate(a1,[0 1 0],90,[0,0,0])

b1 = plot3([0,0],[0,0],[0,1],'r','linewidth',2);
b2 = plot3([0,0],[0,0],[0,1],'r','linewidth',2);
th0 = 30;
rotate(b2,[1 0 0],-90+th0,[0,0,0])
rotate(b1,[1 0 0],th0,[0,0,0])

%draw a cube
cubeScale = 0.075;
X =[-1    -1    -1    -1    -1     1;
     1    -1     1     1     1     1;
     1    -1     1     1     1     1;
    -1    -1    -1    -1    -1     1]*cubeScale;

Y =[-1    -1    -1    -1     1    -1;
    -1     1    -1    -1     1     1;
    -1     1     1     1     1     1;
    -1    -1     1     1     1    -1]*cubeScale;

Z =[-1    -1     1    -1    -1    -1;
    -1    -1     1    -1    -1    -1;
     1     1     1    -1     1     1;
     1     1     1    -1     1     1]*cubeScale;
C = [0.5 1 0 0 0.5 1];
bxpos = [0.8,0.5,0.6];
bx = fill3(X+bxpos(1),Y+bxpos(2),Z+bxpos(3),C);
rotate(bx,[1,0,0],-th0,bxpos)
bvec = plot3([0,bxpos(1)],[0,bxpos(2)],[0,bxpos(3)],'k');

%set limits and view
axis equal
view(110,10)
axis([-1.1,1.1,-1.1,1.1,-1.1,1.1])
set(gca,'Visible','off')

%add labels
le3 = text(1,-0.05,0.05,'$\mathbf{\hat{e}}_3$','FontSize',18,...
    'Interpreter','LaTex');
lb3 = text(1,0.07,0,'$\mathbf{\hat{b}}_3$','FontSize',18,...
    'Interpreter','LaTex');
le1 = text(0,0.99,0.03,'$\mathbf{\hat{e}}_1$','FontSize',18,...
    'Interpreter','LaTex');
le2 = text(0,0.02,0.98,'$\mathbf{\hat{e}}_2$','FontSize',18,...
    'Interpreter','LaTex');
lI = text(0,-0.08,1.01,'$\mathcal{I}$','FontSize',18,...
    'Interpreter','LaTex');
lb1 = text(0,cos(th0*pi/180),sin(th0*pi/180),'$\mathbf{\hat{b}}_1$',...
    'FontSize',18,'Interpreter','LaTex');
lb2 = text(0,-sin(th0*pi/180)+0.025,cos(th0*pi/180),...
    '$\mathbf{\hat{b}}_2$','FontSize',18,'Interpreter','LaTex');
lB = text(0,-sin(th0*pi/180)-0.075,cos(th0*pi/180)+0.01,...
    '$\mathcal{B}$','FontSize',18,'Interpreter','LaTex');

disp('Press any key')
pause

for j=1:360
    pause(0.02)
    rotate(b2,[1 0 0],1,[0,0,0])
    rotate(b1,[1 0 0],1,[0,0,0])
    rotate(bx,[1,0,0],1,[0,0,0])
    rotate(bvec,[1,0,0],1,[0,0,0])
    rotate(lb2,[1 0 0],1,[0,0,0])
    rotate(lb1,[1 0 0],1,[0,0,0])
    rotate(lB,[1 0 0],1,[0,0,0])
end

end