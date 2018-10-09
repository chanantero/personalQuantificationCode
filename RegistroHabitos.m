%% Registro hábitos

habitXML = '../Datos/Registro cuantificable.xml';
habitBullFileName = '../Datos/HabitBull CSV Data File Export 22-07-2018.csv';

% Importa nuevos hábitos
ThabitBull = habitBullExport2habitTable(habitBullFileName);

% Importa los hábitos registrad2s hasta ahora
Thabit = habitXML2table(habitXML);

% Concatena ambas tablas.
% Ten en cuenta que no quieres sobrescribir los registros de los días que
% ya están en Thabit, aunque los de ThabitBull sean distintos.
ThabitBull(ThabitBull.Date < datetime(2018, 1, 1), :) = []; % Antes el hábito de Cold approach se llamaba ColdApproach
[~, indNewRows] = setdiff(ThabitBull(:, {'Date', 'Habit'}), Thabit(:, {'Date', 'Habit'}), 'rows');

T = [ThabitBull(indNewRows, :); Thabit];

% Escribe la nueva información
habitTable2XML(T, habitXML);
