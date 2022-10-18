function tf = isValidFormatSpec(A)
% isValidFormatSpec  Determine if input is valid formatSpec
%   ISVALIDFORMATSPEC determines if the input is a valid format specifier.
%
%   Syntax
%     tf = ISVALIDFORMATSPEC(A)
%
%   Description
%     tf = ISVALIDFORMATSPEC(A)  Description of syntax 1.
%
%   Example(s)
%     tf = ISVALIDFORMATSPEC('%f')  returns tf = true
%     tf = ISVALIDFORMATSPEC('%Z')  returns tf = false
%     tf = ISVALIDFORMATSPEC('%{YYYY-MM-dd}D')  returns tf = true
%     tf = ISVALIDFORMATSPEC({'%f','%C'})  returns tf = [true,true]
%     tf = ISVALIDFORMATSPEC({'%f','%n';'%t','%C'})  returns tf = [true,true;false,true]
%
%
%   Input Arguments
%     A - Input array
%       char row vector | cellstr
%         Input array specified as a char row vector or a cellstr.
%
%
%   Output Arguments
%     tf - Validation result
%       logical array
%         Validation result returned as a logical array in the same shape as the
%         input A, with true elements indicating a valid formatSpec and false
%         indicating an invalid formatSpec.
%
%
%   Name-Value Pair Arguments
%
%
%   See also TABLE.FORMATSPEC
%
%   Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
%
    
    % Input validation
    validateattributes(A,{'char','cell'},{'nonempty'},mfilename,'A',1)
    if ischar(A)
        A = cellstr(A);
    elseif ~iscellstr(A)
        error('Utilities:table:formatSpec:isValidFormatSpec:invalidCellDataType',...
            'Expected input number 1, A, to be one of these types:\n\nchar, cellstr\n\nInstead its type was cell.')
    end
    
    % Vectorize A
    sz = size(A);
    A = A(:);
    
    % Validate format specifiers
    validFormatSpec = table.formatSpec.listFormatSpecs;
    nFormatSpecs    = size(validFormatSpec,1);
    maskFormatSpec	= false(numel(A),1);
    for fs = 1:nFormatSpecs
        maskFormatSpec  	= maskFormatSpec | ~cellfun(@isempty,regexp(A,validFormatSpec{fs,'Regexp'}));
    end
    
    % Reshape to originial shape
    tf = reshape(maskFormatSpec,sz);
end
