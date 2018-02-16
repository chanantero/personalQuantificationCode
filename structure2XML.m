function structure2XML( theStruct, fileName, appendFlag )

if nargin < 3
    appendFlag = false;
end

if appendFlag
    DocNode = xmlread(XMLfileName);
    DOMnode = DocNode.getDocumentElement;
    DOMnode = structure2DOMnode(theStruct, DOMnode, DocNode);
else
    DOMnode = structure2DOMnode( theStruct );
end

xmlwrite(fileName, DOMnode);

end

