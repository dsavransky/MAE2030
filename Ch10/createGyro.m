function [rotor,axle,gimbalaxle,frameaxle,ogimbal,igimbal,frame,l] = ...
    createGyro(h, frameon)
% createGyro generates graphics objects simulating a 3-axis gimbaled 
% gyroscope suitable for use in animation.
% 
% [rotor,axle,gimbalaxle,frameaxle,ogimbal,igimbal,frame,l] = createGyro(h) 
% returns the graphics objects associated with each of the named
% components in figure h.

% Written by Dmitry Savransky sometime in 2009
% Copyright (c) 2016 Dmitry Savransky (ds264@cornell.edu)

%if no inputs given
if ~exist('h','var') || isempty(h), h = 1; end
if ~exist('frameon','var') || isempty(frameon), frameon = true; end

cs = colormap('Gray');
inds = round(linspace(length(cs)*0.3,length(cs)/1.5,4));
cs = cs(inds,:);

figure(h)
clf

[xt,yt,zt] = cylinder(1,100);
zt = zt - 0.5;

rotorc = cs(4,:);
axlec = cs(2,:);
gimbalc = cs(3,:);
framec = cs(1,:);

%lights
l(1) = light('Position',[4 4 4]);
hold on
l(2) = light('Position',[4 -4 4]);
lighting phong

%rotor
rotor(1) = surface(xt,yt,0.5*zt,'FaceColor',rotorc,'FaceAlpha',0.75);
rotor(2) = fill3(xt(1,:),yt(1,:),0.5*zt(1,:),rotorc,'FaceAlpha',0.75);
rotor(3) = fill3(xt(1,:),yt(1,:),0.5*zt(2,:),rotorc,'FaceAlpha',0.75);
rotate(rotor,[0 1 0],90,[0,0,0])

%various axles
axle = surface(xt*0.1,yt*0.1,zt*5.2,'FaceColor',axlec,'EdgeColor','none');
rotate(axle,[0 1 0],90,[0 0 0 ])
gimbalaxle(1) = surface(xt*0.1,yt*0.1,zt*0.25+2.6,...
    'FaceColor',axlec,'EdgeColor','none');
gimbalaxle(2) = surface(xt*0.1,yt*0.1,zt*0.25-2.6,...
    'FaceColor',axlec,'EdgeColor','none');
frameaxle(1) = surface(xt*0.1,yt*0.1,zt+3.1,...
    'FaceColor',axlec,'EdgeColor','none');
frameaxle(2) = surface(xt*0.1,yt*0.1,zt-3.1,...
    'FaceColor',axlec,'EdgeColor','none');
rotate(frameaxle,[1 0 0],90,[0,0,0])

%inner gimbal
igimbal = surface(2.5*xt,2.5*yt,0.5*zt,'FaceColor',gimbalc,...
    'FaceAlpha',0.9,'EdgeColor','none');
rotate(igimbal,[1 0 0],90,[0 0 0])
ogimbal = surface(2.7*xt,2.7*yt,0.5*zt,'FaceColor',gimbalc,...
    'FaceAlpha',0.9,'EdgeColor','none');
rotate(ogimbal,[0 1 0],90,[0,0,0])

%frame
frame = zeros(4,1);
x = 0.375;
y = 3.5; 
v = [-x,-y;x,-y;x,y;-x,y;-x,-y];
for j=1:4
    frame(j) = fill3(v(:,1),v(:,2),zeros(length(v),1),framec,...
        'FaceAlpha',0.9,'EdgeColor','none','BackFaceLighting','lit');
end
set(frame(1),'ZData',get(frame(1),'ZData')+y)
set(frame(2),'ZData',get(frame(2),'ZData')-y)
rotate(frame(3:4),[1 0 0], 90, [0 0 0])
set(frame(3),'YData',get(frame(3),'YData')-y)
set(frame(4),'YData',get(frame(4),'YData')+y)
if ~frameon
    set(frame, 'Visible', 'off')
end

view(135,10)
axis equal
hold off

set(gca,'Visible','off','XLimMode','manual','YLimMode','manual',...
    'ZLimMode','manual')
