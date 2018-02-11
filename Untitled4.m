% Lectura Habit Bull CSV y guardado en xml de h·bitos
T = habitBullExport2habitTable('../Datos/HabitBull CSV Data File Export.csv');

wakeUpFlag = strcmp(T.Tag, 'Waking up');
sleepFlag = strcmp(T.Tag, 'Time to sleep');
lowStimulusFlag = strcmp(T.Tag, 'Fase de bajo est√≠mulo');

wakeUpDate = T.Date(wakeUpFlag);
sleepDate = T.Date(sleepFlag);
lowStimulusDate = T.Date(lowStimulusFlag);

wakeUpHourDur = str2duration(T.Value(wakeUpFlag));
sleepHourDur = str2duration(T.Value(sleepFlag));
lowStimulusHourDur = str2duration(T.Value(lowStimulusFlag));

threshold = hours(6);
wakeUpTime = dateAndTime2datetime(wakeUpDate, wakeUpHourDur, threshold);
sleepTime = dateAndTime2datetime(sleepDate, sleepHourDur, threshold);
lowStimulusTime = dateAndTime2datetime(lowStimulusDate, lowStimulusHourDur, threshold);

wakeUpStartOfDay = dateshift(wakeUpDate, 'start', 'day');
sleepStartOfDay = dateshift(sleepDate, 'start', 'day');
lowStimulusStartOfDay = dateshift(lowStimulusDate, 'start', 'day');

plot(wakeUpStartOfDay, hours(wakeUpTime - wakeUpStartOfDay), ...
    sleepStartOfDay, hours(sleepTime - sleepStartOfDay),...
    lowStimulusStartOfDay, hours(lowStimulusTime - lowStimulusStartOfDay)); 