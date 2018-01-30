function time = dateAndTime2datetime(date, hourDuration, threshold)
% It takes in account when the time is after midnight, but it belongs
% informally to the previous day.

if nargin < 3
    threshold = hours(6);
end

time = date + hourDuration;
time(hourDuration < threshold) = time(hourDuration < threshold) + caldays(1);

end