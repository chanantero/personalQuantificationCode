function [Tschedule] = activityTable2scheduleTable(Tact)
Tschedule = Tact(:, {'name', 'start', 'duration', 'category'});
Tschedule.Properties.VariableNames = {'Name', 'Start', 'Duration', 'Tags'};
Tschedule.Tags = cellstr(Tschedule.Tags);

% Add flag columns. Not useful, just a formalism for the timeSchedule class
Tschedule = [Tschedule, table(false(size(Tschedule, 1), 1), false(size(Tschedule, 1), 1), false(size(Tschedule, 1), 1),...
    'VariableNames', {'FixedStart', 'FixedDuration', 'FixedEnd'})];
end

