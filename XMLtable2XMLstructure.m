function s = XMLtable2XMLstructure(T, extScheme)
% T and scheme are in the extended version

numLevels = size(extScheme, 2);
absScheme = extended2absoluteTreeScheme(extScheme);

basicS = struct('Tag', [], 'Attributes', [], 'Data', [], 'Children', []);

numNodesPerLevel = max(extScheme, [], 1);

% Each level, from the deepest to the most superficial, I'm going to
% generate the nodes and assign the corresponding children
s_prev = [];
for depth = numLevels:-1:1
    s_curr = repmat(basicS, [numNodesPerLevel(depth), 1]);
    
    [C, ia] = unique(extScheme(:, depth));
    ia = ia(C~=0);
    
    
    % Add childrens
    numChildren = absScheme{depth}(:);
    aux = [0; cumsum(numChildren)];
    for n = 1:numNodesPerLevel(depth)
        ind = aux(n)+1:aux(n+1);
        if ~isempty(ind)
            s_curr(n).Children = s_prev(ind);
        end
        
        s_curr(n).Tag = T{ia(n), sprintf('Tag_Level_%d', depth)};
        s_curr(n).Data = T{ia(n), sprintf('Data_Level_%d', depth)};     
        s_curr(n).Attributes = T{ia(n), sprintf('Attributes_Level_%d', depth)}{1};
        
    end
    
    s_prev = s_curr;
end

s = s_prev;
end