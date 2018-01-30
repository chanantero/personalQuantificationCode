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
        
        function nodes = getNodesByElementTag(obj, tag)
            [absoluteTreeScheme, ~] = getTreeAbsoluteScheme( obj.s, [] );
            numChildrenLevel1 = absoluteTreeScheme{1};
            
            % Get elements of the hierarchy level 1 with tag tag
            flag = false(numChildrenLevel1, 1);
            for c = 1:numChildrenLevel1
                if strcmp(obj.s.Children(c).Tag, tag)
                    flag(c) = true;
                end
            end
            
            nodes = obj.s.Children(flag);
        end
    end
    
    methods(Static)
        function theStruct = xml2structure(fileName)
            % Read de xml file
            DOMnode = xmlread(fileName);
            
            % Create the structure
            theStruct = parseChildNodes(DOMnode);
        end
    end
end