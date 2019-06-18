function Tact = activityXML2activityTable(fileName, varargin)

p = inputParser;
addParameter(p, 'invalidDataAction', 'invalid2default', @(x) ismember(x, {'invalid2default', 'invalid2undefined'}))
parse(p, varargin{:})
invalidDataAction = p.Results.invalidDataAction;

% Find and read XML schema definition file
xsdFile = getXSDfile(fileName);
if ~isempty(xsdFile)
    Tattrib = XmlTools.XSDfile2XSDattributeTable(xsdFile, 'activity');
else
    error('activityXML2table:noXSD', 'The XML file has no XSD scheme referenced')
    % Completar un Tattrib con los campos que s� que uso s� o s�: start,
    % ending, duration, tags, category, etc.
end
numAttribs = size(Tattrib, 1);

% Create table with attributes
theStruct = XmlTools.xml2structure(fileName);
[T, extScheme] = XmlTools.XMLstructure2XMLtable(theStruct);
indActiv = find(ismember(T.('Tag_Level_2'), 'activity'));
numActivities = length(indActiv);
[Tact, attribIndices] = unfoldAttributesInTable(T(indActiv, :), 'Attributes_Level_2', Tattrib.name);

% Substitute default values
for a = 1:numAttribs
    notSet = attribIndices(:, a) == 0;
    Tact{notSet, a} = Tattrib.('default')(a);
end

% Add descriptions
absScheme = TreeStructureTools.extended2absoluteTreeScheme(extScheme);
numChildren = absScheme{2};
hasDescription = numChildren(indActiv) > 0;
descriptions = strings(numActivities, 1);
for a = 1:numActivities
    if hasDescription(a)
        strs = T{extScheme(:, 2) == indActiv(a), 'Data_Level_3'};
        description = strjoin(string(strs), '\n');
        descriptions(a) = description;
    end
end

Tdesc = table(descriptions, 'VariableNames', {'description'});
Tact = [Tact, Tdesc];

% Convert to the aproppiate types
[Tact] = stringActivityTable2XSDspecification(Tact, Tattrib, invalidDataAction);

end

% Old way
% %% Lectura actividades
% function T = activityXML2table(fileName)
% % An activity is an entity that symbolizes an action or a group of actions
% % of the same type done in a given period of time. For example, studying
% % from 16:00h to 18:00h is an activity. That a group of actions are the
% % same type is, obviously, subjective.
% % An activity is characterized by a set of properties.
% % Main properties
% % - name. Name of the activity. String.
% % - start. Starting time of the activity. Datetime.
% % - duration. Duration of the activity. Duration.
% % - ending. Ending time of the activity. Datetime.
% % - description. String.
% % - people. People with whom the activity was done. String array.
% % - category. Type/class/kind of activity. activityCategory or String.
% % - tags. The use of this property is not clear. String array.
% % Other properties:
% % - focus. Whether the activity has a prominent concentration aspect. PropFlag.
% % - social. Whether the activity has a prominent social aspect. PropFlag.
% % - exercise. Whether the activity involves a significant physical
% % activity. PropFlag.
% % - game. Whether the activity involves cold-approach, seduction, sex or
% % another aspect related to game. PropFlag.
% % - study. Whether the activity involves learning intelectual information
% % or developing technical skills. PropFlag.
% % - development. Whether the activity helps to develop some skill (soft or
% % hard). PropFlag.
%
% theStruct = xmlStructureHandler.xml2structure(fileName);
%
% % Selecciona solo los elementos hijos del nodo global con la etiqueta 'activity'
% activities = xmlStructureHandler.getNodesByTag(theStruct.Children, 'activity');
% numActivities = numel(activities);
%
% mainAttributes = {'name', 'start', 'duration', 'ending', 'category', 'tags', 'description', 'people'};
% mainAttribDataType = {'string', 'datetime', 'duration', 'datetime', 'activityCategory', 'string', 'string', 'string'};
% secondaryAttributes = {'focus', 'social', 'exercise', 'game', 'study', 'development'};
% secondaryAttribDataType = {'PropFlag', 'PropFlag', 'PropFlag', 'PropFlag', 'PropFlag', 'PropFlag'};
% categoryStrings = {'Exercise', 'Game', 'Work', 'Study', 'Waste', 'Porn', 'Meal', 'Cook'};
%
% variableNames = [mainAttributes, secondaryAttributes];
% variableDataTypes = [mainAttribDataType, secondaryAttribDataType];
% numVariableNames = numel(variableNames);
%
% % Crea tabla de actividades
% data = strings(numActivities, numVariableNames);
% [propertyIndMatrix, ~] = xmlStructureHandler.existAttributes(activities, variableNames);
% indDesc = find(strcmp(variableNames, 'description'));
% numChildren = xmlStructureHandler.getNumberOfChildren(activities);
% hasDescription = numChildren > 0;
% for a = 1:numActivities
%     ind = propertyIndMatrix(a, :);
%     values = {activities(a).Attributes(ind(ind ~= 0)).Value};
%     data(a, ind ~= 0) = values;
%
%     if hasDescription(a)
%         textNodes = xmlStructureHandler.getNodesByTag(activities(a).Children, '#text');
%         description = strjoin(string({textNodes.Data}), '\n');
%         data(a, indDesc) = description;
%     end
% end
% data = mat2cell(data, numActivities, ones(1, numVariableNames));
% T = table(data{:}, 'VariableNames', variableNames);
%
% % Convierte start y ending a clase datetime y duration a clase duration
% T.start = datetime(T.start, 'InputFormat', 'yyyy/MM/dd HH:mm:ss');
% T.ending = datetime(T.ending, 'InputFormat', 'yyyy/MM/dd HH:mm:ss');
%
% % Parse durations
% names = regexp(T.duration, '(?<value>\d+(\.\d+)?)(?<unit>[hms]*)', 'names');
% durationMatrix = zeros(numActivities, 3); % [h, m, s]
% for a = 1:numActivities
%     numFields = numel(names{a});
%
%     if numFields == 0
%         durationMatrix(a, :) = NaN;
%     else
%     for k = 1:numFields
%         durationUnit = names{a}(k).unit;
%         value = str2double(names{a}(k).value);
%         if isnan(value)
%             value = 0;
%         end
%
%         switch durationUnit
%             case 'h'
%                 durationMatrix(a, 1) = value;
%             case 'm'
%                 durationMatrix(a, 2) = value;
%             case 's'
%                 durationMatrix(a, 3) = value;
%             otherwise
%                 % We assume the duration unit is minutes
%                 durationMatrix(a, 2) = value;
%         end
%     end
%     end
% end
% T.duration = duration(durationMatrix);
%
% for at = 1:numVariableNames
%     switch variableDataTypes{at}
%         case 'PropFlag'
%             [flags, ind] = ismember(T.(at), {'true', 'false'});
%             values = PropFlag(zeros(numActivities, 1));
%             values(~flags) = PropFlag.Unknown;
%             values(ind == 1) = PropFlag.True;
%             values(ind == 2) = PropFlag.False;
%             T.(at) = values;
%         case 'activityCategory'
%             [~, ind] = ismember(T.(at), categoryStrings);
%             values = activityCategory(ind);
%             T.(at) = values;
%     end
% end
%
% end
%
% % % Old function
% % function T = activityXML2table(fileName)
% % obj = xmlStructureHandler(fileName);
% %
% % % Selecciona solo los elementos hijos del nodo global con la etiqueta 'activity'
% % activities = obj.getNodesByElementTag('activity');
% % numActivities = numel(activities);
% %
% % variableNames = {'name', 'start', 'duration', 'ending', 'tags', 'description'};
% % numVariableNames = numel(variableNames);
% %
% % % Crea tabla de actividades
% % data = cell(numActivities, numVariableNames);
% % for a = 1:numActivities
% %     names = {activities(a).Attributes(:).Name};
% %     values = {activities(a).Attributes(:).Value};
% %
% %     % Detecta los elementos de texto que son hijos de la actividad. Es la
% %     % descripci�n
% %     if ~isempty(activities(a).Children)
% %     textFlag = strcmp('#text', {activities(a).Children.Tag});
% %     description = strjoin({activities(a).Children(textFlag).Data}, sprintf('\n'));
% %     names = [names, {'description'}];
% %     values = [values, {description}];
% %     end
% %
% %     [flag, ind] = ismember(variableNames, names);
% %
% %     data(a, flag) = values(ind(flag));
% % end
% %
% % data = mat2cell(data, numActivities, ones(1, numVariableNames));
% %
% % T = table(data{:}, 'VariableNames', variableNames);
% %
% % % Convierte start y ending a clase datetime y duration a clase duration
% % for a = 1:numel(T.ending)
% %     if isempty(T.ending{a})
% %         T.ending{a} = '';
% %     end
% %
% %     if isempty(T.start{a})
% %         T.start{a} = '';
% %     end
% %
% %     if isempty(T.duration{a})
% %         T.duration{a} = '';
% %     end
% % end
% %
% % T.start = datetime(T.start, 'InputFormat', 'yyyy/MM/dd HH:mm');
% % T.ending = datetime(T.ending, 'InputFormat', 'yyyy/MM/dd HH:mm');
% %
% % names = regexp(T.duration, '(?<value>\d+)(?<unit>\D*)', 'names');
% % durationMatrix = zeros(numActivities, 3); % [h, m, s]
% % for a = 1:numActivities
% %     numFields = numel(names{a});
% %
% %     for k = 1:numFields
% %         durationUnit = names{a}(k).unit;
% %         value = str2double(names{a}(k).value);
% %         if isnan(value)
% %             value = 0;
% %         end
% %
% %         switch durationUnit
% %             case 'h'
% %                 durationMatrix(a, 1) = value;
% %             case 'm'
% %                 durationMatrix(a, 2) = value;
% %             case 's'
% %                 durationMatrix(a, 3) = value;
% %             otherwise
% %                 % We assume the duration unit is minutes
% %                 durationMatrix(a, 2) = value;
% %         end
% %     end
% % end
% % T.duration = duration(durationMatrix);
% % end