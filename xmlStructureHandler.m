classdef xmlStructureHandler < handle
    % Class created to work with strutures that come from xml files. The
    % ideal would be to use the xml functions in https://docs.oracle.com/javase/7/docs/api/org/w3c/dom/package-summary.html
    % but I don't have time to learn it now. This is simpler.
    
    properties
        fileName
        s % structure that comes from xmlStructurHandler.xml2structure(XMLfileName)
    end
    
    methods
        function obj = xmlStructureHandler(input)
            if isstruct(input)
                obj.s = input;
            else
                fileName = input;
                obj.fileName = fileName;
                obj.s = xmlStructureHandler.xml2structure(fileName);
            end
        end          
    end
    
    methods(Static)
        function theStruct = xml2structure(fileName)
            % Read de xml file
            DOMnode = xmlread(fileName);
            
            % Create the structure
            theStruct = XmlTools.parseChildNodes(DOMnode);
        end
        
        function [propertyIndMatrix, extraAttributes] = existAttributes(nodes, attributeNames)
            numNodes = length(nodes);
            numAttributeNames = length(attributeNames);
            
            propertyIndMatrix = zeros(numNodes, numAttributeNames);
            extraAttributes = zeros(numNodes, 1);
            
            for n = 1:numNodes
                attributeNames_this = {nodes(n).Attributes(:).Name};
                [flags, ind] = ismember(attributeNames, attributeNames_this);     
                
                propertyIndMatrix(n, :) = ind;
                extraAttributes(n) = length(attributeNames_this) - nnz(flags);
            end
        end
        
        function numChildren = getNumberOfChildren(nodes)
%             % One way
%             absoluteTreeScheme = TreeStructureTools.getTreeAbsoluteScheme(nodes);
%             numChildren = absoluteTreeScheme{1};
            
            % Other way, more efficient
            numNodes = length(nodes);
            numChildren = zeros(numNodes, 1);
            for n = 1:numNodes
                numChildren(n) = length(nodes(n).Children);
            end
        end
        
        function nodes = getNodesByTag(nodes, tag)            
            flag = ismember({nodes.Tag}, tag);           
            nodes = nodes(flag);
        end
        
    end
end