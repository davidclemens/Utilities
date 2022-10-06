function R = sub2excelRange(startSubs,endSubs)
% sub2excelRange  Convert two subscript pairs to Excel range 
%   SUB2EXCELRANGE converts two 2D subscript pairs startSub and endSub to an 
%     Excel range.
%
%   Syntax
%     R = SUB2EXCELRANGE(startSubs,endSubs)
%
%   Description
%     R = SUB2EXCELRANGE(startSubs,endSubs)  Converts an 2D array range defined
%       by startSubs = [startRow, startCol] and endSubs = [endRow,endCol] to an
%       Excel range in the A1:B2 reference style, where the column subscripts
%       are represented alphabetically in base 26 and the rows numerically in
%       base 10.
%
%   Example(s)
%     R = SUB2EXCELRANGE([2,4],[5,10])  returns R = {'D2:J5'}
%     R = SUB2EXCELRANGE([2,4;1,1],[5,10;2,2])  returns R = {'D2:J5';'A1:B2'}
%
%
%   Input Arguments
%     startSubs - 2D subscript of the start cell
%       Nx2 integer vector
%         Defines the start 2D subscript of the range, where
%         startSubs = [startRow, startCol]. Each row is treated seperately.
%
%     endSubs - 2D subscript of the end cell
%       Nx2 integer vector
%         Defines the end 2D subscript of the range, where
%         endSubs = [endRow, endCol]. Each row is treated seperately.
%
%
%   Output Arguments
%     R - Excel range reference
%       cellstr
%         The Excel range reference returned as a cellstr column vector. Each
%         row corresponds to the input rows of startSubs and endSubs. It is
%         defined in the A1:B2 reference style, where the column subscripts are
%         represented alphabetically in base 26 and the rows numerically in base
%         10.
%
%
%   Name-Value Pair Arguments
%     NameValuePair1 - NameValuePair1 short description
%       defaultValue (default) | otherPossibleValues | ...
%         NameValuePair1 long description, that can also span multiple lines,
%         since it really goes into detail.
%
%     NameValuePair2 - NameValuePair2 short description
%       defaultValue (default) | otherPossibleValues | ...
%         NameValuePair2 long description, that can also span multiple lines,
%         since it really goes into detail.
%
%
%   See also 
%
%   Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
%

    % Validate inputs
    validateattributes(startSubs,{'numeric'},{'size',[NaN,2],'integer','positive'},mfilename,'startSubs',1)
    validateattributes(endSubs,{'numeric'},{'size',[NaN,2],'integer','positive'},mfilename,'endSubs',2)
    
    iRow = startSubs(:,1);
    iCol = startSubs(:,2);
    jRow = endSubs(:,1);
    jCol = endSubs(:,2);
    
    % Start row/col subscripts need to be smaller or equal to the end row/col
    % subscripts
    assert(all(iRow <= jRow),...
        'Utilities:sub2excelRange:StartRowExceedsEndRow',...
        'A start row subscript is greater than an end row subscript.')
    assert(all(iCol <= jCol),...
        'Utilities:sub2excelRange:StartColumnExceedsEndColumn',...
        'A start column subscript is greater than an end column subscript.')
    
    % Warn if Excel limits are reached. See https://support.microsoft.com/en-us/office/excel-specifications-and-limits-1672b34d-7043-467e-8e27-269d656771c3
    maxRows = 1048576;
    maxCols = 16384;
    if jRow > maxRows
        warning('Utilities:sub2excelRange:ExcelMaxRowsExceeded',...
            'The maximum number of rows in Excel (%u) is exceeded.',maxRows)
    end
    if jCol > maxCols
        warning('Utilities:sub2excelRange:ExcelMaxColsExceeded',...
            'The maximum number of columns in Excel (%u) is exceeded.',maxCols)
    end
    
    % Convert subscripts to character vectors
    iColNames   = namedRange(iCol);
    iRowNames   = strip(cellstr(num2str(iRow,'%u')),'left');
    jColNames   = namedRange(jCol);
    jRowNames   = strip(cellstr(num2str(jRow,'%u')),'left');
    
    % Join the character vectors
    R = strcat(iColNames,iRowNames,{':'},jColNames,jRowNames);
    
    function s = namedRange(v)
    % namedRange  Convert numeric to Excel alphabetical column reference
    %   NAMEDRANGE converts numeric column subscripts to Excel alphabetical column
    %     references.
    
        % Define symbols in base 26
        symbols = 'A':'Z';
        base    = numel(symbols);

        % Reshape to column vector
        shape       = size(v);
        v_          = v(:);
        nVals       = numel(v_);

        nDigits     = floor(log(v_)/log(base)) + 1; % The number of digits of v_ in base 26
        maxDigits   = max(nDigits); % The maximum number of digits of v_ in base 26

        d = cumsum(base.^(0:maxDigits + 1)); % Offset
        d = d(maxDigits:-1:1);               % Reverse and shorten
        r = mod(floor((v_ - d)./base.^(maxDigits - 1:-1:0)),base) + 1;  % Modulus
        s = arrayfun(@(row) char(r(row,end - nDigits(row) + 1:end) + 64),(1:nVals)','un',0);

        % Reshape to original shape
        s = reshape(s,shape);
    end
end
