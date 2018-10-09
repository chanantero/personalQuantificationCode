%% Registro actividades

activityXML = '../Datos/ActividadesNuevo.xml';
ultrachronFileName = '../Datos/Timing 10-9.txt';

% Importa actividades
Tultrachron = ultrachron2activityTable(ultrachronFileName);
Tultrachron = flip(Tultrachron);

% Haz las modificaciones pertinentes
% ...

% A�ade nuevas actividades al XML. Como los voy a a�adir s� o s�, sin
% necesidad de comprobar si ya existe o no, no hace falta que extraiga la
% tabla ya existente
% Read de xml file
theStruct = activityTable2structure(Tultrachron);
structure2XML( theStruct, activityXML, true, true ); % append = true

% % Otra forma
% Importa las actividades registradas hasta ahora
% Tact = activityXML2table(activityXML);

% Concatena ambas tablas
% T = [Tultrachron; Tact];

% % Escribe la nueva informaci�n
% activityTable2XML( T, activityXML);