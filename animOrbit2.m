function varargout = animOrbit2(varargin)
% ANIMORBIT2 Animate an elliptical orbit.   

% Written by Dmitry Savransky with GUIDE v2.5 24-Feb-2009 13:40:29
% Copyright (c) 2015 Dmitry Savransky (ds264@cornell.edu)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @animOrbit2_OpeningFcn, ...
                   'gui_OutputFcn',  @animOrbit2_OutputFcn, ...
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
% End initialization code - DO NOT EDIT

% --- Executes just before animOrbit2 is made visible.
function animOrbit2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to animOrbit2 (see VARARGIN)

% Choose default command line output for animOrbit2
handles.output = hObject;

%set intial data set
handles.data.isPlaying = false;
handles.data.e = get(handles.e_slider,'Value');
set(handles.eccen,'String',num2str(handles.data.e))
handles.data.t = 1;
handles.data.Nsteps = 250;
handles.data.a = 1;
th = 0:pi/50:2*pi;
handles.data.circ = [cos(th);sin(th)]*handles.data.a/10;
handles.data.M = linspace(0,2*pi - 2*pi/handles.data.Nsteps,...
    handles.data.Nsteps);
handles.data.axlim = [-handles.data.a*1.15,handles.data.a*1.15];
handles.data.showvvec = 1;
set(handles.showvvec,'Value',handles.data.showvvec);

% This sets up the initial plot
handles.data.orbit = plot([0,1],[0,1],'k--');
hold on
handles.data.star = plot(0,0,'y.','MarkerSize',handles.data.a*50);
handles.data.planet = fill(handles.data.circ(1,:),handles.data.circ(2,:),'b');
handles.data.arrow = plot([0,1],[0,1],'r',[0,1],[0,1],'r',[0,1],[0,1],'r');

hold off
set(handles.orbAxes,'XTickLabel',[],'XGrid','on','YTickLabel',[],...
    'YGrid','on','XLim',handles.data.axlim,'YLim',handles.data.axlim);
axis(handles.orbAxes,'square');

% Update handles structure
guidata(hObject, handles)

%calculate initial orbit
animOribt2_calcOrbit(hObject);



% UIWAIT makes animOrbit2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = animOrbit2_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function e_slider_Callback(hObject, eventdata, handles)
% hObject    handle to e_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.data.e = get(hObject,'Value');
set(handles.eccen,'String',num2str(handles.data.e));

% Update handles structure
guidata(hObject, handles);

animOribt2_calcOrbit(hObject);

% --- Executes during object creation, after setting all properties.
function e_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in showvvec.
function showvvec_Callback(hObject, eventdata, handles)
% hObject    handle to showvvec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.data.showvvec = get(hObject,'Value');
if handles.data.showvvec
    set(handles.data.arrow,'Visible','on')
else
    set(handles.data.arrow,'Visible','off')
end

function eccen_Callback(hObject, eventdata, handles)
% hObject    handle to eccen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
value = str2double(get(hObject,'String'));
if isnan(value)
    warning('animOrbit2:NaNInput','Input must be numeric.');
    set(handles.eccen,'String',num2str(handles.data.e));
    return
end
if (value < 0) || (value >= 1)
    warning('animOrbit2:OOBInput','Eccentricity must be in [0,1).');
    set(handles.eccen,'String',num2str(handles.data.e));
    return
end
handles.data.e = value;
set(handles.e_slider,'Value',value);

% Update handles structure
guidata(hObject, handles);

animOribt2_calcOrbit(hObject);


% --- Executes during object creation, after setting all properties.
function eccen_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eccen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in playPause.
function playPause_Callback(hObject, eventdata, handles)
% hObject    handle to playPause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.data.isPlaying
    handles.data.isPlaying = false;
    set(handles.playPause,'String','Play')
else
    handles.data.isPlaying = true;
    set(handles.playPause,'String','Pause')
end

% Update handles structure
guidata(hObject, handles);

animOribt2_doAnim(hObject)


%calculate orbit based on current values
function animOribt2_calcOrbit(hObject)

handles = guidata(hObject);

a = handles.data.a;
e = handles.data.e;
M = handles.data.M;
b = a*sqrt(1 - e^2);

%calculate true anomaly and r, v
if handles.data.e > 0
    counter = 0;
    del = 1;
    E = M./(1-e);
    inds = E > sqrt(6*(1-e)./e);
    if length(e) == 1
        einds = 1;
    else
        einds = inds;
    end
    E(inds) = (6*M(inds)./e(einds)).^(1/3);
    
    %iterate
    while ((del > eps(2*pi)) && (counter <1000))
        E = E - (M - E + e.*sin(E))./(e.*cos(E)-1);
        del = max(abs(M - (E - e.*sin(E))));
        counter = counter+1;
    end
else
    E = M;
end

r = [a*cos(E); b*sin(E)]; %orbit is offset by ae to keep it centered at 0
rad = a*(1 - e*cos(E));
v = [-a^2./rad.*sin(E);b*a./rad.*cos(E)]; %arbitrary units st n = 1

%tmp = v(:,j)/norm(v(:,j)) *0.1 + r(:,j);
%plot([r(1,j),tmp(1)],[r(2,j),tmp(2)],'r');

% Update handles structure
handles.data.r = r;
handles.data.E = E;
handles.data.v = v;

% update plot
set(handles.data.orbit,'XData',handles.data.r(1,:),'YData',handles.data.r(2,:));
set(handles.data.star,'XData',handles.data.a*handles.data.e,'YData',0);
if ~handles.data.isPlaying
    set(handles.data.planet,'XData',handles.data.circ(1,:)+handles.data.r(1,handles.data.t),...
        'YData',handles.data.circ(2,:)+handles.data.r(2,handles.data.t));
    
    t = handles.data.t;
    tmp = handles.data.v(:,t)*0.4 + handles.data.r(:,t);
    th = atan2(handles.data.v(2,t),handles.data.v(1,t))+pi/4;
    ar = norm(handles.data.v(:,t))*0.1;
    set(handles.data.arrow(1),'XData',[handles.data.r(1,t),tmp(1)],'YData',[handles.data.r(2,t),tmp(2)])
    set(handles.data.arrow(2),'XData',[tmp(1),tmp(1) - cos(th)*ar],'YData',[tmp(2),tmp(2) - sin(th)*ar])
    set(handles.data.arrow(3),'XData',[tmp(1),tmp(1) - sin(th)*ar],'YData',[tmp(2),tmp(2) + cos(th)*ar])
end

%set(handles.orbAxes,'XTickLabel',[],'XGrid','on','YTickLabel',[],...
%    'YGrid','on','XLim',handles.data.axlim,'YLim',handles.data.axlim);

guidata(hObject, handles);

function animOribt2_doAnim(hObject)

handles = guidata(hObject);
go = handles.data.isPlaying;
t = handles.data.t;

while go
    t = t+1;
    if t > length(handles.data.M)
        t = 1;
    end
    set(handles.data.planet,'XData',handles.data.circ(1,:)+handles.data.r(1,t),...
        'YData',handles.data.circ(2,:)+handles.data.r(2,t));
    
    tmp = handles.data.v(:,t)*0.4 + handles.data.r(:,t);
    th = atan2(handles.data.v(2,t),handles.data.v(1,t))+pi/4;
    ar = norm(handles.data.v(:,t))*0.1;
    set(handles.data.arrow(1),'XData',[handles.data.r(1,t),tmp(1)],'YData',[handles.data.r(2,t),tmp(2)])
    set(handles.data.arrow(2),'XData',[tmp(1),tmp(1) - cos(th)*ar],'YData',[tmp(2),tmp(2) - sin(th)*ar])
    set(handles.data.arrow(3),'XData',[tmp(1),tmp(1) - sin(th)*ar],'YData',[tmp(2),tmp(2) + cos(th)*ar])
%     set(handles.orbAxes,'XTickLabel',[],'XGrid','on','YTickLabel',[],...
%         'YGrid','on','XLim',handles.data.axlim,'YLim',handles.data.axlim);
%     axis(handles.orbAxes,'square');
%     
    drawnow
    pause(eps);
    
    %update handles
    handles = guidata(hObject);
    go = handles.data.isPlaying;
end

%update handles
handles.data.t = t;
guidata(hObject,handles);
