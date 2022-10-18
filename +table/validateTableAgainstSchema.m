function Tout = validateTableAgainstSchema(Tin,schemaTable)
% validateTableAgainstSchema  Short description of the function/method
%   VALIDATETABLEAGAINSTSCHEMA long description goes here. It can hold multiple
%   lines as it can go into lots of detail.
%
%   Syntax
%     Tout = VALIDATETABLEAGAINSTSCHEMA(Tin,schemaTable)
%
%   Description
%     Tout = VALIDATETABLEAGAINSTSCHEMA(Tin,schemaTable)  Description of syntax 1.
%
%   Example(s)
%     Tout = VALIDATETABLEAGAINSTSCHEMA(Tin,schemaTable)  returns X
%
%
%   Input Arguments
%     Tin - input1 short description
%       data type restriction 1 | data type restriction 2
%         Input1 long description, that can also span multiple lines, since it
%         really goes into detail.
%
%     schemaTable - input2 short description
%       data type restriction 1 | data type restriction 2
%         Input2 long description, that can also span multiple lines, since it
%         really goes into detail.
%
%
%   Output Arguments
%     Tout - input1 short description
%       data type restriction 1 | data type restriction 2
%         Input1 long description, that can also span multiple lines, since it
%         really goes into detail.
%
%
%   Name-Value Pair Arguments
%
%
%   See also 
%
%   Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
%
 
    import table.formatSpec
    import table.validateTableDataTypes
    import table.validateTableSchema
    import table.validateTableVariableNames
    
    validateattributes(Tin,{'table'},{'nonempty'},mfilename,'Tin',1)
    validateattributes(schemaTable,{'table'},{'nonempty'},mfilename,'schemaTable',2)
    
    % Validate schema table
    assert(validateTableSchema(schemaTable),...
        'Utilities:table:validateTableAgainstSchema:invalidSchemaTable',...
        'The schema table is invalid.')
    
    % Validate table variable names
    assert(validateTableVariableNames(Tin,schemaTable{'VariableNames',:}),...
        'Utilities:table:validateTableAgainstSchema:missingVariableNames',...
        'Not all variable names required by the table schema are members of the table.')
    
    % Only keep relevant columns
    Tout = Tin(:,schemaTable{'VariableNames',:});
    
    % Validate column data types
    invalidDataTypes = ~validateTableDataTypes(Tout,schemaTable{'VariableFormatSpec',:});
    if any(invalidDataTypes)
        errorColInd = find(invalidDataTypes,1);
        variableFormatSpec = formatSpec.fromFormatSpec(schemaTable{'VariableFormatSpec',:});
        error('Utilities:table:validateTableAgainstSchema:invalidDataType',...
            'Column %u (''%s'') should be %s. Was %s instead.',errorColInd,schemaTable{'VariableNames',errorColInd}{:},variableFormatSpec(errorColInd),class(Tout{1,errorColInd}))
    end
    
    % Write units
    Tout.Properties.VariableUnits = schemaTable{'VariableUnits',:};
    
    % Write descriptions
    Tout.Properties.VariableDescriptions = schemaTable{'VariableDescriptions',:};
end
