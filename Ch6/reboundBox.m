function reboundBox(e)
% reboundBox simulates a particle undergoing sequential collisions in a
% square bounding box with coefficient of restitution e.
%
% Examples:
%   %e=0.8
%   reboundBox()
%   %e=1 (no energy loss)
%   reboundBox(1)
%   %e = 0.1
%   reboundBox(0.1)
%
%
% Copyright (c) 2015 Dmitry Savransky (ds264@cornell.edu)

if ~exist('e','var'), e = 0.8; end        %coefficient of restitution
L = 5;          %box half size
vel = [10,14];    %velocity components in inertial frame
pos = [0,0];    %position components in inertial frame

figure(1)
clf
hold on
%draw box
Ld = L+0.2;
plot([-Ld,Ld,Ld,-Ld,-Ld],[Ld,Ld,-Ld,-Ld,Ld],'b','linewidth',4);
set(gca,'Xlim',[-Ld,Ld]*1.1,'Ylim',[-Ld,Ld]*1.1,'XTick',[],'YTick',[],'Visible','off')
p = plot(pos(1),pos(2),'o','MarkerFaceColor','r','MarkerSize',16);
axis equal

for k = 1:20
    %find times to intersection
    t = (L*sign(vel)-pos)./vel;
    [mint,en_ind] = min(t);  %this is the e_n vector of the collision frame
    
    %animate motion
    nframes = 23*mint; %23 fps
    t = linspace(0,mint,nframes);
    trk = plot(pos(1),pos(2),'k--');
    for j = 1:nframes
        set(p,'XData',pos(1)+vel(1)*t(j),'YData',pos(2)+vel(2)*t(j))
        set(trk,'XData',[0,vel(1)*t(j)]+pos(1),'YData',[0,vel(2)*t(j)]+pos(2))
        pause(mint/nframes)
    end
    
    %update velocity and position vectors
    pos = pos + vel*mint;
    vel(en_ind) = -e*vel(en_ind);
    
end

end