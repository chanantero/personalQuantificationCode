%% Read xml and generate a readable structure
T = habitXML2table('../Datos/Registro cuantificable.txt');
T = sortrows(T, {'Date', 'Habit'}, 'ascend');

% Select the desired habit
fig = figure;

ind = T.Habit == 'TFM';
ax = subplot(3, 1, 1);
bar(ax, T.Value(ind))
ax.XTick = 1:sum(ind);
ax.XTickLabels = cellstr(T.Date(ind));
ax.XTickLabelRotation = 70;
ax.YLabel.String = 'TFM';

ind = T.Habit == 'Gym';
ax = subplot(3, 1, 2);
bar(ax, T.Value(ind))
ax.XTick = 1:sum(ind);
ax.XTickLabels = cellstr(T.Date(ind));
ax.XTickLabelRotation = 70;
ax.YLabel.String = 'Gym';

ind = T.Habit == 'ColdApproach';
ax = subplot(3, 1, 3);
bar(ax, T.Value(ind))
ax.XTick = 1:sum(ind);
ax.XTickLabels = cellstr(T.Date(ind));
ax.XTickLabelRotation = 70;
ax.YLabel.String = 'Number of approaches';
