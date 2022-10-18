classdef (SharedTestFixtures = { ...
            matlab.unittest.fixtures.PathFixture(subsref(strsplit(mfilename('fullpath'),'/+'),substruct('{}',{':'})))
        }) sub2excelRange_test < matlab.unittest.TestCase
    % sub2excelRange_test  Unittests for sub2excelRange
    % This class holds the unittests for the sub2excelRange function.
    %
    % It can be run with runtests('Tests.sub2excelRange_test').
    %
    %
    % Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
    %
        
    methods (Test)
        function testValidSmallRangeScalar(testCase)
            actual      = sub2excelRange([1,1],[3,5]);
            expected    = {'A1:E3'};
            
            testCase.verifyEqual(actual,expected)
        end
        function testValidSmallRangeVector(testCase)
            actual      = sub2excelRange([2,4;1,1],[5,10;2,2]);
            expected    = {'D2:J5';'A1:B2'};
            
            testCase.verifyEqual(actual,expected)
        end
        function testValidBigRangeScalar(testCase)
            actual      = sub2excelRange([500,100],[12345,200]);
            expected    = {'CV500:GR12345'};
            
            testCase.verifyEqual(actual,expected)
        end
        function testValidBigRangeVector(testCase)
            actual      = sub2excelRange([500,100;1,1],[12345,200;1000,1000]);
            expected    = {'CV500:GR12345';'A1:ALL1000'};
            
            testCase.verifyEqual(actual,expected)
        end
        function testValidLimitRangeVector(testCase)
            actual      = sub2excelRange([1,1],[1048576,16384]);
            expected    = {'A1:XFD1048576'};
            
            testCase.verifyEqual(actual,expected)
        end
        function testInvalidRange1(testCase)            
            testCase.verifyError(@() sub2excelRange([2,2],[1,5]),'Utilities:sub2excelRange:StartRowExceedsEndRow')
        end
        function testInvalidRange2(testCase)            
            testCase.verifyError(@() sub2excelRange([1,5],[1,1]),'Utilities:sub2excelRange:StartColumnExceedsEndColumn')
        end
	end
end
