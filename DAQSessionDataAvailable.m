function DAQSessionDataAvailable(src, event, handles)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
global DAQBuffer;
global PlotHandler;
global RecFileHandler;

DAQBuffer = DAQBuffer.AppendDataWithTimeStamps(event.Data, event.TimeStamps);
DAQBuffer = DAQBuffer.AppendTriggerSignals(event.Data(:, handles.TriggerChannelPopupmenu.Value)');

PlotHandler.PlottingChannels = handles.ChannelListbox.Value;
PlotHandler.CurrentPeriodIndex = handles.PlotPeriodPopupmenu.Value;
PlotHandler.CurrentZoomIndex = handles.PlotZoomPopupmenu.Value;
PlotHandler.Sensitivity = str2double(handles.PlotSensitivityEdit.String);
if handles.DisplayModePopupmenu.Value == 1;
    PlotHandler.Mode = 1;
    handles.PlotZoomPopupmenu.String = PlotHandler.ZoomIndices;
    handles.PlotZoomPopupmenu.Value = PlotHandler.CurrentZoomIndex;
    handles.PlotPeriodPopupmenu.String = PlotHandler.PeriodIndices;
    handles.PlotPeriodPopupmenu.Value = PlotHandler.CurrentPeriodIndex;
        
    plotToAxes(handles.MainAxes, DAQBuffer.Data);
    
    if handles.States.IsPlottingTriggerMarkers
        [xCors, ~] = DAQBuffer.ExtractTriggers();
        
        if ~isempty(xCors)
            plotTriggerToAxes(handles.MainAxes, xCors);
        end
    end
elseif handles.DisplayModePopupmenu.Value == 2;
    
    PlotHandler.Mode = 2;
    handles.PlotZoomPopupmenu.String = PlotHandler.ZoomIndices;
    handles.PlotZoomPopupmenu.Value = PlotHandler.CurrentZoomIndex;
    handles.PlotPeriodPopupmenu.String = PlotHandler.PeriodIndices;
    handles.PlotPeriodPopupmenu.Value = PlotHandler.CurrentPeriodIndex;
    
%     try
       
            
        triggerSignals = DAQBuffer.TriggerSignals;
    
        % extract 'trigger positions' and 'trigger values' here
        [xCors, values] = ExtractTriggers(triggerSignals);
    
        DAQBuffer = DAQBuffer.UpdateCurrentTriggerState(xCors, values);
        DAQBuffer = DAQBuffer.PushDataToEventRelatedCacheForTrigger(handles.ChannelListbox.Value, str2double(handles.DAQEventMarkerEdit.String));
    
        markerPosition = PlotHandler.MarkerPosition();
        
        plotToAxes(handles.MainAxes, DAQBuffer.EventRelatedSegment());
        
        line(handles.MainAxes, [markerPosition markerPosition], handles.MainAxes.YLim, 'LineStyle', '--', 'Color', 'Red');
%     catch
%     end
end
drawnow;

if handles.States.IsRecording
    if exist(handles.Defaults.RecordingDirectory, 'dir')
        if ~RecFileHandler.Started
            disp('Recording directory exists.');
            rmdir(handles.Defaults.RecordingDirectory, 's');
            mkdir(handles.Defaults.RecordingDirectory);
            RecFileHandler.Started = true;
            csvwrite(fullfile(pwd, fullfile(handles.Defaults.RecordingDirectory, datestr(now, 'ddmmyyyyHHMMSSFFF'))), event.Data);
        else
            csvwrite(fullfile(pwd, fullfile(handles.Defaults.RecordingDirectory, datestr(now, 'ddmmyyyyHHMMSSFFF'))), event.Data);
        end
    else
        disp('Recording directory not found.');
        success = mkdir(handles.Defaults.RecordingDirectory);
        if success
            disp('Recording directory created.');
        else
            disp('Cannot create recordgin directory.');
        end
    end
end
end

