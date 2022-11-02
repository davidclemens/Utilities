function [path,varargout] = ressources(toolboxName,option)
% ressources  Return the path to the specified toolbox
%   RESSOURCES returns the path to a toolbox and a list of all
%   ressources in that toolbox
%
%   Syntax
%     path = RESSOURCES(toolboxName)
%     path = RESSOURCES(toolboxName,option)
%     [path,files] = RESSOURCES(__)
%
%   Description
%     path = RESSOURCES(toolboxName) returns the full path to the
%       ressources folder of toolbox 'toolboxName'.
%     path = RESSOURCES(toolboxName,option) additionally specifies the
%       ressource type ('', 'parent' or 'toolbox').
%     [path,files] = RESSOURCES(__) additionally return a struct files
%       with info on the contents of the queried toolbox.
%
%   Example(s)
%     path = RESSOURCES('DataKit') returns '[...]/DataKit/ressources'
%     [path,files] = RESSOURCES('AnalysisKit','toolbox') returns path =
%       '[...]/AnalysisKit' and a list of all top level files files.
%     path = RESSOURCES('DataKit','parent') returns '[...]/Dingi'
%
%
%   Input Arguments
%     toolboxName - name of the toolbox
%       char
%         The name of the toolbox to query.
%
%     option - return options
%       '' (default) | 'parent' | 'toolbox'
%         The return type. The default ('') is to return the info on the 
%         contents of the ressource folder of the queried toolbox. 'parent'
%         returns info on the contents of the parent folder to the queried one.
%         'toolbox' returns info on the contents of the queried toolbox.
%
%
%   Output Arguments
%     path - full path to the queried toolbox
%       char
%         Full path to the queried toolbox ressources (with option = ''), the
%         parent folder (with option = 'parent') or the toolbox (with option =
%         'toolbox').
%
%     files - info on the contents
%       struct
%         Struct containing info on all files in the queried toolbox (depending
%         on option).
%
%
%   Name-Value Pair Arguments
%
%
%   See also WHAT, DIR
%
%   Copyright (c) 2021-2022 David Clemens (dclemens@geomar.de)
%

    % Input validation
    validateattributes(toolboxName,{'char'},{'nonempty','row'},mfilename,'toolboxName',1)
    if exist('option','var') == 1
        validateattributes(option,{'char'},{'nonempty','row'},mfilename,'option',2)
        option = validatestring(option,{'parent','toolbox'});
    else
        option = '';
    end
    
    % Get the relevant path for the toolboxName
    packageInfo     = what(toolboxName);
    
    % Validate toolboxName
    if isempty(packageInfo)
        % No toolbox/package found
        error('Utilities:toolbox:ressources:invalidToolboxName',...
            'The toolboxName ''%s'' did not match any MATLAB toolbox/package.',toolboxName)
    elseif numel(packageInfo) > 1
        % More than 1 toolbox/package found
        warning('Utilities:toolbox:ressources:multipleToolboxMatches',...
            'The toolboxName ''%s'' matched multiple MATLAB toolboxes/packages:\n\t%s\n\nOnly the first entry ''%s'' is used.\nTo return results for the other matches, specify the full path as toolboxName.',toolboxName,strjoin({packageInfo.path},'\n\t'),packageInfo(1).path)
        packageInfo = packageInfo(1);
    end
    
    switch option
        case 'parent'
            path    = packageInfo.path;
            parts   = strsplit(packageInfo.path,filesep);
            path    = [filesep,fullfile(parts{1:end - 1})];
        case 'toolbox'
            path    = packageInfo.path;
        otherwise
            path    = [packageInfo.path,'/ressources'];
            
            % Check if ressource folder exists
            if exist(path,'dir') ~= 7
                error('Utilities:toolbox:ressources:missingRessourceFolder',...
                    'The toolbox/package ''%s'' has no ''/ressource'' folder.',toolboxName)
            end
    end
    
    % List all files/folders
    files           = dir(path);
    
    % Remove '.' and '..' directories
    files(cellfun(@(s) strcmp(s,'.') | strcmp(s,'..'),{files.name})) = [];
    
    varargout{1}    = files;
end
