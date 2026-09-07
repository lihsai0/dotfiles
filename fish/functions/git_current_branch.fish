# git_current_branch — print the current git branch name, or the short HEAD
# when detached. Ported from OMZ lib/git.zsh; autoloaded from fish/functions/
# so both the git and git-lfs cogs can call it.
function git_current_branch -d "Print the current git branch (short HEAD if detached)"
    set -l ref (command git symbolic-ref --quiet HEAD 2>/dev/null)
    set -l ret $status
    if test $ret -ne 0
        if test $ret -eq 128
            return  # no git repo
        end
        set ref (command git rev-parse --short HEAD 2>/dev/null)
        or return
    end
    string replace 'refs/heads/' '' -- $ref
end
