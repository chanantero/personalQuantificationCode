function [T, nodeIndexMatrix] = XMLstructure2XMLtable(nodeTreeStruct, extend, unify)

% nodeTreeStruct = xml2structure('../Datos/Registro cuantificable.txt');
if nargin < 2
    extend = true;
end

if nargin < 3
    unify = true;
end

treeScheme = getTreeAbsoluteScheme(nodeTreeStruct);

% Generate full tables
% We consider that the parent node is level 0. So, be careful that there is
% always a parent node, this is, that nodeTreeStruct is a scalar structure
% and not an array of structures
numLevels = numel(treeScheme);
fullTables = cell(numLevels, 1);
for depth = 1:numLevels
    
    % Loop through each node of that level, and make the table
    numNodesCurrentLevel = length(treeScheme{depth});
%     T = table(cell(numNodesCurrentLevel, 1), cell(numNodesCurrentLevel, 1), cell(numNodesCurrentLevel, 1), ...
%         'VariableNames', {'Tag', 'Attributes', 'Data'});
    T = table(strings(numNodesCurrentLevel, 1), cell(numNodesCurrentLevel, 1), strings(numNodesCurrentLevel, 1), ...
        'VariableNames', {'Tag', 'Attributes', 'Data'});
    for nodeIndex = 1:numNodesCurrentLevel
        nodeDirection = absoluteIndex2NodeDirection( treeScheme, depth, nodeIndex );
        node = getTreeNode(nodeTreeStruct, nodeDirection);
        
        % Get relevant data
        T.Tag{nodeIndex} = node.Tag;
        T.Attributes{nodeIndex} = node.Attributes;
        T.Data{nodeIndex} = node.Data;
    end
    
    fullTables{depth} = T;
end

if extend
    % Extend tables of each level
    nodeIndexMatrix = extendTreeScheme(treeScheme);
    numLeaves = size(nodeIndexMatrix, 1);
if ~unify
    % Keep tables separated
    
    for level = 1:numLevels
        depth = level + 1;
        ind = nodeIndexMatrix(:, depth);
        aux = repmat({cell(numLeaves, 1)}, 1, 3);
        Taux = table(aux{:}, 'VariableNames', {'Tag', 'Attributes', 'Data'});
        Taux(ind~=0, :) = fullTables{level}(ind(ind~=0), :);
        fullTables{level} = Taux;
    end
    
    T = fullTables';
     
else
    % Create one unique table
%     aux = repmat({cell(numLeaves, 1)}, 1, numLevels*3);
    aux = repmat({strings(numLeaves, 1), cell(numLeaves, 1), strings(numLeaves, 1)}, 1, numLevels);
    variableNames = cell(numLevels*3, 1);
    for l = 1:numLevels
        variableNames{(l-1)*3 + 1} = sprintf('Tag_Level_%d', l);
        variableNames{(l-1)*3 + 2} = sprintf('Attributes_Level_%d', l);
        variableNames{(l-1)*3 + 3} = sprintf('Data_Level_%d', l);
    end
    T = table(aux{:}, 'VariableNames', variableNames);

    for depth = 1:numLevels
        ind = nodeIndexMatrix(:, depth);
        T(ind~=0, ((depth - 1)*3 + 1):(depth*3)) = fullTables{depth}(ind(ind~=0), :);
    end
    
end
else
    T = fullTables';
    nodeIndexMatrix = treeScheme;
end

end

% Old way:
% The first node doesn't count and is a parent node, so nodeTreeStruct is a
% scalar necessarily
% function [T, nodeIndexMatrix] = XMLstructure2XMLtable(nodeTreeStruct, extend, unify)
% 
% % nodeTreeStruct = xml2structure('../Datos/Registro cuantificable.txt');
% if nargin < 2
%     extend = true;
% end
% 
% if nargin < 3
%     unify = true;
% end
% 
% treeScheme = getTreeAbsoluteScheme(nodeTreeStruct);
% 
% % Generate full tables
% % We consider that the parent node is level 0. So, be careful that there is
% % always a parent node, this is, that nodeTreeStruct is a scalar structure
% % and not an array of structures
% numLevels = numel(treeScheme) - 1;
% fullTables = cell(numLevels, 1);
% for l = 1:numLevels
%     depth = l + 1; % Parent node is level 0, but depth 1.
%     
%     % Loop through each node of that level, and make the table
%     numNodesCurrentLevel = sum(treeScheme{l});
%     T = table(cell(numNodesCurrentLevel, 1), cell(numNodesCurrentLevel, 1), cell(numNodesCurrentLevel, 1), ...
%         'VariableNames', {'Tags', 'Attributes', 'Data'});
%     for nodeIndex = 1:numNodesCurrentLevel
%         nodeDirectionDepth = absoluteIndex2NodeDirection( treeScheme, depth, nodeIndex );
%         nodeDirection = nodeDirectionDepth(2:end);
%         node = getTreeNode(nodeTreeStruct, nodeDirection);
%         
%         % Get relevant data
%         T.Tags{nodeIndex} = node.Tag;
%         T.Attributes{nodeIndex} = node.Attributes;
%         T.Data{nodeIndex} = node.Data;
%     end
%     
%     fullTables{l} = T;
% end
% 
% if extend
%     % Extend tables of each level
%     nodeIndexMatrix = extendTreeScheme(treeScheme);
%     numLeaves = size(nodeIndexMatrix, 1);
% if ~unify
%     % Keep tables separated
%     
%     for level = 1:numLevels
%         depth = level + 1;
%         ind = nodeIndexMatrix(:, depth);
%         aux = repmat({cell(numLeaves, 1)}, 1, 3);
%         Taux = table(aux{:}, 'VariableNames', {'Tags', 'Attributes', 'Data'});
%         Taux(ind~=0, :) = fullTables{level}(ind(ind~=0), :);
%         fullTables{level} = Taux;
%     end
%     
%     T = fullTables';
%      
% else
%     % Create one unique table
%     aux = repmat({cell(numLeaves, 1)}, 1, numLevels*3);
%     variableNames = cell(numLevels*3, 1);
%     for l = 1:numLevels
%         variableNames{(l-1)*3 + 1} = sprintf('Tags_Level_%d', l);
%         variableNames{(l-1)*3 + 2} = sprintf('Attributes_Level_%d', l);
%         variableNames{(l-1)*3 + 3} = sprintf('Data_Level_%d', l);
%     end
%     T = table(aux{:}, 'VariableNames', variableNames);
%     
%     for level = 1:numLevels
%         depth = level + 1;
%         ind = nodeIndexMatrix(:, depth);
%         T(ind~=0, ((level - 1)*3 + 1):(level*3)) = fullTables{level}(ind(ind~=0), :);
%     end
%     
% end
% else
%     T = fullTables';
%     nodeIndexMatrix = treeScheme;
% end
% 
% % First column of nodeIndexMatrix corresponds to depth 1, which is the
% % parent node (level 0). Delete it.
% nodeIndexMatrix = nodeIndexMatrix(:, 2:end);
% 
% end