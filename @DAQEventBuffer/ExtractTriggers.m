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

