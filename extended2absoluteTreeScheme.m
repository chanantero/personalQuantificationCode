function [absScheme] = extended2absoluteTreeScheme(extScheme)

numLevels = size(extScheme, 2);
numNodesPerLevel = max(extScheme, [], 1);

absScheme = cell(numLevels, 1);
for depth = numLevels:-1:1    
    if depth < numLevels
        [aux, ia] = unique(extScheme(:, [depth, depth + 1]), 'rows', 'stable');
        numChildren = histcounts(categorical(aux(:, 1)), categorical(1:numNodesPerLevel(depth)));
        zeroChildren = extScheme(ia, depth + 1) == 0;
        numChildren(zeroChildren) = 0;
    else
        numChildren = zeros(numNodesPerLevel(depth), 1);
    end
    
    absScheme{depth} = numChildren;
end

end
