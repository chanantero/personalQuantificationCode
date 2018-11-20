function Tact = toggl2activityTable(togglFileName, Tattrib, varargin)

p = inputParser;
addParameter(p, 'unset2default', false)
parse(p, varargin{:})
unset2default = p.Results.unset2default;

Ttoggl = readtable(togglFileName, 'ReadVariableNames', true, 'TextType', 'string', 'Delimiter', ',');
numEntries = size(Ttoggl, 1);

numAttributes = size(Tattrib, 1);

aux = repmat({strings(numEntries, 1)}, [1 numAttributes]);
Tact = table(aux{:}, 'VariableNames', cellstr(Tattrib.name));

for a = 1:numAttributes
    attribName = Tattrib.name(a);
    attribType = Tattrib.type(a);
    
    if Tattrib.kind(a) == "native"      
        switch attribType
            case 'xs:string'
                % Do nothing
            case 'xs:dateTime'
                Tact.(char(attribName)) = NaT(numEntries, 1);
            case 'xs:duration'
        end
    else
        if Tattrib.kind(a) == "enumeration"
            categ = cellstr(Tattrib.enumeration{a});
            if unset2default
                Tact.(char(attribName)) = repmat(categorical(Tattrib.default(a), categ, categ), [numEntries, 1]);
            else
                Tact.(char(attribName)) = repmat(categorical("", categ, categ), [numEntries, 1]);
            end
        else
            if Tattrib.kind(a) ~= "external"
                warning('activityXML2table:irregularity', 'This data type should be declared as external')
            end
            switch attribType
                case 'duration'
                    Tact.(char(attribName)) = str2duration(Tact.(char(attribName)));
                case 'datetime'
                    Tact.(char(attribName)) = datetime(Tact.(char(attribName)), 'InputFormat', 'yyyy/MM/dd HH:mm:ss');
                otherwise
                    warning('activityXML2table:unkownDataType', 'I don''t know what to do with this')
            end
        end
    end
end

categoryValues = cellstr(Tattrib.enumeration{Tattrib.name == "category"});
Tact.('category') = categorical(Ttoggl.('Project'), categoryValues, categoryValues);
Tact.('name') = Ttoggl.('Description');
Tact.('duration') = Ttoggl.('Duration');

start = Ttoggl.StartDate + Ttoggl.StartTime;
start.Format = 'uuuu/MM/dd HH:mm:ss';
Tact.('start') = start;
ending = Ttoggl.EndDate + Ttoggl.EndTime;
ending.Format = 'uuuu/MM/dd HH:mm:ss';
Tact.('ending') = ending;

TattribSel = Tattrib(Tattrib.kind == "enumeration", :);
for k = 1:size(TattribSel, 1)
    TattribSel.('enumeration'){k} = cellstr(TattribSel.('enumeration'){k});
end

for e = 1:numEntries
    tags = strsplit(Ttoggl.Tags(e), ", ");
    [flag, ind] = ismember(tags, TattribSel.name);
    indAttr = ind(flag);
    numFoundAttribs = nnz(flag);
    for a = 1:numFoundAttribs
        Tact{e, char(TattribSel.name(indAttr(a)))} = categorical(TattribSel.enumeration{indAttr(a)}(1), TattribSel.enumeration{indAttr(a)}, TattribSel.enumeration{indAttr(a)});
    end
    
    % Extra non-recognized tags go to the tags variable, if it exists. If
    % it doesn't, this tags in toggl get lost
    tagsCandidates = ["tags", "Tags", "Tag", "tag"];
    flagTags = ismember(tagsCandidates, Tattrib.name);
    if any(flagTags)
        tagsName = char(tagsCandidates(flagTags));
        Tact{e, tagsName} = strjoin(tags(~flag),";");
    end
end

end