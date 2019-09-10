function [hObject, handles] = UpdateFromChannelPopupmenu(hObject, handles, fromValue)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here
if isempty(handles.DAQHandler.Devices)
    handles.FromChannelPopupmenu.String = 'n/a';
    handles.ToChannelPopupmenu.String = 'n/a';
    
    handles.FromChannelPopupmenu.Enable = 'off';
    handles.ToChannelPopupmenu.Enable = 'off';
else
    selectedDevice = handles.DAQDevicesPopupmenu.Value;
    channelsList = handles.DAQHandler.Devices(selectedDevice).Subsystems(1).ChannelNames;

    handles.FromChannelPopupmenu.Value = fromValue;
    handles.FromChannelPopupmenu.String = channelsList;

    handles.ToChannelPopupmenu.String = channelsList(fromValue:end);
    handles.ToChannelPopupmenu.Value = 1;
    
    handles.FromChannelPopupmenu.Enable = 'on';
    handles.ToChannelPopupmenu.Enable = 'on';
end
end

