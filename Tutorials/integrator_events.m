function [t,z,te,ze] = integrator_events(z0) 
% Numerical integration with integrator events
% z0 = [x0, xdot0, y0, ydot0] - initial conditions

if ~exist('z0','var') || isempty(z0)
    z0 = [0,0,10,0];  %initial conditions
end

%define constants
g = 9.81;   %m/s^2  acceleration due to graivty

    function dz = particle_in_gravity_eom(~,z)
        %z = [x,xdot,y,ydot]
        dz = [z(2); 0; z(4); -g];
    end

    function [value,isterminal,direction] = article_in_gravity_event(~,z)
        %z = [x,xdot,y,ydot]
        % this will be zero when the mass has a height of 0:
        value = z(3); 
        isterminal = 1; %we wish to stop the integration at this point
        %direction = 1; %trigger increasing events
        direction = -1; %trigger decreasing events
    end

% set options
options = odeset('events',@article_in_gravity_event);
[t,z,te,ze] = ode45(@particle_in_gravity_eom,0:0.1:100,z0,options);

x = z(:,1);
y = z(:,3);

figure(1)
clf
plot([min([min(x),-1]),max([max(x), 1])],[0,0],'k', 'Linewidth',3)
hold on
ylim([-1,y(1)])
p = plot(x(1), y(1), '.b','MarkerSize', 100);
traj = plot(x(1),y(1), 'b--', 'Linewidth',2);

for j=2:length(y)
    set(p,'XData', x(j), 'YData', y(j))
    set(traj,'XData', x(1:j), 'YData', y(1:j))
    pause(t(j)-t(j-1))
    ylim([min([-1,y(j)-5]),y(1)])
end

end