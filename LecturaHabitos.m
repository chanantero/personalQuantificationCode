%% Read xml and generate a readable structure
T = habitXML2table('../Registro cuantificable.txt');

% Select the desired habit
fig = figure;

ind = T.Tag == 'TFM';
ax = subplot(3, 1, 1);
bar(ax, T.Value(ind))
ax.XTick = 1:sum(ind);
ax.XTickLabels = cellstr(T.Day(ind));
ax.XTickLabelRotation = 70;
ax.YLabel.String = 'TFM';

ind = T.Tag == 'Gym';
ax = subplot(3, 1, 2);
bar(ax, T.Value(ind))
ax.XTick = 1:sum(ind);
ax.XTickLabels = cellstr(T.Day(ind));
ax.XTickLabelRotation = 70;
ax.YLabel.String = 'Gym';

ind = T.Tag == 'ColdApproach';
ax = subplot(3, 1, 3);
bar(ax, T.Value(ind))
ax.XTick = 1:sum(ind);
ax.XTickLabels = cellstr(T.Day(ind));
ax.XTickLabelRotation = 70;
ax.YLabel.String = 'Number of approaches';
