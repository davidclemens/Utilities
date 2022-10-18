
function T = listFormatSpecs()
% listFormatSpecs  Table overview of all formatSpecs
%   LISTFORMATSPECS creates a table that lists, Class and IsNumeric attributes
%   as well as a regular expression to match each formatSpec.
%
%   Syntax
%     T = LISTFORMATSPECS()
%
%   Description
%     T = LISTFORMATSPECS()  returns table T that lists Class and IsNumeric
%       attributes as well as a regular expression to match each formatSpec
%
%   Example(s)
%     T = LISTFORMATSPECS()  returns table T that lists Class and IsNumeric
%       attributes as well as a regular expression to match each formatSpec
%
%
%   Input Arguments
%
%
%   Output Arguments
%     T - Overview table
%       table
%         Overview table returned as a table with columns FormatSpec, Class,
%         IsNumeric & Regexp. The table holds one row for each formatSpec.
%
%
%   Name-Value Pair Arguments
%
%
%   See also TABLE.FORMATSPEC
%
%   Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
%
    
    % Define table contents as cell
    C = arrayfun(@(f) cat(2,...
        f.FormatSpec,...
        repmat(cellstr(f),size(f.FormatSpec)), ...
        repmat({f.IsNumeric},size(f.FormatSpec)), ...
        strcat({'^%(?<keepColumn>\*?)(?<formatSpec>{.+})?'},strip(f.FormatSpec,'left','%'),{'$'})), ...
        enumeration('table.formatSpec'),'un',0);

    % Convert to table
    T = cell2table(cat(1,C{:}),'VariableNames',{'FormatSpec','Class','IsNumeric','Regexp'});
end