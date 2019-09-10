classdef DAQEventBuffer
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Frequency
        
        TriggerPositions
        TriggerValues
        TriggerCount
    end
    
    properties (SetAccess = private)
        Data
        TimeStamps
        TriggerSignals
        BufferLength
        
        EventRelatedCache
        EventRelatedCacheLength
    end
    
    methods
        function obj = DAQEventBuffer(bufferLength, cacheLength)
            obj.BufferLength = bufferLength;
            obj.EventRelatedCacheLength = cacheLength;
            obj.Frequency = 1;
        end
        
        function obj = set.Frequency(obj, frequency)
            if (frequency > 0)
                obj.Frequency = frequency;
            else
                error('Frequency must be positive')
            end
        end
        
        function obj = AppendDataWithTimeStamps(obj, newData, newTimeStamps)
            if size(newData, 1) == size(newTimeStamps, 1)
                if size(obj.Data, 2) == 0
                    obj.Data = newData';
                    obj.TimeStamps = newTimeStamps';
                else
                    obj.Data = [obj.Data, newData'];
                    obj.TimeStamps = [obj.TimeStamps, newTimeStamps'];
                end
                
                if size(obj.Data, 2) > obj.BufferLength * obj.Frequency
                    obj.Data = obj.Data(:, size(obj.Data, 2) + 1 - (obj.BufferLength * obj.Frequency):end);
                    obj.TimeStamps = obj.TimeStamps(:, size(obj.TimeStamps, 2) + 1 - (obj.BufferLength * obj.Frequency):end);
                end
            else
                error('Data and TimeStamps dimensions must agree.');
            end
        end
        
        function obj = PushDataToEventRelatedCacheForTrigger(obj, channelIndices, triggerValue)
            detectionPeriod = [length(obj.Data) - (obj.Frequency * obj.EventRelatedCacheLength), length(obj.Data) - (obj.Frequency * (obj.EventRelatedCacheLength - 1))];
            cacheData = obj.Data(channelIndices, :);
            if ~isempty(obj.TriggerPositions) && ~isempty(obj.TriggerValues)
                for i=1:length(obj.TriggerPositions)
                    if obj.TriggerPositions(i) >= detectionPeriod(1) && obj.TriggerPositions(i) < detectionPeriod(2)
                        if obj.TriggerValues(i) == triggerValue
                            obj.TriggerCount = obj.TriggerCount + 1;
                            DataSegment = cacheData(:, obj.TriggerPositions(i) - (1 * obj.Frequency):obj.TriggerPositions(i) + ((obj.EventRelatedCacheLength - 1) * obj.Frequency) - 1);
                            if obj.TriggerCount == 1
                                obj.EventRelatedCache = DataSegment;
                            else
                                obj.EventRelatedCache = DataSegment;
                                % implement running average calculation
                                % here if needed.
                            end
                        end
                    end
                end
            end
        end
        
        function segment = EventRelatedSegment(obj)
            segment = obj.EventRelatedCache;
        end
        
        function obj =AppendTriggerSignals(obj, triggerSignals)
            if size(obj.TriggerSignals, 2) == 0
                obj.TriggerSignals = triggerSignals;
            else
                obj.TriggerSignals = [obj.TriggerSignals, triggerSignals];
            end
            
            if size(obj.TriggerSignals, 2) > obj.BufferLength * obj.Frequency
                obj.TriggerSignals = obj.TriggerSignals(:, size(obj.TriggerSignals, 2) + 1 - (obj.BufferLength * obj.Frequency):end);
            end
        end
        
        function obj = UpdateCurrentTriggerState(obj, xCor, values)
            obj.TriggerPositions = xCor;
            obj.TriggerValues = values;
        end
        
        function [Timepoints, Markers] = ExtractTriggers(obj)
            %UNTITLED Summary of this function goes here
            %   Detailed explanation goes here

            triggerSignal = obj.TriggerSignals;

            Timepoints = zeros(1, length(triggerSignal));
            Markers = zeros(1, length(triggerSignal));

            count = 1;
            previousValue = triggerSignal(1);

            for i=2:length(triggerSignal)
                currentValue = triggerSignal(i);
                if (previousValue <= 0.1 && previousValue > -0.1) && (currentValue > 0.1)
                    Timepoints(count) = i;
                    Markers(count) = triggerSignal(i);
                    count = count + 1;
                end
                previousValue = currentValue;
            end

            Timepoints = Timepoints(1:count - 1);
            Markers = Markers(1:count - 1);

        end
    end
    
end

