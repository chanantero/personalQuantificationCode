%% Registro actividades

activityXML = '../Datos/Actividades.xml';
ultrachronFileName = '../Datos/Timing.txt';

% Importa actividades
Tultrachron = ultrachron2activityTable(ultrachronFileName);

% Haz las modificaciones pertinentes
% ...

% Importa las actividades registradas hasta ahora
Tact = activityXML2table(activityXML);

% Concatena ambas tablas
T = [Tultrachron; Tact];

% Escribe la nueva información
activityTable2XML( T, activityXML);


