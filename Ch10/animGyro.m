% Script that draws a 3-element gyro and animates its motion 

% Written by Dmitry Savransky sometime in 2009
% Copyright (c) 2016 Dmitry Savransky (ds264@cornell.edu)

[rotor,axle,gimbalaxle,frameaxle,ogimbal,igimbal,frame] = createGyro();

%coordinate system
coordSys = eye(3);
%define rotation matrices
rotMatE3 = @(ang) [cos(ang) sin(ang) 0;-sin(ang) cos(ang) 0;0 0 1];
rotMatE2 = @(ang) [cos(ang) 0 -sin(ang);0 1 0;sin(ang) 0 cos(ang)];
rotMatE1 = @(ang) [1 0 0;0 cos(ang) sin(ang);0 -sin(ang) cos(ang)];
rotMats = {rotMatE1,rotMatE2,rotMatE3};

psi = 180;
theta = 180;
n = 180;
for k = 1:1000
    for j = 1:n
        rotate([rotor,axle,ogimbal,igimbal,gimbalaxle],[0 1 0],psi/n,...
            [0 0 0])
        coordSys = rotMats{2}(psi/n*pi/180)*coordSys;
        rotate([rotor,axle,igimbal],coordSys(3,:),theta/n,[0 0 0])
        pause(0.01);
    end
end

