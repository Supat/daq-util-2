function plotToAxes(axes, data)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
global PlotHandler

if PlotHandler.Mode == 1 
    plottingData = data(PlotHandler.PlottingChannels, :);
elseif PlotHandler.Mode == 2
    plottingData = data;
end

[PlotHandler.NumberOfPlottingChannels, PlotHandler.PlottingLength] = size(plottingData);

yTickPosition = PlotHandler.YTickPosition();

for i = 1:PlotHandler.NumberOfPlottingChannels
    plottingData(i, :) = plottingData(i, :) - mean(plottingData(i, :));
    plottingData(i, :) = plottingData(i, :) + yTickPosition(i);
end
[yTickPosition, yTickSortIndex] = sort(yTickPosition);

labels = PlotHandler.PlottingChannelsLabels();
plottingLabels = labels(yTickSortIndex);

plot(axes, plottingData');

if length(plottingData) < PlotHandler.Frequency

else
end

axes.XLimMode = 'manual';
axes.XLim = [PlotHandler.LeftMargin(), PlotHandler.RightMargin()];
axes.XTick = PlotHandler.XTickPosition();
axes.XTickLabel = PlotHandler.XTickLabel();


axes.YTick = transpose(yTickPosition);
axes.YTickLabel = transpose(plottingLabels);
if PlotHandler.TopMargin() > PlotHandler.BottomMargin()
    axes.YLimMode = 'manual';
    axes.YLim = [PlotHandler.BottomMargin(), PlotHandler.TopMargin()];
else
    axes.YLimMode = 'auto';
end
end

