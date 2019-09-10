function plotTriggerToAxes(axes, xCoordinates)
%UNTITLED この関数の概要をここに記述
%   詳細説明をここに記述

[newXTicks, xTickSortIndex] = sort([axes.XTick, xCoordinates]);
xLabels = char(axes.XTickLabel, repmat('M', length(xCoordinates), 1));
newXTickLabels = xLabels(xTickSortIndex, :, :);

axes.XTick = newXTicks;
axes.XTickLabel = newXTickLabels;
for i=1:length(xCoordinates)
    line(axes, [xCoordinates(i) xCoordinates(i)], axes.YLim, 'LineStyle', '--', 'Color', 'Red');
end

end

