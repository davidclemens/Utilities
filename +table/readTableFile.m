function T = readTableFile(filename, varargin)
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
%         1 to 3 are read as character vectors. 4 must be one of the types
%         defined in the formatSpec of <a href="https://www.mathworks.com/help/releases/R2017b/matlab/ref/textscan.html#inputarg_formatSpec">textscan</a>.
%
%         Tips:
%           - To skip a column add a star to format spec: %*k, where k is any 
%             conversion specifier.
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
%   See also TABLE
%
%   Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
%

    % TODO: validate header rows.
    
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
    
    % make sure all header entries are cellstrings
    rawHeader       = rawWithHeader(1:4,:);
    rawHeader(~cellfun(@ischar,rawHeader))	= {''};
    VarFormat       = rawHeader(4,:);     % extract variable format

    % definitions
    validFormatSpec             = {'%d','%d8','%d16','%d32','%d64','%u','%u8','%u16','%u32','%u64','%f','%f32','%f64','%n','%L','%s','%D','%C'};
    validFormatSpecClass        = {'int32','int8','int16','int32','int64','uint32','uint8','uint16','uint32','uint64','double','single','double','double','logical','cellstr','datetime','categorical'};
    validFormatSpecIsNumeric    = [true,true,true,true,true,true,true,true,true,true,true,true,true,true,false,false,false,false];
    validFormatSpecRE           = {'^%(\*?)\*?d$','^%(\*?)d8$','^%(\*?)d16$','^%(\*?)d32$','^%(\*?)d64$','^%(\*?)u$','^%(\*?)u8$','^%(\*?)u16$','^%(\*?)u32$','^%(\*?)u64$','^%(\*?)f$','^%(\*?)f32$','^%(\*?)f64$','^%(\*?)n$','^%(\*?)L$','^%(\*?)s$','^%(\*?)D$','^%(\*?)C$'};
    nValidFormatSpecs           = numel(validFormatSpecRE);

    [validClasses,indU1,indU2] 	= unique(validFormatSpecClass,'stable');
    validClassesIsNumeric       = validFormatSpecIsNumeric(indU1);
    nValidClasses               = numel(validClasses);
    
    % check formatSpec input
    nColumns            = size(rawWithHeader,2);
    maskFormatSpec     	= false(nValidFormatSpecs,nColumns);
    tokens              = cell(nValidFormatSpecs,nColumns);
    for fs = 1:nValidFormatSpecs
        [tmp1,tokens(fs,:)]  	= regexp(VarFormat,validFormatSpecRE{fs},'start','tokens','forceCellOutput');
        maskFormatSpec(fs,:)  	= ~cellfun(@isempty,tmp1);
    end
    
    % Find columns to skip
    tokens = cat(1,tokens{maskFormatSpec});
    tokens = cat(1,tokens{:});
    keepColumns = ~ismember(tokens,'*');
    
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
                case 'cellstr'
                    classCell{cl} = repmat({''},nRows,1);
                case 'datetime'
                    classCell{cl} = NaT(nRows,1,'Format','dd.MM.yyyy HH:mm:ss');
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
                    case 'cellstr'
                        valIsChar = cellfun(@ischar,rawIn);
                        if any(valIsChar)
                            data = T{~maskNoData(:,col),col}; % Initialize
                            data(valIsChar) = rawIn(valIsChar);
                            data(~valIsChar) = cellfun(@(s) num2str(s,'%g'),rawIn(~valIsChar),'un',0); % Convert numerics and logicals to cellstr
                        else
                            data = rawIn;
                        end
                    case 'datetime'
                        data    = datetime(cat(1,rawIn{:}),'ConvertFrom','excel');
                    case 'categorical'
                        valIsNumeric = cellfun(@isnumeric,rawIn);
                        if any(valIsNumeric)
                            data = T{~maskNoData(:,col),col}; % Initialize
                            data(valIsNumeric) = categorical(cellfun(@num2str,rawIn(valIsNumeric),'un',0));
                            data(~valIsNumeric) = categorical(rawIn(~valIsNumeric));
                        else
                            data = categorical(rawIn);
                        end
                    otherwise
                        error('Utilities:table:readTableFile:TODO',...
                          'TODO: ''%s'' needs implementing',columnClass)
                end
            end
        catch ME
            switch ME.identifier
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
