function theStruct = xml2structure(fileName)

% Read de xml file
DOMnode = xmlread(fileName);

% Create the structure
theStruct = parseChildNodes(DOMnode);

end