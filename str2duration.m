function dur = str2duration(str)

model = 'twopoints';
switch model
    case 'hms'
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
    case 'twopoints'
        fields = regexp(str, ':' ,'split');
        
        N = numel(str);
        hs = zeros(N, 1);
        ms = zeros(N, 1);
        ss = zeros(N, 1);
        notValid = false(N, 1);
        for k = 1:numel(str)
            numFields = length(fields{k});
            if numFields == 2
                hStr = fields{k}(1);
                h = str2double(hStr);
                if ~isnan(h)
                    hs(k) = h;
                else
                    notValid(k) = true;
                end
                
                mStr = fields{k}(2);
                m = str2double(mStr);
                if ~isnan(m)
                    ms(k) = m;
                else
                    notValid(k) = true;
                end
            elseif numFields == 3
                hStr = fields{k}(1);
                h = str2double(hStr);
                if ~isnan(h)
                    hs(k) = h;
                else
                    notValid(k) = true;
                end
                
                mStr = fields{k}(2);
                m = str2double(mStr);
                if ~isnan(m)
                    ms(k) = m;
                else
                    notValid(k) = true;
                end
                
                sStr = fields{k}(3);
                s = str2double(sStr);
                if ~isnan(s)
                    ms(k) = s;
                else
                    notValid(k) = true;
                end
            end            
        end
        
        dur = duration(hs, ms, ss);
        dur(notValid) = NaN;
end

end