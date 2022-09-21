function T = readCalkulateResultFile(file)
% readCalkulateResultFile  Reads a result file from AlkalinityAnalysis
%   READCALKULATERESULTFILE reads the .csv result file from an
%     AlkalinityAnalysis export (via calkulateDatasetToCSV) and returns the data
%     as a table.
%
%   Syntax
%     T = READCALKULATERESULTFILE(file)
%
%   Description
%     T = READCALKULATERESULTFILE(file) reads the .csv file at the fullpath file 
%       and returns it as a table T.
%
%   Example(s)
%     T = READCALKULATERESULTFILE('~/TA-measurement.results.csv')
%
%
%   Input Arguments
%     file - absolute path to file
%       char
%         The absolute path to the .csv file to read.
%
%
%   Output Arguments
%     T - output table
%       table
%         The data from the .csv file returned as a table.
%
%
%   Name-Value Pair Arguments
%
%
%   See also READTABLE
%
%   Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
%

    % Read the data
	T = readtable(file,...
        'FileType',             'text',...
        'Delimiter',            'comma',...
        'Encoding',             'UTF-8',...
        'ReadVariableNames',	true);
    
    % Modify time format
    T.titration_start.Format = 'dd.MM.yyyy HH:mm:ss';
end
