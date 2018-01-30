function T = habitXML2table(fileName)
theStruct = xml2structure(fileName);

% Clean structure and make it easy to use
    % Filter day elements
    daysCand = theStruct.Children;
    isDay = ismember({daysCand.Tag}, 'day');
    daysElem = daysCand(isDay);
    numDays = numel(daysElem);

    % Find the date
    numElems = zeros(numDays, 1);
    dates = cell(numDays, 1);
    for d = 1:numDays
        dayElem = daysElem(d);

        % Find date
        attrib = dayElem.Attributes;
        ind = ismember({attrib.Name}, 'date');
        dates{d} = attrib(ind).Value;

        % Filter elements
        elemCand = dayElem.Children;
        isElem = ismember({elemCand.Tag}, 'element');
        elem = elemCand(isElem);
        numElems(d) = numel(elem);
        daysElem(d).Children = elem;
    end

    theStruct.Children = daysElem;

% % A tree node can be uniquely specified by a vector. The i-th element of
% % the vector is the index of the child in the i-th level of depth. The
% % parent node of the tree is level 0.
% nodeDirection = [2, 3];
% node = getTreeNode(theStruct, nodeDirection);

% % Based on the absolute index of a node in the i-th depth level, find the node
% % direction. We need to use the numberScheme calculated by getTreeStruct
% depthLevel = 2;
% nodeIndex = 5;
% nodeDirection = absoluteIndex2NodeDirection( treeScheme, depthLevel, nodeIndex );

% Associate data to each node. For each depth, you can find the data with a
% relative strucutre direction
dataDirection = {[], '.Attributes.Value', '.Attributes.Value', '.Data' };

% Go through all the tree and get the data for every node
[absoluteTreeScheme, dataTree] = getTreeAbsoluteScheme( theStruct, dataDirection );

% Extend everything to fit a table format
numLevels = numel(absoluteTreeScheme);
dataTable = [];
for d = 1:numLevels - 1
    dataTable = extendArray([dataTable, dataTree{d}], 1, absoluteTreeScheme{d});
end
dataTable = [dataTable, dataTree{numLevels}];

% Generate table
aux = mat2cell(dataTable, size(dataTable, 1), ones(1, size(dataTable, 2)));
T = table(aux{:});
T.Properties.VariableNames ={'Date', 'Tag', 'Value'};
T.Date = datetime(T.Date, 'InputFormat', 'dd/MM/yyyy');
T.Tag = categorical(T.Tag);
T.Value = str2double(T.Value);
T = sortrows(T, {'Date', 'Tag'}, 'ascend');
end