function T = ultrachron2activityTable( fileName )
% The Android App Ultrachron lite allows to export the user activity into a
% text file. This function allows to convert that text file into an
% activity table.
% fileName = '../Datos/Timing.txt';
str = fileread(fileName);

% Find starting time
% Example of string: 'Start Time: 24 Jan 2018 10:27:18 a.m.';
% Other useful expressions:
% - expression = 'Start Time: (?<day>\d+) (?<month>\D+) (?<year>\d{4}) (?<hour>\d+):(?<minute>\d+):(?<second>\d+) (?<ampm>[ap])\.m\.';
% - expression = 'Start Time: (?<date>\d+ \D+ \d{4}) (?<hour>\d+):(?<minute>\d+):(?<second>\d+) (?<ampm>[ap])\.m\.';
expression = 'Start Time: (?<dateAndTime>\d+ \D+ \d{4} \d+:\d+:\d+) (?<ampm>[ap])\.m\.';
names = regexp(str, expression, 'names');

inputFormat = 'd MMM yyyy h:mm:ss a';
startTimeStr = [names.dateAndTime, ' ', upper(names.ampm), 'M'];
startTimeAll = datetime(startTimeStr, 'InputFormat', inputFormat);

% Find durations
% Example of string: Lap Total Time: 08:29:01.7
expression = 'Lap Total Time: (?<hours>\d{2}):(?<minutes>\d{2}):(?<seconds>\d{2}(.\d+)?)';
names = regexp(str, expression, 'names');

numLaps = numel(names);

H = zeros(numLaps, 1);
M = zeros(numLaps, 1);
S = zeros(numLaps, 1);

for l = 1:numLaps
    H(l) = str2double(names(l).hours);
    M(l) = str2double(names(l).minutes);
    S(l) = str2double(names(l).seconds);
end

elapsedTime = duration(H, M, S);

ending = startTimeAll + elapsedTime;
start = [ending(2:end); startTimeAll];
dur = ending - start;

% Find descriptions
% Example of string: 'Lap Description: Lap 4...'
expression = 'Lap Description: (?<description>.*?)\n';
names = regexp(str, expression, 'names');
descriptions = {names.description}';

% Create table
T = table(descriptions, start, dur, ending, cell(numLaps, 1), cell(numLaps, 1), 'VariableNames', {'name', 'start', 'duration', 'ending', 'tags', 'description'});

end

