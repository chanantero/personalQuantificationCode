Tact = activityXML2table('../Datos/Actividades.xml');

filterTags = {'TFM'};
tags = Tact.tags;
numAct = size(Tact, 1);
selInd = false(numAct, 1);
for ac = 1:numAct
    tags_ = strsplit(tags{ac}, ';');
    selInd(ac) = any(ismember(filterTags, tags_));
end

Tact.category(selInd) = "Study";

obj = ActivityHandler(Tact);
obj.draw()

%%
xmlFile = '../Datos/ActividadesNuevo.xml';
T = activityXML2table(xmlFile);


