function DOMnode = structure2DOMnode( s, varargin )

% Cómo hacerlo de forma estructurada?
% Puedo seguir la estructura recursiva que uso en parseChildNodes.
% Puedo usar el conocimiento de la estructura en árbol para hacerlo de
% forma más iterativa y controlada

% La recursión tiene la ventaja de no necesitar conocimiento de la
% estructura, por lo que tenemos independencia de las funciones que
% calculan la estructura en árbol.

p = inputParser;

addOptional(p, 'DOMnode', [])
addOptional(p, 'DocNode', [])
addParameter(p, 'insertBefore', false)

parse(p, varargin{:})

if all(ismember({'DOMnode', 'DocNode'}, p.UsingDefaults))
    % First level of the recursion
    % Create DOMnode
    DocNode = com.mathworks.xml.XMLUtils.createDocument(s.Tag);
    DOMnode = DocNode.getDocumentElement;
else
    DOMnode = p.Results.DOMnode;
    DocNode = p.Results.DocNode;
end

insertBeforeFlag = p.Results.insertBefore;

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
    
    if insertBeforeFlag
        firstChild = DOMnode.getFirstChild();
        if isempty(firstChild)
            DOMnode.appendChild(child);
        else
            DOMnode.insertBefore(child, firstChild);
        end
    else
        DOMnode.appendChild(child);
    end
end

end

