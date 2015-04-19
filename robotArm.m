function varargout = robotArm(varargin)
%ROBOTARM - Simulate 3-link robot arm to smoothly raise a glass.
%      ROBOTARM, by itself, creates a new ROBOTARM or raises the existing
%      singleton.
%
%      H = ROBOTARM returns the handle to a new ROBOTARM or the handle to
%      the existing singleton.
%
%      This simulation finds the angular velocity time histories required
%      to raise a glass from ground level to table height in a straight 45
%      degree trajectory.  Build Robot constructs the robot from inputs,
%      and Go! starts the simulation.
%
%      Editable fields are:
%       d_1 - Base of initial triangle formed by first arm
%       d_2 - Base of initial triangle formed by second arm
%       h   - height of initial triangle formed by two arms
%       table_height - height of table where glass is placed
%       Time - Amount of time motion should take.
%
%      d_1, d_2 and h determine the lengths of the two arms, and Time
%      determines the initial angular velocities.
%
%      The plot menu allows you to generate plots of the angle and angular
%      velocity time histories for the two arms. The angles are measured
%      from inertial horizontal (i.e., the bottom two angles of the initial
%      triangle) and the angular velocities are of dextral reference frames
%      aligned with the two arms (i.e. {}^\mathcal{I}\omega^\mathcal{A} =
%      \dot\omega_1 and {}^\mathcal{I}\omega^\mathcal{B} = -\dot\omega_2).
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Written by Dmitry Savransky, 12 February 2010
% Copyright (c) 2015 Dmitry Savransky (ds264@cornell.edu)

% Begin initialization code
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @robotArm_OpeningFcn, ...
                   'gui_OutputFcn',  @robotArm_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code


% --- Executes just before robotArm is made visible.
function robotArm_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for robotArm
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = robotArm_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function robotArm_validateInput(hObject,handles,gtval)
%gtval - value must be > gtval

%get the tag name and input value
tag = get(hObject,'Tag');
value = str2double(get(hObject,'String'));

%validate input
inval = false;
if isnan(value)
    warning('robotArm:NaNInput','Input must be numeric.');
    inval = true;
end
if exist('gtval','var') && ~isempty(gtval) && value <= gtval
    warning('robotArm:BadInput',[tag,' must be greater than ',num2str(gtval)]);
    inval = true;
end
if inval
    set(handles.(tag), 'String','1');
    %update gui
    guidata(hObject, handles);
end

% All Inputs
function d_1_Callback(hObject, eventdata, handles)
robotArm_validateInput(hObject,handles,0)

function d_1_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function d_2_Callback(hObject, eventdata, handles)
robotArm_validateInput(hObject,handles,0)

function d_2_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function h_Callback(hObject, eventdata, handles)
robotArm_validateInput(hObject,handles,0)

function h_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function table_h_Callback(hObject, eventdata, handles)
robotArm_validateInput(hObject,handles,0)

function table_h_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function time_Callback(hObject, eventdata, handles)
robotArm_validateInput(hObject,handles,0)

function time_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%All Buttons

% --- Executes on button press in build.
function build_Callback(hObject, eventdata, handles)

%first, find all dimensions
h = str2double(get(handles.h,'String'));
d1 = str2double(get(handles.d_1,'String'));
d2 = str2double(get(handles.d_2,'String'));
l1 = sqrt(d1^2+h^2);
l2 = sqrt(d2^2+h^2);
w = max([l1,l2])/7;
l3 = w*1.5;

%generate arms
axes(handles.axes1);
hold off
arm1 = robotArm_genRoundedRec(l1,w,'r');
hold on
arm2 = robotArm_genRoundedRec(l2,w,'b');
glass = fill([0 0 l3/2 l3/2 0],[0 1.5*w 1.5*w 0 0],'c');
arm3 = robotArm_genRoundedRec(l3,w,'g');
handles.odat.arm1x = get(arm1,'XData');
handles.odat.arm1y = get(arm1,'YData');
handles.odat.arm2x = get(arm2,'XData');
handles.odat.arm2y = get(arm2,'YData');
handles.odat.arm3x = get(arm3,'XData');
handles.odat.arm3y = get(arm3,'YData');
handles.odat.glassx = get(glass,'XData');
handles.odat.glassy = get(glass,'YData');

%position and orient arms
set(arm3,'XData',get(arm3,'XData')+d1+d2);
%rotate arm1 th1 degree about origin
th1 = atan(h/d1);
rotate(arm1,[0 0 1],th1*180/pi,[0 0 0]);
%position end of arm2 at d1+d2, and rotate -th2 degrees about end
set(arm2,'XData',get(arm2,'XData')+d1+d2-l2);
th2 = atan(h/d2);
rotate(arm2,[0 0 1],-th2*180/pi,[d1+d2 0 0]);
set(glass,'XData',get(glass,'XData')+d1+d2+l3,'YData',get(glass,'YData')-w/2);

%make table
tableh = str2double(get(handles.table_h,'String'));
plot([d1+d2+l3+tableh,d1+d2+l3+tableh,d1+d2+l3+tableh+l3*3/2],...
    [0-w/2,tableh-1.25*w,tableh-1.25*w],'k','LineWidth',2)

%clean up axes
set(handles.axes1,'XTick',[],'YTick',[])
axis equal
temp = get(handles.axes1,'Xlim');
set(handles.axes1,'Xlim',[temp(1),d1+d2+l3+tableh+l3*3/2]);
temp = get(handles.axes1,'Ylim');
set(handles.axes1,'Ylim',[-w/2,temp(2)]);

%assign to handle structure and update gui
handles.arm1 = arm1;
handles.arm2 = arm2;
handles.arm3 = arm3;
handles.glass = glass;
handles.vals.d1 = d1;
handles.vals.d2 = d2;
handles.vals.h = h;
handles.vals.l1 = l1;
handles.vals.l2 = l2;
handles.vals.l3 = l3;
handles.vals.w = w;
handles.vals.tableh = tableh;
guidata(hObject, handles);

function h = robotArm_genRoundedRec(l,w,c)

th = linspace(pi/2,3*pi/2,10);
xs = [0,   w/2*cos(th(end:-1:1)),0,  l,  -w/2*cos(th)+l,l,0];
ys = [-w/2,w/2*sin(th(end:-1:1)),w/2,w/2,w/2*sin(th),-w/2,-w/2];
h = fill(xs,ys,c);
set(h,'FaceAlpha',0.75')

function dz = robotArm_eoms(t,z,l1,l2)
%z = [th1 th2 omegaA omegaB]
th1 = z(1); th2 = z(2); omegaA = z(3); omegaB = z(4);
dz = [omegaA;...
      -omegaB;...
      -(l1*omegaA^2*(cos(th1)*sin(th1+th2) - sin(th2)) + ...
        l2*omegaB^2*(cos(th2)*sin(th1+th2) - sin(th2)*cos(th1+th2)))/...
        (l1*sin(th1)*sin(th1+th2));
      (l1*omegaA^2 + l2*omegaB^2*cos(th1+th2))/(l2*sin(th1+th2))];


% --- Executes on button press in animate.
function animate_Callback(hObject, eventdata, handles)

if ~strcmp(get(hObject,'String'),'Go!')
    set(hObject,'String','Go!')
    handles.stopAnim = true;
    guidata(hObject, handles);
    return
end

%if robot doesn't exist, error out
if ~isfield(handles,'vals')
    error('robotArm:robotNotBuilt','You must build the robot before doing this.')
end

%if old figures are up, kill them
if ishandle(272), delete(272); end
if ishandle(273), delete(273); end

%handles to objects
arm1 = handles.arm1;
arm2 = handles.arm2;
arm3 = handles.arm3;
glass = handles.glass;

%find appropriate u0
time = str2double(get(handles.time,'String'));
u0 = sqrt(2)*handles.vals.tableh/time;
omegaA = sqrt(2)*u0/2*(1 - handles.vals.d2/handles.vals.h)/...
    (handles.vals.d1+handles.vals.d2);
omegaB = sqrt(2)*u0/(2*handles.vals.h) + omegaA;

%get time history
t = 0:0.1:time;
[t,z] = ode45(@robotArm_eoms,t,[atan(handles.vals.h/handles.vals.d1),...
    atan(handles.vals.h/handles.vals.d2),omegaA,omegaB],[],...
    handles.vals.l1,handles.vals.l2);
if t(end) ~= time
    failConfig = true;
else
    failConfig = false;
end

th1 = z(:,1);
th2 = z(:,2);
r1 = [handles.vals.l1*cos(th1),...
      handles.vals.l1*sin(th1)];
r2 = [handles.vals.l1*cos(th1)+handles.vals.l2*cos(th2),...
      handles.vals.l1*sin(th1)-handles.vals.l2*sin(th2)];

%set gloabl values
handles.res.t = t;
handles.res.z = z;
handles.stopAnim = false;
set(hObject,'String','Stop!')
guidata(hObject, handles);

for j = 2:length(t)
    handles = guidata(handles.figure1);
    if handles.stopAnim, break; end   
     
    %position arm 3
    set(arm3,'XData',handles.odat.arm3x+r2(j,1),...
        'YData',handles.odat.arm3y+r2(j,2));
    %rotate arm1 th1 degrees about origin
    set(arm1,'XData',handles.odat.arm1x,...
        'YData',handles.odat.arm1y);
    rotate(arm1,[0 0 1],th1(j)*180/pi,[0 0 0]);
    %position end of arm2 at r1, and rotate -th2 degrees about end
    set(arm2,'XData',handles.odat.arm2x+r1(j,1),...
        'YData',handles.odat.arm2y+r1(j,2));
    rotate(arm2,[0 0 1],-th2(j)*180/pi,[r1(j,:) 0]);
    set(glass,'XData',handles.odat.glassx+r2(j,1)+handles.vals.l3,...
        'YData',handles.odat.glassy+r2(j,2)-handles.vals.w/2);
    %plot trajectory
     plot([handles.vals.d1+handles.vals.d2,r2(j,1)]+handles.vals.l3,...
         [0,r2(j,2)],'--')
    pause(t(j) - t(j-1));
end

for j = 1:10
    handles = guidata(handles.figure1);
    if handles.stopAnim, break; end
    if failConfig
        set(glass,'YData',get(glass,'YData')-(r2(end,2)+handles.vals.w/2)/10);
    else
        set(glass,'YData',get(glass,'YData')-(handles.vals.w*0.75)/10);
    end
    pause(0.1)
end
if failConfig, set(glass,'Visible','off'); end

for j = length(t):-1:1
    handles = guidata(handles.figure1);
    if handles.stopAnim, break; end   
     
    %position arm 3
    set(arm3,'XData',handles.odat.arm3x+r2(j,1),...
        'YData',handles.odat.arm3y+r2(j,2));
    %rotate arm1 th1 degrees about origin
    set(arm1,'XData',handles.odat.arm1x,...
        'YData',handles.odat.arm1y);
    rotate(arm1,[0 0 1],th1(j)*180/pi,[0 0 0]);
    %position end of arm2 at r1, and rotate -th2 degrees about end
    set(arm2,'XData',handles.odat.arm2x+r1(j,1),...
        'YData',handles.odat.arm2y+r1(j,2));
    rotate(arm2,[0 0 1],-th2(j)*180/pi,[r1(j,:) 0]);
    
    if j > 1
        pause(t(j) - t(j-1));
    else
        pause(1)
    end
end

%get fresh robot
set(hObject,'String','Go!')
build_Callback(hObject, eventdata, handles)

%Plotting menu

% --------------------------------------------------------------------
function plots_Callback(hObject, eventdata, handles)
%nothing here

function plot_angles_Callback(hObject, eventdata, handles)

%if results don't exist, error out
if ~isfield(handles,'res')
    error('robotArm:robotNotRun','You must run the robot before doing this.')
end

figure(272)
set(272,'Name','robotArm: Angles','NumberTitle','off')
plot(handles.res.t,handles.res.z(:,1),handles.res.t,handles.res.z(:,2),...
    '--','LineWidth',1.25)
set(gca,'FontSize',12,'Box','on','FontName','Times','FontWeight','normal')
grid on
xlabel('Time (sec)')
ylabel('Angle (rad)')
legend({'$$\theta_1$$','$$\theta_2$$'},'Interpreter','LaTex')

function plot_omegas_Callback(hObject, eventdata, handles)

%if results don't exist, error out
if ~isfield(handles,'res')
    error('robotArm:robotNotRun','You must run the robot before doing this.')
end

figure(273)
set(273,'Name','robotArm: Angular Velocities','NumberTitle','off')
plot(handles.res.t,handles.res.z(:,3),handles.res.t,handles.res.z(:,4),...
    '--','LineWidth',1.25)
set(gca,'FontSize',12,'Box','on','FontName','Times','FontWeight','normal')
grid on
xlabel('Time (sec)')
ylabel('Angular Velocity (rad/s)')
legend({'$${}^\mathcal{I}\omega^\mathcal{A}$$',...
    '$${}^\mathcal{I}\omega^\mathcal{B}$$'},'Interpreter','LaTex')


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)

if ishandle(272), delete(272); end
if ishandle(273), delete(273); end

delete(hObject);
