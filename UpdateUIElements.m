function [hObject, handles] = UpdateUIElements(hObject, handles)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

handles.DAQTimerCheckbox.Value = ~handles.States.IsDAQSessionContinuous;
handles.RecordDataCheckbox.Value = handles.States.IsRecording;
handles.PlotTriggerMarkerCheckbox.Value = handles.States.IsPlottingTriggerMarkers;
end

