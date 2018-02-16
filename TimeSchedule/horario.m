% dormirS.duration = duration([9 0 0]);
% rutinaMatinalS.duration = duration([1 15 0]);
% desayunarS.duration = duration([0 40 0]);
% comerS.duration = duration([1 30 0]);
% cenarS.duration = duration([1 30 0]);
% rutinaVespertinaS.duration = duration([0 80 0]);
% rutinaNocturnaS.duration = duration([0 30 0]);
% casaBibliotecaS.duration = duration([0 30 0]);
% bloqueProductivoS.duration = duration([3 0 0]);
% defaultS.duration = duration([1 0 0]);
% 
% dormirS.name  = 'Dormir';
% rutinaMatinalS.name  = 'Rutina matinal';
% desayunarS.name  = 'Desayunar';
% comerS.name  = 'Comer';
% cenarS.name  = 'Cenar';
% rutinaVespertinaS.name  = 'Rutina vespertina';
% rutinaNocturnaS.name  = 'Rutina nocturna';
% casaBibliotecaS.name  = 'Trayecto';
% bloqueProductivoS.name  = 'Bloque productivo';
% defaultS.name = 'Default';
% 
% types = {'Dormir', 'Rutina matinal', 'Desayunar', 'Comer', 'Cenar', 'Rutiva vespertina',...
%     'Rutina nocturna', 'Trayecto', 'Bloque productivo', 'Default'};
% 
% activities = [dormirS; rutinaMatinalS; rutinaVespertinaS; rutinaNocturnaS;...
%     desayunarS; comerS; cenarS; bloqueProductivoS; casaBibliotecaS; defaultS];
% 

hex2norm_RGB = @(s) hex2dec({s(1:2), s(3:4), s(5:6)})'/255;
colorRutines = hex2norm_RGB('4EC500');
colorMeals = hex2norm_RGB('F6E000');

data = {'Dormir', [9 0 0], [0 0 0];
        'Rutina matinal', [1 20 0], colorRutines;
        'Rutina vespertina', [0 80 0], colorRutines;
        'Rutina nocturna', [0 30 0], colorRutines;
        'Desayunar', [0 40 0], colorMeals
        'Comer', [1 30 0], colorMeals;
        'Cenar', [1 30 0], colorMeals;
        'Bloque productivo', [3 0 0], hex2norm_RGB('F300F3');
        'Default', [1 0 0], hex2norm_RGB('555555');
        'Trayecto', [0 30 0], hex2norm_RGB('15B4E1')};

data = mat2cell(data, size(data, 1), ones(1, 3));
activityTable = table(data{:}, 'VariableNames', {'Type', 'Duration', 'Color'});
    

obj = timeSchedule(activityTable);
% 
% % Set colors
% obj.cmap(1, :) = [0 0 0];
% hex2norm_RGB = @(s) hex2dec({s(1:2), s(3:4), s(5:6)})'/255;
% obj.cmap([2, 3, 4], :) = repmat(hex2norm_RGB('4EC500'), 3, 1);
% obj.cmap(5:7, :) = repmat(hex2norm_RGB('F6E000'), 3, 1);
% obj.cmap(8, :) = hex2norm_RGB('F300F3');
% obj.cmap(9, :) = hex2norm_RGB('15B4E1');

%%
ordenSemanal = {...    
    'Dormir'
    'Rutina matinal'
    'Desayunar'
    'Trayecto'
    'Bloque productivo'
    'Comer'
    'Bloque productivo'
    'Sesión control'
    'Respuesta social'
    'Trayecto'
    'Meditación vespertina'
    'Cenar'
    'Tucán'
    'Rutina nocturna'
    
    'Dormir'
    'Rutina matinal'
    'Comer'
    'Trayecto'
    'Gym'
    'Trayecto'
    'Rutina vespertina'
    'Trayecto'
    'Baile'
    'Cenar'
    'Rutina nocturna'
    
    'Dormir'
    'Rutina matinal'
    'Desayunar'
    'Trayecto'
    'Bloque productivo'
    'Comer'
    'Bloque productivo'
    'Trayecto'
    'Rutina vespertina'
    'Cena'
    'Trayecto'
    'Baile'
    'Fiesta'
    'Rutina nocturna'
    };
    
aDormir = datetime(2018, 1, 15, 4, 30, 0);
obj.startingTime = aDormir;
fixedStartsInd = 1;
fixedStarts = datetime(2018, 1, 17, 1, 0, 0);
obj.generateSchedule(ordenSemanal, fixedStartsInd, fixedStarts);         
obj.viewSchedule();

%%
obj.orderSchedule();
obj.updateGUI();

% % Save
% s = obj.schedule;
% save('planSemanal16-1.mat', 's')

% Write file
obj.exportSchedule();

% Load
load('planSemanal16-1.mat')
obj.schedule = s;