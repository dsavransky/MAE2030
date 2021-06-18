function ssrb_plot()
rat = 10;
I2 = 1/(rat - 0.5);     %kg m^2
I1 = rat*I2;    %kg m^2
dims = [sqrt(I2/2), sqrt(I1 - I2/2)];
M1 = 5*I2;
[xe,ye,ze]=ellipsoid(0,0,0,dims(1),dims(2),dims(1),100);
rotMats = DCMs();

[t,z] = ode45(@ssrb_eom,0:0.1:29.7,[pi/6,0,0,-0.1,0,20]);
th = z(:,1); psi = z(:,3);
b2hist = [-sin(psi).*cos(th),cos(psi).*cos(th), sin(th)];
b1hist = [cos(psi),sin(psi), zeros(size(psi))];

    function dz = ssrb_eom(~,z)
        %z = [th,thd,psi,psid,phi,Omega]
        theta = z(1);
        thetadot = z(2);
        psidot = z(4);
        Omega = z(6);
        
        thetaddot = (-I1.*psidot.^2.*sin(2*theta)/2 + I2.*Omega.*psidot.*cos(theta) +...
            I2.*psidot.^2.*sin(2*theta)/2 - M1)./I1;
        psiddot = thetadot.*(2*I1.*psidot.*tan(theta) - I2.*Omega./cos(theta) - ...
            I2.*psidot.*tan(theta))./I1;
        Omegadot = thetadot.*(-I1.*psidot.*sin(theta).^2 - I1.*psidot + ...
            I2.*Omega.*sin(theta) + I2.*psidot.*sin(theta).^2)./(I1.*cos(theta));
        
        dz = [thetadot;
            thetaddot;
            psidot;
            psiddot;
            Omega;
            Omegadot];
    end

figure(1)
clf

s1 = surface(xe,ye,ze,'FaceAlpha',0.9);
shading interp
view(3)
axis equal
view([120,25])
b2cur = [0,1,0].';
b1cur = [1,0,0].';

th = z(1,1);
rotate(s1,b1cur,th*180/pi)
b2cur = rotMats{1}(th)*b2cur;

hold on
e3 = quiver3(0,0,0,0,0,1.1,0,'Linewidth',2,'Color','k');
b2 = quiver3(0,0,0,b2hist(1,1)*1.1,b2hist(1,2)*1.1,...
    b2hist(1,3)*1.1,0,'LineWidth',2);
b2trace = plot3(b2hist(:,1)*1.1*1.1,b2hist(:,2)*1.1,...
    b2hist(:,3)*1.1,'k-','Linewidth',2);
hold off
set(gca,'Visible','off')
t1 = text(0,0,1.2,'$\mathbf{\hat{e}}_3$','Interpreter','Latex','FontSize',18,'HorizontalAlignment','center');
t2 = text(b2hist(1,1)*1.25,b2hist(1,2)*1.25,b2hist(1,3)*1.25,'$\mathbf{\hat{b}}_2$','Interpreter','Latex','FontSize',18,'HorizontalAlignment','center');

f2 = figure(2);
f2.Position = [914 634 600 200];
clf
Omegatrace = plot(t,z(:,end),'Linewidth',2);
set(gca,'XTick',[],'YTick',[],'FontName','Times','FontSize',18)
xlabel('Time','Interpreter','Latex')
ylabel('$\Omega$','Interpreter','Latex')
ylim([min(z(:,end)),max(z(:,end))])
end