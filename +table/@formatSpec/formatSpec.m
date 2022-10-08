classdef formatSpec
    % formatSpec  Find the formatSpec of a class
    % This enumeration class defines the formatSpec for all relevant classes (as
    % defined in <a href="https://www.mathworks.com/help/releases/R2017b/matlab/ref/textscan.html#inputarg_formatSpec">textscan</a>) as well as their constructors.
    %
    %
    % Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
    %
    
    enumeration
        % class         Id      FromatSpec          IsNumeric   Constructor
        double         	(0,     {'%f';'%f64';'%n'}, true,       @double)
        single          (1,     {'%f32'},           true,       @single)
        int8            (2,    	{'%d8'},            true,       @int8)
        int16           (3,    	{'%d16'},           true,       @int16)
        int32           (4,    	{'%d32'},           true,       @int32)
        int64           (5,    	{'%d64'},           true,       @int64)
        uint8           (6,    	{'%u8'},            true,       @uint8)
        uint16          (7,    	{'%u16'},           true,       @uint16)
        uint32          (8,    	{'%u32'},           true,       @uint32)
        uint64          (9,    	{'%u64'},           true,       @uint64)
        logical         (10,   	{'%L'},             false,      @logical)
        datetime        (11,   	{'%D'},             false,      @datetime)
        categorical     (12,   	{'%C'},             false,      @categorical)
        cell            (13,   	{'%s'},             false,      @cell)
    end
    properties (SetAccess = 'immutable')
        Id uint8
        FormatSpec cell
        IsNumeric logical
        Constructor function_handle
    end
    methods
        function obj = formatSpec(id,fSpec,isNumeric,constructor,varargin)
            obj.Id              = id;
            obj.FormatSpec      = fSpec;
            obj.IsNumeric       = isNumeric;
            obj.Constructor     = constructor;
        end
    end
    methods (Static)
        function T = listFormatSpecs()
        % listFormatSpecs  Table overview of all formatSpecs
        %   LISTFORMATSPECS creates a table that lists, Class and IsNumeric attributes
        %   for each formatSpec.
        %
        %   Syntax
        %     T = LISTFORMATSPECS()
        %
        %   Description
        %     T = LISTFORMATSPECS()  returns table T that lists Class and IsNumeric
        %       attributes for each formatSpec
        %
        %   Example(s)
        %     T = LISTFORMATSPECS()  returns table T that lists Class and IsNumeric
        %       attributes for each formatSpec
        %
        %
        %   Input Arguments
        %
        %
        %   Output Arguments
        %     T - Overview table
        %       table
        %         Overview table returned as a table with columns FormatSpec, Class &
        %         IsNumeric. The table holds one row for each formatSpec.
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
                repmat({f.IsNumeric},size(f.FormatSpec))), ...
                enumeration('table.formatSpec'),'un',0);

            % Convert to table
            T = cell2table(cat(1,C{:}),'VariableNames',{'FormatSpec','Class','IsNumeric'});
        end
    end
end
