function tf = validateTableDataTypes(T,expectedFormatSpec)
% validateTableDataTypes  Test if table has expected data types
%   VALIDATETABLEDATATYPES tests if table T contains the expected data types 
%     provided as format specifiers in expectedFormatSpec.
%
%   Syntax
%     tf = VALIDATETABLEDATATYPES(T,expectedFormatSpec)
%
%   Description
%     tf = VALIDATETABLEDATATYPES(T,expectedFormatSpec)  Test if the columns in
%       table T are of a specific data type specified as format specifier in 
%       expectedFormatSpec. This comparison is positional.
%
%   Example(s)
%     tf = VALIDATETABLEDATATYPES(table(1,2,categorical(3),'VariableNames',{'a','b','c'}),{'%f','%n','%C'})
%       returns tf = [true,true,true].
%     tf = VALIDATETABLEDATATYPES(table(1,2,3,'VariableNames',{'a','b','c'}),{'%f','%n','%C'})
%       returns tf = [true,true,false].
%
%   Input Arguments
%     T - Input table
%       table
%         The table against which the expected format specifiers are tested.
%
%     expectedFormatSpec - expected column formatSpec
%       cellstr vector
%         Expected column data type specified as cellstr of format specifiers.
%         Is required to have a valid entry for each column in T. The comparison
%         is positional, meaning that the first element in expectedFormatSpec
%         tests the data type of the first column in T, etc.
%         See the <a href="matlab:help table.formatSpec">table.formatSpec</a> documentation for details.
%
%
%   Output Arguments
%     tf - validation result
%       logical vector
%         True for each column of T that matches the data types specified as 
%         format specifiers in expectedFormatSpec.
%
%
%   Name-Value Pair Arguments
%
%
%   See also TABLE.FORMATSPEC, TABLE.VALIDATETABLEVARIABLENAMES, TABLE.VALIDATETABLESCHEMA
%
%   Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
%

    import table.formatSpec
    
    % Validate inputs
    validateattributes(T,{'table'},{},mfilename,'T',1)
    nCols = size(T,2);
    validateattributes(expectedFormatSpec,{'cell'},{'vector','numel',nCols},mfilename,'expectedFormatSpec',2)
    
    assert(iscellstr(expectedFormatSpec),...
        'Utilities:table:validateTableDataTypes:invalidType',...
        'Expected input number 2, expectedFormatSpec, to be one of these types:\n\ncellstr.\n\nInstead its type was %s.',class(expectedFormatSpec))

    fSpecMembers = enumeration('table.formatSpec');
    expectedFormatSpec = cellfun(@(s) validatestring(s,cat(1,fSpecMembers.FormatSpec),mfilename,'expectedFormatSpec',2),expectedFormatSpec,'un',0);
    
    % Get the formatSpec for each column
    fSpec   = arrayfun(@(col) formatSpec(class(T{1,col})),1:nCols);
    
    % Compare to expectations
    tf = arrayfun(@(fs,efs) any(ismember(fs.FormatSpec,efs)),fSpec,expectedFormatSpec);
end
