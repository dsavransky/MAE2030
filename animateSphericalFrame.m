function animateSphericalFrame()
% animageSphericalFrame generates an animation of the two rotations from an
% inertial (cartesian) frame to a cylindrical (polar) frame to a spherical
% frame whose 3rd axis points at a point P.
%
% Copyright (c) 2015 Dmitry Savransky (ds264@cornell.edu)

h = 1;
th = 45;
phi = 30;
thr = th*pi/180;
phir = phi*pi/180;

%create inertial frame
as = make3daxes(h);
hold on
plot3(cos(thr)*sin(phir),sin(thr)*sin(phir),cos(phir),'k.','MarkerSize',25)
hold off
set(h,'Position',[60,30, 800, 600])
text(cos(thr)*sin(phir),sin(thr)*sin(phir),cos(phir)+0.1,'$$P$$',...
    'FontName','Times','FontSize',24,'Interpreter','Latex')
text(0,-0.15,1,'$$\mathbf{e}_z$$','FontName','Times',...
    'FontSize',24,'Interpreter','Latex')
text(1,-0.15,0,'$$\mathbf{e}_x$$','FontName','Times',...
    'FontSize',24,'Interpreter','Latex')
text(0,0.85,-0.075,'$$\mathbf{e}_y$$','FontName','Times',...
    'FontSize',24,'Interpreter','Latex')
pause

%rotate into cylindrical frame
rot3daxes(h,as,[0,0,1],th,'-');
text(cos(thr),sin(thr)+0.01,-0.05,'$$\mathbf{e}_r$$','FontName',...
    'Times','FontSize',24,'Interpreter','Latex')
text(-sin(thr)-0.1,cos(thr)+0.02,-0.05,'$$\mathbf{e}_\theta$$',...
    'FontName','Times','FontSize',24,'Interpreter','Latex')

pause
rot3daxes(h,as,[-sin(thr),cos(thr),0],phi,'--');
text(cos(thr)*cos(phir),sin(thr)*cos(phir),-sin(phir)-0.05,...
    '$$\mathbf{e}_\phi$$','FontName','Times',...
    'FontSize',24,'Interpreter','Latex')
text(cos(thr)*sin(phir),sin(thr)*sin(phir),cos(phir)-0.1,...
    '$$\mathbf{e}_\rho$$','FontName','Times',...
    'FontSize',24,'Interpreter','Latex')
