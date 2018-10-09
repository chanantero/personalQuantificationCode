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
% - people. People with whom the activity was done. String array.
% - category. Type/class/kind of activity. CategoryEnum or String.
% - tags. The use of this property is not clear. String array.
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
    end
    
    methods
        function obj = ActivityHandler(activityTable)
            obj.Tact = activityTable;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

