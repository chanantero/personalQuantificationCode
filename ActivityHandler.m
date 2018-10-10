classdef ActivityHandler < handle
% An activity is an entity that symbolizes an action or a group of actions
% of the same type done in a given period of time. For example, studying
% from 16:00h to 18:00h is an activity. That a group of actions are the
% same type is, obviously, subjective.
% An activity is characterized by a set of properties.
% Main properties
% - name. Name of the activity. String.
% - start. Starting time of the activity. Datetime.
% - duration. Duration of the activity. Duration.
% - ending. Ending time of the activity. Datetime.
% - description. String.
% - people. People with whom the activity was done. String.
% - category. Type/class/kind of activity. CategoryEnum or String.
% - tags. The use of this property is not clear. String.
% Other properties:
% - focus. Whether the activity has a prominent concentration aspect. PropFlag.
% - social. Whether the activity has a prominent social aspect. PropFlag.
% - exercise. Whether the activity involves a significant physical
% activity. PropFlag.
% - game. Whether the activity involves cold-approach, seduction, sex or
% another aspect related to game. PropFlag.
% - study. Whether the activity involves learning intelectual information
% or developing technical skills. PropFlag
% - development. Whether the activity helps to develop some skill (soft or
% hard)
% 
% Properties "start", "duration" and "ending" are dependent (ending - start = duration),
% so only two of the three parameters are necessary.

    properties
        Tact
              
        % GUI
        fig
        
        axPieChart
        axHist
        axAcum
        axBar
                
        minTime
        maxTime
        
        indepVar
    end
    
    properties (Constant)
        activityAttributes = {'name', 'start', 'duration', 'ending', 'category', 'tags', 'description', 'people',...
            'focus', 'social', 'exercise', 'game', 'study', 'development'};
    end
    
    % Getters and setters
    methods
        function set.Tact(obj, value)
            % If there are NaN values in the duration, calculate it with the end time
            ind = isnan(value.duration);
            value.duration(ind) = value.ending(ind) - value.start(ind);
            
            % If there are NaN values in the endint time, calculate it with
            % the duration
            ind = isnat(value.ending);
            value.ending(ind) = value.start(ind) + value.duration(ind);
            
            obj.Tact = value;
        end
        
        function set.indepVar(obj, value)
            if isempty(obj.indepVar)
                obj.indepVar = value;
            else
                obj.indepVar(1) = value;
            end
        end
    end
    
    methods
        function obj = ActivityHandler(activityTable)
            obj.Tact = activityTable;
                 
            obj.minTime = datetime([2000, 1, 1]);
            obj.maxTime = datetime([2100, 1, 1]);
            obj.indepVar = categorical({'category'}, obj.activityAttributes, obj.activityAttributes, 'Protected', true);
            
            obj.fig = figure;
            obj.axPieChart = subplot(2, 2, 1);
            obj.axHist = subplot(2, 2, 2);
            obj.axHist.XLabel.String = "Duration (Hours)";
            obj.axAcum = subplot(2, 2, 3);
            obj.axBar = subplot(2, 2, 4);
        end
        
        function draw(obj)
            flag = obj.Tact.start >= obj.minTime & obj.Tact.ending <= obj.maxTime;
            Tsel = obj.Tact(flag, :);
            
            % grpstats doesn't work with duration arrays, so convert it to
            % numeric
            Tsel.duration = hours(Tsel.duration);
            
            Tgrp = grpstats(Tsel, obj.indepVar, 'sum', 'DataVars', {'duration'}, 'VarNames', {char(obj.indepVar), 'GroupCount', 'TotalDuration'});
            
            pie(obj.axPieChart, Tgrp.TotalDuration, cellstr(Tgrp{:, char(obj.indepVar)}))
            
            cla(obj.axHist);
            obj.axHist.NextPlot = 'Add';
            N = size(Tgrp, 1);
            for n = 1:N
                ind = Tsel{:, char(obj.indepVar)} == Tgrp{n, char(obj.indepVar)};
                [X, edges] = histcounts(Tsel.duration(ind), 10, 'Normalization', 'pdf');
                step = edges(2) - edges(1);
                aux = [edges, edges(end) + step] - step/2;
                plot(obj.axHist, aux, [0 X 0])
            end
            obj.axHist.NextPlot = 'Replace';
            legend(obj.axHist, string(Tgrp{:, char(obj.indepVar)}))
                  
            dates = dateshift(Tsel.start, 'start', 'week');
            datesDay = dateshift(Tsel.start, 'start', 'day');
            taux = table(dates, datesDay, 'VariableNames', {'WeekBeginning', 'DayBeginning'});
            selTact = [Tsel, taux];
            selTact.WeekBeginning.Format = 'dd-MMM';  
                        
            cla(obj.axBar);
            cla(obj.axAcum);
            obj.axBar.NextPlot = 'Add';
            obj.axAcum.NextPlot = 'Add';
            for n = 1:N
                ind = Tsel{:, char(obj.indepVar)} == Tgrp{n, char(obj.indepVar)};
                Tgrup = grpstats(selTact(ind, :), 'WeekBeginning', 'sum', 'DataVars', {'duration'}, 'VarNames', {'WeekBeginning', 'GroupCount', 'SumHours'});
                daysPassed = days(Tgrup.WeekBeginning - datetime('01/Jan/2018'));
                plot(obj.axBar, daysPassed, Tgrup.('SumHours'))
                plot(obj.axAcum, daysPassed, cumsum(Tgrup.('SumHours')))
            end
            obj.axBar.NextPlot = 'Replace';
            obj.axAcum.NextPlot = 'Replace';
            legend(obj.axBar, string(Tgrp{:, char(obj.indepVar)}))
            legend(obj.axAcum, string(Tgrp{:, char(obj.indepVar)}))
            
            numXTicks = 20;
            step = max(floor(size(Tgrup, 1)/numXTicks), 1);
            indTick = 1:step:size(Tgrup, 1);
            daysPassed = unique(days(selTact.WeekBeginning - datetime('01/Jan/2018')));
            obj.axBar.XTick = daysPassed(indTick);
            obj.axBar.XTickLabels = cellstr(Tgrup.WeekBeginning(indTick));
            obj.axBar.XTickLabelRotation = 70;
                   
            obj.axAcum.XTick = daysPassed(indTick);
            obj.axAcum.XTickLabels = cellstr(Tgrup.WeekBeginning(indTick));
            obj.axAcum.XTickLabelRotation = 70;
        end
    end
end

