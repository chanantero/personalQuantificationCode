function dur = str2duration(str)
names = regexp(str, '(?<hours>\d+):(?<minutes>\d+)', 'names');

N = numel(str);
hs = zeros(N, 1);
ms = zeros(N, 1);
ss = zeros(N, 1);
notValid = false(N, 1);
for k = 1:numel(str)
    if ~isempty(names{k})
    hStr = names{k}(1).hours;
    h = str2double(hStr);
    if ~isnan(h)
        hs(k) = h;
    else
        notValid(k) = true;
    end
    
    mStr = names{k}(1).minutes;
    m = str2double(mStr);
    if ~isnan(m)
        ms(k) = m;
    else
        notValid(k) = true;
    end
    else
        notValid(k) = true;
    end
    
end

dur = duration(hs, ms, ss);
dur(notValid) = NaN;
end