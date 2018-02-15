%% Registro hábitos

habitXML = '../Datos/Registro cuantificable.xml';
habitBullFileName = '../Datos/HabitBull CSV Data File Export.csv';

% Importa nuevos hábitos
ThabitBull = habitBullExport2habitTable(habitBullFileName);

% Importa los hábitos registrad2s hasta ahora
Thabit = habitXML2table(habitXML);

% Concatena ambas tablas.
% Ten en cuenta que no quieres sobrescribir los registros de los días que
% ya están en Thabit, aunque los de ThabitBull sean distintos.
ThabitBull(ismember(ThabitBull.Date, Thabit.Date), :) = [];
T = [ThabitBull; Thabit];

% Escribe la nueva información
habitTable2XML(T, habitXML);

