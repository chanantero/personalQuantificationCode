function globalStruct = activityTable2structure( T )

numActivities = size(T, 1);

structs = repmat(struct('Tag', 'activity', 'Attributes', [], 'Data', [], 'Children', []), ...
    numActivities, 1);
    
attributeNames = {'name', 'start', 'duration', 'ending', 'tags', 'description'};
numAttributes = numel(attributeNames);
for ac = 1:numActivities
    attributes = repmat(struct('Name', [], 'Value', []), numAttributes, 1);
    
    at = 1;
    % 'name'
    attributes(at).Name = 'name';
    attributes(at).Value = T{ac, 'name'}{1};
    at = at + 1;
    
    % 'start'
    start = T{ac, 'start'};
    if ~isnat(start)
        attributes(at).Name = 'start';
        attributes(at).Value = datestr(start, 'yyyy/mm/dd HH:MM:SS');
        at = at + 1;
    end
    
    % 'duration'
    dur = T{ac, 'duration'};
    attributes(at).Name = 'duration';
    hms = duration2HMS(dur);
    attributes(at).Value = [num2str(hms(1)), 'h', num2str(hms(2)), 'm', num2str(hms(3)), 's'];   
    at = at + 1;
    
    % 'end'
    ending = T{ac, 'ending'};
    if ~isnat(ending)
        attributes(at).Name = 'ending';
        attributes(at).Value = datestr(ending, 'yyyy/mm/dd HH:MM:SS');
        at = at + 1;
    end
    
    % 'tags'
    tags = T{ac, 'tags'}{1};
    if ~isempty(tags)
        attributes(at).Name = 'tags';
        attributes(at).Value = tags;
        at = at + 1;
    end
    
    attributes(end - (numAttributes - at):end) = [];
    
    structs(ac).Attributes = attributes;
    
    % 'description'
    description = T{ac, 'description'}{1};
    if ~isempty(description)
        structs(ac).Children = struct('Tag', '#text', 'Attributes', [], 'Data', description, 'Children', []);
    end    
    
end

globalStruct = struct('Tag', 'global', 'Attributes', [], 'Data', [], 'Children', structs);

end

