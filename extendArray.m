function B = extendArray( A, dim, extensionVector)

sizeA = size(A);
numDim = ndims(A);

aux = 1:numDim; aux(dim) = [];
permOrder = [dim, aux];
Aperm = permute(A, permOrder);
sizeAperm = permute(sizeA, permOrder);
N = sizeA(dim);

extensionVector = extensionVector(:);

B = cell([sum(extensionVector), sizeAperm(2:end)]);
acum = cumsum(extensionVector);
start = [0; acum(1:end-1)] + 1;
finish = acum;

for k = 1:N
    c = cell([1, sizeAperm(2:end)]);
    c(:) = Aperm(k, :);
    B(start(k):finish(k), :) = repmat(c, [extensionVector(k), ones(1, numDim-1)]);
end

order = [2:dim-1, 1, dim+1:numDim];
B = permute(B, order);

end

