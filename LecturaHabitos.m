%% Read xml and generate a readable structure
T = habitXML2table('../Datos/Registro cuantificable.xml');

%% Wake up, sleep and low stimulus times
wakeUpFlag = T.Habit == 'Waking up';
sleepFlag = T.Habit == 'Time to sleep';
lowStimulusFlag = T.Habit == 'Fase de bajo estimulo';

wakeUpDate = T.Date(wakeUpFlag);
sleepDate = T.Date(sleepFlag);
lowStimulusDate = T.Date(lowStimulusFlag);

wakeUpHourDur = str2duration(T.Value(wakeUpFlag));
sleepHourDur = str2duration(T.Value(sleepFlag));
lowStimulusHourDur = str2duration(T.Value(lowStimulusFlag));

wakeUpTime = dateAndTime2datetime(wakeUpDate, wakeUpHourDur, hours(0));
sleepTime = dateAndTime2datetime(sleepDate, sleepHourDur, hours(12));
lowStimulusTime = dateAndTime2datetime(lowStimulusDate, lowStimulusHourDur, hours(12));

wakeUpStartOfDay = dateshift(wakeUpDate, 'start', 'day');
sleepStartOfDay = dateshift(sleepDate, 'start', 'day');
lowStimulusStartOfDay = dateshift(lowStimulusDate, 'start', 'day');

plot(wakeUpStartOfDay, hours(wakeUpTime - wakeUpStartOfDay), ...
    sleepStartOfDay, hours(sleepTime - sleepStartOfDay),...
    lowStimulusStartOfDay, hours(lowStimulusTime - lowStimulusStartOfDay)); 


%% Quantificable habits
T = sortrows(T, {'Date', 'Habit'}, 'ascend');

% Select the desired habit
fig = figure;

ind = T.Habit == 'TFM';
ax = subplot(3, 1, 1);
bar(ax, str2double(T.Value(ind)))
ax.XTick = 1:sum(ind);
ax.XTickLabels = cellstr(T.Date(ind));
ax.XTickLabelRotation = 70;
ax.YLabel.String = 'TFM';

ind = T.Habit == 'Gym';
ax = subplot(3, 1, 2);
bar(ax, str2double(T.Value(ind)))
ax.XTick = 1:sum(ind);
ax.XTickLabels = cellstr(T.Date(ind));
ax.XTickLabelRotation = 70;
ax.YLabel.String = 'Gym';

ind = T.Habit == 'ColdApproach' | T.Habit == 'Cold approach';
ax = subplot(3, 1, 3);
bar(ax, str2double(T.Value(ind)))
ax.XTick = 1:sum(ind);
ax.XTickLabels = cellstr(T.Date(ind));
ax.XTickLabelRotation = 70;
ax.YLabel.String = 'Number of approaches';
