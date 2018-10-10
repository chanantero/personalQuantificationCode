function node = getTreeNode( tree, nodeDirection )
% A tree node can be uniquely specified by a vector. The i-th element of
% the vector is the index of the child in the i-th level of depth. The
% parent node of the tree is level 0.

nodeDepth = numel(nodeDirection);
numNodes = numel(tree);

if nodeDirection(1) > 0 && nodeDirection(1) <= numNodes    
    if nodeDepth > 1
        node = getTreeNode(tree(nodeDirection(1)).Children, nodeDirection(2:end));
    else
        node = tree(nodeDirection(1));
    end
else
    node = [];
    warning('The node doesn''t exist');
end

end

% Old way
% The first node doesn't count and is a parent node, so tree is a
% scalar necessarily
% function node = getTreeNode( tree, nodeDirection, obviateParentNode )
% % A tree node can be uniquely specified by a vector. The i-th element of
% % the vector is the index of the child in the i-th level of depth. The
% % parent node of the tree is level 0.
% 
% nodeDepth = numel(nodeDirection);
% numChildren = numel(tree.Children);
% nextChildrenInd = nodeDirection(1);
% 
% if nextChildrenInd > 0 && nextChildrenInd <= numChildren
%     nextChildrenTree = tree.Children(nextChildrenInd);
%     
%     if nodeDepth > 1
%         node = getTreeNode(nextChildrenTree, nodeDirection(2:end), obviateParentNode);
%     else
%         node = nextChildrenTree;
%     end
% else
%     node = [];
%     warning('The node doesn''t exist');
% end
% 
% end
