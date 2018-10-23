function [Txml, extScheme] = activityTable2XMLtable(Tact, Tattrib, varargin)
% Tact is a table. Each row is an activity. Each column is an attribute of
% the activity.
% Tattrib is a table with 6 variables/columns: 
% [name, type, use, default, kind, enumeration].

p = inputParser;
addParameter(p, 'includeDefaults', false)
parse(p, varargin{:})
includeDefaults = p.Results.includeDefaults;

% Transform all columns of Tact to string format according to the type.
variableNames = Tact.Properties.VariableNames;
[flag, ind] = ismember(variableNames, Tattrib.name);
ind = ind(flag);
numPresentAttr = length(ind);
for a = 1:numPresentAttr
    kind = Tattrib.kind(ind(a));
    type = Tattrib.type(ind(a));
    name = char(Tattrib.name(ind(a)));
    switch kind
        case 'native'
            switch type
                case 'xs:string'
                    % Do nothing
                case 'xs:dateTime'
                    Tact.(name).Format = 'uuuu-MM-ddTHH:mm:ss';
                    Tact.(name) = string(Tact.(name));
                case 'xs:duration'
                    warning('activityTable2XMLtable:incomplete', 'Must complete this part of the code') 
                otherwise
                    warning('activityTable2XMLtable:unknownType', 'I don''t know')
            end
        case 'external'
            switch type
                case 'duration'
                    Tact.(name).Format = 'hh:mm:ss';
                    Tact.(name) = string(Tact.(name));
                case 'datetime'
                    Tact.(name).Format = 'uuuu/MM/dd HH:mm:ss';
                    Tact.(name) = string(Tact.(name));
            end
        case 'enumeration'
            categs = cellstr(Tattrib.enumeration{ind(a)});
            aux = string(categorical(Tact.(name), categs, categs));
            if iscategorical(Tact.(name))
                emptyFlag = isundefined(Tact.(name));
            else
                emptyFlag = isempty(Tact.(name));
            end         
            aux(emptyFlag) = "";
            Tact.(name) = aux;
        otherwise
            warning('activityTable2XMLtable:unknownKind', 'I don''t know')
    end
end

% Agrup each row of the table in a structure to create the attributes
% column
numRows = size(Tact, 1);
sBase = struct('Name', '', 'Value', '');
recognizedAttr = variableNames(flag);
ss = cell(numRows, 1);
for r = 1:numRows
    notEmpty = Tact{r, recognizedAttr} ~= "";
    if includeDefaults
        notDefault = Tact{r, recognizedAttr} ~= (Tattrib.default(ind))';
        flag = notEmpty & notDefault;
    else
        flag = notEmpty;
    end
    s = repmat(sBase, [1, nnz(flag)]);
    [s.Name] = recognizedAttr{flag};
    aux = Tact{r, recognizedAttr(flag)};
    [s.Value] = aux{:};
    ss{r} = s;
end

Txml = table(repmat("activity", [numRows, 1]), ss, cell(numRows, 1), 'VariableNames', {'Tag_Level_1', 'Attributes_Level_1', 'Data_Level_1'});
extScheme = (1:numRows)';

% Find the description attribute and transform it to a text child
indDesc = strcmp('description', variableNames);
if any(indDesc)
    notEmpty = Tact.('description') ~= "";
    tagData = strings(numRows, 1);
    tagData(notEmpty) = "#text";
    Tdesc = table(tagData, cell(numRows, 1), Tact.('description'), 'VariableNames', {'Tag_Level_2', 'Attributes_Level_2', 'Data_Level_2'});
    Txml = [Txml, Tdesc];
    aux = notEmpty;
    aux(notEmpty) = 1:nnz(notEmpty); 
    extScheme = [(1:numRows)', aux];
end

end
