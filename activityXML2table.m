%% Lectura actividades
function T = activityXML2table(fileName)
obj = xmlStructureHandler(fileName);

% Selecciona solo los elementos hijos del nodo global con la etiqueta 'activity'
activities = obj.getNodesByElementTag('activity');
numActivities = numel(activities);

variableNames = {'name', 'start', 'duration', 'ending', 'tags', 'description'};
numVariableNames = numel(variableNames);

% Crea tabla de actividades
data = cell(numActivities, numVariableNames);
for k = 1:numel(data)
    data{k} = '';
end

for a = 1:numActivities
    names = {activities(a).Attributes(:).Name};
    values = {activities(a).Attributes(:).Value};
    
    % Detecta los elementos de texto que son hijos de la actividad. Es la
    % descripción
    if ~isempty(activities(a).Children)
        textFlag = strcmp('#text', {activities(a).Children.Tag});
        description = strjoin({activities(a).Children(textFlag).Data}, sprintf('\n'));
        names = [names, {'description'}];
        values = [values, {description}];
    end
    
    [flag, ind] = ismember(variableNames, names);
    
    data(a, flag) = values(ind(flag));
end

data = mat2cell(data, numActivities, ones(1, numVariableNames));

T = table(data{:}, 'VariableNames', variableNames);

% Convierte start y ending a clase datetime y duration a clase duration
% for a = 1:numActivities % numel(T.ending)
%     if isempty(T.ending{a})
%         T.ending{a} = '';
%     end
%     
%     if isempty(T.start{a})
%         T.start{a} = '';
%     end
%     
%     if isempty(T.duration{a})
%         T.duration{a} = '';
%     end
% end

T.start = datetime(T.start, 'InputFormat', 'yyyy/MM/dd HH:mm:ss');
T.ending = datetime(T.ending, 'InputFormat', 'yyyy/MM/dd HH:mm:ss');

% Parse durations
names = regexp(T.duration, '(?<value>\d+(\.\d+)?)(?<unit>[hms]*)', 'names');
durationMatrix = zeros(numActivities, 3); % [h, m, s]
for a = 1:numActivities
    numFields = numel(names{a});
    
    for k = 1:numFields
        durationUnit = names{a}(k).unit;
        value = str2double(names{a}(k).value);
        if isnan(value)
            value = 0;
        end
        
        switch durationUnit
            case 'h'
                durationMatrix(a, 1) = value;
            case 'm'
                durationMatrix(a, 2) = value;
            case 's'
                durationMatrix(a, 3) = value;
            otherwise
                % We assume the duration unit is minutes
                durationMatrix(a, 2) = value;
        end
    end
end
T.duration = duration(durationMatrix);
end

% % Old function
% function T = activityXML2table(fileName)
% obj = xmlStructureHandler(fileName);
% 
% % Selecciona solo los elementos hijos del nodo global con la etiqueta 'activity'
% activities = obj.getNodesByElementTag('activity');
% numActivities = numel(activities);
% 
% variableNames = {'name', 'start', 'duration', 'ending', 'tags', 'description'};
% numVariableNames = numel(variableNames);
% 
% % Crea tabla de actividades
% data = cell(numActivities, numVariableNames);
% for a = 1:numActivities
%     names = {activities(a).Attributes(:).Name};
%     values = {activities(a).Attributes(:).Value};
%     
%     % Detecta los elementos de texto que son hijos de la actividad. Es la
%     % descripción
%     if ~isempty(activities(a).Children)
%     textFlag = strcmp('#text', {activities(a).Children.Tag});
%     description = strjoin({activities(a).Children(textFlag).Data}, sprintf('\n'));
%     names = [names, {'description'}];
%     values = [values, {description}];       
%     end
%     
%     [flag, ind] = ismember(variableNames, names);
%     
%     data(a, flag) = values(ind(flag));
% end
% 
% data = mat2cell(data, numActivities, ones(1, numVariableNames));
% 
% T = table(data{:}, 'VariableNames', variableNames);
% 
% % Convierte start y ending a clase datetime y duration a clase duration
% for a = 1:numel(T.ending)
%     if isempty(T.ending{a})
%         T.ending{a} = '';
%     end
%     
%     if isempty(T.start{a})
%         T.start{a} = '';
%     end
%     
%     if isempty(T.duration{a})
%         T.duration{a} = '';
%     end
% end
% 
% T.start = datetime(T.start, 'InputFormat', 'yyyy/MM/dd HH:mm');
% T.ending = datetime(T.ending, 'InputFormat', 'yyyy/MM/dd HH:mm');
% 
% names = regexp(T.duration, '(?<value>\d+)(?<unit>\D*)', 'names');
% durationMatrix = zeros(numActivities, 3); % [h, m, s]
% for a = 1:numActivities
%     numFields = numel(names{a});
%     
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
% end
% T.duration = duration(durationMatrix);
% end