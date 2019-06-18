function structure2XML( theStruct, fileName, appendFlag, beforeFlag )

if nargin < 3
    appendFlag = false;
end

if nargin < 4
    beforeFlag = false;
end

DocNode = xmlread(fileName);
if appendFlag
    DOMnode = DocNode.getDocumentElement;
    doctype = DocNode.getDoctype;
    DOMnode = XmlTools.structure2DOMnode(theStruct, DOMnode, DocNode, 'insertBefore', beforeFlag);
else
    DOMnode = XmlTools.structure2DOMnode( theStruct );
end

xmlwrite(fileName, DOMnode, DocNode); % Before it was wrong: xmlwrite(fileName, DOMnode);

end

