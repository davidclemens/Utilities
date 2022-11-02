function tf = isOnReleaseBranch(toolboxName)
% isOnReleaseBranch  Test if the toolbox git repository is on release branch
%   ISONRELEASEBRANCH test if the git repository of toolbox/package toolboxName
%     is on the release branch
%
%   Syntax
%     tf = ISONRELEASEBRANCH(toolboxName)
%
%   Description
%     tf = ISONRELEASEBRANCH(toolboxName)  Test if the git repository of
%       toolbox/package toolboxName is on the releas branch.
%
%   Example(s)
%     tf = ISONRELEASEBRANCH('Dingi')  returns false.
%
%
%   Input Arguments
%     toolboxName - name of the toolbox
%       char
%         The name of the toolbox to query.
%
%
%   Output Arguments
%     tf - test result
%       logical
%         tf is true if the toolbox/package is on the release branch and false
%         if it is not.
%
%
%   Name-Value Pair Arguments
%
%
%   See also TOOLBOX.RESSOURCES
%
%   Copyright (c) 2021-2022 David Clemens (dclemens@geomar.de)
%

    % Get the path to repository and cd to it
    repoPath        = toolbox.ressources(toolboxName,'toolbox');
    originalPath	= cd(repoPath);
    
    % Get current branch name for repo
    [status,branchName] = system('git rev-parse --abbrev-ref HEAD');
    
    % Handle folders that are not a git repo
    if status ~= 0
        error('Utilities:toolbox:isOnReleaseBranch:noGitRepo',...
            'The toolbox ''%s'' is not a git repository.',repoPath)
    end
    
    % Check if the branch is the release branch
    tf = strcmp(branchName,'release');
    
    % Change back to original path
    cd(originalPath);
end
