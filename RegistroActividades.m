%% Registro actividades

% Forma con toggl app
activityXML = '../Datos/Actividades.xml';
togglFileName = '../Datos/Toggl_time_entries_2018-12-16_to_2018-12-22.csv';

% Importa actividades
xsdFile = getXSDfile(activityXML);
Tattrib = XmlTools.XSDfile2XSDattributeTable(xsdFile, 'activity');
Ttoggl = toggl2activityTable(togglFileName, Tattrib, 'unset2default', false);

% Haz las modificaciones pertinentes
% ...

% Lee las actividades ya registradas
Tact = activityXML2activityTable(activityXML);

% A�ade solo las actividades posteriores a la actividad m�s reciente
% registrada
lastRegisteredStartTime = max(Tact.start);
if isscalar(lastRegisteredStartTime)
    Ttoggl = Ttoggl(Ttoggl.start > lastRegisteredStartTime, :);
end

[Txml, extScheme] = activityTable2XMLtable(Ttoggl, Tattrib, 'includeDefaults', false);
if ~isempty(Txml)
    theStruct = XmlTools.XMLtable2XMLstructure(Txml, extScheme); 
    theStructGlob = struct('Tag', 'global', 'Data', [], 'Attributes', [], 'Children', theStruct); % theStructGlobal is scalar (one global parent node)
    structure2XML( theStructGlob, activityXML, true, true ); % append = true
end

%%
% % Forma con ultrachron app
% activityXML = '../Datos/ActividadesNuevo.xml';
% ultrachronFileName = '../Datos/Timing 10-9.txt';
% 
% % Importa actividades
% Tultrachron = ultrachron2activityTable(ultrachronFileName);
% Tultrachron = flip(Tultrachron);
% 
% % Haz las modificaciones pertinentes
% % ...
% 
% % A�ade nuevas actividades al XML. Como los voy a a�adir s� o s�, sin
% % necesidad de comprobar si ya existe o no, no hace falta que extraiga la
% % tabla ya existente
% % Read de xml file
% theStruct = activityTable2structure(Tultrachron);
% structure2XML( theStruct, activityXML, true, true ); % append = true

%%
% % Otra forma
% Importa las actividades registradas hasta ahora
% Tact = activityXML2table(activityXML);

% Concatena ambas tablas
% T = [Tultrachron; Tact];

% % Escribe la nueva informaci�n
% activityTable2XML( T, activityXML);