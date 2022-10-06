classdef (SharedTestFixtures = { ...
            matlab.unittest.fixtures.PathFixture(subsref(strsplit(mfilename('fullpath'),'/+'),substruct('{}',{':'})))
        }) readTableFile_test < matlab.unittest.TestCase
    % readTableFile_test  Unittests for table.readTableFile
    % This class holds the unittests for the table.readTableFile function.
    %
    % It can be run with runtests('Tests.table.readTableFile_test').
    %
    %
    % Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
    %
    
    properties
        RessourcePath = [fileparts(mfilename('fullpath')),'/ressources/']
    end
    
    methods (Test)
        function testLogical(testCase)
            % Define the file with the test data
            filename	= [testCase.RessourcePath,'tableFileLogical.xlsx'];
            
            % Read it
            T           = table.readTableFile(filename);
            
            % Only compare the actual data. Metadata is tested elsewhere
            actual      = T{:,:};
            expected    = false(19,3);
            expected([1,4:8,14:16],1) = true;
            expected(3:19,3) = true;
            
            testCase.verifyEqual(actual,expected)
        end
        function testCategorical(testCase)
            % Define the file with the test data
            filename	= [testCase.RessourcePath,'tableFileCategorical.xlsx'];
            
            % Read it
            T           = table.readTableFile(filename);
            
            % Only compare the actual data. Metadata is tested elsewhere
            actual      = T{:,:};
            expected    = categorical({
                'Cat1',     '',     'Cat1';...
                'Cat2',     '',     'Cat2';...
                '',         '',     'Cat1';...
                'Cat3',     '',     'Cat2';...
                '4',        '',     'Cat1';...
                '-10',      '',     'Cat2';...
                '4',        '',     'Cat1';...
                '-10',      '',     'Cat2';...
                '44562',    '',     'Cat1';...
                '01.01.22', '',     'Cat2';...
                '',         '',     'Cat1';...
                '',         '',     'Cat2';...
                'undefined','',     'Cat1'});
            
            testCase.verifyEqual(actual,expected)
        end
        function testDatetime(testCase)
            % Define the file with the test data
            filename	= [testCase.RessourcePath,'tableFileDatetime.xlsx'];
            
            % Read it
            T           = table.readTableFile(filename);
            
            % Only compare the actual data. Metadata is tested elsewhere
            actual      = T{:,:};
            expected    = reshape(datetime([
                2022           1           1           0           0           0
                2022           1           1          10          34           1
                 NaN         NaN         NaN         NaN         NaN         NaN
                2020           7          18           0           0           0
                 NaN         NaN         NaN         NaN         NaN         NaN
                 NaN         NaN         NaN         NaN         NaN         NaN
                 NaN         NaN         NaN         NaN         NaN         NaN
                 NaN         NaN         NaN         NaN         NaN         NaN
                 NaN         NaN         NaN         NaN         NaN         NaN
                 NaN         NaN         NaN         NaN         NaN         NaN
                 NaN         NaN         NaN         NaN         NaN         NaN
                 NaN         NaN         NaN         NaN         NaN         NaN
                2022           1           1           0           0           0
                2022           1           1           0           0           0
                2022           1           1           0           0           0
                2022           1           1           0           0           0
                2022           1           1           0           0           0
                2022           1           1           0           0           0]),[],3);
            
            testCase.verifyEqual(actual,expected)
        end
        function testCellstr(testCase)
            % Define the file with the test data
            filename	= [testCase.RessourcePath,'tableFileCellstr.xlsx'];
            
            % Read it
            T           = table.readTableFile(filename);
            
            % Only compare the actual data. Metadata is tested elsewhere
            actual      = T{:,:};
            expected    = {
                '1',        '', 'abc';
                '',         '', 'abc';
                'test',     '', 'def';
                'string',   '', 'abc';
                '1',        '', 'def';
                '-2',       '', 'def';
                '',         '', 'def';
                '',         '', 'abc'};
            
            testCase.verifyEqual(actual,expected)
        end
        function testNumeric(testCase)
            % Define the file with the test data
            filename	= [testCase.RessourcePath,'tableFileNumeric.xlsx'];
            
            % Read it
            T           = table.readTableFile(filename);
            
            % Only compare the actual data. Metadata is tested elsewhere
            expectedClasses = {'double','single','uint16','int8'};
            expectedValues  = { ...
                double([
                    1          
                    2         
                    NaN    
                    38010000   
                    31341      
                    NaN        
                    Inf]),...
                single([
                    NaN
                    NaN
                    NaN
                    NaN
                    NaN
                    NaN
                    NaN]),...
                uint16([
                    1    
                    2    
                    3    
                    4    
                    65535
                    6    
                    7]),...
                int8([
                    1
                    2
                    3
                    4
                    127
                    6
                    7])
                };
            actualClasses = cell(1,size(T,2));
            actualValues = cell(1,size(T,2));
            for col = 1:size(T,2)
                actualClasses{col} = class(T{1,col});
                actualValues{col} = T{:,col};
                testCase.verifyEqual(actualValues{col},expectedValues{col})
            end
            
            testCase.verifyEqual(actualClasses,expectedClasses)
        end
        function testSkipColumn(testCase)
            % Define the file with the test data
            filename	= [testCase.RessourcePath,'tableFileSkipColumn.xlsx'];
            
            % Read it
            T           = table.readTableFile(filename);
            
            % Only compare the actual data. Metadata is tested elsewhere
            actual      = T{:,:};
            expected    = {
                '1',        'abc';
                '',         'abc';
                'test',     'def';
                'string',   'abc';
                '1',        'def';
                '-2',       'def';
                '',         'def';
                '',         'abc'};
            
            testCase.verifyEqual(actual,expected)
        end
        function testEmptyTable(testCase)
            % Define the file with the test data
            filename	= [testCase.RessourcePath,'tableFileEmptyTable.xlsx'];
            
            % Read it
            T           = table.readTableFile(filename);
            
            % Only compare the actual data. Metadata is tested elsewhere
            actual      = T{:,:};
            expected    = cell(0,3);
            
            testCase.verifyEqual(actual,expected)
        end
        function testEmptyFile(testCase)
            % Define the file with the test data
            filename	= [testCase.RessourcePath,'tableFileEmptyFile.xlsx'];
            
            % Test error
            errorId     = 'Utilities:table:readTableFile:MissingHeader';
            testCase.verifyError(@() table.readTableFile(filename),errorId)
        end
        function testInvalidFile(testCase)
            % Define the file with the test data
            filename	= [testCase.RessourcePath,'tableFileInvalidFile.xlsx'];
            
            % Test error
            errorId     = 'Utilities:table:readTableFile:InvalidFile';
            testCase.verifyError(@() table.readTableFile(filename),errorId)
        end
	end
end
