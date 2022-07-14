function tf = isOnReleaseBranch(repoName)
    
    % Get the path to this script and cd to it
    dingiPath       = getToolboxRessources(repoName,'toolbox');
    originalPath    = cd(dingiPath);
    
    % Get current branch name for repo
    [~,branchName] = system('git rev-parse --abbrev-ref HEAD');
    
    % Check if the branch is the release branch
    tf = strcmp(branchName,'release');
    
    % Change back to original path
    cd(originalPath);
end
