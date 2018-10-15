function Tact = activityXML2tablePrueba(fileName)

% Find and read XML schema definition file
xsdFile = getXSDfile(fileName);
xsdStruct = xml2structure(xsdFile);

% Find allowed activity attributes
% 1) Find node of type xs:element whose attribute "name" is "activity
xsdTable = XMLstructure2XMLtable(xsdStruct.Children, 'maxLevel', 1);
TattribElem = unfoldAttributesInTable(xsdTable, 'Attributes_Level_1', 'name');
indActiv = ismember(TattribElem.name, 'activity');
% 2) Find nodes grandchildren (not children because of the structure of the XSD syntax)
% of the activity element node that have type xs:attribute
activTable = XMLstructure2XMLtable(xsdStruct.Children(indActiv));
indAttrib = strcmp(activTable.('Tag_Level_3'), 'xs:attribute');
Tattrib = unfoldAttributesInTable(activTable(indAttrib, :), 'Attributes_Level_3', ["name", "type", "use", "default"]);
numAttribs = size(Tattrib, 1);

% Create table with attributes
theStruct = xmlStructureHandler.xml2structure(fileName);
[T, extScheme] = XMLstructure2XMLtable(theStruct);
indActiv = find(ismember(T.('Tag_Level_2'), 'activity'));
numActivities = length(indActiv);
[Tact, attribIndices] = unfoldAttributesInTable(T(indActiv, :), 'Attributes_Level_2', Tattrib.name);

% Substitute default values
for a = 1:numAttribs
    notSet = attribIndices(:, a) == 0;
    Tact{notSet, a} = Tattrib.('default')(a);
end

% Add descriptions
absScheme = extended2absoluteTreeScheme(extScheme);
numChildren = absScheme{2};
hasDescription = numChildren(indActiv) > 0;
descriptions = strings(numActivities, 1);
for a = 1:numActivities
    if hasDescription(a)
        strs = T{extScheme(:, 2) == indActiv(a), 'Data_Level_3'};
        description = strjoin(string(strs), '\n');
        descriptions(a) = description;
    end
end

Tdesc = table(descriptions, 'VariableNames', {'description'});
Tact = [Tact, Tdesc];

% What are the types of type
startInd = regexp(Tattrib.type, '^xs:.*');
customFlag = cellfun(@(x) isempty(x), startInd);
customInd = find(customFlag);
[uniqueAttribType, ~, ic] = unique(Tattrib.type(customFlag));
numUniqueCustomAttribs = length(uniqueAttribType);
customTypesStruct = repmat(struct('Type', [], 'Values', []), numUniqueCustomAttribs, 1);
isExternal = false(numUniqueCustomAttribs, 1);
isEnumeration = false(numUniqueCustomAttribs, 1);
for a = 1:numUniqueCustomAttribs    
   attribType = uniqueAttribType(a);
   customTypesStruct(a).Type = attribType;
   indElem = ismember(TattribElem.name, attribType);
   activTable = XMLstructure2XMLtable(xsdStruct.Children(indElem));
   commentInd = find(strcmp(activTable.('Tag_Level_2'), '#comment'));
   if ~isempty(commentInd)
       isExternal(a) = contains(activTable.('Data_Level_2')(commentInd(1)), 'externalDefinition'); % Only the first comment is considered: commentInd(1)
   else
       isExternal(a) = false;
   end
   if ~isExternal(a) % I guess it is an enumeration
       enumInd = strcmp(activTable.('Tag_Level_3'), 'xs:enumeration');
       if ~isempty(enumInd)
           TtypeAttrib = unfoldAttributesInTable(activTable(enumInd, :), 'Attributes_Level_3', "value");
           customTypesStruct(a).Values = TtypeAttrib.value;
           isEnumeration(a) = true;
       else
           warning('activityXML2table:unkownDataType', 'I don''t know what to do with this')
       end
   end
end

isExternalComplete = false(numAttribs, 1);
isExternalComplete(customInd(ismember(ic, find(isExternal)))) = true;

isEnumerationComplete = false(numAttribs, 1);
isEnumerationComplete(customInd(ismember(ic, find(isEnumeration)))) = true;

Tattrib = [Tattrib, table(customFlag, isExternalComplete, isEnumerationComplete, 'VariableNames', {'custom', 'external', 'enumeration'})];
% The external column indicates if the data type was declared as external
% in the xml file. We actually don't have to use that information, but it's
% good to know maybe for future functionalities. In the actual
% implementation, we use it in fact. We only reevaluate the variables that
% are declared as external.

for a = 1:numAttribs
    attribName = Tattrib.name(a);
    attribType = Tattrib.type(a);
    
    if Tattrib.custom(a)
        if ~Tattrib.enumeration(a)
            if ~Tattrib.external(a)
                warning('activityXML2table:irregularity', 'This data type should be declared as external')
            end
            switch attribType
                case 'duration'
                    Tact.(char(attribName)) = str2duration(Tact.(char(attribName)));
                otherwise
                    warning('activityXML2table:unkownDataType', 'I don''t know what to do with this')
            end
        else
            ind = strcmp(uniqueAttribType, attribType);
            categ = cellstr(customTypesStruct(ind).Values);
            Tact.(char(attribName)) = categorical(Tact.(char(attribName)), categ, categ);
            
            % Second substitution for default values in case the XML file is invalid.
            % This time, it's not
            % because we define it in the XSD file; the values of the
            % absent attributes where already set to the default value lines above.
            % Now we have the case that the values, even if they were set
            % (or substituted by the default value), are none of the values
            % admitted by the data type, wheter it is because the value we
            % set was incorrect (the XML file was not valid), wheter we the attribute was absent and the
            % default value was an incorrect one (the XSD file is directly
            % incorrect itself). 
            % ¿How are we going to treat those cases?
            % If the default value is incorrect, this is, is not one of the
            % admitted values by the data type, we cannot do anything. The
            % XSD file is itself incorrect, we cannot fix that problem.
            % However, if the error comes because the attribute value that
            % was set in the XML file is incorrect (not valid XML), then we
            % are going to change the value to the default one.
            undef = isundefined(Tact.(char(attribName)));
            Tact.(char(attribName))(isundefined(Tact.(char(attribName)))) = ...
                repmat(categorical(Tattrib.default(a), categ, categ), [sum(undef), 1]);
        end
    else
        switch attribType
            case 'xs:string'
                % Do nothing
            case 'xs:dateTime'
                Tact.(char(attribName)) = datetime(Tact.(char(attribName)), 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss');
            case 'xs:duration'
        end
    end
end

end

