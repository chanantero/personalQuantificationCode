function [Tattrib, attribIndices] = unfoldAttributesInTable(T, attributeColumnNames, attributeNames)
% attributeColumnNames is a cellstring array, not a string array

if isstring(attributeColumnNames)
    attributeColumnNames = cellstr(attributeColumnNames);
elseif ischar(attributeColumnNames)
    attributeColumnNames = {attributeColumnNames};
end

if isstring(attributeNames)
    attributeNames = cellstr(attributeNames);
elseif ischar(attributeNames)
    attributeNames = {attributeNames};
end

numRows = size(T, 1);
numAttributeColumns = length(attributeColumnNames);
numAttributeNames = length(attributeNames);

data = strings(numRows, numAttributeNames*numAttributeColumns);
attribIndices = zeros(numRows, numAttributeNames*numAttributeColumns);
for c = 1:numAttributeColumns
    attrColumn = T.(attributeColumnNames{c});
    for r = 1:numRows
        attrStruct = attrColumn{r};
        if ~isempty(attrStruct)
            [exist, ind] = ismember(attributeNames, {attrStruct.Name});
            data(r, numAttributeNames*(c-1) + find(exist)) = string({attrStruct(ind(exist)).Value});
            attribIndices(r, numAttributeNames*(c-1)+(1:numAttributeNames)) = ind;
        end
    end
end

data = mat2cell(data, numRows, ones(1, size(data, 2)));
Tattrib = table(data{:}, 'VariableNames', repmat(attributeNames(:), [numAttributeColumns, 1]));

end

