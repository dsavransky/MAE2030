function [t,z] = simplePendulumNumericalIntegration(tspan, z0, l)
% Inputs:
%   tspan (nx1)  Time span to integrate over.  See ode45 documentation for
%                details
%   z0 (2x1) Initial conditions [\theta(0); \dot\theta(0)] where theta is
%            the angle of the pendulum arm measured from the vertical
%   l  (1x1) Length of pendulum arm in m
%
% Outputs:
%   t  (nx1) Time output for numerical integration. See ode45 documentation
%            for details.
%   z  (nx2) Integrated state history for the simple pendulum.  See
%            ode45 documentation for details. 

% constants
g = 9.81;   %m/s^2  acceleration due to graivty

    %simple pendulum ODE function
    %state defined as z = [\theta; \dot\theta]
    function dz = simplePendulumODE(t,z)
        dz = [z(2);...
            -g/l*sin(z(1))];
    end

[t,z] = ode45(@simplePendulumODE,tspan,z0);


end