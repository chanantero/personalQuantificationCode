function hms = duration2HMS( dur )

h = floor(hours(dur));

remaining = dur - hours(h);
m = floor(minutes(remaining));

remaining = remaining - minutes(m);
s = floor(seconds(remaining));

hms = [h, m, s];

end

