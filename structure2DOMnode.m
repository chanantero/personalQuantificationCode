function DOMnode = structure2DOMnode( s, DOMnode, DocNode )

% C�mo hacerlo de forma estructurada?
% Puedo seguir la estructura recursiva que uso en parseChildNodes.
% Puedo usar el conocimiento de la estructura en �rbol para hacerlo de
% forma m�s iterativa y controlada

% La recursi�n tiene la ventaja de no necesitar conocimiento de la
% estructura, por lo que tenemos independencia de las funciones que
% calculan la estructura en �rbol.

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

