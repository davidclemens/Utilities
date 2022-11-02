function T = readTableFile(filename)
% readTableFile  Read fully defined Excel table
%   READTABLEFILE reads an Excel file with four header rows that define the
%     column names, descriptions, units and data types, which are returned as
%     properties of the resulting table.
%
%   Syntax
%     T = READTABLEFILE(filename)
%
%   Description
%     T = READTABLEFILE(filename)  Reads file filename and returns table T,
%       which stores the metadata found in the four header rows of the file.
%
%   Example(s)
%     T = READTABLEFILE('table.xls')  Returns the table found in 'table.xls' as
%       table T.
%
%
%   Input Arguments
%     filename - Full path to file
%       char vector
%         Full path to the file to read, specified as a character vector. The
%         four header rows are required and are defined as follows:
%
%         1. Variable (column) names
%         2. Variable (column) units
%         3. Variable (column) descriptions
%         4. Varaible (column) data type
%
%         1 to 3 are read as character vectors. 4 must be one of the conversion
%         specifiers defined in the formatSpec of <a href="https://www.mathworks.com/help/releases/R2017b/matlab/ref/textscan.html#inputarg_formatSpec">textscan</a>.
%         
%         Special values are interpreted as follows:
%           - If data type is double or single, 'NaN' & empty cells are read as
%             NaN. 'Inf' & '-Inf' are read as Inf & -Inf respectively.
%           - If data type is datetime, 'NaT' & empty cells are read as NaT.
%            'Inf' & '-Inf' are read as Inf & -Inf respectively.
%           - If data type is categorical, '<undefined>' is read as <undefined>.
%
%         Tips:
%           - To skip a column add a star to format spec: %*k, where k is any 
%             conversion specifier.
%           - To improve importing of non-Excel datetimes, also specify the
%             formatSpec of the column with '%{fmt}D' as defined for <a href="https://www.mathworks.com/help/releases/R2017b/matlab/ref/datetime.html#inputarg_infmt">datetime</a>.
%
%   Output Arguments
%     T - Output table
%       table
%         Output table returned as a table. The table stores the metadata
%         defined in the four header rows of the file. They can be accessed
%         with T.Properties.<meta>, where <meta> can be VariableNames,
%         VariableDescriptions or VariableUnits.
%
%
%   Name-Value Pair Arguments
%
%
%   See also TABLE.READTABLEFILE, TABLE
%
%   Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
%

    import table.formatSpec.isValidFormatSpec
    
    % TODO: Validate header rows.
    
    % Check that file exists
    if exist(filename,'file') ~= 2
        error('Utilities:table:readTableFile:InvalidFile',...
            '''%s'' is not a valid file.',filename)
    end
    
    % Read the file
    [~,~,ext]  = fileparts(filename);
    switch ext
        case {'.xls','.xlsx'}
            [~,~,rawWithHeader]       = xlsread(filename,'','','basic');
        otherwise
            error('Utilities:table:readTableFile:unknownFiletype',...
                'The reading of table files with file extension ''%s'' is not implemented yet.',ext)
    end
    
    % Validate number of rows
    nRows = size(rawWithHeader,1);
    if nRows < 4
        error('Utilities:table:readTableFile:MissingHeader',...
        	'There are only %u rows in the table file. At least 4 header rows are required.',nRows)
    end
    
    % Make sure all header entries are cellstrings
    rawHeader       = rawWithHeader(1:4,:);
    rawHeader(~cellfun(@ischar,rawHeader))	= {''};
    VarFormat       = rawHeader(4,:);     % extract variable format

    % Definitions of format specifiers
    validFormatSpecT            = table.formatSpec.listFormatSpecs;
    validFormatSpec             = validFormatSpecT{:,'FormatSpec'};
    validFormatSpecClass        = validFormatSpecT{:,'Class'};
    validFormatSpecIsNumeric    = validFormatSpecT{:,'IsNumeric'};
    validFormatSpecRE           = validFormatSpecT{:,'Regexp'};
    nValidFormatSpecs           = numel(validFormatSpecRE);

    [validClasses,indU1,indU2] 	= unique(validFormatSpecClass,'stable');
    validClassesIsNumeric       = validFormatSpecIsNumeric(indU1);
    nValidClasses               = numel(validClasses);
    
    % Check formatSpec input
    formatSpecIsValid   = isValidFormatSpec(VarFormat);
    assert(all(formatSpecIsValid),...
        'Utilities:table:readTableFile:invalidFormatSpec',...
        '''%s'' is not a valid formatSpec in column %u of file:\n\t%s\nValid formatSpecs are:\n\t%s',VarFormat{find(~formatSpecIsValid,1)},find(~formatSpecIsValid,1),filename,strjoin(validFormatSpec,'\n\t'))
    
    % Find formatSpec attributes
    nColumns            = size(rawWithHeader,2);
    maskFormatSpec     	= false(nValidFormatSpecs,nColumns);
    tokens              = cell(nValidFormatSpecs,nColumns);
    for fs = 1:nValidFormatSpecs
        [tmp1,tokens(fs,:)]  	= regexp(VarFormat,validFormatSpecRE{fs},'start','names','forceCellOutput');
        maskFormatSpec(fs,:)  	= ~cellfun(@isempty,tmp1);
    end
    [formatSpecInd,~] = find(maskFormatSpec);
    fSAttributes = table;
    for col = 1:nColumns
        tmp = tokens{formatSpecInd(col),col};
        if ~ismember('formatSpec',fieldnames(tmp))
            % If there is no formatSpec column, add it. This is missing for all format
            % specifiers except for datetime and duration.
            tmp.formatSpec = '';
        end
        fSAttributes = cat(1,fSAttributes,struct2table(tmp,'AsArray',true));
    end
    keepColumns = ~ismember(fSAttributes{:,'keepColumn'},'*');
    formatSpec	= cellfun(@(s) regexprep(s,'[{}]',''),fSAttributes{:,'formatSpec'},'un',0);
    
    % Only keep relevant columns
    if ~all(keepColumns)
        % Update relevant variables
        rawWithHeader = rawWithHeader(:,keepColumns);
        rawHeader = rawHeader(:,keepColumns);
        maskFormatSpec = maskFormatSpec(:,keepColumns);
        VarFormat = VarFormat(:,keepColumns);
    end

    % Extract header information
    VarName         = rawHeader(1,:);     % extract variable name
    VarUnit         = rawHeader(2,:);     % extract variable unit
    VarDesc         = rawHeader(3,:);     % extract variable description
    
    % Extract raw data
    raw                 = rawWithHeader(5:end,:); % extract data
    [nRows,nColumns]	= size(raw);
    
    indUnknownFormatSpec    = find(sum(maskFormatSpec) ~= 1,1);
    if ~isempty(indUnknownFormatSpec)
        error('Utilities:table:readTableFile:noValidFormatSpecFound',...
            '''%s'' is not a valid formatSpec in file:\n\t%s\nValid formatSpecs are:\n\t%s',VarFormat{indUnknownFormatSpec},filename,strjoin(validFormatSpec,'\n\t'))
    end
    
    % Initialize the empty table
    validClassesCount       = accumarray(indU2,sum(maskFormatSpec,2),[nValidClasses,1],@sum);
    occuringClassesInd   	= find(validClassesCount > 0);
    occuringClassesN        = numel(occuringClassesInd);
    occuringClasses         = validClasses(occuringClassesInd);

    classCell           = cell(occuringClassesN,1);
    classCellColumns    = cell(occuringClassesN,1);
    
    % Loop over all classes occuring in the file and initialize them respectively
    for cl = 1:occuringClassesN
        maskColumns     = any(maskFormatSpec(indU2 == occuringClassesInd(cl),:));
        classCellColumns{cl}    = find(maskColumns);
        if validClassesIsNumeric(occuringClassesInd(cl))
            switch validClasses{occuringClassesInd(cl)}
                case {'single','double'}
                    classCell{cl} = NaN(nRows,1,validClasses{occuringClassesInd(cl)});
                otherwise
                    classCell{cl} = zeros(nRows,1,validClasses{occuringClassesInd(cl)});
            end
        else
            switch validClasses{occuringClassesInd(cl)}
                case 'logical'
                    classCell{cl} = false(nRows,1);
                case 'cell'
                    classCell{cl} = repmat({''},nRows,1);
                case 'datetime'
                    classCell{cl} = NaT(nRows,1);
                case 'duration'
                    classCell{cl} = duration(NaN(nRows,3));
                case 'categorical'
                    classCell{cl} = categorical(NaN(nRows,1));
                otherwise
                    error('Utilities:table:readTableFile:formatSpecNotImplemented',...
                        'Class ''%s'' is not implemented (yet).',occuringClasses{cl})
            end
        end
    end
    
    % Convert to table holding the initialized class values.
    initTbl    	= table(classCell{:});
    
    % Grow the table
    [tmpInd1,~]	= find(maskFormatSpec);
    [tmpInd2,~]	= find(indU2(tmpInd1)' == occuringClassesInd);
    T           = initTbl(:,tmpInd2);
    
    % Set table metadata
    % TODO: make invalid variable names valid using matlab.lang.makeValidName
    T.Properties.VariableNames            = VarName;
    T.Properties.VariableDescriptions     = VarDesc;
    T.Properties.VariableUnits            = VarUnit;
    
    % Flag empty raw data columns
    maskNoData = cellfun(@(x) ...
        isempty(x) || ...
        (isnumeric(x) && isnan(x)) || ...
        strcmp(x,'NaN') || ...
        strcmp(x,'NaT') || ...
        (isdatetime(x) && isnat(x)) || ...
        (iscategorical(x) && isundefined(x)), ...
        raw);
    maskColContainsNoData   = all(maskNoData,1);
    
    % Write raw data to table
    for col = 1:nColumns
        columnClassInd	= indU2(maskFormatSpec(:,col));
        columnClass     = validClasses{columnClassInd};

        if maskColContainsNoData(col)
            continue
        end

        % Try to convert the data to the correct data type
        try
            rawIn = raw(~maskNoData(:,col),col);
            if validClassesIsNumeric(columnClassInd)
                % If the raw numeric data contains text, try to convert it to numeric
                valIsChar = cellfun(@ischar,rawIn);
                if any(valIsChar)
                    data = T{~maskNoData(:,col),col}; % Initialize
                    data(valIsChar) = cellfun(@str2double,rawIn(valIsChar)); % Convert chars to numeric
                    data(~valIsChar) = cat(1,rawIn{~valIsChar}); 
                else
                    data = cat(1,rawIn{:});
                end
            else
                switch columnClass
                    case 'logical'
                        % If the raw logical data contains text, try to convert it to logicals
                        valIsChar = cellfun(@ischar,rawIn);
                        if any(valIsChar)
                            data = T{~maskNoData(:,col),col}; % Initialize
                            data(valIsChar) = cellfun(@(s) strcmp(validatestring(s,{'True','False'}),'True'),rawIn(valIsChar)); % Convert True, TRUE, true, T, t, False, FALSE, false, F & f to logical
                            data(~valIsChar) = logical(cat(1,rawIn{~valIsChar})); % Convert numeric data to logical. Everything becomes True, except for 0, which becomes False.
                        else
                            data = logical(cat(1,rawIn{:})); % If raw logical data contains no text save the extra steps.
                        end
                    case 'cell'
                        valIsChar = cellfun(@ischar,rawIn);
                        if any(valIsChar)
                            data = T{~maskNoData(:,col),col}; % Initialize
                            data(valIsChar) = rawIn(valIsChar);
                            data(~valIsChar) = cellfun(@(s) num2str(s,'%g'),rawIn(~valIsChar),'un',0); % Convert numerics and logicals to cellstr
                        else
                            data = rawIn;
                        end
                    case 'datetime'
                        valIsChar = cellfun(@ischar,rawIn);
                        valIsInf = valIsChar;
                        valIsInf(valIsChar) = ~cellfun(@isempty,regexp(rawIn(valIsChar),'^\-?Inf$','forcecelloutput'));
                        valIsNonInfChar = valIsChar & ~valIsInf;
                        valIsExcelNumeric = ~valIsChar;
                        
                        data = T{~maskNoData(:,col),col}; % Initialize
                        if any(valIsNonInfChar)
                            % If rawIn contains chars and the column is a datetime, the row(s) containing
                            % chars are not an Excel date. Import them accorting to formatSpec, but import
                            % Excel dates (row(s) containing numeric values) as Excel dates.
                            
                            % Non-Excel dates only work with non-empty formatSpec
                            assert(~isempty(formatSpec{col}),...
                                'Utilities:table:readTableFile:NonExcelDateWithoutFormatSpec',...
                                'Column %u has non-Excel-date dates (prior to 1900) without a formatSpec being specified. Please specify a formatSpec in the 4th header row as ''%%{fmt}D''.',col)
                            
                            data(valIsNonInfChar)	= datetime(rawIn(valIsNonInfChar),...
                                                'InputFormat',  formatSpec{col},...
                                                'Locale',       'system');
                        end
                        if any(valIsInf)
                            data(valIsInf) = datetime(rawIn(valIsInf));
                        end
                        if any(valIsExcelNumeric)
                            % Excel 1900 date system is used
                            data(valIsExcelNumeric) = datetime(cat(1,rawIn{valIsExcelNumeric}),'ConvertFrom','excel');
                        end
                    case 'duration'
                        valIsChar = cellfun(@ischar,rawIn);
                        valIsInf = valIsChar;
                        valIsInf(valIsChar) = ~cellfun(@isempty,regexp(rawIn(valIsChar),'^\-?Inf$','forcecelloutput'));
                        valIsNonInfChar = valIsChar & ~valIsInf;
                        valIsExcelNumeric = ~valIsChar;
                        
                        data = T{~maskNoData(:,col),col}; % Initialize
                        if any(valIsNonInfChar)
                            % If rawIn contains chars and the column is a duration, the row(s) containing
                            % chars are not an Excel date. Import them accorting to formatSpec.
                            
                            % Non-Excel dates only work with non-empty formatSpec
                            assert(~isempty(formatSpec{col}),...
                                'Utilities:table:readTableFile:interpretDurationFormatSpecifierAndData:NonNumericDurationWithoutFormatSpec',...
                                'Column %u has non-numeric duration without a formatSpec being specified. Please specify a formatSpec in the 4th header row as ''%%{fmt}T''.',col)
                            
                            % Process the cellstr data
                            [func,durationComponents] = interpretDurationFormatSpecifierAndData(formatSpec{col},rawIn(valIsNonInfChar));
                            
                            % Convert numbers to duration
                            data(valIsNonInfChar) = func(durationComponents);
                        end
                        if any(valIsInf)
                            data(valIsInf) = duration(repmat(str2double(rawIn(valIsInf)),1,3));
                        end
                        if any(valIsExcelNumeric)
                            % A duration in Excel is given in fractional days
                            if ~isempty(formatSpec{col})
                                switch formatSpec{col}
                                    case 'y'
                                        func = @years;
                                    case 'd'
                                        func = @days;
                                    case 'h'
                                        func = @hours;
                                    case 'm'
                                        func = @minutes;
                                    case 's'
                                        func = @seconds;
                                    otherwise
                                        error('Utilities:table:readTableFile:interpretDurationFormatSpecifierAndData:invalidSingleNumberDurationFormatSpecifier',...
                                            ['The duration format specifier of type single number ''%s'' is invalid.\n',...
                                             'Valid single number duration format specifiers are:\n',...
                                             '\t''y''\n\t''d''\n\t''h''\n\t''m''\n\t''s'''],...
                                             formatSpec{col})
                                end
                                data(valIsExcelNumeric) = func(cat(1,rawIn{valIsExcelNumeric}));
                            else
                                data(valIsExcelNumeric) = days(cat(1,rawIn{valIsExcelNumeric}));
                            end
                        end
                    case 'categorical'
                        % Replace '<undefined>' with '' to be converted to <undefined>
                        isChar          = cellfun(@ischar,rawIn);
                        rawIn(isChar)   = cellfun(@(s) strrep(s,'<undefined>',''),rawIn(isChar),'un',0);
                        
                        valIsNumeric = cellfun(@isnumeric,rawIn);
                        if any(valIsNumeric)
                            data = T{~maskNoData(:,col),col}; % Initialize
                            data(valIsNumeric) = categorical(cellfun(@num2str,rawIn(valIsNumeric),'un',0));
                            data(~valIsNumeric) = categorical(rawIn(~valIsNumeric));
                        else
                            data = categorical(rawIn);
                        end
                    otherwise
                        error('Utilities:table:readTableFile:invalidFormatSpecifier',...
                          'TODO: ''%s'' needs implementing',columnClass)
                end
            end
        catch ME
            switch ME.identifier
                case {'Utilities:table:readTableFile:NonExcelDateWithoutFormatSpec'}
                    rethrow(ME)
                otherwise
                    error('Utilities:table:readTableFile:Conversion',...
                        'While trying to convert column %u to %s the following error occured:\n%s\n',col,columnClass,ME.message)
            end
        end

        % Try to write the data to the table
        try
            T{~maskNoData(:,col),col}     = data;
        catch ME
            switch ME.identifier
                otherwise
                    rethrow(ME)
            end
        end
    end
end

function [func,dataComponents] = interpretDurationFormatSpecifierAndData(fmt,dataStr)

    nDigits = @(x) 10.^(floor(log10(max(1,abs(x)))) + 1);
    
    % Test if the format is a single number duration
    isSingleNumberDurationFormat = ~cellfun(@isempty,regexp(fmt,'^[smhdy]$','forceCellOutput'));
    isDigitalTimerDurationFormat = strncmp(fmt,'dd:hh:mm:ss',numel('dd:hh:mm:ss')) || ...
                                   strncmp(fmt,'hh:mm:ss',numel('hh:mm:ss')) || ...
                                   strncmp(fmt,'mm:ss',numel('mm:ss')) || ...
                                   strncmp(fmt,'hh:mm',numel('hh:mm'));
    if isSingleNumberDurationFormat
        % Single number with time unit
        switch fmt
            case 'y'
                func = @years;
            case 'd'
                func = @days;
            case 'h'
                func = @hours;
            case 'm'
                func = @minutes;
            case 's'
                func = @seconds;
            otherwise
                error('Utilities:table:readTableFile:interpretDurationFormatSpecifierAndData:invalidSingleNumberDurationFormatSpecifier',...
                    ['The duration format specifier of type single number ''%s'' is invalid.\n',...
                     'Valid single number duration format specifiers are:\n',...
                     '\t''y''\n\t''d''\n\t''h''\n\t''m''\n\t''s'''],...
                     fmt)
        end

        % Convert raw data duration components to numbers
        dataComponents = cellfun(@str2double,dataStr);

    elseif isDigitalTimerDurationFormat
        % Digital timer formats
        timerComponents = strsplit(fmt,'.');
        hasFractionalSeconds = numel(timerComponents) == 2;
        if hasFractionalSeconds
            expressionFractionalSeconds = ['\.(?<fractionalSeconds>\d{',num2str(numel(timerComponents{2})),'})'];
        else
            expressionFractionalSeconds = '';
        end
        switch timerComponents{1}
            case 'dd:hh:mm:ss'
                expression = '^(?<days>\-?\d+):(?<hours>\-?\d{2}):(?<minutes>\-?\d{2}):(?<seconds>\-?\d{2})';
                func1 = @(x) days(x(:,1)) + hours(x(:,2)) + minutes(x(:,3)) + seconds(x(:,4));
            case 'hh:mm:ss'
                expression = '^(?<hours>\-?\d+):(?<minutes>\-?\d{2}):(?<seconds>\-?\d{2})';
                func1 = @(x) hours(x(:,1)) + minutes(x(:,2)) + seconds(x(:,3));
            case 'mm:ss'
                expression = '^(?<minutes>\-?\d+):(?<seconds>\-?\d{2})';
                func1 = @(x) minutes(x(:,1)) + seconds(x(:,2));
            case 'hh:mm'
                expression = '^(?<hours>\-?\d+):(?<minutes>\-?\d{2})';
                func1 = @(x) hours(x(:,1)) + minutes(x(:,2));
            otherwise
                error('Utilities:table:readTableFile:interpretDurationFormatSpecifierAndData:invalidDigitalTimerDurationFormatSpecifier',...
                    ['The duration format specifier of type digital timer ''%s'' is invalid.\n',...
                     'Valid digital timer duration format specifiers are:\n',...
                     '\t''dd:hh:mm:ss''\n\t''hh:mm:ss''\n\t''mm:ss''\n\t''hh:mm''\nFor any of the first three formats, up to nine S characters can be appended to indicate fractional second digits, such as ''hh:mm:ss.SSSS''.'],...
                     fmt)
        end
        if hasFractionalSeconds && strcmp(timerComponents{1}(end - 1:end),'ss')
            expression = cat(2,expression,expressionFractionalSeconds);
            func = @(x) func1(x(:,1:end - 1)) + seconds(x(:,end)./nDigits(x(:,end)));
        else
            func = @(x) func1(x);
        end

        % Convert raw data duration components to numbers
        tokens = regexp(dataStr,expression,'names','forceCellOutput');
        dataComponents = cellfun(@str2double,struct2cell(cat(1,tokens{:})))';
    else
        error('Utilities:table:readTableFile:interpretDurationFormatSpecifierAndData:invalidDurationFormatSpecifier',...
            ['The duration format specifier ''%s'' is invalid.\n',...
             'Valid single number duration format specifiers are:\n',...
             '\t''y''\n\t''d''\n\t''h''\n\t''m''\n\t''s''\n',...
             'Valid digital timer duration format specifiers are:\n',...
             '\t''dd:hh:mm:ss''\n\t''hh:mm:ss''\n\t''mm:ss''\n\t''hh:mm''\nFor any of the first three formats, up to nine S characters can be appended to indicate fractional second digits, such as ''hh:mm:ss.SSSS''.'],...
             fmt)
    end
end
