function [Tact] = projectXMLplan2activityTable(fileName)
% This function reads a Microsoft Office Project file with the format I
% usually use for planning weeks.
% As it is highly specific, there is a lot of hard-coding, so it probably
% returns error when some variation appears. This function's purpose is not
% general or intended to work with much flexibility. It is rather intended
% for grouping code that maybe, in a future, I will extend and improve.

theStruct = XmlTools.xml2structure(fileName);
tasksNode = xmlStructureHandler.getNodesByTag(theStruct.Children, 'Tasks');
taskNodes = tasksNode.Children;
[T, extScheme] = XmlTools.XMLstructure2XMLtable(taskNodes, 'maxLevel', 3);

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
Tattrib = XmlTools.XSDfile2XSDattributeTable(xsdFile, 'activity');
categ = cellstr(Tattrib{Tattrib.name == "category", 'enumeration'}{1});
Tact.category = categorical(Tact.category, categ, categ, 'Protected', true);
Tact.category(isundefined(Tact.category)) = 'undetermined';

ind = find(~ismember(Tattrib.name, Tact.Properties.VariableNames));
N = length(ind);
numAct = size(Tact, 1);
data = strings(numAct , N);
for n = 1:N
    data(:, n) = Tattrib.default(ind(n));
end
data = mat2cell(data, numAct, ones(1, N));
Tact = [Tact, table(data{:}, strings(numAct, 1), 'VariableNames', cellstr([Tattrib.name(ind); "description"]))];

Tact = stringActivityTable2XSDspecification(Tact, Tattrib);

end

