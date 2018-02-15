function theStruct =  habitTable2structure(T)
% A habit table has 3 fields: Date, Tag and Value.
% T = habitXML2table('../Datos/Registro cuantificable.txt');

uniqueDates = flip(unique(T.Date));

numDates = size(uniqueDates, 1);

s = repmat(struct('Tag', 'day', 'Attributes', [], 'Data', [], 'Children', []), numDates, 1);

dateStrings = cellstr(datestr(uniqueDates, 'dd/mm/yyyy'));
for d = 1:numDates
    s(d).Attributes = struct('Name', 'date', 'Value', dateStrings{d});
    Taux = T(T.Date == uniqueDates(d), :);
    numHabits = size(Taux, 1);
    children = repmat(struct('Tag', 'element', 'Attributes', [], 'Data', [], 'Children', []), numHabits, 1);
    
    for h = 1:numHabits
        children(h).Attributes = struct('Name', 'tag', 'Value', char(Taux{h, 'Habit'}));
        children(h).Children = struct('Tag', '#text', 'Attributes', [], 'Data', Taux{h, 'Value'}{1}, 'Children', []);
    end
    
    s(d).Children = children;
end

theStruct = struct('Tag', 'global', 'Attributes', [], 'Data', [], 'Children', s);

end