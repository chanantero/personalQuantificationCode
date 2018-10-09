function structure2XML( theStruct, fileName, appendFlag, beforeFlag )

if nargin < 3
    appendFlag = false;
end

if nargin < 4
    beforeFlag = false;
end

if appendFlag
    DocNode = xmlread(fileName);
    DOMnode = DocNode.getDocumentElement;
    doctype = DocNode.getDoctype;
    DOMnode = structure2DOMnode(theStruct, DOMnode, DocNode, 'insertBefore', beforeFlag);
else
    DOMnode = structure2DOMnode( theStruct );
end

xmlwrite(fileName, DocNode); % Before it was wrong: xmlwrite(fileName, DOMnode);

end

