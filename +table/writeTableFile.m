function writeTableFile(T,filename,varargin)
% writeTableFile  Write table to fully defined Excel table
%   WRITETABLEFILE writes a table to an Excel table with four header rows that 
%     define the column names, descriptions, units and data types of each
%     column. That file can be read again by TABLE.READTABLEFILE and all data is
%     restored.
%
%   Syntax
%     WRITETABLEFILE(T,filename)
%     WRITETABLEFILE(__,Name,Value)
%
%   Description
%     WRITETABLEFILE(T,filename)  Writes table T to an Excel file named
%       filename.
%     WRITETABLEFILE(__,Name,Value)  Add additional options specified by one or
%       more Name,Value pair arguments. You can include any of the input
%       arguments in previous syntaxes.
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
%     WriteNaNs - Write NaNs to the file
%       false (default) | true
%         If false, WRITETABLEFILE replaces all NaNs in the table with blanks
%         (default). If true, NaNs are included in the file.
%
%
%   See also TABLE.READTABLEFILE, TABLE
%
%   Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
%
    
    import internal.stats.parseArgs
    import table.formatSpec
    
    
    %   parse Name-Value pairs
    optionName          = {'WriteNaNs'}; %   valid options (Name)
    optionDefaultValue  = {false}; %   default value (Value)
    [WriteNaNs...
    ]	= parseArgs(optionName,optionDefaultValue,varargin{:}); %   parse function arguments
    
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
    
    % Error if fSpec contains non cellstr cells
    assert(all(ismember(cellfun(@class,T{1,fSpec == 'cell'},'un',0),'char')),...
        'Utilities:table:writeTableFile:NonCellstrCellColumn',...
        'All cell columns are required to be cellstr.')
    
    % Generate header table
    headerC = cat(1,...
        T.Properties.VariableNames,...
        T.Properties.VariableUnits,...
        T.Properties.VariableDescriptions,...
        fS);
    headerT = cell2table(headerC);
    
    if WriteNaNs
        error('Utilities:table:writeTableFile:TODO',...
            'Writing NaNs is not implemented yet.')
    else
        % Warn about NaNs being replaced by blanks, if necessary
        couldBeNaN = ismember(fSpec,{'double','single'});
        if any(couldBeNaN) && any(reshape(isnan(T{:,couldBeNaN}),[],1))
            warning('Utilities:table:writeTableFile:NaNsReplacedByBlanks',...
                'All %u ''NaNs'' in the table were replaced by blanks.',sum(reshape(isnan(T{:,couldBeNaN}),[],1)))
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
end
