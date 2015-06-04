function compareSimplePendulumSHO
% compareSimplePendulumSHO draws plots comparing the trajectories of the
% numerically integrated simple pendulum equations of motion with the
% analytical results of the linearized equations.
%
% See Example 3.9

% Copyright (c) 2015 Dmitry Savransky (ds264@cornell.edu)

g = 9.81;           %m/s^2  acceleration due to graivty
l = 1;              %m      length of pendulum arm
w0 = sqrt(g/l);     %natural frequency of linearized equations

t = linspace(0,10,150); %time (s)
do_compareSimplePendulumSHO_plots(1,[pi/3,0])
do_compareSimplePendulumSHO_plots(2,[0.1,0])
set(1,'Position',[1,1,575,700])
set(2,'Position',[576,1,575,700])

    function do_compareSimplePendulumSHO_plots(h,y0)
        A = y0(1);
        B = y0(2)/w0;
        
        thsho = A*cos(w0*t) + B*sin(w0*t);
        thdsho = -A*w0*sin(w0*t) + B*w0*cos(w0*t);
        
        res = simplePendulumAnimation(t,y0,false);
        theta = res(:,1);
        thetad = res(:,2);
        
        figure(h)
        clf
        subplot(2,1,1)
        plot(t,thsho,t,theta,'--')
        legend({'SHO Equations','Numerical Integration'})
        set(gca,'FontName','Times','FontSize',18)
        ylabel('$\theta$ (rad)','Interpreter','Latex')
        title(['$\theta(0) = $',num2str(y0(1)),...
            ', $\dot\theta(0) = $',num2str(y0(2))],'Interpreter','Latex');
        subplot(2,1,2)
        plot(t,thdsho,t,thetad,'--')
        set(gca,'FontName','Times','FontSize',18)
        xlabel('Time (s)','Interpreter','Latex')
        ylabel('$\dot\theta$ (rad/s)','Interpreter','Latex')
    end

end