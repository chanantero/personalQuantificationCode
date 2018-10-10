Tact = activityXML2table('../Datos/Actividades.xml');
numAct = size(Tact, 1);

selTact = Tact;

% % Filter rows
% filterTags = {'FocusedIntelectualWork'};
% tags = selTact.tags;
% selInd = false(numAct, 1);
% for ac = 1:numAct
%     tags_ = strsplit(tags{ac}, ';');
%     selInd(ac) = any(ismember(filterTags, tags_));
% end
% selTact = selTact(selInd, :);
% 

firstDay = max(dateshift(Tact.start, 'start', 'day')) - days(3);
selTact = selTact(selTact.start >= firstDay, :);

numActSel = size(selTact, 1);

% If there are NaN values in the duration, calculate it with the end time
ind = isnan(selTact.duration);
selTact.duration(ind) = selTact.ending(ind) - selTact.start(ind);

% Transform format of the table so the class timeSchedule can manage it
Tschedule = selTact(:, {'name', 'start', 'duration', 'tags'});
Tschedule.Properties.VariableNames = {'Name', 'Start', 'Duration', 'Tags'};
    % Keep only the first tag
for r = 1:numActSel
    currTags = strsplit(Tschedule.Tags{r}, ';');
    if isempty(currTags)
        Tschedule.Tags(r) = {''};
    else
        Tschedule.Tags(r) = currTags(1);
    end
end
    % Convert tags
Tschedule.Tags = strrep(Tschedule.Tags, 'FocusedIntelectualWork', 'Bloque productivo');
Tschedule.Tags = strrep(Tschedule.Tags, 'ocio', 'Ocio');
Tschedule.Tags = strrep(Tschedule.Tags, 'social', 'Social');
Tschedule.Tags = strrep(Tschedule.Tags, 'noPurpose', 'No intencion');
Tschedule.Tags = strrep(Tschedule.Tags, 'meal', 'Comer');
Tschedule.Tags = strrep(Tschedule.Tags, 'trayecto', 'Trayecto');
    % Add flag columns. Not useful, just a formalism
Tschedule = [Tschedule, table(false(numActSel, 1), false(numActSel, 1), false(numActSel, 1),...
    'VariableNames', {'FixedStart', 'FixedDuration', 'FixedEnd'})];

% Create timeSchedule object and visualize
addpath('TimeSchedule')
obj = timeSchedule();
obj.schedule = Tschedule;
obj.viewSchedule();

%% Horas TFM por día
% Tact = activityXML2table('../Datos/Actividades.xml');
% numAct = size(Tact, 1);

% Filter rows
filterTags = {'TFM'};
tags = Tact.tags;
selInd = false(numAct, 1);
for ac = 1:numAct
    tags_ = strsplit(tags{ac}, ';');
    selInd(ac) = any(ismember(filterTags, tags_));
end
selTact = Tact(selInd, :);

% If there are NaN values in the duration, calculate it with the end time
ind = isnan(selTact.duration);
selTact.duration(ind) = selTact.ending(ind) - selTact.start(ind);

dates = dateshift(selTact.start, 'start', 'week');
datesDay = dateshift(selTact.start, 'start', 'day');
duration = hours(selTact.duration);
% grpstats(duration, dates, 'sum') % Low level version
taux = table(dates, datesDay, duration, 'VariableNames', {'day', 'dayIndividual', 'hours'});
selTact = [selTact, taux];
Tgrup = grpstats(selTact, 'day', 'sum', 'DataVars', {'hours'});
Tgrup.day.Format = 'dd-MMM';
TgrupIndiv = grpstats(selTact, 'dayIndividual', 'sum', 'DataVars', {'hours'});
TgrupIndiv.dayIndividual.Format = 'dd-MMM';

ax = axes(figure);
% plot(ax, Tgrup.day, Tgrup.sum_hours, 'o');
% ax.YLim = [0, 10];
daysPassed = days(Tgrup.day - datetime('01/Jan/2018'));
bar(ax, daysPassed, Tgrup.sum_hours)
numXTicks = 20;
step = max(floor(size(Tgrup, 1)/numXTicks), 1);
indTick = 1:step:size(Tgrup, 1);
ax.XTick = daysPassed(indTick);
ax.XTickLabels = cellstr(Tgrup.day(indTick));
ax.XTickLabelRotation = 70;

% Day by Day
ax = axes(figure);
% plot(ax, Tgrup.day, Tgrup.sum_hours, 'o');
% ax.YLim = [0, 10];
daysPassed = days(TgrupIndiv.dayIndividual - datetime('01/Jan/2018'));
bar(ax, daysPassed, TgrupIndiv.sum_hours)
numXTicks = 20;
step = max(floor(size(TgrupIndiv, 1)/numXTicks), 1);
indTick = 1:step:size(TgrupIndiv, 1);
ax.XTick = daysPassed(indTick);
ax.XTickLabels = cellstr(TgrupIndiv.dayIndividual(indTick));
ax.XTickLabelRotation = 70;


ax = axes(figure);
daysPassed = days(Tgrup.day - datetime('01/Jan/2018'));
stairs(ax, daysPassed, cumsum(Tgrup.sum_hours))
numXTicks = 20;
step = max(floor(size(Tgrup, 1)/numXTicks), 1);
indTick = 1:step:size(Tgrup, 1);
ax.XTick = daysPassed(indTick);
ax.XTickLabels = cellstr(Tgrup.day(indTick));
ax.XTickLabelRotation = 70;



% plot(ax, Tgrup.day, Tgrup.sum_hours)
% ax.XAxis