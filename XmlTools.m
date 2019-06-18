classdef XmlTools  
    methods (Static)
        function children = parseChildNodes(theNode)
            % Recurse over node children.
            % https://es.mathworks.com/help/matlab/ref/xmlread.html
            children = [];
            if theNode.hasChildNodes
                childNodes = theNode.getChildNodes;
                numChildNodes = childNodes.getLength;
                allocCell = cell(1, numChildNodes);
                
                children = struct(             ...
                    'Tag', allocCell, 'Attributes', allocCell,    ...
                    'Data', allocCell, 'Children', allocCell);
                
                is_just_white_space = false(numChildNodes, 1);
                for count = 1:numChildNodes
                    theChild = childNodes.item(count-1);
                    children(count) = XmlTools.makeStructFromNode(theChild);
                    if strcmp(children(count).Tag, '#text') && textIsJustWhiteSpace(children(count).Data)
                        is_just_white_space(count) = true;
                    end
                end

                children(is_just_white_space) = [];
            end

            function just_white_space = textIsJustWhiteSpace(txt)
                just_white_space = isempty(regexp(txt, '\S'));
            end
        end
        
        function nodeStruct = makeStructFromNode(theNode)
            % Create structure of node info.
            % https://es.mathworks.com/help/matlab/ref/xmlread.html
            
            nodeStruct = struct(                        ...
            'Tag', char(theNode.getNodeName()),       ...
            'Attributes', XmlTools.parseAttributes(theNode),  ...
            'Data', '',                              ...
            'Children', XmlTools.parseChildNodes(theNode));
            
            if any(strcmp(methods(theNode), 'getData'))
            nodeStruct.Data = char(theNode.getData); 
            else
            nodeStruct.Data = '';
            end
        end
        
        function attributes = parseAttributes(theNode)
            % Create attributes structure.
            % https://es.mathworks.com/help/matlab/ref/xmlread.html
            attributes = [];
            if theNode.hasAttributes
            theAttributes = theNode.getAttributes;
            numAttributes = theAttributes.getLength;
            allocCell = cell(1, numAttributes);
            attributes = struct('Name', allocCell, 'Value', ...
                                allocCell);
            
            for count = 1:numAttributes
                attrib = theAttributes.item(count-1);
                attributes(count).Name = char(attrib.getName);
                attributes(count).Value = char(attrib.getValue);
            end
            end
        end

        function validate( xml,schemaFile )
            %UNTITLED Summary of this function goes here
            %   Detailed explanation goes here
            import java.io.*;
            import javax.xml.transform.Source;
            import javax.xml.transform.stream.StreamSource;
            import javax.xml.validation.*;
            
            factory = SchemaFactory.newInstance('http://www.w3.org/2001/XMLSchema');
            schemaLocation = File(schemaFile);
            schema = factory.newSchema(schemaLocation);
            validator = schema.newValidator();
            sr = StringReader(xml);
            source = StreamSource(sr);
            validator.validate(source);
            
        end
        
        function DOMnode = structure2DOMnode( s, varargin )

            % C�mo hacerlo de forma estructurada?
            % Puedo seguir la estructura recursiva que uso en XmlTools.parseChildNodes.
            % Puedo usar el conocimiento de la estructura en �rbol para hacerlo de
            % forma m�s iterativa y controlada
            
            % La recursi�n tiene la ventaja de no necesitar conocimiento de la
            % estructura, por lo que tenemos independencia de las funciones que
            % calculan la estructura en �rbol.
            
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
                        child = XmlTools.structure2DOMnode(children(c), child, DocNode);
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
            
        function DOMnode = removeWhiteSpaceNodes(DOMnode)
            childNodes = DOMnode.getChildNodes;
            numChildNodes = childNodes.getLength;
            
            count = 0;
            for c = 1:numChildNodes
                theChild = childNodes.item(count);
                child = XmlTools.makeStructFromNode(theChild);
                
                if strcmp(child.Tag, '#text') && textIsJustWhiteSpace(child.Data)
                    DOMnode.removeChild(theChild);
                else
                    count = count + 1;
                end
            end

            function just_white_space = textIsJustWhiteSpace(txt)
                just_white_space = isempty(regexp(txt, '\S'));
            end
        end

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
                DOMnode = XmlTools.removeWhiteSpaceNodes(DOMnode);
                DOMnode = XmlTools.structure2DOMnode(theStruct, DOMnode, DocNode, 'insertBefore', beforeFlag);
            else
                DOMnode = XmlTools.structure2DOMnode( theStruct );
            end
            
            xmlwrite(fileName, DOMnode, DocNode); % Before it was wrong: xmlwrite(fileName, DOMnode);
        end

        function theStruct = xml2structure(fileName)

            % Read de xml file
            DOMnode = xmlread(fileName);
            
            % Create the structure
            theStruct = XmlTools.parseChildNodes(DOMnode);
            
        end

        function [T, nodeIndexMatrix] = XMLstructure2ExtendedTables(nodeTreeStruct, unify)
            %error('Cambia esta funci�n!!!!')
            [T, nodeIndexMatrix] = XmlTools.XMLstructure2XMLtable(nodeTreeStruct, 'extend', true, 'unify', unify);
        end

        function [T, nodeIndexMatrix] = XMLstructure2XMLtable(nodeTreeStruct, varargin)

            p = inputParser;
            addParameter(p, 'extend', true)
            addParameter(p, 'unify', true)
            addParameter(p, 'maxLevel', [])
            parse(p, varargin{:})
            
            extend = p.Results.extend;
            unify = p.Results.unify;
            maxLevel = p.Results.maxLevel;
            
            treeScheme = TreeStructureTools.getTreeAbsoluteScheme(nodeTreeStruct);
            
            % Generate full tables
            numLevels = numel(treeScheme);
            if ~isempty(maxLevel)
                numLevels = maxLevel;
            end
            
            fullTables = cell(numLevels, 1);
            for depth = 1:numLevels
                
                % Loop through each node of that level, and make the table
                numNodesCurrentLevel = length(treeScheme{depth});
                %     T = table(cell(numNodesCurrentLevel, 1), cell(numNodesCurrentLevel, 1), cell(numNodesCurrentLevel, 1), ...
                %         'VariableNames', {'Tag', 'Attributes', 'Data'});
                T = table(strings(numNodesCurrentLevel, 1), cell(numNodesCurrentLevel, 1), strings(numNodesCurrentLevel, 1), ...
                    'VariableNames', {'Tag', 'Attributes', 'Data'});
                for nodeIndex = 1:numNodesCurrentLevel
                    nodeDirection = TreeStructureTools.absoluteIndex2NodeDirection( treeScheme, depth, nodeIndex );
                    node = TreeStructureTools.getTreeNode(nodeTreeStruct, nodeDirection);
                    
                    % Get relevant data
                    T.Tag{nodeIndex} = node.Tag;
                    T.Attributes{nodeIndex} = node.Attributes;
                    T.Data{nodeIndex} = node.Data;
                end
                
                fullTables{depth} = T;
            end
            
            if extend
                % Extend tables of each level
                treeScheme{numLevels} = zeros(length(treeScheme{numLevels}), 1);
                nodeIndexMatrix = TreeStructureTools.extendTreeScheme(treeScheme(1:numLevels));
                numLeaves = size(nodeIndexMatrix, 1);
                if ~unify
                    % Keep tables separated
                    
                    for level = 1:numLevels
                        depth = level + 1;
                        ind = nodeIndexMatrix(:, depth);
                        aux = repmat({cell(numLeaves, 1)}, 1, 3);
                        Taux = table(aux{:}, 'VariableNames', {'Tag', 'Attributes', 'Data'});
                        Taux(ind~=0, :) = fullTables{level}(ind(ind~=0), :);
                        fullTables{level} = Taux;
                    end
                    
                    T = fullTables';
                    
                else
                    % Create one unique table
                    %     aux = repmat({cell(numLeaves, 1)}, 1, numLevels*3);
                    aux = repmat({strings(numLeaves, 1), cell(numLeaves, 1), strings(numLeaves, 1)}, 1, numLevels);
                    variableNames = cell(numLevels*3, 1);
                    for l = 1:numLevels
                        variableNames{(l-1)*3 + 1} = sprintf('Tag_Level_%d', l);
                        variableNames{(l-1)*3 + 2} = sprintf('Attributes_Level_%d', l);
                        variableNames{(l-1)*3 + 3} = sprintf('Data_Level_%d', l);
                    end
                    T = table(aux{:}, 'VariableNames', variableNames);
                    
                    for depth = 1:numLevels
                        ind = nodeIndexMatrix(:, depth);
                        T(ind~=0, ((depth - 1)*3 + 1):(depth*3)) = fullTables{depth}(ind(ind~=0), :);
                    end
                    
                end
            else
                T = fullTables';
                nodeIndexMatrix = treeScheme;
            end
            
        end

        function s = XMLtable2XMLstructure(T, extScheme)
            % T and scheme are in the extended version
            
            numLevels = size(extScheme, 2);
            absScheme = TreeStructureTools.extended2absoluteTreeScheme(extScheme);
            
            basicS = struct('Tag', [], 'Attributes', [], 'Data', [], 'Children', []);
            
            numNodesPerLevel = max(extScheme, [], 1);
            
            % Each level, from the deepest to the most superficial, I'm going to
            % generate the nodes and assign the corresponding children
            s_prev = [];
            for depth = numLevels:-1:1
                s_curr = repmat(basicS, [numNodesPerLevel(depth), 1]);
                
                [C, ia] = unique(extScheme(:, depth));
                ia = ia(C~=0);
                
                
                % Add childrens
                numChildren = absScheme{depth}(:);
                aux = [0; cumsum(numChildren)];
                for n = 1:numNodesPerLevel(depth)
                    ind = aux(n)+1:aux(n+1);
                    if ~isempty(ind)
                        s_curr(n).Children = s_prev(ind);
                    end
                    
                    s_curr(n).Tag = T{ia(n), sprintf('Tag_Level_%d', depth)};
                    s_curr(n).Data = T{ia(n), sprintf('Data_Level_%d', depth)};     
                    s_curr(n).Attributes = T{ia(n), sprintf('Attributes_Level_%d', depth)}{1};
                    
                end
                
                s_prev = s_curr;
            end
            
            s = s_prev;
        end

        function Tattrib = XSDfile2XSDattributeTable(xsdFile, elementName)

            % Read XML schema definition file
            xsdStruct = XmlTools.xml2structure(xsdFile);
            % Find allowed activity attributes
            % 1) Find node of type xs:element whose attribute "name" is "activity
            xsdTable = XmlTools.XMLstructure2XMLtable(xsdStruct.Children, 'maxLevel', 1);
            TattribElem = unfoldAttributesInTable(xsdTable, 'Attributes_Level_1', 'name');
            indActiv = ismember(TattribElem.name, elementName);
            % 2) Find nodes grandchildren (not children because of the structure of the XSD syntax)
            % of the activity element node that have type xs:attribute
            activTable = XmlTools.XMLstructure2XMLtable(xsdStruct.Children(indActiv));
            indAttrib = strcmp(activTable.('Tag_Level_3'), 'xs:attribute');
            Tattrib = unfoldAttributesInTable(activTable(indAttrib, :), 'Attributes_Level_3', ["name", "type", "use", "default"]);
            numAttribs = size(Tattrib, 1);
            
            % What are the types of type
            startInd = regexp(Tattrib.type, '^xs:.*');
            customFlag = cellfun(@(x) isempty(x), startInd);
            customInd = find(customFlag);
            [uniqueAttribType, ~, ic] = unique(Tattrib.type(customFlag));
            numUniqueCustomAttribs = length(uniqueAttribType);
            customTypesStruct = repmat(struct('Type', [], 'Values', []), numUniqueCustomAttribs, 1);
            isExternal = false(numUniqueCustomAttribs, 1);
            isEnumeration = false(numUniqueCustomAttribs, 1);
            for a = 1:numUniqueCustomAttribs
                attribType = uniqueAttribType(a);
                customTypesStruct(a).Type = attribType;
                indElem = ismember(TattribElem.name, attribType);
                activTable = XmlTools.XMLstructure2XMLtable(xsdStruct.Children(indElem));
                commentInd = find(strcmp(activTable.('Tag_Level_2'), '#comment'));
                if ~isempty(commentInd)
                    isExternal(a) = contains(activTable.('Data_Level_2')(commentInd(1)), 'externalDefinition'); % Only the first comment is considered: commentInd(1)
                else
                    isExternal(a) = false;
                end
                if ~isExternal(a) % I guess it is an enumeration
                    enumInd = strcmp(activTable.('Tag_Level_3'), 'xs:enumeration');
                    if ~isempty(enumInd)
                        TtypeAttrib = unfoldAttributesInTable(activTable(enumInd, :), 'Attributes_Level_3', "value");
                        customTypesStruct(a).Values = TtypeAttrib.value;
                        isEnumeration(a) = true;
                    else
                        warning('activityXML2table:unkownDataType', 'I don''t know what to do with this')
                    end
                end
            end
            
            isExternalComplete = false(numAttribs, 1);
            isExternalComplete(customInd(ismember(ic, find(isExternal)))) = true;
            
            isEnumerationComplete = false(numAttribs, 1);
            isEnumerationComplete(customInd(ismember(ic, find(isEnumeration)))) = true;
            
            enumerationValuesComplete = cell(numAttribs, 1);
            enumerationValues = {customTypesStruct.Values};
            enumerationValues = enumerationValues(ic);
            enumerationValuesComplete(customInd) = enumerationValues;
            
            kind = categorical(repmat("native", [numAttribs, 1]), {'native', 'enumeration', 'external'}, {'native', 'enumeration', 'external'}, 'Protected', true);
            kind(isExternalComplete) = "external";
            kind(isEnumerationComplete) = "enumeration";
            kind(customFlag & ~isExternalComplete & ~isEnumerationComplete) = "";
            
            Tattrib = [Tattrib, table(kind, enumerationValuesComplete, 'VariableNames', {'kind', 'enumeration'})];
            
        end
    end
end

