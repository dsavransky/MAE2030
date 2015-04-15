function [t,z,r_PO] = wattLinkage(n,npathpoints,lengths,omega)
% wattLinkage - integrate the equations of motion for a Watt Linkage and
% animate
%
% [t,z,r_PO] = wattLinkage(n,npathpoints,lengths,omega) integrates the
% equations of motion for a 3 bar Watt linkage and animates the motion of
% the system over n cycles (one cycle is defined as a full sweep top to
% bottom - 10 by default).  npathpoints determines the number of trajectory 
% points to plot (Inf by default, for all).  lengths is an optional 3 
% element array of inkage lengths ([3,1,3] by default).  
% omega is the angular rate in radians per second (0.5 by default).  
%
% The returned values are the intergrator outputs (t and z) and the 
% position of the center of the intermediate bar.
% 
% Example  
%    % animate system over 10 cycles
%    wattLinkage();
%    %animate asymmetric linkage
%    [t,z,r_PO] = wattLinkage([],[],[5 1 2]);

% Written by Dmitry Savransky 21 May 2007
% Copyright (c) 2015 Dmitry Savransky (ds264@cornell.edu)

%check inputs
if ~exist('n','var') || isempty(n),n = 10;end
if ~exist('npathpoints','var') || isempty(npathpoints),npathpoints=Inf;end
if ~exist('lengths','var') || isempty(lengths) || numel(lengths) ~= 3
    %linkage lengths
    l1 = 3;
    l2 = 1;
    l3 = l1;
else
    l1 = lengths(1); l2 = lengths(2); l3 = lengths(3);
end
if ~exist('omega','var') || isempty(omega), omega = -0.5; end

%initial conditions
z0 = [0,0,0];
t = 0;
z = z0;
%calculate trajectory for n cycles
for j=1:n
    [t1,z1] = ode45(@wattLinkage_eq,t(end):1/25:t(end)+10,z(end,:),...
        odeset('RelTol',1e-12,'AbsTol',1e-12,'Events',@wattLinkage_event));
    omega = -omega;
    t = [t;t1];
    z = [z;z1];
end

%calculate positions of all points
tAB = z(:,1);
tBC = z(:,2);
tCD = z(:,3);
r_PO = [l1*cos(tAB) + l2/2*sin(tBC),l1*sin(tAB) - l2/2*cos(tBC)];
r_B = [l1*cos(tAB),l1*sin(tAB)];
r_C = [l1*cos(tAB) + l2*sin(tBC),l1*sin(tAB) - l2*cos(tBC)];

%generate supports
h = l2/5;
s1 = [0,h/2,-h/2 0;0,-h,-h,0];
s2 = [s1(1,:)+l1+l3;s1(2,:)-l2];

%findmaximum axis area
ax = [ min([-h/2,0;r_B;r_C]), max([l1+l3+h/2,0;r_B;r_C])];
ax = ax([1,3,2,4]);
ax(3:4) = ax(3:4)*1.05;

%animate
figure(1)
hold off
for j = 1:length(t)
    %plot links
    plot([0,r_B(j,1)],[0,r_B(j,2)],'r',...
         [r_B(j,1),r_C(j,1)],[r_B(j,2),r_C(j,2)],'g',...
         [r_C(j,1),l1+l3],[r_C(j,2),-l2],'b','LineWidth',3)
    hold on
    
    %draw supports
    fill(s1(1,:),s1(2,:),'r')
    fill(s2(1,:),s2(2,:),'b')
    
    %plot track so far:
    plot(r_PO(max([j-npathpoints,1]):j,1),...
        r_PO(max([j-npathpoints,1]):j,2),'k--');
    
    %set axes to proper values:
    axis equal;
    grid on;
    axis(ax);
    set(gca,'XTickLabel',[],'YTickLabel',[])
    hold off;
    %pause for length of time step
    if j < length(t)
        pause(t(j+1)-t(j));
    end
    
end

    function dz = wattLinkage_eq(t,z)
        %z =[theta_AB,theta_BC,theta_CD]
        tAB = z(1);
        tBC = z(2);
        tCD = z(3);
        
        dz = [omega;...
             (omega *l1*sin(tAB - tCD))/(l2*cos(tBC - tCD));...
             (-omega*l1*cos(tAB - tBC))/(l3*cos(tBC - tCD))];
    end

    function [val,isterminal,dr] = wattLinkage_event(t,z)
        %terminate when tAB - tBC + pi/2 = 0 and tBC - tCD - pi/2 = 0
        val = [z(1) - z(2) + pi/2*0.9,z(2) - z(3) - pi/2*0.9];
        isterminal = [1,1];
        dr = [0,0];
        
    end
end