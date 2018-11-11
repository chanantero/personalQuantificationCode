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
        schedule     
        % Table
        % Variables:
        %   Normal variables
        %       - Name
        %       - Start
        %       - Duration
        %       - Tags
        %   Planning variables
        %       - FixedStart
        %       - FixedDuration
        %       - FixedEnd
        
    end
    
    properties(Constant)
        scheduleVariableNames = {'Name', 'Start', 'Duration', 'Tags', 'FixedStart', 'FixedDuration', 'FixedEnd'};
    end
    
    properties(Access = public)
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
        
        tableGUI
        tableGUISelectedCellIndices
        
        upButton
        downButton
        addButton
        deleteButton
    end
    
    properties(Dependent)
        % Activities
        types
        typeDurations
        numTypes
        
        % Schedule
        names
        durations
        starts
        ends
        fixedStarts
        fixedDurations
        fixedEnds
        tags
        activityTypes
        numActivities
    end
    
    % Getters and setters
    methods
        
        % Activities
        function types = get.types(obj)            
            types = obj.getType(1:obj.numTypes);
        end
        
        function typeDurations = get.typeDurations(obj)
            typeDurations = obj.getTypeDuration(1:obj.numTypes);
        end
        
        function numTypes = get.numTypes(obj)
            numTypes = size(obj.activities, 1);
        end
        
        function set.activities(obj, value)
            obj.activities = value;
            obj.updateColormap();
        end
        
        % Schedule       
        function names = get.names(obj)            
            names = obj.getName(1:obj.numActivities);
        end
        
        function durations = get.durations(obj)
            durations = obj.getDuration(1:obj.numActivities);
        end
        
        function starts = get.starts(obj)
            starts = obj.getStart(1:obj.numActivities);
        end
        
        function numActivities = get.numActivities(obj)
            numActivities = size(obj.schedule, 1);
        end
        
        function tags = get.tags(obj)
            tags = obj.getTags(1:obj.numActivities);
        end
        
        function activityTypes = get.activityTypes(obj)
            activityTypes = getActivityType(obj, 1:obj.numActivities);
        end
        
        function fixedStarts = get.fixedStarts(obj)
            fixedStarts = obj.getFixedStart(1:obj.numActivities);
        end
                
    end
    
    methods
        
        function obj = timeSchedule(activities)
            obj.createGUI();
            if nargin == 0
                activities = timeSchedule.getDefaultActivityTable();
            end
            obj.activities = activities;
            obj.startingTime = datetime(2018, 1, 1, 0, 0, 0);
        end
        
        function createGUI(obj)
            % Figure
            obj.f = figure;
            obj.f.WindowButtonMotionFcn = @(src, callbackdata) obj.windowMotionCallback(src, callbackdata);
            obj.f.WindowButtonUpFcn = @(src, callbackdata) obj.windowButtonUpCallback(src, callbackdata);
            obj.f.DeleteFcn = @(src, callbackdata) obj.deleteFigure();
            
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
            columnEditableGUI = [true, true, true, true, true, true];
            obj.tableGUI = uitable(obj.f, 'Units', 'Normalized', 'Position', posTable,...
                'ColumnName', columnNames, 'ColumnFormat', columnFormat,...
                'ColumnEditable', columnEditableGUI, 'CellEditCallback', @(hObject, eventData) obj.tableGUICellEditCallback(hObject, eventData),...
                'CellSelectionCallback', @(hObj, evntdata) obj.tableGUICellSelectionCallback(hObj, evntdata));
            obj.tableGUI.Data = {};
            
            
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
                'String', 'Add', 'Callback', @(hObject, eventdata, handles) obj.addSchedActivity(obj.tableGUISelectedCellIndices(:, 1)));
            obj.deleteButton = uicontrol(obj.f, 'Style', 'pushbutton', 'Units', 'normalized', 'Position', posDeleteButtion,...
                'String', 'Delete', 'Callback', @(hObject, eventdata, handles) obj.deleteScheduledActivity(obj.tableGUISelectedCellIndices(:, 1)));
        end
        
        function generateSchedule(obj, activityTypes, fixedStartInd, fixedStarts)
            
            N = numel(activityTypes);
                        
            obj.schedule = table(cell(N, 1), NaT(N, 1), minutes(zeros(N, 1)), cell(N, 1), ...
                false(N, 1), false(N, 1), false(N, 1), 'VariableNames', obj.scheduleVariableNames);
            obj.schedule.Start.Format = 'dd-MM hh:mm';
            
            obj.setName(activityTypes);
            
            notFound = ~ismember(activityTypes, obj.types);
            activityTypes(notFound) = {'Default'};
            obj.setActivityType(activityTypes);
            
            durs = obj.getTypeDuration(activityTypes);
            obj.setDuration(durs);
            
            if nargin == 4
                obj.setStart(fixedStarts, fixedStartInd);
                obj.setFixedStart(true(numel(fixedStartInd), 1), fixedStartInd);
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
                obj.setStart(obj.startingTime, 1);
            end
            fixedStart = [fixedStart; obj.numActivities+1]; 
            
            startsSched = obj.starts;
            
            start = NaT(obj.numActivities, 1);
            start(fixedStart(1:end-1)) = startsSched(fixedStart(1:end-1));
            for k = 1:numel(fixedStart)-1
                ind = fixedStart(k):fixedStart(k+1)-1; % Indices to adjust
                startRef = start(fixedStart(k));
                start(ind) = [startRef; startRef + cumsum(durs(ind(1:end-1)))];

                if k < numel(fixedStart)-1
                    lastInd = fixedStart(k+1)-1;             
                    lastDur = durs(lastInd);
                    lastStart = start(lastInd);
                    beyondStart = start(lastInd + 1);
                    cut = lastStart + lastDur - beyondStart;
                    
                    if cut > 0
                        nextInd = fixedStart(k+1);
                        nextFixedStart = start(nextInd);
                        
                        overload = start(ind) + durs(ind) > nextFixedStart;
                        
                        start(lastInd-(sum(overload)-1):lastInd) = start(lastInd-(sum(overload)-1):lastInd) - cut;
                    end
                end
                
            end
            
            obj.setStart(start);
        end
        
        function viewSchedule(obj)

            % Prepare figure and axes
            if ~isvalid(obj.f)
                % If there is no figure
                obj.createGUI();
            elseif ~isempty(obj.activityShapes) && any(isvalid(obj.activityShapes))
                % If there are activityShapes that are still valid
                % (drawed), delete them.
                obj.userMode = false;
                delete(obj.activityShapes)
                cla(obj.ax);
                obj.userMode = true;
            end
                        
            % Create rectangles. One rectange per activity
            names_ = obj.names;
            [~, mapSchedToAct] = ismember(obj.activityTypes, obj.types);
            N = obj.numActivities;
            obj.activityShapes = gobjects(N, 1);
            for n = 1:N
                r = rectangle(obj.ax, 'FaceColor', obj.activities.Color{mapSchedToAct(n)}/255, 'Tag', names_{n});
                r.ButtonDownFcn = @(src, eventdata) obj.shapeButtonDownCallback(src, eventdata);
                r.DeleteFcn = @(src, eventdata) obj.beingDeletedCallback(src, eventdata);
                obj.activityShapes(n) = r;
            end
            
            % Update GUI
            obj.updateGUI();
        end
        
        function addSchedActivity(obj, index, activityType)
            
            if nargin < 3 || ~ismember(activityType, obj.tableGUI)
                activityType = 'Default';
            end
            
            start = obj.getStart(index);
            if isempty(start)
                start = obj.startingTime;
            end
            
            newRow = table({'Sin nombre'}, start, hours(1), {{activityType}}, false, false, false, 'VariableNames', obj.scheduleVariableNames);
                            
            obj.schedule = [obj.schedule(1:index-1, :); newRow; obj.schedule(index:end, :)];
                        
            obj.viewSchedule();
        end
         
        function deleteScheduledActivity(obj, ind)
            obj.schedule(ind, :) = [];
            obj.userMode = false;
            delete(obj.activityShapes(ind));
            obj.userMode = true;
            obj.activityShapes(ind) = [];
            obj.updateGUI();
        end
        
        function exportSchedule(obj, filename)
            if nargin == 1
                filename = 'tableGUIdata.txt';
            end
            
            T = cell2tableGUI(obj.tableGUI.Data(:, [1, 2, 4]), 'VariableNames', {'Name','Start', 'End'});
            writetableGUI(T, filename);
        end
        
        % GUI        
        function deleteFigure(obj)
            obj.userMode = false;
        end
        
        function windowMotionCallback(obj, ~, ~) 
            if ~isempty(obj.activeShape)
%                 fprintf('Current Point: [%g, %g]\n', obj.ax.CurrentPoint(1), obj.ax.CurrentPoint(3));
                currPoint = obj.ax.CurrentPoint(1, [1, 2]);
                relPoint = currPoint - obj.refAxPointPos;
                xPos = obj.refShapePos(1) + relPoint(1);
                obj.activeShape.Position(1) = xPos;
                
                % Update new starting value in schedule structure
                newStart = hours(xPos) + obj.axXLimTime(1);
                obj.setStart(newStart, obj.indActiveSchedAct );
                drawnow;
                
                obj.updateGUI(obj.indActiveSchedAct );
            end
        end
        
        function windowButtonUpCallback(obj, ~, ~)
            obj.activeShape = [];
%             obj.indActiveSchedAct  = []; % This is commented so you remember
%             that you don't have to put it here. Trust me.
        end
        
        function shapeButtonDownCallback(obj, src, ~)
            fprintf('Active Shape: %s\n', src.Tag);
            obj.activeShape = src;
            obj.refAxPointPos = obj.ax.CurrentPoint(1, [1, 2]);
            obj.refShapePos = src.Position(1:2);
            obj.indActiveSchedAct  = find(eq(obj.activeShape, obj.activityShapes));
            obj.updateEdits();
        end
        
        function tableGUICellEditCallback(obj, ~, callbackData)
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
                    start = obj.getStart(indSched);
                    start.Hour = str2double(HH);
                    start.Minute = str2double(MM);
                    obj.setStart(start, indSched);
                case 'duration'
                    dur = minutes(newData);
                    if ~isnan(dur)
                        obj.setScheduleDurations(dur, indSched);
                    end
                case 'end'
                    HHMM = strsplit(newData, ':');
                    HH = HHMM{1};
                    MM = HHMM{2};
                    start = obj.getStart(indSched);
                    dur = obj.getDuration(indSched);
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
        
        function tableGUICellSelectionCallback(obj, ~, callbackData)
            obj.tableGUISelectedCellIndices = callbackData.Indices;
        end
        
        function moveSchedActCallback(obj, type)           
            if ~isempty(obj.tableGUISelectedCellIndices)
                indSchedOrig = obj.tableGUISelectedCellIndices(1);
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
            name = obj.getName(obj.indActiveSchedAct );
            start = obj.getStart(obj.indActiveSchedAct );
            dur = obj.getDuration(obj.indActiveSchedAct );
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
            
            names_ = obj.getName(indices);
            start = obj.getStart(indices);
            startCol = cellstr(datestr(start, 'HH:MM'));
            dur = obj.getDuration(indices);
            durationCol = num2cell(minutes(obj.getDuration(indices)));
            ends_ = cellstr(datestr(start + dur, 'HH:MM'));
            types_ = obj.getActivityType(indices);
            data = [names_, startCol, durationCol, ends_, num2cell(obj.getFixedStart(indices)), types_];
            
            if nargin == 1
                obj.tableGUI.Data = cellstr(data); % For the first time
            else
                obj.tableGUI.Data(indices, :) = cellstr(data);
            end
        end
        
        function setAxesProperties(obj)
            % Set axes properties
                % Axes X Limits
            axStart = min(obj.getStart(1:obj.numActivities));
            if isempty(axStart)
                axStart = obj.startingTime;
            end
            axEnd = max(obj.getStart(1:obj.numActivities) + obj.getDuration(1:obj.numActivities));
            if isempty(axEnd)
                axEnd = axStart + hours(1);
            end
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
            
            tStarts = obj.getStart(indices);
            axStart = obj.axXLimTime(1);
            xPos = hours(tStarts - axStart);
            xWidth = hours(obj.getDuration(indices));

            N = numel(indices);
            for n = 1:N
                obj.activityShapes(indices(n)).Position(1) = xPos(n);
                obj.activityShapes(indices(n)).Position(3) = xWidth(n);
            end
        end
        
        function updateShapeColors(obj)
            [~, mapSchedToAct] = ismember(obj.tags(), obj.tableGUI);
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
                    start = obj.getStart(obj.indActiveSchedAct );
                    start.Hour = str2double(HH);
                    start.Minute = str2double(MM);
                    obj.setStart(start, obj.indActiveSchedAct );
                case 'duration'
                    dur = duration([0, str2double(obj.editDur.String), 0]);
                    if ~isnan(dur)
                        obj.setScheduleDurations(dur, obj.indActiveSchedAct );
                    end
                case 'end'
                    HHMM = strsplit(obj.editEnd.String, ':');
                    HH = HHMM{1};
                    MM = HHMM{2};
                    start = obj.getStart(obj.indActiveSchedAct );
                    dur = obj.getDuration(obj.indActiveSchedAct );
                    ending = start + dur;
                    ending.Hour = str2double(HH);
                    ending.Minute = str2double(MM);
                    dur = ending - start;
                    obj.setScheduleDurations(dur, obj.indActiveSchedAct );
            end
            
            obj.updateGUI(obj.indActiveSchedAct );
        end
        
        function beingDeletedCallback(obj, hObj, ~)
            
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
        
        function indices = name2ind(obj, actNames)
            if ischar(actNames )
                actNames = {actNames};
            end
            indices = find(ismember(obj.names, actNames));
        end
        
            % Type Getters
        function types = getType(obj, indices)
            types = obj.activities.Type(indices);
        end
        
        function typeDurations = getTypeDuration(obj, indices)
            
            if iscellstr(indices) || ischar(indices)
                if ischar(indices)
                    indices = {indices};
                end
                typeNames = indices;
                [~, indices] = ismember(typeNames, obj.types);
            end
            
            typeDurations = obj.activities.Duration(indices);
            
        end
            
            % Activity Getters
        function names = getName(obj, indices)
            % Con estructura
            % names = {obj.schedule(indices).name}';
            
            % Con tabla
            names = obj.schedule.Name(indices);
        end
                   
        function starts = getStart(obj, indices)
            
            if iscellstr(indices) || ischar(indices)
                indices = name2ind(obj, indices);
            end
            
            starts = obj.getValues('Start', indices);
            
        end
        
        function durations = getDuration(obj, indices)
            
            if iscellstr(indices) || ischar(indices)
                indices = name2ind(obj, indices);
            end
            
            durations = obj.getValues('Duration', indices);
            
        end
        
        function ends = getEnd(obj, indices)
            if iscellstr(indices) || ischar(indices)
                indices = name2ind(obj, indices);
            end
            
            startsVal = obj.getStart(indices);
            durs = obj.getDurations(indices);
            ends = startsVal + durs;
        end
        
        function fixedStarts = getFixedStart(obj, indices)
            
            if iscellstr(indices) || ischar(indices)
                indices = name2ind(obj, indices);
            end
            
            fixedStarts = obj.getValues('FixedStart', indices);
            
        end
        
        function fixedDurations = getFixedDuration(obj, indices)
            
            if iscellstr(indices) || ischar(indices)
                indices = name2ind(obj, indices);
            end
            
            fixedDurations = obj.getValues('FixedDuration', indices);
            
        end
        
        function fixedEnds = getFixedEnd(obj, indices)
            
            if iscellstr(indices) || ischar(indices)
                indices = name2ind(obj, indices);
            end
            
            fixedEnds = obj.getValues('FixedEnd', indices);
            
        end
        
        function types = getActivityType(obj, indices)
            
            tagsCol = obj.getTags(indices);
            
            % Select the first tag
            N = numel(indices);
            types = cell(N, 1);
            for n = 1:N
                curTags = tagsCol{n};
                
                if ~isempty(curTags)
                    if ischar(curTags)
                        actType = curTags;
                    elseif iscellstr(curTags)
                        actType = curTags{1};
                    end
                    if ~ismember(actType, obj.types)
                        actType = 'Default';
                    end
                    types{n} = actType;
                else
                    types{n} = 'Default';
                end
            end
            
        end
        
        function tags = getTags(obj, indices)
            
            if iscellstr(indices) || ischar(indices)
                indices = name2ind(obj, indices);
            end
            
            tags = obj.getValues('Tags', indices);
        end
        
        function values = getValues(obj, variableName, indices)
            if nargin < 3
%                 indices = 1:min(obj.numActivities, numel(indices));
                indices = 1:obj.numActivities;
            end
            
            if all(indices > 0) && all(indices <= obj.numActivities)
                values = obj.schedule.(variableName)(indices);
            else
                values = [];
            end
            
            if isempty(values)
                switch variableName
                    case 'Name'
                        values = cell.empty;
                    case 'Start'
                        values = datetime.empty;
                    case 'Duration'
                        values = duration.empty;
                    case 'Tags'
                        values = cell.empty;
                    case 'FixedStart'
                        values = logical.empty;
                    case 'FixedDuration'
                        values = logical.empty;
                    case 'FixedEnd'
                        values = logical.empty;
                end
            end
            
        end
                
            % Activity Setters
        function setName(obj, names, indices)
            if nargin == 2
                indices = 1:min(obj.numActivities, numel(names));
            end
            
            if ~iscellstr(names)
                names = {names};
            end
            
            obj.setValues('Name', names, indices);
            
        end
        
        function setStart(obj, starts, indices)
            if nargin == 2
                indices = 1:min(obj.numActivities, numel(starts));
            end
            
            obj.setValues('Start', starts, indices);
        end
        
        function setDuration(obj, durations, indices)
            if nargin == 2
                indices = 1:min(obj.numActivities, numel(durations));
            end
            
            obj.setValues('Duration', durations, indices);
            
        end
        
        function setEnd(obj, ends, indices)
            if nargin == 2
                indices = 1:min(obj.numActivities, numel(ends));
            end
            
            obj.setValues('End', ends, indices);
        end
        
        function setActivityType(obj, activityTypes, indices)
            if nargin == 2
                indices = 1:min(obj.numActivities, numel(activityTypes));
            end
            
            N = numel(indices);
            firstPos = num2cell(ones(N, 1));
            activityTypes = num2cell(activityTypes);
            
            obj.addTags(activityTypes, firstPos, indices);
        end
        
        function setTags(obj, tags, indices)
            if nargin == 2
                indices = 1:min(obj.numActivities, numel(tags));
            end
            
            if ~iscellstr(tags)
                tags = {tags};
            end
            
            obj.setValues('Tags', tags, indices);         
        end
        
        function addTags(obj, tags, pos, indices)
            % Add the tags to the existing tags, in the indicated position
            % N. Number of indices
            % - tags. Cell array with N elements. The i-th element contains a
            % cell string array, with as many elements as new tags to add
            % to the i-th activity.
            
            if nargin == 2
                indices = 1:min(obj.numActivities, numel(tags));
            end
            
            N = numel(indices);
            for n = 1:N
                existingTags = obj.getTags(indices(n)); existingTags = existingTags{1};
                tagsToAdd = tags{n};
                posToAdd = pos{n};
                
                numExistingTags = numel(existingTags);
                numTagsToAdd = numel(tagsToAdd);
                numNewTags = numExistingTags + numTagsToAdd;
                
                newTags = cell(numNewTags, 1);
                posLogical = false(numNewTags, 1);
                posLogical(posToAdd) = true;
                newTags(~posLogical) = existingTags;
                newTags(posLogical) = tagsToAdd;
                
                obj.setTags(newTags, indices(n));
            end
            
        end
        
        function setFixedStart(obj, flags, indices)
            if nargin == 2
                indices = 1:min(obj.numActivities, numel(flags));
            end
            
            obj.setValues('FixedStart', flags, indices);
        end
        
        function setFixedDuration(obj, flags, indices)
            if nargin == 2
                indices = 1:min(obj.numActivities, numel(flags));
            end
            
            obj.setValues('FixedDuration', flags, indices);
        end
        
        function setFixedEnd(obj, flags, indices)
            if nargin == 2
                indices = 1:min(obj.numActivities, numel(flags));
            end
            
            obj.setValues('FixedEnd', flags, indices);
        end
        
        function setValues(obj, variableName, values, indices)
            
            if nargin < 4
                indices = 1:min(obj.numActivities, numel(values));
            end
            
            switch variableName
                case 'End'
                    % Set duration depending on the ending time
                    obj.schedule.('Duration')(indices) = obj.getDuration(indices) - obj.getStart(indices);
                otherwise
                    obj.schedule.(variableName)(indices) = values;
            end
        end
    end
    
    methods(Static)
        function activityTable = getDefaultActivityTable()
            
            categories = string(enumeration(categoryColor.undetermined));
            numCateg = length(categories);
            
            data = cell(numCateg, 2);
            for c = 1:numCateg
                data{c, 1} = [1 0 0];
                data{c, 2} = [categoryColor(categories(c)).R categoryColor(categories(c)).G categoryColor(categories(c)).B];
            end
                              
            data = mat2cell(data, size(data, 1), ones(1, 2));
            activityTable = table(categories, data{:}, 'VariableNames', {'Type', 'Duration', 'Color'});
                        
%             % Old, before 28/10/2015
%             hex2norm_RGB = @(s) hex2dec({s(1:2), s(3:4), s(5:6)})'/255;
%             colorRutines = hex2norm_RGB('4EC500');
%             colorMeals = hex2norm_RGB('F6E000');
            
%             data = {'Dormir', [9 0 0], [0 0 0];
%                 'Rutina matinal', [1 20 0], colorRutines;
%                 'Rutina vespertina', [0 80 0], colorRutines;
%                 'Rutina nocturna', [0 30 0], colorRutines;
%                 'Desayunar', [0 40 0], colorMeals
%                 'Comer', [1 30 0], colorMeals;
%                 'Cenar', [1 30 0], colorMeals;
%                 'Bloque productivo', [3 0 0], hex2norm_RGB('F300F3');
%                 'Default', [1 0 0], hex2norm_RGB('555555');
%                 'Trayecto', [0 30 0], hex2norm_RGB('15B4E1');
%                 'Social', [1 0 0], hex2norm_RGB('B0F91E')
%                 'No intencion', [1 0 0], hex2norm_RGB('32244F');
%                 'Ocio', [1 0 0], hex2norm_RGB('98CD14')
%                 };
            
%             data = mat2cell(data, size(data, 1), ones(1, 3));
%             activityTable = table(data{:}, 'VariableNames', {'Type', 'Duration', 'Color'});
%             
        end
    end
    
end

