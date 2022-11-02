function tf = validateTableSchema(schemaTable)
% validateTableSchema  Validate table schema format
%   VALIDATETABLESCHEMA tests if table schemaTable holds a valid table schema to
%   be used with table.writeTableFile.
%
%   Syntax
%     tf = VALIDATETABLESCHEMA(schemaTable)
%
%   Description
%     tf = VALIDATETABLESCHEMA(schemaTable)  Test if table schemaTable is a
%       valid table schema.
%
%   Example(s)
%     tf = VALIDATETABLESCHEMA(table())  returns tf = false.
%
%
%   Input Arguments
%     schemaTable - schema table
%       table
%         The schema table to be tested.
%
%
%   Output Arguments
%     tf - validation result
%       logical scalar
%         True if table schemaTable is a valid table schema.
%
%
%   Name-Value Pair Arguments
%
%
%   See also TABLE.WRITETABLEFILE, TABLE.VALIDATETABLEVARIABLENAMES, TABLE.VALIDATETABLEDATATYPES
%
%   Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
%

    import table.formatSpec.isValidFormatSpec
    
    % Validate inputs
    validateattributes(schemaTable,{'table'},{'size',[4,NaN]},mfilename,'schemaTable',1)
    
    expectedRowNames = {'VariableNames','VariableUnits','VariableDescriptions','VariableFormatSpec'}';
    
    % Validate row names
    rowNameMatches = ismember(expectedRowNames,schemaTable.Properties.RowNames);
    tf = all(rowNameMatches);
    
    % Validate VariableNames row
    tf = tf & all(cellfun(@isvarname,schemaTable{'VariableNames',:}));
    
    % Validate VariableFormatSpec row
    formatSpecIsValid = isValidFormatSpec(schemaTable{'VariableFormatSpec',:});
    tf = tf & all(formatSpecIsValid);
end
