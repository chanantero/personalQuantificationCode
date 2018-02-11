function [T, nodeIndexMatrix] = XMLstructure2ExtendedTables(nodeTreeStruct, unify)

% nodeTreeStruct = xml2structure('../Datos/Registro cuantificable.txt');

if nargin < 2
    unify = false;
end

treeScheme = getTreeAbsoluteScheme(nodeTreeStruct);

% Generate full tables
% We consider that the parent node is level 0. So, be careful that there is
% always a parent node, this is, that nodeTreeStruct is a scalar structure
% and not an array of structures
numLevels = numel(treeScheme) - 1;
fullTables = cell(numLevels, 1);
for l = 1:numLevels
    depth = l + 1; % Parent node is level 0, but depth 1.
    
    % Loop through each node of that level, and make the table
    numNodesCurrentLevel = sum(treeScheme{l});
    T = table(cell(numNodesCurrentLevel, 1), cell(numNodesCurrentLevel, 1), cell(numNodesCurrentLevel, 1), ...
        'VariableNames', {'Tags', 'Attributes', 'Data'});
    for nodeIndex = 1:numNodesCurrentLevel
        nodeDirectionDepth = absoluteIndex2NodeDirection( treeScheme, depth, nodeIndex );
        nodeDirection = nodeDirectionDepth(2:end);
        node = getTreeNode(nodeTreeStruct, nodeDirection);
        
        % Get relevant data
        T.Tags{nodeIndex} = node.Tag;
        T.Attributes{nodeIndex} = node.Attributes;
        T.Data{nodeIndex} = node.Data;
    end
    
    fullTables{l} = T;
end

% Extend tables of each level
nodeIndexMatrix = extendTreeScheme(treeScheme);
numLeaves = size(nodeIndexMatrix, 1);

if ~unify
    % Keep tables separated
    
    for level = 1:numLevels
        depth = level + 1;
        ind = nodeIndexMatrix(:, depth);
        aux = repmat({cell(numLeaves, 1)}, 1, 3);
        Taux = table(aux{:}, 'VariableNames', {'Tags', 'Attributes', 'Data'});
        Taux(ind~=0, :) = fullTables{level}(ind(ind~=0), :);
        fullTables{level} = Taux;
    end
    
    T = fullTables';
     
else
    % Create one unique table
    aux = repmat({cell(numLeaves, 1)}, 1, numLevels*3);
    variableNames = cell(numLevels*3, 1);
    for l = 1:numLevels
        variableNames{(l-1)*3 + 1} = sprintf('Tags_Level_%d', l);
        variableNames{(l-1)*3 + 2} = sprintf('Attributes_Level_%d', l);
        variableNames{(l-1)*3 + 3} = sprintf('Data_Level_%d', l);
    end
    T = table(aux{:}, 'VariableNames', variableNames);
    
    for level = 1:numLevels
        depth = level + 1;
        ind = nodeIndexMatrix(:, depth);
        T(ind~=0, ((level - 1)*3 + 1):(level*3)) = fullTables{level}(ind(ind~=0), :);
    end
    
end

% First column of nodeIndexMatrix corresponds to depth 1, which is the
% parent node (level 0). Delete it.
nodeIndexMatrix = nodeIndexMatrix(:, 2:end);

end