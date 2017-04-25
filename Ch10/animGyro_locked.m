[rotor,axle,gimbalaxle,frameaxle,ogimbal,igimbal,frame] = createGyro();

%coordinate system
coordSys = eye(3);
%define rotation matrices
rotMatE3 = @(ang) [cos(ang) sin(ang) 0;-sin(ang) cos(ang) 0;0 0 1];
rotMatE2 = @(ang) [cos(ang) 0 -sin(ang);0 1 0;sin(ang) 0 cos(ang)];
rotMatE1 = @(ang) [1 0 0;0 cos(ang) sin(ang);0 -sin(ang) cos(ang)];
rotMats = {rotMatE1,rotMatE2,rotMatE3};

rotate([rotor,axle,igimbal],[0,0,1],90,[0 0 0])
axlim = axis(gca);
axlim = [min(axlim),max(axlim),min(axlim),max(axlim),min(axlim),max(axlim)];

psi = 180;
n = 180;
for k = 1:1000
    for j = 1:n
        %rotate([rotor,axle,ogimbal,igimbal,gimbalaxle],coordSys(2,:),psi/n,[0 0 0])
        rotate([rotor,axle,ogimbal,igimbal,gimbalaxle],[0 1 0],psi/n,[0 0 0])
%         coordSys = rotMats{2}(psi/n*pi/180)*coordSys;
%         rotate([rotor,axle,igimbal],coordSys(3,:),theta/n,[0 0 0])
        axis(axlim)
        pause(0.01);
    end
end

