function sprng = drawSpring(p1,p2,nlink,ht)
% drawSpring returns an array of coordinates for plotting a spring drawing
%      sprng = drawSpring(p1,p2) returns a 2x16 array of x,y coordinates
%      describing a spring stretched between coordinates p1 and p2 (these
%      are (x,y) arrays).
%
%      sprng = drawSpring(p1,p2,nlink,ht) returns coordinates for a spring 
%      with nlink links (minimum 4) of height ht (in pixels).
%
%      Example:
%      sprng = drawSpring([0,0],[10,10])
%      plot(sprng(1,:),sprng(2,:));axis equal
%     

% Copyright (c) 2015 Dmitry Savransky (ds264@cornell.edu)

if ~exist('nlink','var')
    nlink = 10;
end

if ~exist('ht','var')
    ht = 1;
end

if nlink<4
    nlink = 4;
end

if mod (nlink,2) ~= 0
    nlink = nlink+1;
end

%get length and angle
dp = p1 - p2;
l = sqrt(sum(dp.^2));
th = atan2(dp(2),dp(1));
R = [cos(th),-sin(th);sin(th),cos(th)];

%create a triangle
tri = [0,1,2;...
       ht,-ht,ht];

%generate spring
sprng = [[-1,-tan(pi/6);0,0],tri];
for j = 1:nlink/2-2
    sprng = [sprng,tri+[ones(1,3)*sprng(1,end);zeros(1,3)]];
end
sprng = [sprng,[sprng(1,end)+[tan(pi/6),1];0,0]];

%scale and rotate
sprng(1,:) = (sprng(1,:)+1)/(sprng(1,end)+1)*l;
sprng = R*sprng;
sprng = sprng+repmat(p2(:),1,length(sprng));