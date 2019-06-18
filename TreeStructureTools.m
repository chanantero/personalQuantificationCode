classdef TreeStructureTools  
    methods (Static)
        function nodeDirection = absoluteIndex2NodeDirection( absoluteTreeScheme, depthLevel, absoluteNodeIndex )
            % Based on the absolute index of a node in the i-th depth level, find the node
            % direction. We need to use the numberScheme calculated by getTreeStruct
            % The depth of the parent node is 1.

            nodeDirection = zeros(depthLevel, 1);
            currentNodeIndex = absoluteNodeIndex;
            for d = depthLevel:-1:2
                prevDepthLevel = d - 1;
                acum = [0; cumsum(absoluteTreeScheme{prevDepthLevel})];
                previousDepthIndex = find(currentNodeIndex > acum, 1, 'last');
                nodeDirection(d) = currentNodeIndex - acum(previousDepthIndex);
                currentNodeIndex = previousDepthIndex;
            end
            nodeDirection(1) = currentNodeIndex;
        end
        
        function [ collapsedIndices ] = collapseTreeByLevel( nodeAbsoluteIndexExtendedMatrix, level )
            % Collapse at level 'level'
            numLeaves = size(nodeAbsoluteIndexExtendedMatrix, 1);
            maxDepth = size(nodeAbsoluteIndexExtendedMatrix, 2);
            leafDepth = TreeStructureTools.getLeafLevel(nodeAbsoluteIndexExtendedMatrix);
            
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

        function nodeIndexMatrix = extendTreeScheme( treeScheme )
            % Parent node is level 1.
            % treeScheme is an absolute tree scheme
            
            treeScheme = treeScheme(:);
            if length(treeScheme{1}) > 1
                treeScheme = [{length(treeScheme{1})}; treeScheme];
                artificialRoot = true;
            else
                artificialRoot = false;
            end
            
            numLevels = numel(treeScheme);
            
            nodeIndices = cell(1, numLevels);
            for level = 1:numLevels
                nodeIndices{level} = 1:numel(treeScheme{level});
            end
            
            % Extend everything to fit a table format. There will be as many rows as
            % leaves.
            nodeIndexMatrix = [];
            for d = 1:numLevels
                if d == 1
                    extVec = treeScheme{1};
                    nodeIndicesNext = nodeIndices{d};
                else
                    extVecNext = zeros(numel(treeScheme{d}) + sum(zeroChildren), 1);
                    nodeIndicesNext = zeros(numel(treeScheme{d}) + sum(zeroChildren), 1);
                    
                    for k = 1:sum(~zeroChildren)
                        extVecNext(startsNext(k):endingsNext(k)) = treeScheme{d}(starts(k):endings(k));
                        nodeIndicesNext(startsNext(k):endingsNext(k)) = nodeIndices{d}(starts(k):endings(k));
                    end
                    
                    extVec = extVecNext;   
                end
                
                zeroChildren = extVec == 0;
                extVec(zeroChildren) = 1;
                nodeIndexMatrix = extendArray([nodeIndexMatrix, nodeIndicesNext], 1, extVec);
                
                endingsNext = cumsum(extVec);
                startsNext = [0; endingsNext(1:end - 1)] + 1;
                endingsNext(zeroChildren) = [];
                startsNext(zeroChildren) =[];
            
                endings = cumsum(extVec(~zeroChildren));
                starts = [0; endings(1:end - 1)] + 1;
            end
            
            if artificialRoot
                nodeIndexMatrix = nodeIndexMatrix(:, 2:end);
            end
            
        end
            
        function [ leafDepth ] = getLeafLevel( nodeAbsoluteIndexExtendedMatrix )

            numLeaves = size(nodeAbsoluteIndexExtendedMatrix, 1);
            maxDepth = size(nodeAbsoluteIndexExtendedMatrix, 2);
            
            leafDepth = zeros(numLeaves, 1);
            for l = 1:numLeaves
                indFirstZero = find(nodeAbsoluteIndexExtendedMatrix(l, :) == 0, 1, 'first');
                if isempty(indFirstZero)
                    depth = maxDepth;
                else
                    depth = indFirstZero - 1;
                end
                leafDepth(l) = depth;
            end
            
        end

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
                numberSchemeChild{c} = TreeStructureTools.getTreeAbsoluteScheme(tree.Children(c));
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

        function [absoluteTreeScheme, dataTree] = getTreeAbsoluteSchemeAndData( tree, dataRelativePaths )

            numChildren = numel(tree.Children);
            
            % Get the number scheme for each of the children
            numberSchemeChild = cell(numChildren, 1);
            dataTreeChildren = cell(numChildren, 1);
            for c = 1:numChildren
                [numberSchemeChild{c}, dataTreeChildren{c}] = TreeStructureTools.getTreeAbsoluteSchemeAndData(tree.Children(c), dataRelativePaths(2:end));
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
        
        function node = getTreeNode( tree, nodeDirection )
            % A tree node can be uniquely specified by a vector. The i-th element of
            % the vector is the index of the child in the i-th level of depth. The
            % parent node of the tree is level 0.
            
            nodeDepth = numel(nodeDirection);
            numNodes = numel(tree);
            
            if nodeDirection(1) > 0 && nodeDirection(1) <= numNodes    
                if nodeDepth > 1
                    node = TreeStructureTools.getTreeNode(tree(nodeDirection(1)).Children, nodeDirection(2:end));
                else
                    node = tree(nodeDirection(1));
                end
            else
                node = [];
                warning('The node doesn''t exist');
            end
            
        end
            
    end
end

