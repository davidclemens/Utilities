function [tf,varargout] = validateTableVariableNames(T,expectedVariableNames)
% validateTableVariableNames  Test if table has expected column names
%   VALIDATETABLEVARIABLENAMES tests if table T contains all of the expected
%     column names (variable names) provided in expectedVariableNames.
%
%   Syntax
%     tf = VALIDATETABLEVARIABLENAMES(T,expectedVariableNames)
%     [tf,ind] = VALIDATETABLEVARIABLENAMES(__)
%
%   Description
%     tf = VALIDATETABLEVARIABLENAMES(T,expectedVariableNames)  Test if table 
%       T has all variable names defined in expectedVariableNames.
%     [tf,ind] = VALIDATETABLEVARIABLENAMES(__)  Also return the column index at
%       which the expectedVariableNames are found in T.
%
%   Example(s)
%     tf = VALIDATETABLEVARIABLENAMES(table(1,2,3,'VariableNames',{'a','b','c'}),{'a','c','b','d'})
%       returns tf = false.
%     tf = VALIDATETABLEVARIABLENAMES(table(1,2,3,'VariableNames',{'a','b','c'}),{'a','c'})
%       returns tf = true.
%     [tf,ind] =VALIDATETABLEVARIABLENAMES(table(1,2,3,'VariableNames',{'a','b','c'}),{'a','c'})
%       returns tf = true and ind = [1,3].
%
%
%   Input Arguments
%     T - Input table
%       table
%         The table against which the expected variable names are tested.
%
%     expectedVariableNames - expected column names
%       cellstr vector
%         Cellstr list of variable names that are required to be a member of
%         table T.
%
%
%   Output Arguments
%     tf - test result
%       logical scalar
%         True if all entries in expectedVariableNames are variable names in
%         table T.
%     ind - column indices
%       integer vector
%         The column indices at which the expectedVariableNames are found in
%         table T returned as an integer vector.
%
%
%   Name-Value Pair Arguments
%
%
%   See also TABLE.VALIDATETABLEDATATYPES
%
%   Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
%
    
    nargoutchk(0,2)
    
    % Validate inputs
    validateattributes(T,{'table'},{},mfilename,'T',1)
    validateattributes(expectedVariableNames,{'cell'},{'vector'},mfilename,'expectedVariableNames',2)
    
    assert(iscellstr(expectedVariableNames),...
        'Utilities:table:validateTableVariableNames:invalidType',...
        'Expected input number 2, expectedVariableNames, to be one of these types:\n\ncellstr.\n\nInstead its type was %s.',class(expectedVariableNames))

    nCols = size(T,2);
    nExpectedVariableNames = numel(expectedVariableNames);
    assert(nExpectedVariableNames <= nCols,...
        'Utilities:table:validateTableVariableNames:notEnoughVariableNames',...
        'There were only %u espected variable names provided, even though the table has %u columns.',nExpectedVariableNames,nCols)
    
    % Test if all variable names occur in table and their column index
    [im,imInd] = ismember(expectedVariableNames,T.Properties.VariableNames);
    tf = all(im);
    
    % Optionally return column indices
    if nargout == 2
        varargout{1} = imInd;
    end
end
