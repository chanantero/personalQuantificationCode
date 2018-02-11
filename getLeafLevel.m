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

