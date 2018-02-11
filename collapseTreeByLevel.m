function [ collapsedIndices ] = collapseTreeByLevel( nodeAbsoluteIndexExtendedMatrix, level )
% Collapse at level 'level'
numLeaves = size(nodeAbsoluteIndexExtendedMatrix, 1);
maxDepth = size(nodeAbsoluteIndexExtendedMatrix, 2);
leafDepth = getLeafLevel(nodeAbsoluteIndexExtendedMatrix);

if maxDepth > level
    leafOverLevel = leafDepth > level;
    [~, firstChild] = unique(nodeAbsoluteIndexExtendedMatrix(leafOverLevel, level));    
    flags = false(size(firstChild));
    flags(firstChild) = true;
    collapsedIndices = false(numLeaves, 1);
    collapsedIndices(~leafOverLevel) = true;
    collapsedIndices(leafOverLevel) = flags;
else
    collapsedIndices = true(numLeaves, 1);
end


end

