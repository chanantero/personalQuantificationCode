Tact = activityXML2activityTable('../Datos/Actividades.xml');

obj = ActivityHandler(Tact);
obj.draw()

Tsched = Tact;
Tschedule = Tact(:, {'name', 'start', 'duration', 'category'});
Tschedule.Properties.VariableNames = {'Name', 'Start', 'Duration', 'Tags'};
Tschedule.Tags = cellstr(Tschedule.Tags);

% Add flag columns. Not useful, just a formalism
Tschedule = [Tschedule, table(false(size(Tschedule, 1), 1), false(size(Tschedule, 1), 1), false(size(Tschedule, 1), 1),...
    'VariableNames', {'FixedStart', 'FixedDuration', 'FixedEnd'})];

% Create timeSchedule object and visualize
addpath('TimeSchedule')
obj = timeSchedule();
obj.schedule = Tschedule;
obj.viewSchedule();

%% Lectura proyectos Project

fileName = '../Plan.xml';
theStruct = xml2structure(fileName);
tasksNode = xmlStructureHandler.getNodesByTag(theStruct.Children, 'Tasks');
taskNodes = tasksNode.Children;
[T, extScheme] = XMLstructure2XMLtable(taskNodes, 'maxLevel', 3);

startInd = find(strcmp(T.Tag_Level_2, 'Start'));
finishInd = find(strcmp(T.Tag_Level_2, 'Finish'));
nameInd = find(strcmp(T.Tag_Level_2, 'Name'));
outlineLevelInd = find(strcmp(T.Tag_Level_2, 'OutlineLevel'));
notesInd = find(strcmp(T.Tag_Level_2, 'Notes'));

outlineLevel = T{outlineLevelInd, 'Data_Level_3'};
outlineLevel2ind = outlineLevelInd(outlineLevel == "2");

taskHasStart = extScheme(startInd, 1); % Assume taskHasFinish would be the same as taskHasStart
taskHasOutlineLevel2 = extScheme(outlineLevel2ind, 1);
numTasks = length(taskHasOutlineLevel2);
taskHasName = extScheme(nameInd, 1);
taskHasNotes = extScheme(notesInd, 1);

indNameForTaskWithOL2 = nameInd(ismember(taskHasName, taskHasOutlineLevel2));
indStartForTaskWithOL2 = startInd(ismember(taskHasStart, taskHasOutlineLevel2));
indFinishForTaskWithOL2 = finishInd(ismember(taskHasStart, taskHasOutlineLevel2));

start = datetime(T{indStartForTaskWithOL2, 'Data_Level_3'}, 'InputFormat', 'uuuu-MM-dd''T''HH:mm:ss');
finish = datetime(T{indFinishForTaskWithOL2, 'Data_Level_3'}, 'InputFormat', 'uuuu-MM-dd''T''HH:mm:ss');
name = T{indNameForTaskWithOL2, 'Data_Level_3'};
notes = strings(numTasks, 1);
[flag, ind] = ismember(taskHasOutlineLevel2, taskHasNotes);
notes(flag) = T{notesInd(ind(flag)), 'Data_Level_3'};
dur = finish - start;

Tact = table(name, start, finish, dur, notes, 'VariableNames', {'name', 'start', 'ending', 'duration', 'category'});

activityXML = '../Datos/Actividades.xml';
xsdFile = getXSDfile(activityXML);
Tattrib = XSDfile2XSDattributeTable(xsdFile, 'activity');
categ = cellstr(Tattrib{Tattrib.name == "category", 'enumeration'}{1});
Tact.category = categorical(Tact.category, categ, categ, 'Protected', true);
Tact.category(isundefined(Tact.category)) = 'undetermined';

obj = ActivityHandler(Tact);
obj.draw()

Tsel = Tact;
Tsel.duration = hours(Tsel.duration);
Tgrp = grpstats(Tsel, 'category', 'sum', 'DataVars', {'duration'}, 'VarNames', {'category', 'GroupCount', 'TotalDuration'});
ax = axes(figure);
bar(ax, Tgrp.category, Tgrp.TotalDuration)

Tschedule = Tact(:, {'name', 'start', 'duration', 'category'});
Tschedule.Properties.VariableNames = {'Name', 'Start', 'Duration', 'Tags'};
Tschedule.Tags = cellstr(Tschedule.Tags);
Tschedule = [Tschedule, table(false(size(Tschedule, 1), 1), false(size(Tschedule, 1), 1), false(size(Tschedule, 1), 1),...
    'VariableNames', {'FixedStart', 'FixedDuration', 'FixedEnd'})];
addpath('TimeSchedule')
obj = timeSchedule();
obj.schedule = Tschedule;
obj.viewSchedule();


