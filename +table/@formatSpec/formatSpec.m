classdef formatSpec
    % formatSpec  Find the formatSpec of a class
    % This enumeration class defines the formatSpec for all relevant classes (as
    % defined in <a href="https://www.mathworks.com/help/releases/R2017b/matlab/ref/textscan.html#inputarg_formatSpec">textscan</a>) as well as their constructors.
    %
    %
    % Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
    %
    
    enumeration
        % class         Id      FromatSpec                  Constructor
        double         	(0,     {'%f';'%f64';'%n'},         @double)
        single          (1,     {'%f32'},                   @single)
        int8            (2,    	{'%int8'},                  @int8)
        int16           (3,    	{'%int16'},                 @int16)
        int32           (4,    	{'%int32'},                 @int32)
        int64           (5,    	{'%int64'},                 @int64)
        uint8           (6,    	{'%uint8'},                 @uint8)
        uint16          (7,    	{'%uint16'},                @uint16)
        uint32          (8,    	{'%uint32'},                @uint32)
        uint64          (9,    	{'%uint64'},                @uint64)
        logical         (10,   	{'%L'},                     @logical)
        datetime        (11,   	{'%D'},                     @datetime)
        categorical     (12,   	{'%C'},                     @categorical)
        cell            (13,   	{'%s'},                     @cell)
    end
    properties (SetAccess = 'immutable')
        Id uint8
        FormatSpec cell
        Constructor function_handle
    end
    methods
        function obj = formatSpec(id,fSpec,constructor,varargin)
            obj.Id              = id;
            obj.FormatSpec      = fSpec;
            obj.Constructor     = constructor;
        end
    end
end
