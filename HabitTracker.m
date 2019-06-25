classdef HabitTracker < handle
    
    properties
        xml_file_name
    end
    
    methods
        function obj = HabitTracker(xml_file_name)
            obj.xml_file_name = xml_file_name;
        end
        
        function registerHabits(obj, file_name, input_format)
            if nargin < 3
                input_format = 'HabitBull';
            end

            switch input_format
                case 'HabitBull'
                    obj.habitBullExportToHabitXmlFile(file_name);
            end
            
        end
        
        function habitBullExportToHabitXmlFile(obj, habit_bull_file_name)
            habit_bull_table = HabitTracker.habitBullExport2habitTable(habit_bull_file_name);
            existing_habits_table = HabitTracker.habitXML2table(obj.xml_file_name);
    
            habit_bull_table(habit_bull_table.Date < datetime(2018, 1, 1), :) = []; % Antes el h�bito de Cold approach se llamaba ColdApproach
            new_registers = getNewRegisters(habit_bull_table, existing_habits_table);

            HabitTracker.habitTable2XML(new_registers, obj.xml_file_name);
            
            function new_registers = getNewRegisters(registers, existing_registers)
                [~, indNewRows] = setdiff(registers(:, {'Date', 'Habit'}), existing_registers(:, {'Date', 'Habit'}), 'rows');
                new_registers = registers(indNewRows, :);
            end
        end
    end

    methods(Static)
        function T = habitXML2table(fileName)
            % fileName = '../Datos/Registro cuantificable.txt';
            
            nodeTreeStruct = XmlTools.xml2structure(fileName);
            
            joinTables = true;
            [extTable, nodeIndexMatrix] = XmlTools.XMLstructure2ExtendedTables(nodeTreeStruct.Children, joinTables);
            
            if size(nodeIndexMatrix, 2) < 3
                error('At least 3 levels of depth must be present in the structure')
                return;
            end
            
            % Compute some tree structure parameters
            numLeaves = size(extTable, 1);
            leafDepth = TreeStructureTools.getLeafLevel(nodeIndexMatrix);
            
            % There aren't supposed to be more than three levels. In any case, if there
            % are more, we are not interested in them, so we are going to collapse any
            % leafes with a depth greater than 3.
            collapsedIndices = TreeStructureTools.collapseTreeByLevel( nodeIndexMatrix, 3 );
            
            % Filter only those leaves with tag #text that are children of second level nodes with tag
            % 'element' and children of first level nodes with tag day. Leafs that are
            % second level are also kept.
            isDayChild = false(numLeaves, 1);
            isElementChild = false(numLeaves, 1);
            isText = false(numLeaves, 1);
            for r = 1:numLeaves
                isDayChild(r) = strcmp(extTable.('Tag_Level_1'){r}, 'day');
                isElementChild(r) = strcmp(extTable.('Tag_Level_2'){r}, 'element');
                isText(r) = strcmp(extTable.('Tag_Level_3'){r}, '#text');
            end
            
            filter = collapsedIndices & isDayChild & isElementChild & (isText | leafDepth == 2);
            extTable = extTable(filter, :);
            nodeIndexMatrix = nodeIndexMatrix(filter, :);
            
            % Get the first child of every element on the second level. This is the
            % same as collapsing the current tree to the second level.
            collapsedIndices = TreeStructureTools.collapseTreeByLevel( nodeIndexMatrix, 2 );
            extTable = extTable(collapsedIndices, :);
            numElements = size(collapsedIndices, 1);
            
            % Create table with the next variable names: 'date', 'habit', 'value'. Fill
            % it with the appropiate data.
            dateColumn = cell(numElements, 1);
            for r = 1:numElements
                attributes = extTable.('Attributes_Level_1'){r};
                % Search for the attribute with the name 'date'
                names = {attributes.Name};
                ind = find(ismember(names, 'date'), 1, 'first');
                % Get the value
                dateColumn{r} = attributes(ind).Value;
            end
            
            habitColumn = cell(numElements, 1);
            for r = 1:numElements
                attributes = extTable.('Attributes_Level_2'){r};
                % Search for the attribute with the name 'tag'
                names = {attributes.Name};
                ind = find(ismember(names, 'tag'), 1, 'first');
                habitColumn{r} = attributes(ind).Value;
            end
            
            valueColumn = cell(numElements, 1);
            for r = 1:numElements
                valueColumn{r} = extTable.('Data_Level_3'){r};
                if isempty(valueColumn{r})
                    valueColumn{r} = '';
                end
            end
            
            T = table(dateColumn, habitColumn, valueColumn, 'VariableNames', {'Date', 'Habit', 'Value'});
            
            T.Date = datetime(T.Date, 'InputFormat', 'dd/MM/yyyy');
            T.Habit = categorical(T.Habit);
            % T.Value = str2double(T.Value);
            T = sortrows(T, {'Date', 'Habit'}, 'descend');
        end

        function habitTable2XML(T, fileName)
            if ~isempty(T)
                theStruct = HabitTracker.habitTable2structure(T);
                XmlTools.structure2XML(theStruct, fileName, true, true);
            end
        end

        function theStruct =  habitTable2structure(T)
            % A habit table has 3 fields: Date, Tag and Value.
            % T = HabitTracker.habitXML2table('../Datos/Registro cuantificable.txt');
            
            uniqueDates = unique(T.Date);
            
            numDates = size(uniqueDates, 1);
            
            s = repmat(struct('Tag', 'day', 'Attributes', [], 'Data', [], 'Children', []), numDates, 1);
            
            dateStrings = cellstr(datestr(uniqueDates, 'dd/mm/yyyy'));
            for d = 1:numDates
                s(d).Attributes = struct('Name', 'date', 'Value', dateStrings{d});
                Taux = T(T.Date == uniqueDates(d), :);
                numHabits = size(Taux, 1);
                children = repmat(struct('Tag', 'element', 'Attributes', [], 'Data', [], 'Children', []), numHabits, 1);
                
                for h = 1:numHabits
                    children(h).Attributes = struct('Name', 'tag', 'Value', char(Taux{h, 'Habit'}));
                    children(h).Children = struct('Tag', '#text', 'Attributes', [], 'Data', Taux{h, 'Value'}{1}, 'Children', []);
                end
                
                s(d).Children = children;
            end
            
            theStruct = struct('Tag', 'global', 'Attributes', [], 'Data', [], 'Children', s);
        end

        function T = habitBullExport2habitTable(fileName)

            T_habitBull = readtable(fileName);
            
            % Select only relevant variables
            T = T_habitBull(:, {'CalendarDate', 'HabitName', 'Value'});
            T.Properties.VariableNames = {'Date', 'Habit', 'Value'};
            T.Value = num2cell(T.Value);
            for k = 1:size(T, 1)
                T.Value{k} = num2str(T.Value{k});
            end
            
            % For some variables, the relevant value is written in the comment column
            flag = ismember(T_habitBull.HabitName, {'Waking up', 'Time to sleep', 'Fase de bajo estimulo'});
            T(flag, 'Value') = T_habitBull(flag, 'CommentText');
            
            T.Date = datetime(T.Date, 'InputFormat', 'yyyy-MM-dd');
            T.Habit = categorical(T.Habit);
        end
    end
end

