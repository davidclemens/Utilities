function obj = fromFormatSpec(A)
% fromFormatSpec  Create class instances from FormatSpec property
%   FROMFORMATSPEC creates table.formatSpec class instances from the input of
%   valid format specifiers.
%
%   Syntax
%     obj = FROMFORMATSPEC(A)
%
%   Description
%     obj = FROMFORMATSPEC(A)  Create array of table.formatSpec instances obj
%       from an array A of format specifiers specified as char/cellstr.
%
%   Example(s)
%     obj = FROMFORMATSPEC({'%f','%s';'%D','%u16'})  returns obj = [double,cell;datetime,uint16]
%
%
%   Input Arguments
%     A - Input array
%       char row vector | cellstr
%         Input array of valid format specifiers specified as a char row vector
%         or a cellstr.
%
%
%   Output Arguments
%     obj - Instances of table.formatSpec
%       table.formatSpec array
%         Array of table.formatSpec instances created from their format
%         specifiers.
%
%
%   Name-Value Pair Arguments
%
%
%   See also TABLE.FORMATSPEC
%
%   Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
%
    
    import table.formatSpec.isValidFormatSpec
    import table.formatSpec.listFormatSpecs
    
    % Get list of members
    enumMembers = listFormatSpecs;
    
    isValid = isValidFormatSpec(A);
    if any(~isValid)
        indInvalid = find(~isValid,1);
        error('Utilities:table:formatSpec:invalidFormatSpec',...
            '''%s'' is not a valid format specifier. Valid specifiers are:\n\n%s\n',A{indInvalid},strjoin(enumMembers{:,'FormatSpec'},', '))
    end
    
    % Vectorize A
    sz = size(A);
    A = A(:);
    
    % Check uniquenes of FormatSpec
    if numel(unique(enumMembers{:,'FormatSpec'})) ~= numel(enumMembers{:,'FormatSpec'})
        error('Utilities:table:formatSpec:nonUniqueProperty',...
            'The ''FormatSpec'' property for enumeration class table.formatSpec has non-unique entries.')
    end
    
    % Find A in members list
    [~,ind] = ismember(A,enumMembers{:,'FormatSpec'});
    
    % Create enum instances
    obj = table.formatSpec(enumMembers{ind,'Class'});
    
    % Reshape to originial shape
    obj = reshape(obj,sz);
end
