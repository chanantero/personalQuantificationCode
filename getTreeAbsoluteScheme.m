function absoluteTreeScheme = getTreeAbsoluteScheme( tree )
% tree is a structure

if length(tree) == 1
    artificialGlobal = false;
else
    treeAux = struct('tag', 'root', 'Attributes', [], 'Data', [], 'Children', tree);
    tree = treeAux;
    artificialGlobal = true;
end

numChildren = numel(tree.Children);

% Get the number scheme for each of the children
numberSchemeChild = cell(numChildren, 1);
for c = 1:numChildren
    numberSchemeChild{c} = getTreeAbsoluteScheme(tree.Children(c));
end

% Concatenate the schemes of the children
depths = zeros(numChildren, 1); % The depth of each sub-tree (tree of each children)
for c = 1:numChildren
    depths(c) = numel(numberSchemeChild{c});
end

maxDepth = max(depths);

absoluteTreeScheme = cell(1 + maxDepth, 1);
absoluteTreeScheme{1} = numChildren;

for d = 1:maxDepth
    % Concatenate the k-th level
    currentLevelScheme = cell(numChildren, 1);
    
    for c = 1:numChildren
        if depths(c) >= d
            currentLevelScheme{c} = numberSchemeChild{c}{d};
        end
    end
    
    absoluteTreeScheme{d+1} = cat(1, currentLevelScheme{:});
end

if artificialGlobal
    absoluteTreeScheme = absoluteTreeScheme(2:end);
end

end

