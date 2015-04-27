function varargout = ssrb(varargin)
% SSRB MATLAB code for ssrb.fig
%      Animate and explore the motion of a symmetric spinning body with a
%      constant moment applied to one transverse body frame axis.
%
%      SSRB, by itself, creates a new SSRB or raises the existing
%      singleton*.
%
%      H = SSRB returns the handle to a new SSRB or the handle to
%      the existing singleton*.
%
%      SSRB('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SSRB.M with the given input arguments.
%
%      SSRB('Property','Value',...) creates a new SSRB or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ssrb_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ssrb_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Written by Dmitry Savransky 02-May-2011
% Copyright (c) 2015 Dmitry Savransky (ds264@cornell.edu)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ssrb_OpeningFcn, ...
                   'gui_OutputFcn',  @ssrb_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
end
% End initialization code - DO NOT EDIT


% --- Executes just before ssrb is made visible.
function ssrb_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ssrb (see VARARGIN)

% add file location to path
handles.path0 = path();
s = which('ssrb');
pathstr = fileparts(s);
path(pathstr,path)

% Choose default command line output for ssrb
handles.output = hObject;
handles.main3d = rotate3d(handles.mainAx);
handles.baseView = [40,25];
if ~isempty(varargin)
    tmp = varargin{1};
    if isnumeric(tmp) && numel(tmp) == 2
        handles.baseView = tmp;
    end
end
set(handles.main3d,'RotateStyle','box','Enable','on');

%rotation matrices
rotMatE3 = @(ang) [cos(ang) -sin(ang) 0;sin(ang) cos(ang) 0;0 0 1];
rotMatE2 = @(ang) [cos(ang) 0 sin(ang);0 1 0;-sin(ang) 0 cos(ang)];
rotMatE1 = @(ang) [1 0 0;0 cos(ang) -sin(ang);0 sin(ang) cos(ang)];
handles.rotMats = {rotMatE1,rotMatE2,rotMatE3};

%set default values
handles.I2 = 1/(10 - 0.5);     %kg m^2
handles.I1 = 10*handles.I2;    %kg m^2
handles.dims = [sqrt(handles.I2/2), sqrt(handles.I1 - handles.I2/2)];
handles.Omega = 20; %rad/s
handles.M1 = 5*handles.I2;      %N m
set(handles.MOIslider,'Value',log10(handles.I1/handles.I2));
set(handles.MOItext,'String',sprintf('I1/I2 = %2.3f',handles.I1/handles.I2))
set(handles.M1slider,'Value',handles.M1/handles.I2);
set(handles.M1text,'String',sprintf('M1/I2 = %2.3f',handles.M1/handles.I2))

% handles.M2 = 0*handles.I2;      %N m
% set(handles.M2slider,'Value',handles.M2/handles.I2);
% set(handles.M2text,'String',sprintf('M2/I2 = %2.3f',handles.M2/handles.I2))

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised
if strcmp(get(hObject,'Visible'),'off')
    ssrb_makeEllipsoid(hObject, handles)
end
end

% --- Executes when user attempts to close mainWindow.
function figure1_CloseRequestFcn(hObject, ~, handles)

path(handles.path0);
delete(hObject);

end

% --- Outputs from this function are returned to the command line.
function varargout = ssrb_OutputFcn(~, ~, handles) 

% Get default command line output from handles structure
varargout{1} = handles.output;

end

% --- Executes on slider movement - slider value is I1/I2
function MOIslider_Callback(hObject, ~, handles)

anim = false;
%if animation is going, stop it
if strcmp(get(handles.runAnim,'String'),'Stop')
    set(handles.runAnim,'String','Go')
    anim = true;
end

rat = 10^get(hObject,'Value');
handles.I2 = 1/(rat - 0.5);     %kg m^2
handles.I1 = rat*handles.I2;    %kg m^2
handles.dims = [sqrt(handles.I2/2), sqrt(handles.I1 - handles.I2/2)];
set(handles.MOItext,'String',sprintf('I1/I2 = %2.3f',handles.I1/handles.I2))

% Update handles structure and regenerate ellipse
guidata(hObject, handles);
ssrb_makeEllipsoid(hObject, handles)
handles = guidata(hObject);

if anim
    set(handles.runAnim,'String','Stop')
    [t,z] = ssrb_intFun(handles);
    ssrb_animate(t,z,handles);
end

end

% --- Executes during object creation, after setting all properties.
function MOIslider_CreateFcn(hObject, ~, ~)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

end

% --- Executes on slider movement.
function M1slider_Callback(hObject, ~, handles)
anim = false;
%if animation is going, stop it
if strcmp(get(handles.runAnim,'String'),'Stop')
    set(handles.runAnim,'String','Go')
    anim = true;
end

handles.M1 = get(hObject,'Value')*handles.I2;
set(handles.M1text,'String',sprintf('M1/I2 = %2.3f',handles.M1/handles.I2))
guidata(hObject, handles);

if anim
    set(handles.runAnim,'String','Stop')
    [t,z] = ssrb_intFun(handles);
    ssrb_animate(t,z,handles);
end

end

% --- Executes during object creation, after setting all properties.
function M1slider_CreateFcn(hObject, ~, ~)

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end

% % --- Executes on slider movement.
% function M2slider_Callback(hObject, ~, handles)
% anim = false;
% %if animation is going, stop it
% if strcmp(get(handles.runAnim,'String'),'Stop')
%     set(handles.runAnim,'String','Go')
%     anim = true;
% end
% 
% handles.M2 = get(hObject,'Value')*handles.I2;
% set(handles.M2text,'String',sprintf('M2/I2 = %2.3f',handles.M2/handles.I2))
% guidata(hObject, handles);
% 
% if anim
%     set(handles.runAnim,'String','Stop')
%     [t,z] = ssrb_intFun(handles);
%     ssrb_animate(t,z,handles);
% end
% end
% 
% % --- Executes during object creation, after setting all properties.
% function M2slider_CreateFcn(hObject, ~, ~)
% 
% if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor',[.9 .9 .9]);
% end
% end


function state_Callback(hObject, ~, handles)
%if animation is going, stop it
if strcmp(get(handles.runAnim,'String'),'Stop')
    set(handles.runAnim,'String','Go')
end

[val,count] = sscanf(get(hObject,'String'),'%f, %f, %f, %f');
if count ~= 4
    set(hObject,'String',sprintf('%3.3f, %3.3f, %3.3f, %3.3f',...
        [handles.th,handles.thd,mod(handles.psi,2*pi),handles.psid]*180/pi));
    return
else
    val = val*pi/180;
    handles.th = val(1);  
    handles.psi = val(3);    
    handles.thd = val(2);  
    handles.psid = val(4);
    handles.symAx = handles.rotMats{1}(handles.th)*handles.rotMats{3}(handles.psi)*[0,1,0].';
    handles.b1 = handles.rotMats{1}(handles.th)*handles.rotMats{3}(handles.psi)*[1,0,0].';
    
    ssrb_makeEllipsoid(hObject, handles)
end
end


% --- Executes during object creation, after setting all properties.
function state_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

%generate the ellipsoid
function ssrb_makeEllipsoid(hObject, handles)

[xe,ye,ze]=ellipsoid(0,0,0,handles.dims(1),handles.dims(2),handles.dims(1),100);

if ~isfield(handles,'s1') || ~ishandle(handles.s1)
    handles.th = pi/6;  %rad
    handles.psi = 0;    %rad;
    handles.thd = 0;    %rad/s;
    handles.psid = -0.1; %rad/s;
    
    handles.s1 = surface(xe,ye,ze,'FaceAlpha',0.9);
    shading interp
    view(3)
    axis equal
    view(handles.baseView)
    handles.symAx = [0,1,0].';
    handles.b1 = [1,0,0].';
    rotate(handles.s1,handles.b1,handles.th*180/pi)
    handles.symAx = handles.rotMats{1}(handles.th)*handles.symAx;
    
    oldObjs = findobj(handles.mainAx,'Type','line');
    if ~isempty(oldObjs), delete(oldObjs); end
else
    temp = [handles.b1,handles.symAx,cross(handles.b1,handles.symAx)]*...
        [xe(:).';ye(:).';ze(:).'];
    set(handles.s1,'XData',reshape(temp(1,:),size(xe)),...
        'YData',reshape(temp(2,:),size(ye)),...
        'ZData',reshape(temp(3,:),size(ze)));
end
axis([-1,1,-1,1,-1,1]*ceil(max(handles.dims)*10)/10)
grid on

set(handles.state,'String',sprintf('%3.3f, %3.3f, %3.3f, %3.3f',...
    [handles.th,handles.thd,mod(handles.psi,2*pi),handles.psid]*180/pi));

% Update handles structure
guidata(hObject, handles);

end

% --- Executes on button press in resetFig.
function resetFig_Callback(hObject, ~, handles)

if strcmp(get(handles.runAnim,'String'),'Stop')
    set(handles.runAnim,'String','Go')
end

if ishandle(handles.s1), delete(handles.s1); end

ssrb_makeEllipsoid(hObject, handles)

end

% --- Executes on button press in runAnim.
function runAnim_Callback(hObject, ~, handles)

if strcmp(get(hObject,'String'),'Go')
    set(hObject,'String','Stop')
    [t,z] = ssrb_intFun(handles);
    if length(t) > 1
        ssrb_animate(t,z,handles);
    end
else
    set(hObject,'String','Go')
    set(handles.state,'String',sprintf('%3.3f, %3.3f, %3.3f, %3.3f',...
    [handles.th,handles.thd,mod(handles.psi,2*pi),handles.psid]*180/pi));
end

end

%performs numerical integration of eoms
function [t,z] = ssrb_intFun(handles)

Omega = handles.Omega;
M1 = handles.M1;
%M2 = handles.M2;
I1 = handles.I1;
I2 = handles.I2;
t = 0:0.2:100-0.2;
z = zeros(length(t),4);

[~,tmp] = ode45(@ssrb_eom,t(1:10),[handles.th,handles.thd,handles.psi,handles.psid]);
z(1:10,:) = tmp;
for j = 2:50
    drawnow
    handles = guidata(handles.figure1);
    if strcmp(get(handles.runAnim,'String'),'Go')
        return;
    end
    inds = (j-1)*10:j*10;
    [~,tmp] = ode45(@ssrb_eom,t(inds),z(inds(1),:));
    if length(tmp) == length(inds)
        z(inds,:) = tmp;
    else
        set(handles.runAnim,'String','Go')
        t = -1;
        return
    end
end

    function dz = ssrb_eom(~,z)
        th = z(1);
        thd = z(2);
        psid = z(4);
        
        dz = [thd;
            (-(I1 - I2)*psid^2*sin(th)*cos(th) + I2*Omega*psid*cos(th) - M1)/I1;
            psid;
            (-(I2 - 2*I1)*psid*thd*sin(th) -I2*Omega*thd)/I1];
    end
end

%animates ellipsoid
function ssrb_animate(t,z,handles)

hold on
for j = 2:length(t)
    drawnow
    if strcmp(get(handles.runAnim,'String'),'Go')
        hold off;
        return;
    end
    dth = z(j,1) - z(j-1,1);
    dpsi = z(j,3) - z(j-1,3);
    dt = t(j) - t(j-1);
    rotate(handles.s1,[0,0,1],dpsi*180/pi)
    handles.symAx = handles.rotMats{3}(dpsi)*handles.symAx;
    handles.b1 = handles.rotMats{3}(dpsi)*handles.b1;
    rotate(handles.s1,handles.b1,dth*180/pi)
    handles.symAx = handles.rotMats{1}(dth)*handles.symAx;
    rotate(handles.s1,handles.symAx,handles.Omega*dt*180/pi)
    plot3(handles.symAx(1)*handles.dims(2),handles.symAx(2)*handles.dims(2),handles.symAx(3)*handles.dims(2),'k.')
    
    
    handles.th = z(j,1);
    handles.thd = z(j,2);
    handles.psi = z(j,3);
    handles.psid = z(j,4);
    
    % Update handles structure
    guidata(handles.figure1, handles);

    pause(dt/2)
end
set(handles.runAnim,'String','Go')
hold off

end
