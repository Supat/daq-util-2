classdef PlottingHandler
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ZoomIndices
        CurrentZoomIndex
        PeriodIndices
        CurrentPeriodIndex
        Sensitivity
        Mode
        PlotBaseline
        NumberOfPlottingChannels
        AddedChannelLabels
        Frequency
        BufferLength
        PlottingChannels
        PlottingLength
    end
    
    methods
        function obj = PlottingHandler()
            %UNTITLED4 Construct an instance of this class
            %   Detailed explanation goes here
            obj.ZoomIndices = 1:1:10;
            obj.CurrentZoomIndex = 1;
            obj.PeriodIndices = 1:1:10;
            obj.CurrentPeriodIndex = 10;
            obj.Sensitivity = 20;
            obj.Mode = 1;
            obj.PlotBaseline = 0;
            obj.NumberOfPlottingChannels = 1;
        end
        
        function obj = set.ZoomIndices(obj, indices)
            obj.ZoomIndices = indices;
        end
        
        function obj = set.PeriodIndices(obj, indices)
            obj.PeriodIndices = indices;
        end
        
        function obj = set.Sensitivity(obj, index)
            obj.Sensitivity = index;
        end
        
        function obj = set.Mode(obj, mode)
            obj.Mode = mode;
            obj = obj.UpdatePlottingMode();
        end
        
        function obj = UpdatePlottingMode(obj)
            if obj.Mode == 1
                obj.PeriodIndices = 1:1:10;
                if obj.CurrentPeriodIndex > length(obj.PeriodIndices)
                    obj.CurrentPeriodIndex = length(obj.PeriodIndices);
                end
                obj.BufferLength = 10;
            elseif obj.Mode == 2
                obj.PeriodIndices = [0.3, 1.5, 3.0];
                if obj.CurrentPeriodIndex > length(obj.PeriodIndices)
                    obj.CurrentPeriodIndex = length(obj.PeriodIndices);
                end
                
                if obj.CurrentPeriodIndex == 1
                    obj.PlottingLength = 0.3 * obj.Frequency;
                elseif obj.CurrentPeriodIndex == 2
                    obj.PlottingLength = 1.5 * obj.Frequency;
                elseif obj.CurrentPeriodIndex == 3
                    obj.PlottingLength = 3 * obj.Frequency;
                end
            else
            end
        end
        
        function obj = set.NumberOfPlottingChannels(obj, chnum)
            if chnum > 0
                obj.NumberOfPlottingChannels = chnum;
            else
                error('Number of channels must be positive.');
            end
        end
        
        function leftMargin = LeftMargin(obj)
            leftMargin = 1 + ((obj.BufferLength - obj.Period()) * obj.Frequency);
        end
        
        function rightMargin = RightMargin(obj)
            rightMargin = obj.Frequency * obj.BufferLength;
        end
        
        function topMargin = TopMargin(obj)
            topMargin = obj.PlotBaseline + obj.Margin();
        end
        
        function bottomMargin = BottomMargin(obj)
            bottomMargin = obj.PlotBaseline - obj.Margin();
        end
        
        function margin = Margin(obj)
            margin = pow2(10, obj.Sensitivity - obj.ZoomIndices(obj.CurrentZoomIndex));
        end
        
        function step = Step(obj)
            step = (obj.TopMargin() - obj.BottomMargin()) / obj.NumberOfPlottingChannels;
        end
        
        function ytickPosition = YTickPosition(obj)
            adjustedYTickPosition = obj.Step() * (1:obj.NumberOfPlottingChannels);
            if mod(obj.NumberOfPlottingChannels, 2) == 0
                head = (adjustedYTickPosition - adjustedYTickPosition(ceil(median(1:obj.NumberOfPlottingChannels))) + (obj.Step() / 2));
                tail = (adjustedYTickPosition - adjustedYTickPosition(floor(median(1:obj.NumberOfPlottingChannels))) - (obj.Step() / 2));
                ytickPosition = [head(1:floor(median(1:obj.NumberOfPlottingChannels))), tail(ceil(median(1:obj.NumberOfPlottingChannels)):end)];
            else
                ytickPosition = adjustedYTickPosition - adjustedYTickPosition(median(1:obj.NumberOfPlottingChannels));
            end
            
            ytickPosition = fliplr(ytickPosition);
        end
        
        function xtickPosition = XTickPosition(obj)
            if obj.PlottingLength < obj.Frequency
                xtickPosition = (0:0.05:obj.BufferLength) * obj.Frequency;
            else
                xtickPosition = (0:0.5:obj.BufferLength) * obj.Frequency;
            end
        end
        
        function xtickLabel = XTickLabel(obj)
            if obj.PlottingLength < obj.Frequency
                xtickLabel = fliplr(0:0.05:obj.BufferLength);
            else
                xtickLabel = fliplr(0:0.5:obj.BufferLength);
            end
        end
        
        function period = Period(obj)
            if obj.Mode == 1
                period = obj.PeriodIndices(obj.CurrentPeriodIndex);
            elseif obj.Mode == 2
                if obj.CurrentPeriodIndex == 1
                    period = 0.3;
                elseif obj.CurrentPeriodIndex == 2
                    period = 1.5;
                elseif obj.CurrentPeriodIndex == 3
                    period = 3;
                end
            end
        end
        
        function zoom = Zoom(obj)
            zoom = obj.ZoomIndices(obj.CurrentZoomIndex);
        end
        
        function num = NumberOfAddedChannels(obj)
            num = length(obj.AddedChannelLabels);
        end
        
        function labels = PlottingChannelsLabels(obj)
            labels = obj.AddedChannelLabels(obj.PlottingChannels, :);
        end
        
        function markerPos = MarkerPosition(obj)
            if obj.CurrentPeriodIndex == 1
                markerPos = floor(obj.Frequency * 0.1);
            elseif obj.CurrentPeriodIndex == 2
                markerPos = floor(obj.Frequency * 0.5);
            elseif obj.CurrentPeriodIndex == 3
                markerPos = obj.Frequency;
            end
        end
    end
end

