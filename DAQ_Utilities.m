function varargout = DAQ_Utilities(varargin)
% DAQ_UTILITIES MATLAB code for DAQ_Utilities.fig
%      DAQ_UTILITIES, by itself, creates a new DAQ_UTILITIES or raises the existing
%      singleton*.
%
%      H = DAQ_UTILITIES returns the handle to a new DAQ_UTILITIES or the handle to
%      the existing singleton*.
%
%      DAQ_UTILITIES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DAQ_UTILITIES.M with the given input arguments.
%
%      DAQ_UTILITIES('Property','Value',...) creates a new DAQ_UTILITIES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DAQ_Utilities_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DAQ_Utilities_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DAQ_Utilities

% Last Modified by GUIDE v2.5 18-Sep-2018 13:33:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DAQ_Utilities_OpeningFcn, ...
                   'gui_OutputFcn',  @DAQ_Utilities_OutputFcn, ...
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


% --- Executes just before DAQ_Utilities is made visible.
function DAQ_Utilities_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DAQ_Utilities (see VARARGIN)

% Choose default command line output for DAQ_Utilities
handles.output = hObject;

handles.DAQHandler = DAQToolboxHandler();

handles.Defaults.Position = [1, 1, 1175, 820];
handles.Defaults.RecordingDirectory = 'temp';

handles.States.IsReadingDAQ = false;
handles.States.IsDAQToolboxAvailable = handles.DAQHandler.ToolboxAvailable;
handles.States.IsLSLAvailable = false;
handles.States.IsStreamingToLSL = false;
handles.States.IsRecording = false;
handles.States.IsDAQSessionContinuous = true;
handles.States.IsPlottingTriggerMarkers = false;

if handles.States.IsDAQToolboxAvailable == false
    msgbox('Cannot use DAQ Toolbox function', 'DAQ Toolbox Error', 'error');
    handles.DAQDevicesPopupmenu.String = 'No DAQ devices';
    handles.ReadDataPushbutton.Enable = 'off';
    handles.DAQDevicesPopupmenu.Enable = 'off';
else
    if isempty(handles.DAQHandler.Devices)
        handles.DAQDevicesPopupmenu.String = 'No DAQ devices';
        handles.DAQDevicesPopupmenu.Enable = 'off';
    else
        handles.DAQDevicesPopupmenu.String = handles.DAQHandler.DeviceList();
        handles.DAQDevicesPopupmenu.Enable = 'on';
        
        handles.DAQDevicesPopupmenu.Value = 1;
        handles.ReadDataPushbutton.Enable = 'on';
    end
end

[hObject, handles] = UpdateFromChannelPopupmenu(hObject, handles, 1);
[hObject, handles] = UpdateUIElements(hObject, handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DAQ_Utilities wait for user response (see UIRESUME)
% uiwait(handles.MainFigure);


% --- Outputs from this function are returned to the command line.
function varargout = DAQ_Utilities_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function Files_Callback(hObject, eventdata, handles)
% hObject    handle to Files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function ExportAsCSVMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to ExportAsCSVMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, path] = uiputfile('Comma-Separated Value file *.csv');
if (path ~= 0)
    contents = dir(handles.Defaults.RecordingDirectory);
    csvContents = [];
    f = waitbar(0 / length(contents) - 2,'Starting...');
    for i=1:length(contents)
        if ~(contents(i).name(1) == ('.'))
            disp(fullfile(handles.Defaults.RecordingDirectory, contents(i).name));
            waitbar(i / length(contents), f,'Reading recorded data...');
            data = csvread(fullfile(handles.Defaults.RecordingDirectory, contents(i).name));
            csvContents = vertcat(csvContents, data);
        end
    end
    waitbar(0.99, f,'Writing to file...');
    csvwrite(fullfile(path, filename), csvContents);
    waitbar(1.0, f,'Finished');
    close(f)
end

% --- Executes when MainFigure is resized.
function MainFigure_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to MainFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
position = hObject.Position;
if position(3) < handles.Defaults.Position(3)
    hObject.Position(3) = handles.Defaults.Position(3);
end

if position(4) < handles.Defaults.Position(4)
    hObject.Position(4) = handles.Defaults.Position(4);
end

handles.DAQDevicesUIPanel.Position = [(hObject.Position(3) - 1115) / 2, 30, 260, 220];
handles.AcquisitionUIPanel.Position = [handles.DAQDevicesUIPanel.Position(1) + handles.DAQDevicesUIPanel.Position(3) + 25, ...
                30, ...
                260, ...
                220];
            handles.LSLStreamingUIPanel.Position = [handles.AcquisitionUIPanel.Position(1) + handles.AcquisitionUIPanel.Position(3) + 25, ...
                30, ...
                260, ...
                220];
            handles.ControlsUIPanel.Position = [handles.LSLStreamingUIPanel.Position(1) + handles.LSLStreamingUIPanel.Position(3) + 25, ...
                30, ...
                260, ...
                220];
            
handles.MainAxes.Position = [50, ...
                handles.DAQDevicesUIPanel.Position(2) + handles.DAQDevicesUIPanel.Position(4) + 40, ...
                hObject.Position(3) - 355, ...
                hObject.Position(4) - 325];
handles.TriggerChannelPopupmenu.Position = [handles.MainAxes.Position(1) + handles.MainAxes.Position(3) + 20, ...
                handles.DAQDevicesUIPanel.Position(2) + handles.DAQDevicesUIPanel.Position(4) + 20, ...
                110, ...
                27];
handles.TriggerChannelPopupmenuLabel.Position = [handles.MainAxes.Position(1) + handles.MainAxes.Position(3) + 20, ...
                handles.TriggerChannelPopupmenu.Position(2) +  handles.TriggerChannelPopupmenu.Position(4) + 5, ...
                100, ...
                17];
handles.ChannelListbox.Position = [handles.MainAxes.Position(1) + handles.MainAxes.Position(3) + 20, ...
                handles.TriggerChannelPopupmenuLabel.Position(2) +  handles.TriggerChannelPopupmenuLabel.Position(4) + 5, ...
                100, ...
                hObject.Position(4) - 370];
handles.ChannelListboxLabel.Position = [handles.MainAxes.Position(1) + handles.MainAxes.Position(3) + 20, ...
                handles.ChannelListbox.Position(2) +  handles.ChannelListbox.Position(4) + 5, ...
                60, ...
                15];
            
handles.DisplayModePopupmenu.Position = [handles.TriggerChannelPopupmenu.Position(1) + handles.TriggerChannelPopupmenu.Position(3) + 20, ...
                handles.DAQDevicesUIPanel.Position(2) + handles.DAQDevicesUIPanel.Position(4) + 20, ...
                110, ...
                27];
handles.DisplayModePopupmenuLabel.Position = [handles.TriggerChannelPopupmenu.Position(1) + handles.TriggerChannelPopupmenu.Position(3) + 20, ...
                handles.DisplayModePopupmenu.Position(2) +  handles.DisplayModePopupmenu.Position(4) + 5, ...
                100, ...
                17];
handles.PlotPeriodPopupmenu.Position = [handles.TriggerChannelPopupmenu.Position(1) + handles.TriggerChannelPopupmenu.Position(3) + 20, ...
                handles.DisplayModePopupmenuLabel.Position(2) +  handles.DisplayModePopupmenuLabel.Position(4) + 5, ...
                110, ...
                27];
handles.PlotPeriodPopupmenuLabel.Position = [handles.TriggerChannelPopupmenu.Position(1) + handles.TriggerChannelPopupmenu.Position(3) + 20, ...
                handles.PlotPeriodPopupmenu.Position(2) +  handles.PlotPeriodPopupmenu.Position(4) + 5, ...
                100, ...
                17];
handles.PlotZoomPopupmenu.Position = [handles.TriggerChannelPopupmenu.Position(1) + handles.TriggerChannelPopupmenu.Position(3) + 20, ...
                handles.PlotPeriodPopupmenuLabel.Position(2) +  handles.PlotPeriodPopupmenuLabel.Position(4) + 5, ...
                110, ...
                27];
handles.PlotZoomPopupmenuLabel.Position = [handles.TriggerChannelPopupmenu.Position(1) + handles.TriggerChannelPopupmenu.Position(3) + 20, ...
                handles.PlotZoomPopupmenu.Position(2) +  handles.PlotZoomPopupmenu.Position(4) + 5, ...
                100, ...
                17];
handles.PlotSensitivityEdit.Position = [handles.TriggerChannelPopupmenu.Position(1) + handles.TriggerChannelPopupmenu.Position(3) + 20, ...
                handles.PlotZoomPopupmenuLabel.Position(2) +  handles.PlotZoomPopupmenuLabel.Position(4) + 5, ...
                110, ...
                27];
handles.PlotSensitivityEditLabel.Position = [handles.TriggerChannelPopupmenu.Position(1) + handles.TriggerChannelPopupmenu.Position(3) + 20, ...
                handles.PlotSensitivityEdit.Position(2) +  handles.PlotSensitivityEdit.Position(4) + 5, ...
                100, ...
                17];
            
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ChannelListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ChannelListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in DisplayModePopupmenu.
function DisplayModePopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to DisplayModePopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns DisplayModePopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DisplayModePopupmenu


% --- Executes during object creation, after setting all properties.
function DisplayModePopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DisplayModePopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in TriggerChannelPopupmenu.
function TriggerChannelPopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to TriggerChannelPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TriggerChannelPopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TriggerChannelPopupmenu


% --- Executes during object creation, after setting all properties.
function TriggerChannelPopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TriggerChannelPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in PlotPeriodPopupmenu.
function PlotPeriodPopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to PlotPeriodPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PlotPeriodPopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PlotPeriodPopupmenu
global PlotHandler
PlotHandler.CurrentPeriodIndex = hObject.Value;
guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function PlotPeriodPopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PlotPeriodPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in PlotZoomPopupmenu.
function PlotZoomPopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to PlotZoomPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PlotZoomPopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PlotZoomPopupmenu
global PlotHandler

PlotHandler.CurrentZoomIndex = hObject.Value;

guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function PlotZoomPopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PlotZoomPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in FromChannelPopupmenu.
function FromChannelPopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to FromChannelPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns FromChannelPopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from FromChannelPopupmenu
UpdateFromChannelPopupmenu(hObject, handles, hObject.Value);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function FromChannelPopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FromChannelPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ToChannelPopupmenu.
function ToChannelPopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to ToChannelPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ToChannelPopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ToChannelPopupmenu


% --- Executes during object creation, after setting all properties.
function ToChannelPopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ToChannelPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in DAQDevicesPopupmenu.
function DAQDevicesPopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to DAQDevicesPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns DAQDevicesPopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DAQDevicesPopupmenu


% --- Executes during object creation, after setting all properties.
function DAQDevicesPopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DAQDevicesPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RefreshDAQPushbutton.
function RefreshDAQPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to RefreshDAQPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.DAQHandler = DAQToolboxHandler();

handles.States.IsReadingDAQ = false;
handles.States.IsDAQToolboxAvailable = handles.DAQHandler.ToolboxAvailable;
handles.States.IsDAQSessionContinuous = true;

if handles.States.IsDAQToolboxAvailable == false
    msgbox('Cannot use DAQ Toolbox function', 'DAQ Toolbox Error', 'error');
    handles.DAQDevicesPopupmenu.String = 'No DAQ devices';
    handles.ReadDataPushbutton.Enable = 'off';
    handles.DAQDevicesPopupmenu.Enable = 'off';
else
    if isempty(handles.DAQHandler.Devices)
        handles.DAQDevicesPopupmenu.String = 'No DAQ devices';
        handles.DAQDevicesPopupmenu.Enable = 'off';
    else
        handles.DAQDevicesPopupmenu.String = handles.DAQHandler.DeviceList();
        handles.DAQDevicesPopupmenu.Enable = 'on';
        
        handles.DAQDevicesPopupmenu.Value = 1;
        handles.ReadDataPushbutton.Enable = 'on';
    end
end

[hObject, handles] = UpdateFromChannelPopupmenu(hObject, handles, 1);
[hObject, handles] = UpdateUIElements(hObject, handles);

guidata(hObject, handles);


% --- Executes on button press in ResetDAQPushbutton.
function ResetDAQPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ResetDAQPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
daqreset();


function LSLTagEdit_Callback(hObject, eventdata, handles)
% hObject    handle to LSLTagEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LSLTagEdit as text
%        str2double(get(hObject,'String')) returns contents of LSLTagEdit as a double


% --- Executes during object creation, after setting all properties.
function LSLTagEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LSLTagEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function LSLIDEdit_Callback(hObject, eventdata, handles)
% hObject    handle to LSLIDEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LSLIDEdit as text
%        str2double(get(hObject,'String')) returns contents of LSLIDEdit as a double


% --- Executes during object creation, after setting all properties.
function LSLIDEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LSLIDEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DAQSamplingRateEdit_Callback(hObject, eventdata, handles)
% hObject    handle to DAQSamplingRateEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DAQSamplingRateEdit as text
%        str2double(get(hObject,'String')) returns contents of DAQSamplingRateEdit as a double


% --- Executes during object creation, after setting all properties.
function DAQSamplingRateEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DAQSamplingRateEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in DAQTimerCheckbox.
function DAQTimerCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to DAQTimerCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DAQTimerCheckbox
if hObject.Value == 1
    handles.States.IsDAQSessionContinuous = false;
else
    handles.States.IsDAQSessionContinuous = true;
end
guidata(hObject, handles);


function DAQTimerDurationEdit_Callback(hObject, eventdata, handles)
% hObject    handle to DAQTimerDurationEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DAQTimerDurationEdit as text
%        str2double(get(hObject,'String')) returns contents of DAQTimerDurationEdit as a double


% --- Executes during object creation, after setting all properties.
function DAQTimerDurationEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DAQTimerDurationEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DAQEventMarkerEdit_Callback(hObject, eventdata, handles)
% hObject    handle to DAQEventMarkerEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DAQEventMarkerEdit as text
%        str2double(get(hObject,'String')) returns contents of DAQEventMarkerEdit as a double


% --- Executes during object creation, after setting all properties.
function DAQEventMarkerEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DAQEventMarkerEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in LSLStreamingCheckbox.
function LSLStreamingCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to LSLStreamingCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of LSLStreamingCheckbox


% --- Executes on button press in RecordDataCheckbox.
function RecordDataCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to RecordDataCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RecordDataCheckbox
if hObject.Value == 1
    handles.States.IsRecording = true;
else
    handles.States.IsRecording = false;
end
guidata(hObject, handles);

% --- Executes on button press in ReadDataPushbutton.
function ReadDataPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ReadDataPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global DAQBuffer;
global PlotHandler;
global RecFileHandler;
DAQBuffer = DAQEventBuffer(10, 3);
DAQBuffer.Frequency = str2double(handles.DAQSamplingRateEdit.String);

PlotHandler = PlottingHandler();
handles.PlotZoomPopupmenu.String = PlotHandler.ZoomIndices;
handles.PlotZoomPopupmenu.Value = PlotHandler.CurrentZoomIndex;
handles.PlotPeriodPopupmenu.String = PlotHandler.PeriodIndices;
handles.PlotPeriodPopupmenu.Value = PlotHandler.CurrentPeriodIndex;

if handles.States.IsReadingDAQ == true
    hObject.String = 'Start Reading';
    hObject.BackgroundColor = [0.78, 1.00, 0.78];
    handles.States.IsReadingDAQ = false;
    
    stop(handles.DAQSession);
    release(handles.DAQSession);
    
    [hObject, handles] = SetUIElementsEnableState(hObject, handles, 'on');
else
    RecFileHandler = FileHandler();
    
    hObject.String = 'Stop Reading';
    hObject.BackgroundColor = [1.00, 0.78, 0.78];
    handles.States.IsReadingDAQ = true;
    
    handles.DAQHandler.SelectedDevice = handles.DAQDevicesPopupmenu.Value;
    handles.DAQHandler.Rate = str2double(handles.DAQSamplingRateEdit.String);
    handles.DAQHandler.SessionDurationInSeconds = str2double(handles.DAQTimerDurationEdit.String);
    handles.DAQHandler.SessionIsContinuous = handles.States.IsDAQSessionContinuous;
    fromChannel = handles.FromChannelPopupmenu.Value;
    toChannel = handles.ToChannelPopupmenu.Value;
    handles.DAQHandler.SelectedChannels = fromChannel - 1:(fromChannel + toChannel -1 -1);
    handles.DAQHandler.AddedChannelLabels = handles.FromChannelPopupmenu.String(fromChannel:fromChannel + toChannel - 1);
    
    handles.DAQSession = daq.createSession(handles.DAQHandler.CurrentDevice().Vendor.ID);
    handles.DAQSession.Rate = handles.DAQHandler.Rate;
    handles.DAQSession.NotifyWhenDataAvailableExceeds = handles.DAQHandler.Rate;
    handles.DAQSession.IsContinuous = handles.DAQHandler.SessionIsContinuous;
    if ~handles.DAQSession.IsContinuous
        handles.DAQSession.DurationInSeconds = handles.DAQHandler.SessionDurationInSeconds;
    end
    handles.DAQAddedChannel = addAnalogInputChannel(handles.DAQSession, handles.DAQHandler.CurrentDevice().ID, handles.DAQHandler.SelectedChannels, 'Voltage');
    for i = 1:length(handles.DAQAddedChannel)
        handles.DAQAddedChannel(i).TerminalConfig = 'SingleEnded';
    end
    
    handles.DAQSessionListener = addlistener(handles.DAQSession, 'DataAvailable', @(src,evt) DAQSessionDataAvailable(src,evt,handles));
    
    handles.ChannelListbox.Value = 1;
    handles.ChannelListbox.String = handles.DAQHandler.AddedChannelLabels;
    handles.TriggerChannelPopupmenu.String = handles.DAQHandler.AddedChannelLabels;
    
    PlotHandler.AddedChannelLabels = handles.DAQHandler.AddedChannelLabels;
    PlotHandler.Frequency = handles.DAQHandler.Rate;
    PlotHandler.BufferLength = DAQBuffer.BufferLength;
    
    [hObject, handles] = SetUIElementsEnableState(hObject, handles, 'off');
    guidata(hObject, handles);
    
    prepare(handles.DAQSession);
    display(handles.DAQSession);
    startBackground(handles.DAQSession);
%     wait(handles.DAQSession, handles.DAQHandler.WaitTimeout);
%     delete(handles.DAQSessionListener);
end
guidata(hObject, handles);


% --- Executes on selection change in ChannelListbox.
function ChannelListbox_Callback(hObject, eventdata, handles)
% hObject    handle to ChannelListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ChannelListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ChannelListbox



function PlotSensitivityEdit_Callback(hObject, eventdata, handles)
% hObject    handle to PlotSensitivityEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PlotSensitivityEdit as text
%        str2double(get(hObject,'String')) returns contents of PlotSensitivityEdit as a double


% --- Executes during object creation, after setting all properties.
function PlotSensitivityEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PlotSensitivityEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PlotTriggerMarkerCheckbox.
function PlotTriggerMarkerCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to PlotTriggerMarkerCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PlotTriggerMarkerCheckbox
if hObject.Value == 1
    handles.States.IsPlottingTriggerMarkers = true;
else
    handles.States.IsPlottingTriggerMarkers = false;
end
guidata(hObject, handles);