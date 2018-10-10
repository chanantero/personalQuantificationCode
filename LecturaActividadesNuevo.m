
Tact = activityXML2table('../Datos/Actividades.xml');

filterTags = {'TFM'};
tags = Tact.tags;
selInd = false(numAct, 1);
for ac = 1:numAct
    tags_ = strsplit(tags{ac}, ';');
    selInd(ac) = any(ismember(filterTags, tags_));
end

Tact.category(selInd) = "Study";

obj = ActivityHandler(Tact);
obj.draw()

xmlStruct = xmlStructureHandler.xml2structure('../Datos/ActividadesNuevo2.xml');
[xmlTable, extScheme] = XMLstructure2XMLtable(xmlStruct);
s = XMLtable2XMLstructure(xmlTable, extScheme);

