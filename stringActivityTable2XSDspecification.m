function [Tact] = stringActivityTable2XSDspecification(Tact, Tattrib, invalidDataAction)
% invalidDataAction: 'invalid2default' or 'invalid2undefined'
if nargin < 3
    invalidDataAction = 'invalid2default';
end

% Convert to the aproppiate types
numAttribs = size(Tattrib, 1);
for a = 1:numAttribs
    attribName = Tattrib.name(a);
    attribType = Tattrib.type(a);
    
    if isstring(Tact.(char(attribName)))
    
    if Tattrib.kind(a) ~= "native"
        if Tattrib.kind(a) ~= "enumeration"
            if Tattrib.kind(a) ~= "external"
                warning('activityXML2table:irregularity', 'This data type should be declared as external')
            end
            switch attribType
                case 'duration'
                    Tact.(char(attribName)) = str2duration(Tact.(char(attribName)));
                case 'datetime'
                    Tact.(char(attribName)) = datetime(Tact.(char(attribName)), 'InputFormat', 'yyyy/MM/dd HH:mm:ss');
                otherwise
                    warning('activityXML2table:unkownDataType', 'I don''t know what to do with this')
            end
        else
            categ = cellstr(Tattrib.enumeration{a});
            Tact.(char(attribName)) = categorical(Tact.(char(attribName)), categ, categ);
            
            % Second substitution for default values in case the XML file is invalid.
            % This time, it's not
            % because we define it in the XSD file; the values of the
            % absent attributes where already set to the default value lines above.
            % Now we have the case that the values, even if they were set
            % (or substituted by the default value), are none of the values
            % admitted by the data type, wheter it is because the value we
            % set was incorrect (the XML file was not valid), wheter we the attribute was absent and the
            % default value was an incorrect one (the XSD file is directly
            % incorrect itself).
            % ¿How are we going to treat those cases?
            % If the default value is incorrect, this is, is not one of the
            % admitted values by the data type, we cannot do anything. The
            % XSD file is itself incorrect, we cannot fix that problem.
            % However, if the error comes because the attribute value that
            % was set in the XML file is incorrect (not valid XML), then we
            % are going to change the value to the default one or the undefined one.
            if strcmp(invalidDataAction, 'invalid2default')
                undef = isundefined(Tact.(char(attribName)));
                Tact.(char(attribName))(undef) = ...
                    repmat(categorical(Tattrib.default(a), categ, categ), [sum(undef), 1]);
            end
        end
    else
        switch attribType
            case 'xs:string'
                % Do nothing
            case 'xs:dateTime'
                Tact.(char(attribName)) = datetime(Tact.(char(attribName)), 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss');
            case 'xs:duration'
        end
    end
    end
end
end

