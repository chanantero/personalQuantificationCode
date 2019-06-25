%% Read xml and generate a readable structure
T = HabitTracker.habitXML2table('../Datos/Registro cuantificable.xml');

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

ax = axes(figure, 'NextPlot', 'Add');
plot(ax, wakeUpStartOfDay, hours(wakeUpTime - wakeUpStartOfDay), ...
    sleepStartOfDay, hours(sleepTime - sleepStartOfDay),...
    lowStimulusStartOfDay, hours(lowStimulusTime - lowStimulusStartOfDay)); 
% plot(ax, ax.XLim, [12 12], '--', ax.XLim, [24 24], '--', ax.XLim, [27 27], '--')
ax.YTick = [6 9 12 15 24 27];
ax.YTickLabels(5:6) = {'Medianoche', '3 AM'};
ax.YGrid = 'on';

% Bar
firstDay = min([wakeUpStartOfDay; sleepStartOfDay]);
lastDay = max([wakeUpStartOfDay; sleepStartOfDay]);
daysVec = (firstDay:caldays(1):lastDay)';
numDays = length(daysVec);

assignedWakeUp = ismember(daysVec, wakeUpDate);
assignedSleep = ismember(daysVec, sleepDate);

types = zeros(numDays, 2);
types(assignedSleep, 1) = 1; % Valid starting of day because there is a sleeping time
types(~assignedSleep, 1) = 3; % Non-specified a sleeping time
types(assignedWakeUp(2:end), 2) = 2; % Valid end of day because there is a waking-up time next morning
types(~assignedWakeUp(2:end), 2) = 3; % Non-specified wake up time next morning
types = types';
% [assignedWakeUp assignedSleep, types]

timesAux = repmat(datetime(2018, 1, 1), [numDays, 2]);
timesAux(assignedWakeUp, 1) = flip(wakeUpTime); % Make it ascending order (time progresses for increasing indices)
timesAux(assignedSleep, 2) = flip(sleepTime);
timesAux = timesAux';
flags = [assignedWakeUp, assignedSleep]';
times = timesAux(flags);
times.Format = 'dd-MMM-uuuu HH:mm:SS';
validTypes = types(flags);

C = zeros(numDays*60*24, 1);
for k = 1:length(times) - 1
    indIni = floor(minutes(times(k) - firstDay) + 1);
    indFin = floor(minutes(times(k+1) - firstDay));
    C(indIni:indFin) = validTypes(k);
end

C = reshape(C(1:numDays*60*24), [60*24, numDays]);
C(C == 0) = 3;

ax = axes(figure);
imagesc(ax, [0 1], [0 24], C)
cmap = [[108 255 40]/255; [14 30 178]/255; 0 0 0];
colormap(ax, cmap);
ax.View = [0 -90];

%% Quantificable habits
T = sortrows(T, {'Date', 'Habit'}, 'ascend');

% Select the desired habit
fig = figure;

% ind = T.Habit == 'TFM';
% ax = subplot(3, 1, 1);
% bar(ax, str2double(T.Value(ind)))
% ax.XTick = 1:sum(ind);
% ax.XTickLabels = cellstr(T.Date(ind));
% ax.XTickLabelRotation = 70;
% ax.YLabel.String = 'TFM';

ind = find(T.Habit == 'Gym');
ax = subplot(2, 1, 1);
bar(ax, str2double(T.Value(ind)))
numXTicks = 20;
step = floor(numel(ind)/numXTicks);
ax.XTick = 1:step:numel(ind);
ax.XTickLabels = cellstr(T.Date(ind(ax.XTick)));
ax.XTickLabelRotation = 70;
ax.YLabel.String = 'Gym';

ind = find(T.Habit == 'ColdApproach' | T.Habit == 'Cold approach');
ax = subplot(2, 1, 2);
bar(ax, str2double(T.Value(ind)))
numXTicks = 20;
step = floor(numel(ind)/numXTicks);
ax.XTick = 1:step:numel(ind);
ax.XTickLabels = cellstr(T.Date(ind(ax.XTick)));
ax.XTickLabelRotation = 70;
ax.YLabel.String = 'Number of approaches';
