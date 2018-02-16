%% Registro actividades

activityXML = '../Datos/Actividades.xml';
ultrachronFileName = '../Datos/Timing 15-02-2018.txt';

% Importa actividades
Tultrachron = ultrachron2activityTable(ultrachronFileName);

% Haz las modificaciones pertinentes
% ...

% Añade nuevas actividades al XML. Como los voy a añadir sí o sí, sin
% necesidad de comprobar si ya existe o no, no hace falta que extraiga la
% tabla ya existente
% Read de xml file
theStruct = activityTable2structure(Tultrachron);
structure2XML( theStruct, activityXML, true ); % append = true

% % Otra forma
% Importa las actividades registradas hasta ahora
% Tact = activityXML2table(activityXML);

% Concatena ambas tablas
% T = [Tultrachron; Tact];

% % Escribe la nueva información
% activityTable2XML( T, activityXML);
