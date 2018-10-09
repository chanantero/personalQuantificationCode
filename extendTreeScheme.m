function nodeIndexMatrix = extendTreeScheme( treeScheme )
% Parent node is level 1.
% treeScheme is an absolute tree scheme

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



end

