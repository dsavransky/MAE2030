function animateSphericalFrame(nopause,doeuler)
% animateSphericalFrame generates an animation of the two rotations from an
% inertial (cartesian) frame to a cylindrical (polar) frame to a spherical
% frame whose 3rd axis points at a point P.
%
% animateSphericalFrame(true) performs the animation without pausing
% between steps (by default there is a pause between each rotation).
%
% animateSphericalFrame([],true) also shows the Euler axis (single simple
% rotation corresponding to the two separate rotations into the spherical
% frame).
%
% Ch. 10.2.2, Figure 10.4.  Note that the book uses $$\mathbf{e}_r$$ in
% both the cylindrical and spherical frames, whereas this animation uses
% $$\mathbf{e}_\rho$$ in the spherical frame definition for the third axis.
%
% Copyright (c) 2015 Dmitry Savransky (ds264@cornell.edu)

if ~exist('nopause','var') || isempty(nopause), nopause = false; end
if ~exist('doeuler','var') || isempty(doeuler), doeuler = false; end

%setup constants
h = 1;
th = 45;
phi = 30;
thr = th*pi/180;
phir = phi*pi/180;
dcm = eye(3);

%create inertial frame
as = make3daxes(h);
hold on
plot3(cos(thr)*sin(phir),sin(thr)*sin(phir),cos(phir),'k.','MarkerSize',25)
hold off
set(h,'Position',[60,30, 800, 600])
view(110,15)
text(cos(thr)*sin(phir),sin(thr)*sin(phir),cos(phir)+0.1,'$$P$$',...
    'FontName','Times','FontSize',24,'Interpreter','Latex')
text(0,-0.15,1,'$$\mathbf{e}_z$$','FontName','Times',...
    'FontSize',24,'Interpreter','Latex')
text(1,-0.15,0,'$$\mathbf{e}_x$$','FontName','Times',...
    'FontSize',24,'Interpreter','Latex')
text(0,0.85,-0.075,'$$\mathbf{e}_y$$','FontName','Times',...
    'FontSize',24,'Interpreter','Latex')
if ~nopause; pause; end

%rotate into cylindrical frame
rot3daxes(h,as,[0,0,1],th,'-');
dcm = [cos(thr) sin(thr) 0;-sin(thr) cos(thr) 0;0 0 1]*dcm;
text(cos(thr),sin(thr)+0.01,-0.05,'$$\mathbf{e}_r$$','FontName',...
    'Times','FontSize',24,'Interpreter','Latex')
text(-sin(thr)-0.1,cos(thr)+0.02,-0.05,'$$\mathbf{e}_\theta$$',...
    'FontName','Times','FontSize',24,'Interpreter','Latex')
if ~nopause; pause; end

%rotate into spherical frame
rot3daxes(h,as,[-sin(thr),cos(thr),0],phi,'--');
dcm = [cos(phir) 0 -sin(phir);0 1 0;sin(phir) 0 cos(phir)]*dcm;
text(cos(thr)*cos(phir),sin(thr)*cos(phir),-sin(phir)-0.05,...
    '$$\mathbf{e}_\phi$$','FontName','Times',...
    'FontSize',24,'Interpreter','Latex')
text(cos(thr)*sin(phir),sin(thr)*sin(phir),cos(phir)-0.1,...
    '$$\mathbf{e}_\rho$$','FontName','Times',...
    'FontSize',24,'Interpreter','Latex')

%if asked, show Euler axis and associated simple rotation
if doeuler
    if ~nopause; pause; end
    %calculate euler axis and rotation angle
    e4 = sqrt(1 + sum(diag(dcm)))/2;
    e1 = (dcm(3,2) - dcm(2,3))/(4*e4);
    e2 = (dcm(1,3) - dcm(3,1))/(4*e4);
    e3 = (dcm(2,1) - dcm(1,2))/(4*e4);
    rotAx = [e1,e2,e3];
    rotAng = 2*acos(e4)*180/pi;
    
    
    plot3([-1,1]*rotAx(1)*5,[-1,1]*rotAx(2)*5,[-1,1]*rotAx(3)*5,...
        'k','LineWidth',2)
    rot3daxes(h,as,rotAx,rotAng,'-.');
    pause(0.5)
    rot3daxes(h,as,rotAx,-rotAng,'-.');
end