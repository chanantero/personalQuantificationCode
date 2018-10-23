function Tattrib = XSDfile2XSDattributeTable(xsdFile, elementName)

% Read XML schema definition file
xsdStruct = xml2structure(xsdFile);
% Find allowed activity attributes
% 1) Find node of type xs:element whose attribute "name" is "activity
xsdTable = XMLstructure2XMLtable(xsdStruct.Children, 'maxLevel', 1);
TattribElem = unfoldAttributesInTable(xsdTable, 'Attributes_Level_1', 'name');
indActiv = ismember(TattribElem.name, elementName);
% 2) Find nodes grandchildren (not children because of the structure of the XSD syntax)
% of the activity element node that have type xs:attribute
activTable = XMLstructure2XMLtable(xsdStruct.Children(indActiv));
indAttrib = strcmp(activTable.('Tag_Level_3'), 'xs:attribute');
Tattrib = unfoldAttributesInTable(activTable(indAttrib, :), 'Attributes_Level_3', ["name", "type", "use", "default"]);
numAttribs = size(Tattrib, 1);

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

enumerationValuesComplete = cell(numAttribs, 1);
enumerationValues = {customTypesStruct.Values};
enumerationValues = enumerationValues(ic);
enumerationValuesComplete(customInd) = enumerationValues;

kind = categorical(repmat("native", [numAttribs, 1]), {'native', 'enumeration', 'external'}, {'native', 'enumeration', 'external'}, 'Protected', true);
kind(isExternalComplete) = "external";
kind(isEnumerationComplete) = "enumeration";
kind(customFlag & ~isExternalComplete & ~isEnumerationComplete) = "";

Tattrib = [Tattrib, table(kind, enumerationValuesComplete, 'VariableNames', {'kind', 'enumeration'})];

end