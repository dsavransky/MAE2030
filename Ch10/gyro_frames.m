rotMatE3 = @(ang) [cos(ang) sin(ang) 0;-sin(ang) cos(ang) 0;0 0 1];
rotMatE2 = @(ang) [cos(ang) 0 -sin(ang);0 1 0;sin(ang) 0 cos(ang)];
rotMatE1 = @(ang) [1 0 0;0 cos(ang) sin(ang);0 -sin(ang) cos(ang)];
rotMats = {rotMatE1,rotMatE2,rotMatE3};

[rotor,axle,gimbalaxle,frameaxle,ogimbal,igimbal,frame] = createGyro([],false);
rotate([rotor,axle,igimbal],[0,0,1], 90, [0,0,0])
coordSys = eye(3);

th1 = 35;
th2 = 60;
th3 = 25;

% first rotation (all components)
rotate([rotor,axle,ogimbal,igimbal,gimbalaxle],[0 1 0],th1,[0 0 0])
coordSys = rotMats{2}(th1*pi/180)*coordSys;

% second rotation (inner gimbal)
rotate([rotor,axle,igimbal],coordSys(3,:),th2,[0 0 0])
coordSys = rotMats{3}(th2*pi/180)*coordSys;

% third rotation (rotor only)
rotate(rotor,coordSys(2,:),th3,[0 0 0])
coordSys = rotMats{2}(th3*pi/180)*coordSys;

hold on
quiver3(0,0,0,coordSys(3,1)*100, coordSys(3,2)*100, coordSys(3,3)*100)
quiver3(0,0,0,coordSys(2,1)*10, coordSys(2,2)*10, coordSys(2,3)*10)