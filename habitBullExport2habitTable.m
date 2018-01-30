function T = habitBullExport2habitTable(fileName)

T_habitBull = readtable(fileName);

% Select only relevant variables
T = T_habitBull(:, {'HabitName', 'CalendarDate', 'Value'});
T.Properties.VariableNames = {'Tag', 'Date', 'Value'};
T.Value = num2cell(T.Value);

% For some variables, the relevant value is written in the comment column
flag = ismember(T_habitBull.HabitName, {'Waking up', 'Time to sleep', 'Fase de bajo estímulo'});
T(flag, 'Value') = T_habitBull(flag, 'CommentText');

T.Date = datetime(T.Date, 'InputFormat', 'yyyy-MM-dd');

end