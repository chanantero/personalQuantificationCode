function DOMnode = structure2DOMnode( s, DOMnode, DocNode )

% Cómo hacerlo de forma estructurada?
% Puedo seguir la estructura recursiva que uso en parseChildNodes.
% Puedo usar el conocimiento de la estructura en árbol para hacerlo de
% forma más iterativa y controlada

% La recursión tiene la ventaja de no necesitar conocimiento de la
% estructura, por lo que tenemos independencia de las funciones que
% calculan la estructura en árbol.

if nargin == 1
    % First level of the recursion
    % Create DOMnode
    DocNode = com.mathworks.xml.XMLUtils.createDocument(s.Tag);
    DOMnode = DocNode.getDocumentElement;
end

children = s.Children;
numChildren = numel(children);

for c = 1:numChildren
    tag = children(c).Tag;
    
    if strcmp(tag, '#text')
        data = children(c).Data;
        child = DocNode.createTextNode(data);
    else
        child = DocNode.createElement(tag);

        attributes = children(c).Attributes;
        numAttributes = numel(attributes);
        for a = 1:numAttributes
            child.setAttribute(attributes(a).Name, attributes(a).Value);
        end
        
        if ~isempty(children(c).Children)
            child = structure2DOMnode(children(c), child, DocNode);
        end  
    end
    
    DOMnode.appendChild(child);
end

end

