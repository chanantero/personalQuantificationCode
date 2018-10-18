function [xsdFile] = getXSDfile(xmlFile)
% Find XML schema definition file
slowWay = false;
if slowWay
    xmlStruct = xml2structure(xmlFile);
    flag = strcmp({xmlStruct.Attributes.Name}, 'xsi:noNamespaceSchemaLocation');
    xsdFileName = xmlStruct.Attributes(flag).Value;
else
    str = fileread(xmlFile);
    xsdFileName = regexp(str, 'xsi:noNamespaceSchemaLocation="(.*?)"', 'once', 'tokens');
    if ~isempty(xsdFileName)
        xsdFileName = xsdFileName{1};
    else
        xsdFile = '';
        return;  
    end
end
xmlPath = fileparts(xmlFile);
[xsdPath, xsdName, xsdExt] = fileparts(xsdFileName);

if isRelative(xsdPath)
    xsdFullPath = GetFullPath([xmlPath, xsdPath]);
    xsdFile = fullfile(xsdFullPath, [xsdName, xsdExt]);
else
    xsdFile = xsdFileName;
end

end


function flag = isRelative(pathName)
if isempty(pathName)
    flag = true;
elseif ~isempty(regexp(pathName, '\.\..*', 'once')) > 0
    flag = true;
else
    flag = false;
end
end