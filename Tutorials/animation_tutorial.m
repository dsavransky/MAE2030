%% some basics of animation

% let's create a fake trajectory over a span of 3 seconds
% the human eye (on average) is sensitive to motion at ~24 fps
tend = 3; 
t = linspace(0, tend, 24*tend);
y = sin(t*20/2/pi);

%% Whole frame drawing
% the simplest approach to animating something is just redrawing the full
% frame over and over again

figure(1)
clf
j = 1
plot(t(j),y(j), 'b.', 'MarkerSize',60)
xlim([min(t),max(t)])
ylim([min(y),max(y)])
for j = 2:length(t)
    pause(t(j)-t(j-1)) %need to pause to allow the frame to render
    plot(t(j),y(j), 'b.', 'MarkerSize',60)
    xlim([min(t),max(t)])
    ylim([min(y),max(y)])
end

%% Object graphics
% note that we had a lot of repeated code in our first animation attempt
% a way to get around this is to use object graphics.  Every MATLAB plot
% element is an object, which can be controlled after it is defined

figure(1)
clf
p = plot(t(j),y(j), 'b.', 'MarkerSize',60);
xlim([min(t),max(t)])
ylim([min(y),max(y)])

for j = 2:length(t)
    pause(t(j)-t(j-1)) %need to pause to allow the frame to render
    set(p, 'XData', t(j), 'YData', y(j))
end

%% multiple objects
% we might also wish to see the full trajectory as it evolves
% we can do so by adding a second object

figure(1)
clf
p = plot(t(j),y(j), 'b.', 'MarkerSize',60);
hold on
traj = plot(t(j), y(j), 'k--');
hold off
xlim([min(t),max(t)])
ylim([min(y),max(y)])

for j = 2:length(t)
    pause(t(j)-t(j-1)) %need to pause to allow the frame to render
    set(p, 'XData', t(j), 'YData', y(j))
    set(traj, 'XData', t(1:j), 'YData', y(1:j))
end

%% rotating extended objects
% our systems will frequently include extended components we wish to rotate
% in place (or rotate and translate simultaneously)
% We can do this using DCMs or the built-in rotate method

figure(1)
clf
p = plot([0,0],[-1,1],'LineWidth',5);
xlim([-1,1])
ylim([-1,1])
axis square
pause

% turn in 5 degree increments
th = 5*pi/180;
R = [cos(th),-sin(th);sin(th),cos(th)];

for j=1:5:360
    pause(0.1) % arbitrary pause
    tmp = R*[p.XData; p.YData];
    set(p, 'XData',tmp(1,:), 'YData', tmp(2,:))
end

%% now with the rotate command
figure(1)
clf
p = plot([0,0],[-1,1],'LineWidth',5);
xlim([-1,1])
ylim([-1,1])
axis square

for j=1:5:360
    pause(0.1) % arbitrary pause
    rotate(p,[0, 0, 1], 5)
end

%% 3D objects and transform objects

% things can get a lot more complex in 3D, but MATLAB has useful built-in
% transforms to help you out. 

% let's draw the Earth
earth = imread('landOcean.jpg'); %read Earth map (should be in MATLAB demos dir)
f1 = figure(1);
clf(f1)

[x,y,z] = sphere(100);
props.AmbientStrength = 0.25;  %some ambient light
props.DiffuseStrength = 1;  %full diffuse illumination
props.SpecularColorReflectance = 0.5;
props.SpecularExponent = 1;
props.SpecularStrength = 0.45;
props.FaceColor= 'texture';
props.EdgeColor = 'none';
props.FaceLighting = 'gouraud';
props.Cdata = earth;
Earth = surface(x,y,flip(z),props);
hold on
g = hgtransform;
Earth.Parent = g;
view(50,10)
axis([-1.5,1.5,-1.5,1.5,-1.5,1.5])
axis equal off

%light is effective point source at sun location
sun = light('Position',[0.5164,-2.0623,-0.8941]*1e4,'Style','local');

%%
w_e = 7.2921150e-5; %Earth rotation (rad/s) 
t = linspace(0, 86400, 86400/24);

for j = 2:length(t)
    set(g,'Matrix',makehgtform('zrotate',w_e*t(j)))
    pause((t(j)-t(j-1))/6000) 
end