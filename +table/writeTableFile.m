function writeTableFile(T,filename)
% writeTableFile  Write table to fully defined Excel table
%   WRITETABLEFILE writes a table to an Excel table with four header rows that 
%     define the column names, descriptions, units and data types of each
%     column. That file can be read again by TABLE.READTABLEFILE and all data is
%     restored.
%
%   Syntax
%     WRITETABLEFILE(T,filename)
%
%   Description
%     WRITETABLEFILE(T,filename)  Writes table T to an Excel file named
%       filename.
%
%   Example(s)
%     WRITETABLEFILE(tbl,'~/table.xlsx)  Writes table tbl to the Excel file
%       '~/table.xlsx'.
%
%
%   Input Arguments
%     T - Input table
%       table
%         The input table that is written to file. The table metadata stored at
%         T.Properties.<meta>, where <meta> can be VariableNames,
%         VariableUnits and VariableDescriptions will be written to the first
%         three header rows respectively. The fourth header row defines the data
%         type of the column following the formatSpec of <a href="https://www.mathworks.com/help/releases/R2017b/matlab/ref/textscan.html#inputarg_formatSpec">textscan</a>.
%
%     filename - File name
%       char vector
%         File name specified as a character vector. To write to a specific
%         folder, specify the full path name. Otherwise, WRITETABLEFILE writes
%         to a file in the current folder.
%
%
%   Output Arguments
%
%
%   Name-Value Pair Arguments
%
%
%   See also TABLE.READTABLEFILE, TABLE
%
%   Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
%
    
    import internal.stats.parseArgs
    import table.formatSpec
    
    % Validate inputs
    validateattributes(T,{'table'},{'nonempty'},mfilename,'T',1)
    validateattributes(filename,{'char'},{'row','nonempty'},mfilename,'filename',2)

    nHeaderRows = 4;
    nDataRows   = size(T,1);
    nCols       = size(T,2);
    
    % Generate Excel range for header and data
    rHeader = sub2excelRange([1,1],[nHeaderRows,nCols]);
    rData   = sub2excelRange([nHeaderRows + 1,1],[nHeaderRows + nDataRows,nCols]);
    
    % Get the formatSpec for each column
    fSpec   = arrayfun(@(col) formatSpec(class(T{1,col})),1:nCols);
    fS      = arrayfun(@(fs) fs.FormatSpec{1},fSpec,'un',0);
    
    % Force all datetime columns to use this format string to ensure locale
    % independence.
    fS      = strrep(fS,'%D','%{yyyy-MM-dd HH:mm:ss}D');
    
    % Error if fSpec contains non cellstr cells
    columnIsCell = fSpec == 'cell';
    if any(columnIsCell)
        assert(all(ismember(cellfun(@class,T{1,columnIsCell},'un',0),'char')),...
            'Utilities:table:writeTableFile:NonCellstrCellColumn',...
            'All cell columns are required to be cellstr.')
    end
    
    % Generate header table
    headerC = cat(1,...
        T.Properties.VariableNames,...
        T.Properties.VariableUnits,...
        T.Properties.VariableDescriptions,...
        fS);
    headerT = cell2table(headerC);
    
    % Deal with Inf, -Inf and missing values (NaN, NaT, <undefined>)    
    isFloat = ismember(fSpec,{'double','single'}); % For NaN, Inf & -Inf
    isDatetime = fSpec == 'datetime'; % For NaT, Inf & -Inf
    isCategorical = fSpec == 'categorical'; % For <undefined>
    
    % Deal with float NaN, Inf & -Inf
    if any(isFloat)
        % Find NaN, Inf or -Inf
        colInd          = find(isFloat);
        isNaNOrInf      = arrayfun(@(col) isnan(T{:,col}) | isinf(T{:,col}),colInd,'un',0);
        isNaNOrInf      = cat(2,isNaNOrInf{:});
        colHasNaNOrInf  = any(isNaNOrInf,1);
        
        if any(colHasNaNOrInf)
            % Convert columns that contain NaN, Inf or -Inf to cellstr. NaNs, Inf & -Inf are
            % are converted to 'NaN', 'Inf' & '-Inf' respectively.
            convertColToCellstrInd = colInd(colHasNaNOrInf);
            T = convertFloatToCellstr(T,convertColToCellstrInd);
        end
    end
    
    % Deal with datetime NaT, Inf & -Inf
    if any(isDatetime)
        % Find NaT, Inf or -Inf
        colInd          = find(isDatetime);
        
        % Convert all columns to cellstr, even if they don't contain NaT, Inf or -Inf.
        % The datestr format is id 31 ('yyyy-mm-dd HH:MM:SS', see 'help datestr') in 
        % order to be locale independent. NaT, Inf & -Inf are converted to 'NaT', 'Inf'
        % & '-Inf'respectively.
        T = convertDatetimeToCellstr(T,colInd);
    end
    
    % Deal with categorical <undefined>
    if any(isCategorical)
        % Find <undefined>
        colInd          = find(isCategorical);
        isUndefined     = isundefined(T{:,colInd});
        colHasUndefined = any(isUndefined,1);
        
        if any(colHasUndefined)
            convertColToCellstrInd = colInd(colHasUndefined);
            T = convertCategoricalToCellstr(T,convertColToCellstrInd);
        end
    end
    
    % Write header
    writetable(headerT,filename,...
        'FileType',             'spreadsheet',...
        'WriteVariableNames',   false,...
        'Range',                rHeader{:});
    
    % Write data
    writetable(T,filename,...
        'FileType',             'spreadsheet',...
        'WriteVariableNames',   false,...
        'Range',                rData{:});
    
    function T = convertFloatToCellstr(T,columns)
        for cc = 1:numel(columns)
            ind = columns(cc);
            T.(T.Properties.VariableNames{ind}) = strip(cellstr(num2str(T{:,ind})));
        end
    end
    function T = convertDatetimeToCellstr(T,columns)
        for cc = 1:numel(columns)
            ind = columns(cc);
            valIsInf = isinf(T{:,ind});
            valIsNaT = isnat(T{:,ind});
            asStr = repmat({''},size(T(:,ind)));
            asStr(valIsInf) = strip(cellstr(num2str(subsref(datevec(T{valIsInf,ind}),struct('type',{'()'},'subs',{{':',1}})))));
            asStr(valIsNaT) = repmat({'NaT'},sum(valIsNaT),1);
            asStr(~valIsInf & ~valIsNaT) = cellstr(datestr(T{~valIsInf & ~valIsNaT,ind},31));
            T.(T.Properties.VariableNames{ind}) = asStr;
        end
    end
    function T = convertCategoricalToCellstr(T,columns)
        for cc = 1:numel(columns)
            ind = columns(cc);
            T.(T.Properties.VariableNames{ind}) = cellstr(T{:,ind});
        end
    end
end