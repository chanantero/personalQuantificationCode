Tact = activityXML2activityTable('../Datos/Actividades.xml');

obj = ActivityHandler(Tact);
obj.draw()

%%
xmlFile = '../Datos/ActividadesNuevo.xml';
Tact = activityXML2activityTable(xmlFile);


