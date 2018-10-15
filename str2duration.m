function dur = str2duration(str)

model = 'new';
switch model
    case 'new'
        names = regexp(str, '(?<value>\d+(\.\d+)?)(?<unit>[hms]*)', 'names');
        N = length(str);
        durationMatrix = zeros(N, 3); % [h, m, s]
        for a = 1:N
            numFields = numel(names{a});
            
            if numFields == 0
                durationMatrix(a, :) = NaN;
            else
                for k = 1:numFields
                    durationUnit = names{a}(k).unit;
                    value = str2double(names{a}(k).value);
                    if isnan(value)
                        value = 0;
                    end
                    
                    switch durationUnit
                        case 'h'
                            durationMatrix(a, 1) = value;
                        case 'm'
                            durationMatrix(a, 2) = value;
                        case 's'
                            durationMatrix(a, 3) = value;
                        otherwise
                            % We assume the duration unit is minutes
                            durationMatrix(a, 2) = value;
                    end
                end
            end
        end
        dur = duration(durationMatrix);
    case 'old'
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

end