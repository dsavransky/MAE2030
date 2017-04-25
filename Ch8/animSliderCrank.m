function varargout = animSliderCrank(varargin)
% ANIMSLIDERCRANK Animate a slider-crank mechanism and plot
% the velocity of the piston.

% Written by Dmitry Savransky with GUIDE v2.5 24-Feb-2009 13:40:29
% Copyright (c) 2015 Dmitry Savransky (ds264@cornell.edu)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @animSliderCrank_OpeningFcn, ...
                   'gui_OutputFcn',  @animSliderCrank_OutputFcn, ...
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

% --- Executes just before animSliderCrank is made visible.
function animSliderCrank_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to animSliderCrank (see VARARGIN)

% Choose default command line output for animSliderCrank
handles.output = hObject;

%set intial data set
handles.data.isPlaying = false;
handles.data.RL = get(handles.RL_slider,'Value');
set(handles.RL,'String',num2str(handles.data.RL))
th = 0:2*pi/100:2*pi;
handles.data.th = th(1:end-1);
handles.data.l = 1/5;
handles.data.w = handles.data.l/2;
handles.data.j = 1;
handles.data.k = 1;

%do initial calculation
handles.data.x = handles.data.RL*cos(handles.data.th) + ...
    sqrt(1 - handles.data.RL^2*sin(handles.data.th).^2);
handles.data.axlim = [-handles.data.RL,handles.data.RL+1+handles.data.l,...
    -handles.data.RL,handles.data.RL*2]*1.1;

v = -handles.data.RL*sin(handles.data.th).*(1 + handles.data.RL*...
    cos(handles.data.th)./sqrt(1 - handles.data.RL^2*sin(handles.data.th).^2));
handles.data.v = repmat(v,1,5)/abs(max(v))*handles.data.RL/2+3*handles.data.RL/2;
handles.data.vx = linspace(handles.data.axlim(1),handles.data.axlim(2),...
    length(handles.data.v));

% This sets up the initial plot
hold on
handles.data.linkA = plot([0,handles.data.RL*cos(handles.data.th(1))],...
    [0,handles.data.RL*sin(handles.data.th(1))],'r','LineWidth',5);
handles.data.point1 = plot(0,0,'k.','MarkerSize',20);
handles.data.linkB = plot([handles.data.RL*cos(handles.data.th(1)),...
    handles.data.x(1)],[handles.data.RL*sin(handles.data.th(1)),0],...
    'b','LineWidth',5);
handles.data.bx = fill([handles.data.x(1),handles.data.x(1)+handles.data.l,...
    handles.data.x(1)+handles.data.l,handles.data.x(1),handles.data.x(1)],...
    [handles.data.w,handles.data.w,-handles.data.w,-handles.data.w,...
    handles.data.w],'k');
handles.data.vplot = plot(handles.data.vx(1),handles.data.v(1));
handles.data.vzero = plot([handles.data.axlim(1),handles.data.axlim(2)],...
    [handles.data.RL,handles.data.RL]*3/2,'k--');
axis(handles.mainAx,'equal');
set(handles.mainAx,'XTickLabel',[],'YTickLabel',[],'XTick',[],'YTick',[],...
    'Xlim',handles.data.axlim(1:2),'Ylim',handles.data.axlim(3:4));
hold off

% Update handles structure
guidata(hObject, handles)


% --- Outputs from this function are returned to the command line.
function varargout = animSliderCrank_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function RL_slider_Callback(hObject, eventdata, handles)
% hObject    handle to RL_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.data.RL = get(hObject,'Value');
set(handles.RL,'String',num2str(handles.data.RL));

% Update handles structure
guidata(hObject, handles);

animSliderCrank_docalc(hObject);

% --- Executes during object creation, after setting all properties.
function RL_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RL_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function RL_Callback(hObject, eventdata, handles)
% hObject    handle to RL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
value = str2double(get(hObject,'String'));
if isnan(value)
    warning('animSliderCrank:NaNInput','Input must be numeric.');
    set(handles.RL,'String',num2str(handles.data.RL));
    return
end
if (value < 0.001) || (value >= 1)
    warning('animSliderCrank:OOBInput','R/L must be in [0.001,1).');
    set(handles.RL,'String',num2str(handles.data.RL));
    return
end
handles.data.RL = value;
set(handles.RL_slider,'Value',value);

% Update handles structure
guidata(hObject, handles);

animSliderCrank_docalc(hObject);


% --- Executes during object creation, after setting all properties.
function RL_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RL (see GCBO)
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

animSliderCrank_doAnim(hObject)


%calculate orbit based on current values
function animSliderCrank_docalc(hObject)

handles = guidata(hObject);

%update position and limit calculations
handles.data.x = handles.data.RL*cos(handles.data.th) + ...
    sqrt(1 - handles.data.RL^2*sin(handles.data.th).^2);
tmp = max([handles.data.RL,handles.data.w]);
handles.data.axlim = [-handles.data.RL,handles.data.RL+1+handles.data.l,...
    -tmp,tmp*2]*1.1;

v = -handles.data.RL*sin(handles.data.th).*(1 + handles.data.RL*...
    cos(handles.data.th)./sqrt(1 - handles.data.RL^2*sin(handles.data.th).^2));
handles.data.v = repmat(v,1,5)/abs(max(v))*tmp/2+3*tmp/2;
handles.data.vx = linspace(handles.data.axlim(1),handles.data.axlim(2),...
    length(handles.data.v));

% update plot
set(handles.mainAx,'Xlim',handles.data.axlim(1:2),'Ylim',handles.data.axlim(3:4));
set(handles.data.vzero,'XData',[handles.data.axlim(1),handles.data.axlim(2)],...
        'YData',[tmp,tmp]*3/2)
if ~handles.data.isPlaying
    set(handles.data.linkA,'XData',[0,handles.data.RL*cos(handles.data.th(handles.data.j))],...
        'YData',[0,handles.data.RL*sin(handles.data.th(handles.data.j))])
    set(handles.data.linkB,'XData',[handles.data.RL*cos(handles.data.th(handles.data.j)),...
        handles.data.x(handles.data.j)],'YData',...
        [handles.data.RL*sin(handles.data.th(handles.data.j)),0])
    tmp = get(handles.data.bx,'XData');
    set(handles.data.bx,'XData',tmp+(handles.data.x(handles.data.j)-min(tmp)))
    set(handles.data.vplot,'XData',handles.data.vx(1:handles.data.k),...
        'YData',handles.data.v(1:handles.data.k))
end

guidata(hObject, handles);

function animSliderCrank_doAnim(hObject)

handles = guidata(hObject);
j = handles.data.j;
k = handles.data.k;

while handles.data.isPlaying
    j = j+1;
    if j > length(handles.data.th)
        j = 1;
    end
    k = k+1;
    if k > length(handles.data.v)
        k = 1;
    end
    
    set(handles.data.linkA,'XData',[0,handles.data.RL*cos(handles.data.th(j))],...
        'YData',[0,handles.data.RL*sin(handles.data.th(j))])
    set(handles.data.linkB,'XData',[handles.data.RL*cos(handles.data.th(j)),...
        handles.data.x(j)],'YData',...
        [handles.data.RL*sin(handles.data.th(j)),0])
    tmp = get(handles.data.bx,'XData');
    set(handles.data.bx,'XData',tmp+(handles.data.x(j)-min(tmp)))
    set(handles.data.vplot,'XData',handles.data.vx(1:k),...
        'YData',handles.data.v(1:k))
    drawnow
    pause(0.01);
    
    %update handles
    handles = guidata(hObject);
end

%update handles
handles.data.j = j;
handles.data.k = k;
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function mainAx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mainAx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate mainAx
