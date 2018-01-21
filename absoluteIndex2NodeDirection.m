function nodeDirection = absoluteIndex2NodeDirection( absoluteTreeScheme, depthLevel, absoluteNodeIndex )
% Based on the absolute index of a node in the i-th depth level, find the node
% direction. We need to use the numberScheme calculated by getTreeStruct

nodeDirection = zeros(depthLevel, 1);
currentNodeIndex = absoluteNodeIndex;
for d = depthLevel:-1:1
    prevDepthLevel = depthLevel - 1;
    acum = [0; cumsum(absoluteTreeScheme{prevDepthLevel + 1})];
    previousDepthIndex = find(currentNodeIndex > acum, 1, 'last');
    nodeDirection(d) = currentNodeIndex - acum(previousDepthIndex);
    currentNodeIndex = previousDepthIndex;
end

end

