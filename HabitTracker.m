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
            habit_bull_table = habitBullExport2habitTable(habit_bull_file_name);
            existing_habits_table = habitXML2table(obj.xml_file_name);
    
            habit_bull_table(habit_bull_table.Date < datetime(2018, 1, 1), :) = []; % Antes el h�bito de Cold approach se llamaba ColdApproach
            [~, indNewRows] = setdiff(habit_bull_table(:, {'Date', 'Habit'}), existing_habits_table(:, {'Date', 'Habit'}), 'rows');
    
            T = [habit_bull_table(indNewRows, :); existing_habits_table];
    
            habitTable2XML(T, obj.xml_file_name);
        end
    end
end

