classdef formatSpec
    % formatSpec  Find the formatSpec of a class
    % This enumeration class defines the formatSpec for all relevant classes (as
    % defined in <a href="https://www.mathworks.com/help/releases/R2017b/matlab/ref/textscan.html#inputarg_formatSpec">textscan</a>) as well as their constructors.
    %
    %
    % Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
    %
    
    enumeration
        % class         Id      FormatSpec          IsNumeric   Constructor
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
        duration        (14,   	{'%T'},             false,      @duration)
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
        T = listFormatSpecs()
        tf = isValidFormatSpec(A)
        obj = fromFormatSpec(A)
    end
end
