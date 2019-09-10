function plotTriggerToAxes(axes, xCoordinates)
%UNTITLED ���̊֐��̊T�v�������ɋL�q
%   �ڍא����������ɋL�q

[newXTicks, xTickSortIndex] = sort([axes.XTick, xCoordinates]);
xLabels = char(axes.XTickLabel, repmat('M', length(xCoordinates), 1));
newXTickLabels = xLabels(xTickSortIndex, :, :);

axes.XTick = newXTicks;
axes.XTickLabel = newXTickLabels;
for i=1:length(xCoordinates)
    line(axes, [xCoordinates(i) xCoordinates(i)], axes.YLim, 'LineStyle', '--', 'Color', 'Red');
end

end

