classdef (SharedTestFixtures = { ...
            matlab.unittest.fixtures.PathFixture(subsref(strsplit(mfilename('fullpath'),'/+'),substruct('{}',{':'})))
        }) writeTableFile_test < matlab.unittest.TestCase
    % writeTableFile_test  Unittests for table.writeTableFile
    % This class holds the unittests for the table.writeTableFile function.
    %
    % It can be run with runtests('Tests.table.writeTableFile_test').
    %
    %
    % Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
    %
    
    properties
        RessourcePath = [fileparts(mfilename('fullpath')),'/ressources/']
        WriteFolder char
    end
    
    methods(TestMethodSetup)
        function setupWriteFolder(testCase)
            import matlab.unittest.fixtures.TemporaryFolderFixture
            
            writeFolderFixture = testCase.applyFixture(TemporaryFolderFixture);
            testCase.WriteFolder = writeFolderFixture.Folder;
        end
    end
    
    methods (Test)
        function testReadWriteIntegrationCategorical(testCase)
            % Define the file with the test data
            readFilename	= 'tableFileCategorical.xlsx';
            
            % Get actual and expected tables
            [actual,expected] = testReadWriteIntegration(testCase,readFilename);

            testCase.verifyEqual(actual,expected)            
        end
        function testReadWriteIntegrationCellstr(testCase)
            % Define the file with the test data
            readFilename	= 'tableFileCellstr.xlsx';
            
            % Get actual and expected tables
            [actual,expected] = testReadWriteIntegration(testCase,readFilename);

            testCase.verifyEqual(actual,expected)            
        end
        function testReadWriteIntegrationDatetime(testCase)
            % Define the file with the test data
            readFilename	= 'tableFileDatetime.xlsx';
            
            % Get actual and expected tables
            [actual,expected] = testReadWriteIntegration(testCase,readFilename);

            testCase.verifyEqual(actual,expected)            
        end
        function testReadWriteIntegrationDuration(testCase)
            % Define the file with the test data
            readFilename	= 'tableFileDuration.xlsx';
            
            % Get actual and expected tables
            [actual,expected] = testReadWriteIntegration(testCase,readFilename);

            testCase.verifyEqual(actual,expected)            
        end
        function testReadWriteIntegrationLogical(testCase)
            % Define the file with the test data
            readFilename	= 'tableFileLogical.xlsx';
            
            % Get actual and expected tables
            [actual,expected] = testReadWriteIntegration(testCase,readFilename);

            testCase.verifyEqual(actual,expected)            
        end
        function testReadWriteIntegrationNumeric(testCase)
            % Define the file with the test data
            readFilename	= 'tableFileNumeric.xlsx';
            
            % Get actual and expected tables
            [actual,expected] = testReadWriteIntegration(testCase,readFilename);

            testCase.verifyEqual(actual,expected)            
        end
	end
end

function [actual,expected] = testReadWriteIntegration(testCase,filename)
    % Define the file with the test data
    readFilename	= [testCase.RessourcePath,filename];
    
    % Define the temporary write file
    writeFilename   = [testCase.WriteFolder,'/',filename];

    expected = table.readTableFile(readFilename);
    table.writeTableFile(expected,writeFilename)
    actual = table.readTableFile(writeFilename);
end
