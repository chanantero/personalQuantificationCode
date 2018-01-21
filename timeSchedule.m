classdef timeSchedule < handle
    
    properties
        activities % Structure array. Library of activities.
        % Fields:
        % - name
        % - duration
        
        startingTime
        
        % GUI
        cmap % One color per activity
    end
    
    properties
        schedule % Structure array. Concrete schedule of activities
        % Fields:
        % - name
        % - start
        % - duration
        % - fixedStart
        % - activityType
    end
    
    properties(Access = private)
        % GUI
        f
        ax
        axXLimTime % X axis limits in datetime units
        activeShape
        indActiveSchedAct 
        activityShapes
        refAxPointPos % For motion
        refShapePos % For motion
        userMode = true
        
        editName
        editStart
        editDur
        editEnd
        
        table
        tableSelectedCellIndices
        
        upButton
        downButton
        addButton
        deleteButton
    end
    
    properties(Dependent)
        % Activities
        activityTypes
        typeDurations
        numTypes
        
        % Schedule
        names
        durations
        starts
        fixedStarts
        tags
        numActivities
    end
    
    % Getters and setters
    methods
        
        % Activities
        function activityTypes = get.activityTypes(obj)            
            activityTypes = obj.getActivityNames(1:obj.numTypes);
        end
        
        function typeDurations = get.typeDurations(obj)
            typeDurations = obj.getActivityDurations(1:obj.numTypes);
        end
        
        function numTypes = get.numTypes(obj)
            numTypes = numel(obj.activities);
        end
        
        function set.activities(obj, value)
            obj.activities = value;
            obj.updateColormap();
            obj.table.ColumnFormat(end) = {obj.activityTypes};
        end
        
        % Schedule       
        function names = get.names(obj)            
            names = obj.getScheduleNames(1:obj.numActivities);
        end
        
        function durations = get.durations(obj)
            durations = obj.getScheduleDurations(1:obj.numActivities);
        end
        
        function starts = get.starts(obj)
            starts = obj.getScheduleStarts(1:obj.numActivities);
        end
        
        function numActivities = get.numActivities(obj)
            numActivities = numel(obj.schedule);
        end
        
        function tags = get.tags(obj)
            tags = obj.getScheduleActivityTypes(1:obj.numActivities);
        end
        
        function fixedStarts = get.fixedStarts(obj)
            fixedStarts = obj.getFixedStarts(1:obj.numActivities);
        end
                
    end
    
    methods
        
        function obj = timeSchedule(activities)
            obj.createGUI();
            obj.activities = activities;
            obj.startingTime = datetime(2018, 1, 1, 0, 0, 0);
        end
        
        function createGUI(obj)
            % Figure
            obj.f = figure;
            obj.f.WindowButtonMotionFcn = @(src, callbackdata) obj.windowMotionCallback(src, callbackdata);
            obj.f.WindowButtonUpFcn = @(src, callbackdata) obj.windowButtonUpCallback(src, callbackdata);
            
            % Axes
            obj.ax = axes(obj.f, 'Units', 'normalized', 'OuterPosition', [0 0.5 0.8 0.5]);
            obj.ax.XLim = [0, 24];
            obj.ax.YLim = [0, 1];
            
            % Panel of information
            p = uipanel(obj.f, 'Units', 'Normalized', 'Position', [0.8 0.8 0.2 0.2]);
                % Text boxes
            posEndText = [0 5 50 20];
            posDurText = [0  25 50 20];
            posStartText = [0 45 50 20];
            posNameText = [0 65 50 20];
            uicontrol(p, 'Style', 'Text', 'Units', 'pixels', 'Position', posStartText,...
                'String', 'Start:');
            uicontrol(p, 'Style', 'Text', 'Units', 'pixels', 'Position', posDurText,...
                'String', 'Duration:');
            uicontrol(p, 'Style', 'Text', 'Units', 'pixels', 'Position', posEndText,...
                'String', 'End:');
            uicontrol(p, 'Style', 'Text', 'Units', 'pixels', 'Position', posNameText,...
                'String', 'Name:');
                % Edit boxes
            posEndEdit = [50 5 50 20];
            posDurEdit = [50  25 50 20];
            posStartEdit = [50 45 50 20];
            posNameEdit = [50 65 150 20];
            obj.editStart = uicontrol(p, 'Style', 'Edit', 'Units', 'pixels', 'Position', posStartEdit,...
                'String', '', 'Callback', @(hObject, eventdata, handles) obj.editedInfo('start'));
            obj.editDur = uicontrol(p, 'Style', 'Edit', 'Units', 'pixels', 'Position', posDurEdit,...
                'String', '', 'Callback', @(hObject, eventdata, handles) obj.editedInfo('duration'));
            obj.editEnd = uicontrol(p, 'Style', 'Edit', 'Units', 'pixels', 'Position', posEndEdit,...
                'String', '', 'Callback', @(hObject, eventdata, handles) obj.editedInfo('end'));
            obj.editName = uicontrol(p, 'Style', 'Edit', 'Units', 'pixels', 'Position', posNameEdit,...
                'String', '', 'Callback', @(hObject, eventdata, handles) obj.editedInfo('name'));
            
            % Table
            posTable = [0 0 0.5 0.5];
            columnNames = {'Name', 'Start', 'Duration', 'End', 'FixedStart', 'Act. Type'};
            columnFormat = {'char', 'char', 'numeric', 'char', 'logical', {'Default'}};
            columnEditable = [true, true, true, true, true, true];
            obj.table = uitable(obj.f, 'Units', 'Normalized', 'Position', posTable,...
                'ColumnName', columnNames, 'ColumnFormat', columnFormat,...
                'ColumnEditable', columnEditable, 'CellEditCallback', @(hObject, eventData) obj.tableCellEditCallback(hObject, eventData),...
                'CellSelectionCallback', @(hObj, evntdata) obj.tableCellSelectionCallback(hObj, evntdata));
            obj.table.Data = {};
            
            
            % Up and down buttons
            posUpButton = [0.5 0.40 0.1 0.1];
            posDownButton = [0.5 0.30 0.1 0.1];
            posAddButton = [0.5 0.20 0.1 0.1];
            posDeleteButtion = [0.5 0.1 0.1 0.1];
            obj.upButton = uicontrol(obj.f, 'Style', 'pushbutton', 'Units', 'normalized', 'Position', posUpButton,...
                'String', 'Up', 'Callback', @(hObject, eventdata, handles) obj.moveSchedActCallback('up'));
            obj.downButton = uicontrol(obj.f, 'Style', 'pushbutton', 'Units', 'normalized', 'Position', posDownButton,...
                'String', 'Down', 'Callback', @(hObject, eventdata, handles) obj.moveSchedActCallback('down'));
            obj.addButton = uicontrol(obj.f, 'Style', 'pushbutton', 'Units', 'normalized', 'Position', posAddButton,...
                'String', 'Add', 'Callback', @(hObject, eventdata, handles) obj.addSchedActivity(obj.tableSelectedCellIndices(1)));
            obj.deleteButton = uicontrol(obj.f, 'Style', 'pushbutton', 'Units', 'normalized', 'Position', posDeleteButtion,...
                'String', 'Delete', 'Callback', @(hObject, eventdata, handles) obj.deleteScheduledActivity(obj.tableSelectedCellIndices(1)));
        end
        
        function generateSchedule(obj, activityTypes, fixedStartInd, fixedStarts)
            
            N = numel(activityTypes);
            obj.schedule = repmat(...
                struct(...
                'name', [],...
                'start', NaT,...
                'duration', [],...
                'fixedStart', false,...
                'activityType', []...
                ), N, 1);
            
            obj.setScheduleNames(activityTypes);
            
            notFound = ~ismember(activityTypes, obj.activityTypes);
            activityTypes(notFound) = {'Default'};
            obj.setScheduleActivityTypes(activityTypes);
            
            durs = obj.getActivityDurations(activityTypes);
            obj.setScheduleDurations(durs);
            
            if nargin == 4
                obj.setScheduleStarts(fixedStarts, fixedStartInd);
                obj.setFixedStarts(true(numel(fixedStartInd), 1), fixedStartInd);
            end
            
            obj.orderSchedule();
        end
        
        function orderSchedule(obj)
            durs = obj.durations;
            
            % A fixed start will delay an activity creating not assigned
            % slot of time, or else, it will shorten previous activity
            fixedStart = find(obj.fixedStarts);
            if ~ismember(1, fixedStart)
                fixedStart = [1; fixedStart];
                obj.setScheduleStarts(obj.startingTime, 1);
            end
            fixedStart = [fixedStart; obj.numActivities+1]; 
            
            startsSched = obj.starts;
            
            starts = NaT(obj.numActivities, 1);
            starts(fixedStart(1:end-1)) = startsSched(fixedStart(1:end-1));
            for k = 1:numel(fixedStart)-1
                ind = fixedStart(k):fixedStart(k+1)-1; % Indices to adjust
                startRef = starts(fixedStart(k));
                starts(ind) = [startRef; startRef + cumsum(durs(ind(1:end-1)))];

                if k < numel(fixedStart)-1
                    lastInd = fixedStart(k+1)-1;             
                    lastDur = durs(lastInd);
                    lastStart = starts(lastInd);
                    beyondStart = starts(lastInd + 1);
                    cut = lastStart + lastDur - beyondStart;
                    
                    if cut > 0
                        nextInd = fixedStart(k+1);
                        nextFixedStart = starts(nextInd);
                        
                        overload = starts(ind) + durs(ind) > nextFixedStart;
                        
                        starts(lastInd-(sum(overload)-1):lastInd) = starts(lastInd-(sum(overload)-1):lastInd) - cut;
                    end
                end
                
            end
            
            obj.setScheduleStarts(starts);
        end
        
        function viewSchedule(obj)

            % Prepare figure and axes
            if ~isvalid(obj.f)
                obj.createGUI();
            elseif ~all(isempty(obj.activityShapes)) && all(isvalid(obj.activityShapes))
                obj.userMode = false;
                delete(obj.activityShapes)
                cla(obj.ax);
                obj.userMode = true;
            end
                        
            % Create rectangles. One rectange per activity
            names = obj.names;
            actTypes = obj.tags();
            [~, mapSchedToAct] = ismember(actTypes, obj.activityTypes);
            N = obj.numActivities;
            obj.activityShapes = gobjects(N, 1);
            for n = 1:N
                r = rectangle(obj.ax, 'FaceColor', obj.cmap(mapSchedToAct(n), :), 'Tag', names{n});
                r.ButtonDownFcn = @(src, eventdata) obj.shapeButtonDownCallback(src, eventdata);
                r.DeleteFcn = @(src, eventdata) obj.beingDeletedCallback(src, eventdata);
                obj.activityShapes(n) = r;
            end
            
            % Update GUI
            obj.updateGUI();
        end
        
        function addSchedActivity(obj, index, activityType)
            
            if nargin < 3 || ~ismember(activityType, obj.activityTypes)
                activityType = 'Default';
            end
            
            start = obj.getScheduleStarts(index);
            
            s = struct(...
                'name', 'Sin nombre',...
                'start', start,...
                'duration', hours(1),...
                'fixedStart', false,...
                'activityType', activityType);
                
            newSchedule = [obj.schedule; s];
            newSchedule(index+1:end) = newSchedule(index:obj.numActivities);
            newSchedule(index) = s;
            
            obj.schedule = newSchedule;
            
            obj.viewSchedule();
        end
         
        function deleteScheduledActivity(obj, ind)
            obj.schedule(ind) = [];
            obj.activityShapes(ind) = [];
            obj.updateGUI();
        end
        
        function exportSchedule(obj, filename)
            if nargin == 1
                filename = 'tabledata.txt';
            end
            
            T = cell2table(obj.table.Data(:, [1, 2, 4]), 'VariableNames', {'Name','Start', 'End'});
            writetable(T, filename);
        end
        
        % GUI        
        function windowMotionCallback(obj, src, callbackdata) 
            if ~isempty(obj.activeShape)
%                 fprintf('Current Point: [%g, %g]\n', obj.ax.CurrentPoint(1), obj.ax.CurrentPoint(3));
                currPoint = obj.ax.CurrentPoint(1, [1, 2]);
                relPoint = currPoint - obj.refAxPointPos;
                xPos = obj.refShapePos(1) + relPoint(1);
                obj.activeShape.Position(1) = xPos;
                
                % Update new starting value in schedule structure
                newStart = hours(xPos) + obj.axXLimTime(1);
                obj.setScheduleStarts(newStart, obj.indActiveSchedAct );
                drawnow;
                
                obj.updateGUI(obj.indActiveSchedAct );
            end
        end
        
        function windowButtonUpCallback(obj, src, callbackdata)
            obj.activeShape = [];
%             obj.indActiveSchedAct  = []; % This is commented so you remember
%             that you don't have to put it here. Trust me.
        end
        
        function shapeButtonDownCallback(obj, src, eventdata)
            fprintf('Active Shape: %s\n', src.Tag);
            obj.activeShape = src;
            obj.refAxPointPos = obj.ax.CurrentPoint(1, [1, 2]);
            obj.refShapePos = src.Position(1:2);
            obj.indActiveSchedAct  = find(eq(obj.activeShape, obj.activityShapes));
            obj.updateEdits();
        end
        
        function tableCellEditCallback(obj, hObject, callbackData)
            newData = callbackData.NewData;
            indSched = callbackData.Indices(1);
            fieldNames = {'name', 'start', 'duration', 'end', 'fixedStart', 'activityType'};
            field = fieldNames{callbackData.Indices(2)};
            switch field
                case 'name'
                    obj.setScheduleNames(newData, indSched);
                case 'start'
                    HHMM = strsplit(newData, ':');
                    HH = HHMM{1};
                    MM = HHMM{2};
                    start = obj.getScheduleStarts(indSched);
                    start.Hour = str2double(HH);
                    start.Minute = str2double(MM);
                    obj.setScheduleStarts(start, indSched);
                case 'duration'
                    dur = minutes(newData);
                    if ~isnan(dur)
                        obj.setScheduleDurations(dur, indSched);
                    end
                case 'end'
                    HHMM = strsplit(newData, ':');
                    HH = HHMM{1};
                    MM = HHMM{2};
                    start = obj.getScheduleStarts(indSched);
                    dur = obj.getScheduleDurations(indSched);
                    ending = start + dur;
                    ending.Hour = str2double(HH);
                    ending.Minute = str2double(MM);
                    dur = ending - start;
                    obj.setScheduleDurations(dur, indSched);
                case 'fixedStart'
                    obj.setFixedStarts(newData, indSched);
                case 'activityType'
                    obj.setScheduleActivityTypes(newData, indSched);
            end
            
            obj.updateGUI();
        end
        
        function tableCellSelectionCallback(obj, hObject, callbackData)
            obj.tableSelectedCellIndices = callbackData.Indices;
        end
        
        function moveSchedActCallback(obj, type)           
            if ~isempty(obj.tableSelectedCellIndices)
                indSchedOrig = obj.tableSelectedCellIndices(1);
                switch type
                    case 'up'
                        desp = -1;
                        
                    case 'down'
                        desp = 1;
                end
                indSchedDest = mod(indSchedOrig - 1 + desp, obj.numActivities) + 1;
                obj.schedule([indSchedDest; indSchedOrig]) = obj.schedule([indSchedOrig; indSchedDest]);
                
                obj.activityShapes([indSchedDest; indSchedOrig]) = obj.activityShapes([indSchedOrig; indSchedDest]);
                
                if obj.indActiveSchedAct  == indSchedOrig;
                    obj.indActiveSchedAct  = indSchedDest;
                elseif obj.indActiveSchedAct  == indSchedDest
                    obj.indActiveSchedAct  = indSchedOrig;
                end
                
                obj.updateGUI();
            end
        end
        
        function updateGUI(obj, indices)
            if obj.userMode
                
                if nargin == 2
                    obj.updateEdits();
                    obj.updateTable(indices);
                    obj.setAxesProperties();
                    obj.updateShapes(indices);
                else
                    obj.updateEdits();
                    obj.updateTable();
                    obj.setAxesProperties();
                    obj.updateShapes();
                end
            end
        end
        
        function updateEdits(obj)
            name = obj.getScheduleNames(obj.indActiveSchedAct );
            start = obj.getScheduleStarts(obj.indActiveSchedAct );
            dur = obj.getScheduleDurations(obj.indActiveSchedAct );
            ending = start + dur;
            
            obj.editName.String = name;
            obj.editStart.String = datestr(start, 'HH:MM');
            obj.editDur.String = num2str(minutes(dur));
            obj.editEnd.String = datestr(ending, 'HH:MM');
        end
        
        function updateTable(obj, indices)
            if nargin == 1
                indices = 1:obj.numActivities;
            end
            
            names = obj.getScheduleNames(indices);
            start = obj.getScheduleStarts(indices);
            startCol = cellstr(datestr(start, 'HH:MM'));
            dur = obj.getScheduleDurations(indices);
            durationCol = num2cell(minutes(obj.getScheduleDurations(indices)));
            ends = cellstr(datestr(start + dur, 'HH:MM'));
            types = obj.getScheduleActivityTypes(indices);
            data = [names, startCol, durationCol, ends, num2cell(obj.getFixedStarts(indices)), types];
            
            if nargin == 1
                obj.table.Data = data; % For the first time
            else
                obj.table.Data(indices, :) = data;
            end
        end
        
        function setAxesProperties(obj)
            % Set axes properties
                % Axes X Limits
            axStart = obj.getScheduleStarts(1);
            axEnd = obj.getScheduleStarts(obj.numActivities) + obj.getScheduleDurations(obj.numActivities);
            obj.axXLimTime = [axStart, axEnd];
            obj.ax.XLim = [0, hours(axEnd - axStart)];
                % Axes X Ticks and TickLabels
            axStart_startDay = dateshift(axStart, 'start', 'day');
            firstTick = hours(ceil((axStart - axStart_startDay)/hours(1))) + axStart_startDay;
            lastTick = hours(floor((axEnd - axStart_startDay)/hours(1))) + axStart_startDay;
            ticks = firstTick:hours(1):lastTick;
            obj.ax.XTick = hours(ticks - axStart);
            obj.ax.XTickLabel = datestr(hours(obj.ax.XTick) + axStart, 'HH:MM');
            obj.ax.XTickLabelRotation = 60;
        end
        
        function updateShapes(obj, indices)
            if nargin == 1
                indices = 1:obj.numActivities;
            end            
            
            tStarts = obj.getScheduleStarts(indices);
            axStart = obj.axXLimTime(1);
            xPos = hours(tStarts - axStart);
            xWidth = hours(obj.getScheduleDurations(indices));

            N = numel(indices);
            for n = 1:N
                obj.activityShapes(indices(n)).Position(1) = xPos(n);
                obj.activityShapes(indices(n)).Position(3) = xWidth(n);
            end
        end
        
        function updateShapeColors(obj)
            [~, mapSchedToAct] = ismember(obj.tags(), obj.activityTypes);
            N = obj.numActivities;
            for n = 1:N
                obj.activityShapes(n).FaceColor = obj.cmap(mapSchedToAct(n), :);
            end
        end
        
        function editedInfo(obj, editType)
            switch editType
                case 'name'
                    name = obj.editName.String;
                    obj.setScheduleNames(name, obj.indActiveSchedAct );
                case 'start'
                    HHMM = strsplit(obj.editStart.String, ':');
                    HH = HHMM{1};
                    MM = HHMM{2};
                    start = obj.getScheduleStarts(obj.indActiveSchedAct );
                    start.Hour = str2double(HH);
                    start.Minute = str2double(MM);
                    obj.setScheduleStarts(start, obj.indActiveSchedAct );
                case 'duration'
                    dur = duration([0, str2double(obj.editDur.String), 0]);
                    if ~isnan(dur)
                        obj.setScheduleDurations(dur, obj.indActiveSchedAct );
                    end
                case 'end'
                    HHMM = strsplit(obj.editEnd.String, ':');
                    HH = HHMM{1};
                    MM = HHMM{2};
                    start = obj.getScheduleStarts(obj.indActiveSchedAct );
                    dur = obj.getScheduleDurations(obj.indActiveSchedAct );
                    ending = start + dur;
                    ending.Hour = str2double(HH);
                    ending.Minute = str2double(MM);
                    dur = ending - start;
                    obj.setScheduleDurations(dur, obj.indActiveSchedAct );
            end
            
            obj.updateGUI(obj.indActiveSchedAct );
        end
        
        function beingDeletedCallback(obj, hObj, eventData)
            
            if obj.userMode
            N = numel(obj.activityShapes);
            flag = false(N, 1);
            for k = 1:N
                flag(k) = isequal(hObj, obj.activityShapes(k));
            end
            ind = find(flag);
            obj.deleteScheduledActivity(ind);
            end
        end
        
        function updateColormap(obj)
            cm = colormap('jet');
            obj.cmap = cm(round(linspace(1, size(cm, 1), obj.numTypes)), :);
        end
        
        % Not official getters and setters
        
        function activityTypes = getActivityTypes(obj, indices)
            activityTypes = {obj.activities(indices).name};
        end
        
        function typeDurations = getTypeDurations(obj, indices)
            
            if iscellstr(indices) || ischar(indices)
                if ischar(indices)
                    indices = {indices};
                end
                names = indices;
                [~, indices] = ismember(names, obj.activityTypes);
            end
            
            typeDurations = [obj.activities(indices).duration]';
            
        end

        function names = getNames(obj, indices)
            
            names = {obj.schedule(indices).name}';
        end
        
        function durations = getScheduleDurations(obj, indices)
            
            if iscellstr(indices) || ischar(indices)
                if ischar(indices)
                    indices = {indices};
                end
                names = indices;
                indices = ismember(obj.names, names);
            end
            
            durations = [obj.schedule(indices).duration]';
            
        end
        
        function starts = getScheduleStarts(obj, indices)
            
            if iscellstr(indices) || ischar(indices)
                if ischar(indices)
                    indices = {indices};
                end
                names = indices;
                indices = ismember(obj.names, names);
            end
            
            starts = [obj.schedule(indices).start]';
            
        end
        
        function fixedStarts = getFixedStarts(obj, indices)
            fixedStarts = [obj.schedule(indices).fixedStart]';
        end
        
        function activityTypes = getScheduleActivityTypes(obj, indices)
            activityTypes = {obj.schedule(indices).activityType}';
        end
                
        function setScheduleNames(obj, names, indices)
            if nargin == 2
                indices = 1:min(obj.numActivities, numel(names));
            end
            
            if ~iscellstr(names)
                names = {names};
            end
            
            N = numel(indices);
            for n = 1:N
                obj.schedule(indices(n)).name = names{n};
            end
        end
        
        function setScheduleDurations(obj, durations, indices)
            if nargin == 2
                indices = 1:min(obj.numActivities, numel(durations));
            end
            
            N = numel(indices);
            for n = 1:N
                obj.schedule(indices(n)).duration = durations(n);
            end
        end
        
        function setScheduleActivityTypes(obj, activityTypes, indices)
            if nargin == 2
                indices = 1:min(obj.numActivities, numel(activityTypes));
            end
            
            if ~iscellstr(activityTypes)
                activityTypes = {activityTypes};
            end
            
            N = numel(indices);
            for n = 1:N
                obj.schedule(indices(n)).activityType = activityTypes{n};
            end
        end
        
        function setScheduleStarts(obj, startingTimes, indices)
            if nargin == 2
                indices = 1:min(obj.numActivities, numel(startingTimes));
            end
            
            N = numel(indices);
            for n = 1:N
                obj.schedule(indices(n)).start = startingTimes(n);
            end
        end
        
        function setFixedStarts(obj, flags, indices)
            if nargin == 2
                indices = 1:min(obj.numActivities, numel(flags));
            end
            
            N = numel(indices);
            for n = 1:N
                obj.schedule(indices(n)).fixedStart = flags(n);
            end
        end
    end
    
end

