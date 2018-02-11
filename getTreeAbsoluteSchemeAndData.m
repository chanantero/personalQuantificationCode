function [absoluteTreeScheme, dataTree] = getTreeAbsoluteSchemeAndData( tree, dataRelativePaths )

numChildren = numel(tree.Children);

% Get the number scheme for each of the children
numberSchemeChild = cell(numChildren, 1);
dataTreeChildren = cell(numChildren, 1);
for c = 1:numChildren
    [numberSchemeChild{c}, dataTreeChildren{c}] = getTreeAbsoluteSchemeAndData(tree.Children(c), dataRelativePaths(2:end));
end

% Concatenate the schemes of the children
depths = zeros(numChildren, 1); % The depth of each sub-tree (tree of each children)
for c = 1:numChildren
    depths(c) = numel(dataTreeChildren{c});
end

maxDepth = max(depths);

absoluteTreeScheme = cell(1 + maxDepth, 1);
absoluteTreeScheme{1} = numChildren;

dataTree = cell(1 + maxDepth, 1);

if isempty(dataRelativePaths)
    dataRelativePath = [];
else
    dataRelativePath = dataRelativePaths{1};
end

if isempty(dataRelativePath)
    dataTree{1} = {};
else
    try
        dataTree{1} = {eval(['tree', dataRelativePaths{1}])};
    catch
        dataTree{1} = {};
    end
end

for d = 1:maxDepth
    % Concatenate the k-th level
    currentLevelScheme = cell(numChildren, 1);
    currentLevelData = cell(numChildren, 1);
    
    for c = 1:numChildren
        if depths(c) >= d
            currentLevelScheme{c} = numberSchemeChild{c}{d};
            currentLevelData{c} = dataTreeChildren{c}{d};
        end
    end
    
    absoluteTreeScheme{d+1} = cat(1, currentLevelScheme{:});
    dataTree{d+1} = cat(1, currentLevelData{:});
end



end

