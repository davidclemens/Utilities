function version = version(toolboxName)
% version  Return the Dingi version number
%   VERSION returns the Dingi semantic version number.
%
%   Syntax
%     version = VERSION(toolboxName)
%
%   Description
%     version = VERSION(toolboxName) returns the semantic version number of
%       toolbox toolboxName.
%
%   Example(s)
%     version = VERSION('Dingi')
%
%
%   Input Arguments
%     toolboxName - name of the toolbox
%       char
%         The name of the toolbox to query.
%
%
%   Output Arguments
%     version - Dingi semantic version number
%       char
%         The Dingi semantic version number. See <a href="https://semver.org">https://semver.org</a>
%         for reference.
%
%
%   Name-Value Pair Arguments
%
%
%   See also VER
%
%   Copyright (c) 2021-2022 David Clemens (dclemens@geomar.de)
%
    
    info    = ver(toolboxName);
    
    % Get top level files of toolbox
    [~,files] = toolbox.ressources(toolboxName,'toolbox');
    
    % Warn if no version is available
    if ~ismember('Contents.m',{files.name})
        warning('Utilities:toolbox:version:noVersionAvailable',...
            'The toolbox ''%s'' does not contain a ''Contents.m'' file with a version number. Returning empty char.',toolboxName)
        version = '';
    else
        version = info.Version;
    end
end
