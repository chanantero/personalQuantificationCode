%% Lectura actividades
Tact = activityXML2activityTable('../Datos/Actividades.xml');

%% Lectura proyectos Project
TactProj = projectXMLplan2activityTable('../Plan semanal actual.xml');
TactProjAux = [TactProj, table(true(size(TactProj, 1), 1), 'VariableNames', {'plan'})];
writetable(TactProjAux, '../Datos/ActividadesPlan.csv');

%% Exportación a CSV para análisis con Tableau (por ejemplo)

TactAux = [Tact, table(false(size(Tact, 1), 1), 'VariableNames', {'plan'})];

includePlan = false;
if includePlan    
    TactProjAux = readtable('../Datos/ActividadesPlan.csv');
    
    % Actualiza la fecha del plan para ir a la última semana
    aux = dateshift(Tact.start, 'dayofweek', 'monday');
    lastMonday = dateshift(max(aux) - caldays(7), 'start', 'day');
    mondayPlan = dateshift(min(TactProjAux.start), 'start', 'day');
    TactProjAux.start = TactProjAux.start + between(mondayPlan, lastMonday);
    
    Taux = [TactAux; TactProjAux];
    writetable(Taux, '../Datos/ActividadesAnalisis.csv');
else
    Taux = TactAux;
    writetable(Taux, '../Datos/ActividadesAnalisisNoPlan.csv');
end


%%
obj = ActivityHandler(Tact);
obj.draw()

Tsel = Tact;
Tsel.duration = hours(Tsel.duration);
Tgrp = grpstats(Tsel, 'category', 'sum', 'DataVars', {'duration'}, 'VarNames', {'category', 'GroupCount', 'TotalDuration'});
ax = axes(figure);
bar(ax, Tgrp.category, Tgrp.TotalDuration)

%% Compare the amount of time planned and actually dedicated to a category

% Grpstats
    % without table
% weekBeginning = dateshift(Tact.start, 'start', 'week');
% [dur, name] = grpstats(hours(Tact.duration), {Tact.category, weekBeginning}, {'sum', 'gname'});
% name = string(name);
    % with table
TactProjAux = TactProj;
TactProjAux.duration = hours(TactProjAux.duration);
TgrpProj = grpstats(TactProjAux, {'category'}, 'sum', 'DataVars', 'duration');

TactAux.duration = hours(TactAux.duration);
Tgrp = grpstats(TactAux, {'category', 'weekBeginning'}, 'sum', 'DataVars', 'duration');

ind = Tgrp.category == "work";
ax = axes(figure, 'NextPlot', 'Add');
bar(ax, Tgrp.weekBeginning(ind), Tgrp.sum_duration(ind))


%% Visualize with timeSchedule objects

TscheduleAct = activityTable2scheduleTable(Tact);
TscheduleProj = activityTable2scheduleTable(Tact);

addpath('TimeSchedule')

% Create timeSchedule object and visualize
objAct = timeSchedule();
objAct.schedule = Tschedule;
objAct.viewSchedule();

objProj = timeSchedule();
objProj.schedule = Tschedule;
objProj.viewSchedule();

%%




