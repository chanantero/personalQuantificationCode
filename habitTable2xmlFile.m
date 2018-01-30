function habitTable2xmlFile(T)
% xmlwrite(filename,DOMnode)

end

function habitTable2HabitStruct(T)
% A habit table has 3 fields: Date, Tag and Value.

% Get the dates and create a structure array, one element for each day
refDate = datetime(2017,1,1);
T.Date = days(T.Date - refDate);
datesGrp = grpstats(T, 'Date', 'gname', 'DataVars', 'Date');
datesGrp.Date = refDate + dadatesGrp.Date;
numDates = size(datesGrp, 1);


s = repmat(struct('Name', [], 'Attributes', [], 'Data', [], 'Children', []), numDates, 1);
s.Name = 

end

function habitStruct2xmlFile(habitStructure)

end