function structure2XML( theStruct, fileName )

DOMnode = structure2DOMnode( theStruct );

xmlwrite(fileName, DOMnode);

end

