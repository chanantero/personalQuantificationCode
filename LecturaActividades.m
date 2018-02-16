Tact = activityXML2table('../Datos/Actividades.xml');
% addpath('TimeSchedule')

% % Filter rows
% tags = Tact.tags;
% selInd = false(numAct, 1);
% for ac = 1:numAct
%     tags_ = strsplit(tags{ac}, ';');
%     selInd(ac) = ismember('FocusedIntelectualWork', tags_);
% end
% selTact = Tact(selInd, :);
 
selTact = Tact;

numActSel = size(selTact, 1);

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
    % Add flag columns. Not useful, just a formalism
Tschedule = [Tschedule, table(false(numActSel, 1), false(numActSel, 1), false(numActSel, 1),...
    'VariableNames', {'FixedStart', 'FixedDuration', 'FixedEnd'})];

% Create timeSchedule object and visualize
obj = timeSchedule();
obj.schedule = Tschedule;
obj.viewSchedule();

