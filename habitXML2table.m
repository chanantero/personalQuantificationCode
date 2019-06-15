function T = habitXML2table(fileName)
% fileName = '../Datos/Registro cuantificable.txt';

nodeTreeStruct = xml2structure(fileName);

joinTables = true;
[extTable, nodeIndexMatrix] = XMLstructure2ExtendedTables(nodeTreeStruct, joinTables);

if size(nodeIndexMatrix, 2) < 3
    error('At least 3 levels of depth must be present in the structure')
    return;
end

% Compute some tree structure parameters
numLeaves = size(extTable, 1);
leafDepth = getLeafLevel(nodeIndexMatrix);

% There aren't supposed to be more than three levels. In any case, if there
% are more, we are not interested in them, so we are going to collapse any
% leafes with a depth greater than 3.
collapsedIndices = collapseTreeByLevel( nodeIndexMatrix, 3 );

% Filter only those leaves with tag #text that are children of second level nodes with tag
% 'element' and children of first level nodes with tag day. Leafs that are
% second level are also kept.
isDayChild = false(numLeaves, 1);
isElementChild = false(numLeaves, 1);
isText = false(numLeaves, 1);
for r = 1:numLeaves
    isDayChild(r) = strcmp(extTable.('Tag_Level_1'){r}, 'day');
    isElementChild(r) = strcmp(extTable.('Tag_Level_2'){r}, 'element');
    isText(r) = strcmp(extTable.('Tag_Level_3'){r}, '#text');
end

filter = collapsedIndices & isDayChild & isElementChild & (isText | leafDepth == 2);
extTable = extTable(filter, :);
nodeIndexMatrix = nodeIndexMatrix(filter, :);

% Get the first child of every element on the second level. This is the
% same as collapsing the current tree to the second level.
collapsedIndices = collapseTreeByLevel( nodeIndexMatrix, 2 );
extTable = extTable(collapsedIndices, :);
numElements = size(collapsedIndices, 1);

% Create table with the next variable names: 'date', 'habit', 'value'. Fill
% it with the appropiate data.
dateColumn = cell(numElements, 1);
for r = 1:numElements
    attributes = extTable.('Attributes_Level_1'){r};
    % Search for the attribute with the name 'date'
    names = {attributes.Name};
    ind = find(ismember(names, 'date'), 1, 'first');
    % Get the value
    dateColumn{r} = attributes(ind).Value;
end

habitColumn = cell(numElements, 1);
for r = 1:numElements
    attributes = extTable.('Attributes_Level_2'){r};
    % Search for the attribute with the name 'tag'
    names = {attributes.Name};
    ind = find(ismember(names, 'tag'), 1, 'first');
    habitColumn{r} = attributes(ind).Value;
end

valueColumn = cell(numElements, 1);
for r = 1:numElements
    valueColumn{r} = extTable.('Data_Level_3'){r};
    if isempty(valueColumn{r})
        valueColumn{r} = '';
    end
end

T = table(dateColumn, habitColumn, valueColumn, 'VariableNames', {'Date', 'Habit', 'Value'});

T.Date = datetime(T.Date, 'InputFormat', 'dd/MM/yyyy');
T.Habit = categorical(T.Habit);
% T.Value = str2double(T.Value);
T = sortrows(T, {'Date', 'Habit'}, 'descend');

end

% % Old version
% function T = habitXML2table(fileName)
% theStruct = xml2structure(fileName);
% 
% % Clean structure and make it easy to use
%     % Filter day elements
%     daysCand = theStruct.Children;
%     isDay = ismember({daysCand.Tag}, 'day');
%     daysElem = daysCand(isDay);
%     numDays = numel(daysElem);
% 
%     % Find the date
%     numElems = zeros(numDays, 1);
%     dates = cell(numDays, 1);
%     for d = 1:numDays
%         dayElem = daysElem(d);
% 
%         % Find date
%         attrib = dayElem.Attributes;
%         ind = ismember({attrib.Name}, 'date');
%         dates{d} = attrib(ind).Value;
% 
%         % Filter elements
%         elemCand = dayElem.Children;
%         isElem = ismember({elemCand.Tag}, 'element');
%         elem = elemCand(isElem);
%         numElems(d) = numel(elem);
%         daysElem(d).Children = elem;
%     end
% 
%     theStruct.Children = daysElem;
% 
% % % A tree node can be uniquely specified by a vector. The i-th element of
% % % the vector is the index of the child in the i-th level of depth. The
% % % parent node of the tree is level 0.
% % nodeDirection = [2, 3];
% % node = getTreeNode(theStruct, nodeDirection);
% 
% % % Based on the absolute index of a node in the i-th depth level, find the node
% % % direction. We need to use the numberScheme calculated by getTreeStruct
% % depthLevel = 2;
% % nodeIndex = 5;
% % nodeDirection = absoluteIndex2NodeDirection( treeScheme, depthLevel, nodeIndex );
% 
% % Associate data to each node. For each depth, you can find the data with a
% % relative strucutre direction
% dataDirection = {[], '.Attributes.Value', '.Attributes.Value', '.Data' };
% 
% % Go through all the tree and get the data for every node
% [absoluteTreeScheme, dataTree] = getTreeAbsoluteSchemeAndData( theStruct, dataDirection );
% 
% % Extend everything to fit a table format
% numLevels = numel(absoluteTreeScheme);
% dataTable = [];
% for d = 1:numLevels - 1
%     dataTable = extendArray([dataTable, dataTree{d}], 1, absoluteTreeScheme{d});
% end
% dataTable = [dataTable, dataTree{numLevels}];
% 
% % Generate table
% aux = mat2cell(dataTable, size(dataTable, 1), ones(1, size(dataTable, 2)));
% T = table(aux{:});
% T.Properties.VariableNames ={'Date', 'Tag', 'Value'};
% T.Date = datetime(T.Date, 'InputFormat', 'dd/MM/yyyy');
% T.Tag = categorical(T.Tag);
% T.Value = str2double(T.Value);
% T = sortrows(T, {'Date', 'Tag'}, 'ascend');
% end