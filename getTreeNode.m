function node = getTreeNode( tree, nodeDirection )
% A tree node can be uniquely specified by a vector. The i-th element of
% the vector is the index of the child in the i-th level of depth. The
% parent node of the tree is level 0.

nodeDepth = numel(nodeDirection);
numChildren = numel(tree.Children);
nextChildrenInd = nodeDirection(1);

if nextChildrenInd > 0 && nextChildrenInd <= numChildren
    nextChildrenTree = tree.Children(nextChildrenInd);
    
    if nodeDepth > 1
        node = getTreeNode(nextChildrenTree, nodeDirection(2:end));
    else
        node = nextChildrenTree;
    end
else
    node = [];
    warning('The node doesn''t exist');
end



end

