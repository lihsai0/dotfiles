# git-lfs
#
# ALIASES
#   glfsi   → git lfs install
#   glfst   → git lfs track
#   glfsls  → git lfs ls-files
#   glfsmi  → git lfs migrate import --include=
#
# FUNCTIONS
#   gplfs   → git lfs push origin <current branch> --all
#
# NOTE: gplfs calls `git_current_branch`, which is autoloaded from
# fish/functions/git_current_branch.fish (shared with the git cog). The OMZ
# plugin defines no completion.
if not contains "git-lfs" $cogs
    return 0
end

if not command -q git-lfs
    echo "[WARNING] git-lfs not found. Please install it." >&2
    return 1
end

abbr -a glfsi 'git lfs install'
abbr -a glfst 'git lfs track'
abbr -a glfsls 'git lfs ls-files'
abbr -a glfsmi 'git lfs migrate import --include='

function gplfs
    git lfs push origin (git_current_branch) --all
end
