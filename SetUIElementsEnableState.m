function [hObject, handles] = SetUIElementsEnableState(hObject, handles, state)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

handles.DAQTimerCheckbox.Enable = state;
handles.RecordDataCheckbox.Enable = state;
handles.LSLStreamingCheckbox.Enable = state;

handles.DAQSamplingRateEdit.Enable = state;
handles.DAQTimerDurationEdit.Enable = state;
handles.LSLTagEdit.Enable = state;
handles.LSLIDEdit.Enable = state;

handles.RefreshDAQPushbutton.Enable = state;
handles.ResetDAQPushbutton.Enable = state;

handles.DAQDevicesPopupmenu.Enable = state;
handles.FromChannelPopupmenu.Enable = state;
handles.ToChannelPopupmenu.Enable = state;

end

