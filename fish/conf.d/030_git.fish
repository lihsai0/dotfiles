# git
#
# Port of the Oh My Zsh git plugin (git.plugin.zsh).
#
# FUNCTIONS (17)
#   (git_develop_branch, git_main_branch, grename, gunwipall,
#   work_in_progress, ggpnp, gbda, gbds, gccd, gdv, gdnolock,
#   _git_log_prettily, ggu, ggl, ggf, ggfl, ggp) + gtl (zsh function+noglob
#   trick → plain fish function).
#
# ALIASES (201)
#   All 197 `alias` definitions from git.plugin.zsh are ported as `abbr`,
#   plus the 4 version-gated aliases (gfa, gpf, gpsupf, gsta) which have two
#   variants chosen at load time by git version. Force aliases (`…!`) and the
#   backgrounded gitk aliases (`gk`, `gke`) are kept exact.
#
# NOTE skipped (zsh-only):
#   - `grt`/`ggpnp`/… argument handling uses fish `-a` named args for fixed
#     parameters and `$argv` for variadic/passthrough ones.

if not contains "git" $cogs
    return 0
end

if not command -q git
    echo "[WARNING] git not found. Please install it." >&2
    return 1
end

set -l git_version (command git version 2>/dev/null | string replace -r '^git version ' '')

# __git_version_ge <need> <have> — exit 0 when $have >= $need (dotted numeric).
function __git_version_ge -a need have
    set -l need_parts (string split . -- $need)
    set -l have_parts (string split . -- $have)
    for i in 1 2 3
        set -l n 0
        set -l h 0
        if set -q need_parts[$i]
            set n $need_parts[$i]
        end
        if set -q have_parts[$i]
            set h $have_parts[$i]
        end
        if test $h -gt $n
            return 0
        else if test $h -lt $n
            return 1
        end
    end
    return 0
end

# --- functions ---

function git_develop_branch -d "Print the develop branch name (dev/devel/develop/development)"
    command git rev-parse --git-dir >/dev/null 2>&1
    or return
    for branch in dev devel develop development
        if command git show-ref -q --verify refs/heads/$branch
            echo $branch
            return 0
        end
    end
    echo develop
    return 1
end

function git_main_branch -d "Print the main branch name (main/trunk/master/etc.)"
    command git rev-parse --git-dir >/dev/null 2>&1
    or return
    for ref in \
        refs/heads/main refs/heads/trunk refs/heads/mainline \
        refs/heads/default refs/heads/stable refs/heads/master \
        refs/remotes/origin/main refs/remotes/origin/trunk refs/remotes/origin/mainline \
        refs/remotes/origin/default refs/remotes/origin/stable refs/remotes/origin/master \
        refs/remotes/upstream/main refs/remotes/upstream/trunk refs/remotes/upstream/mainline \
        refs/remotes/upstream/default refs/remotes/upstream/stable refs/remotes/upstream/master
        if command git show-ref -q --verify $ref
            string replace -r '.*/' '' -- $ref
            return 0
        end
    end
    for remote in origin upstream
        set -l ref (command git rev-parse --abbrev-ref $remote/HEAD 2>/dev/null)
        if string match -q "$remote/*" -- $ref
            string replace "$remote/" '' -- $ref
            return 0
        end
    end
    echo master
    return 1
end

function grename -a old new -d "Rename a branch and update its upstream"
    if test -z "$old"; or test -z "$new"
        echo "Usage: grename old_branch new_branch" >&2
        return 1
    end
    git branch -m "$old" "$new"
    if git push origin :"$old"
        git push --set-upstream origin "$new"
    end
end

# --- functions (work in progress) ---

function gunwipall -d "Reset to the commit before the last WIP commit"
    set -l commit (git log --grep='--wip--' --invert-grep --max-count=1 --format=format:%H)
    if test "$commit" != (git rev-parse HEAD)
        git reset $commit
        or return 1
    end
end

function work_in_progress -d "Print WIP!! if HEAD is a WIP commit"
    command git -c log.showSignature=false log -n 1 2>/dev/null | grep -q -- "--wip--"
    and echo "WIP!!"
end

function ggpnp -d "Pull and push (or pass args through to both)"
    if test (count $argv) -eq 0
        ggl
        and ggp
    else
        ggl (string join ' ' -- $argv)
        and ggp (string join ' ' -- $argv)
    end
end

function gbda -d "Delete merged branches"
    set -l main (git_main_branch)
    set -l dev (git_develop_branch)
    git branch --no-color --merged \
        | command grep -vE '^([+*]|\s*('"$main"'|'"$dev"')\s*$)' \
        | command xargs git branch --delete 2>/dev/null
end

function gbds -d "Delete branches already merged into the default branch"
    set -l default_branch
    git_main_branch | read default_branch
    if test $pipestatus[1] -ne 0
        git_develop_branch | read default_branch
    end

    git for-each-ref refs/heads/ '--format=%(refname:short)' \
        | while read -l branch
            set -l merge_base (git merge-base $default_branch $branch)
            if git cherry $default_branch (git commit-tree (git rev-parse "$branch^{tree}") -p $merge_base -m _) \
                    | string match -q -- '-*'
                git branch -D $branch
            end
        end
end

function gccd -d "Clone a repo and cd into it"
    # Find the repo URI among the args (a git URL or scp-like host:path).
    # NOTE simplified vs the plugin's extendedglob pattern; matches anything
    # containing `://` or `@`.
    set -l repo
    for arg in $argv
        if string match -q '*://*' -- $arg; or string match -q '*@*' -- $arg
            set repo $arg
            break
        end
    end
    if test -z "$repo"
        set repo $argv[-1]
    end

    command git clone --recurse-submodules $argv
    or return

    if test -d "$argv[-1]"
        cd "$argv[-1]"
    else
        set -l dir (string replace -r '.*[/:]' '' -- $repo)
        cd (string replace -r '\.git/*$' '' -- $dir)
    end
end

function gdv -d "View git diff -w with a pager"
    git diff -w $argv | view -
end

function gdnolock -d "git diff excluding lock files"
    git diff $argv ':(exclude)package-lock.json' ':(exclude)*.lock'
end

function _git_log_prettily -a format -d "git log with the given pretty format"
    if test -n "$format"
        git log --pretty=$format
    end
end

function ggu -a branch -d "git pull --rebase origin <branch> (default: current)"
    if test (count $argv) -ne 1
        set branch (git_current_branch)
    end
    git pull --rebase origin "$branch"
end

function ggl -a branch -d "git pull origin <branch> (default: current; multiple args joined)"
    if test (count $argv) -gt 1
        git pull origin (string join ' ' -- $argv)
        return
    end
    if test (count $argv) -eq 0
        set branch (git_current_branch)
    end
    git pull origin "$branch"
end

function ggf -a branch -d "git push --force origin <branch> (default: current)"
    if test (count $argv) -ne 1
        set branch (git_current_branch)
    end
    git push --force origin "$branch"
end

function ggfl -a branch -d "git push --force-with-lease origin <branch> (default: current)"
    if test (count $argv) -ne 1
        set branch (git_current_branch)
    end
    git push --force-with-lease origin "$branch"
end

function ggp -a branch -d "git push origin <branch> (default: current; multiple args joined)"
    if test (count $argv) -gt 1
        git push origin (string join ' ' -- $argv)
        return
    end
    if test (count $argv) -eq 0
        set branch (git_current_branch)
    end
    git push origin "$branch"
end

function gtl -a prefix -d "List tags matching a prefix"
    git tag --sort=-v:refname -n --list "$prefix*"
end

# --- aliases ---

abbr -a grt 'cd (git rev-parse --show-toplevel; or echo .)'
abbr -a ggpur 'ggu'

abbr -a g 'git'
abbr -a ga 'git add'
abbr -a gaa 'git add --all'
abbr -a gapa 'git add --patch'
abbr -a gau 'git add --update'
abbr -a gav 'git add --verbose'
abbr -a gwip 'git add -A; git rm (git ls-files --deleted) 2>/dev/null; git commit --no-verify --no-gpg-sign --message "--wip-- [skip ci]"'
abbr -a gam 'git am'
abbr -a gama 'git am --abort'
abbr -a gamc 'git am --continue'
abbr -a gamscp 'git am --show-current-patch'
abbr -a gams 'git am --skip'
abbr -a gap 'git apply'
abbr -a gapt 'git apply --3way'
abbr -a gbs 'git bisect'
abbr -a gbsb 'git bisect bad'
abbr -a gbsg 'git bisect good'
abbr -a gbsn 'git bisect new'
abbr -a gbso 'git bisect old'
abbr -a gbsr 'git bisect reset'
abbr -a gbss 'git bisect start'
abbr -a gbl 'git blame -w'
abbr -a gb 'git branch'
abbr -a gba 'git branch --all'
abbr -a gbd 'git branch --delete'
abbr -a gbD 'git branch --delete --force'
abbr -a gbgd 'env LANG=C git branch --no-color -vv | grep ": gone]" | cut -c 3- | awk \'{print $1}\' | xargs git branch -d'
abbr -a gbgD 'env LANG=C git branch --no-color -vv | grep ": gone]" | cut -c 3- | awk \'{print $1}\' | xargs git branch -D'
abbr -a gbm 'git branch --move'
abbr -a gbnm 'git branch --no-merged'
abbr -a gbr 'git branch --remotes'
abbr -a ggsup 'git branch --set-upstream-to=origin/(git_current_branch)'
abbr -a gbg 'env LANG=C git branch -vv | grep ": gone]"'
abbr -a gco 'git checkout'
abbr -a gcor 'git checkout --recurse-submodules'
abbr -a gcb 'git checkout -b'
abbr -a gcB 'git checkout -B'
abbr -a gcd 'git checkout (git_develop_branch)'
abbr -a gcm 'git checkout (git_main_branch)'
abbr -a gcp 'git cherry-pick'
abbr -a gcpa 'git cherry-pick --abort'
abbr -a gcpc 'git cherry-pick --continue'
abbr -a gclean 'git clean --interactive -d'
abbr -a gcl 'git clone --recurse-submodules'
abbr -a gclf 'git clone --recursive --shallow-submodules --filter=blob:none --also-filter-submodules'
abbr -a gcam 'git commit --all --message'
abbr -a gcas 'git commit --all --signoff'
abbr -a gcasm 'git commit --all --signoff --message'
abbr -a gcs 'git commit --gpg-sign'
abbr -a gcss 'git commit --gpg-sign --signoff'
abbr -a gcssm 'git commit --gpg-sign --signoff --message'
abbr -a gcmsg 'git commit --message'
abbr -a gcsm 'git commit --signoff --message'
abbr -a gc 'git commit --verbose'
abbr -a gca 'git commit --verbose --all'
abbr -a 'gca!' 'git commit --verbose --all --amend'
abbr -a 'gcan!' 'git commit --verbose --all --no-edit --amend'
abbr -a 'gcans!' 'git commit --verbose --all --signoff --no-edit --amend'
abbr -a 'gcann!' 'git commit --verbose --all --date=now --no-edit --amend'
abbr -a 'gc!' 'git commit --verbose --amend'
abbr -a gcn 'git commit --verbose --no-edit'
abbr -a 'gcn!' 'git commit --verbose --no-edit --amend'
abbr -a gcf 'git config --list'
abbr -a gcfu 'git commit --fixup'
abbr -a gdct 'git describe --tags (git rev-list --tags --max-count=1)'
abbr -a gd 'git diff'
abbr -a gdca 'git diff --cached'
abbr -a gdcw 'git diff --cached --word-diff'
abbr -a gds 'git diff --staged'
abbr -a gdw 'git diff --word-diff'
abbr -a gdup 'git diff @{upstream}'
abbr -a gdt 'git diff-tree --no-commit-id --name-only -r'
abbr -a gf 'git fetch'
if __git_version_ge 2.8 $git_version
    abbr -a gfa 'git fetch --all --tags --prune --jobs=10'
else
    abbr -a gfa 'git fetch --all --tags --prune'
end
abbr -a gfo 'git fetch origin'
abbr -a gg 'git gui citool'
abbr -a gga 'git gui citool --amend'
abbr -a ghh 'git help'
abbr -a glgg 'git log --graph'
abbr -a glgga 'git log --graph --decorate --all'
abbr -a glgm 'git log --graph --max-count=10'
abbr -a glods 'git log --graph --pretty=\'%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset\' --date=short'
abbr -a glod 'git log --graph --pretty=\'%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset\''
abbr -a glola 'git log --graph --pretty=\'%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset\' --all'
abbr -a glols 'git log --graph --pretty=\'%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset\' --stat'
abbr -a glol 'git log --graph --pretty=\'%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset\''
abbr -a glo 'git log --oneline --decorate'
abbr -a glog 'git log --oneline --decorate --graph'
abbr -a gloga 'git log --oneline --decorate --graph --all'
abbr -a glp '_git_log_prettily'
abbr -a glg 'git log --stat'
abbr -a glgp 'git log --stat --patch'
abbr -a gignored 'git ls-files -v | grep "^[[:lower:]]"'
abbr -a gfg 'git ls-files | grep'
abbr -a gm 'git merge'
abbr -a gma 'git merge --abort'
abbr -a gmc 'git merge --continue'
abbr -a gms 'git merge --squash'
abbr -a gmff 'git merge --ff-only'
abbr -a gmom 'git merge origin/(git_main_branch)'
abbr -a gmum 'git merge upstream/(git_main_branch)'
abbr -a gmtl 'git mergetool --no-prompt'
abbr -a gmtlvim 'git mergetool --no-prompt --tool=vimdiff'
abbr -a gl 'git pull'
abbr -a gpr 'git pull --rebase'
abbr -a gprv 'git pull --rebase -v'
abbr -a gpra 'git pull --rebase --autostash'
abbr -a gprav 'git pull --rebase --autostash -v'
abbr -a gprom 'git pull --rebase origin (git_main_branch)'
abbr -a gpromi 'git pull --rebase=interactive origin (git_main_branch)'
abbr -a gprum 'git pull --rebase upstream (git_main_branch)'
abbr -a gprumi 'git pull --rebase=interactive upstream (git_main_branch)'
abbr -a ggpull 'git pull origin (git_current_branch)'
abbr -a gluc 'git pull upstream (git_current_branch)'
abbr -a glum 'git pull upstream (git_main_branch)'
abbr -a gp 'git push'
abbr -a gpd 'git push --dry-run'
abbr -a 'gpf!' 'git push --force'
if __git_version_ge 2.30 $git_version
    abbr -a gpf 'git push --force-with-lease --force-if-includes'
else
    abbr -a gpf 'git push --force-with-lease'
end
abbr -a gpsup 'git push --set-upstream origin (git_current_branch)'
if __git_version_ge 2.30 $git_version
    abbr -a gpsupf 'git push --set-upstream origin (git_current_branch) --force-with-lease --force-if-includes'
else
    abbr -a gpsupf 'git push --set-upstream origin (git_current_branch) --force-with-lease'
end
abbr -a gpv 'git push --verbose'
abbr -a gpoat 'git push origin --all && git push origin --tags'
abbr -a gpod 'git push origin --delete'
abbr -a ggpush 'git push origin (git_current_branch)'
abbr -a gpu 'git push upstream'
abbr -a grb 'git rebase'
abbr -a grba 'git rebase --abort'
abbr -a grbc 'git rebase --continue'
abbr -a grbi 'git rebase --interactive'
abbr -a grbo 'git rebase --onto'
abbr -a grbs 'git rebase --skip'
abbr -a grbd 'git rebase (git_develop_branch)'
abbr -a grbm 'git rebase (git_main_branch)'
abbr -a grbom 'git rebase origin/(git_main_branch)'
abbr -a grbum 'git rebase upstream/(git_main_branch)'
abbr -a grf 'git reflog'
abbr -a gr 'git remote'
abbr -a grv 'git remote --verbose'
abbr -a gra 'git remote add'
abbr -a grrm 'git remote remove'
abbr -a grmv 'git remote rename'
abbr -a grset 'git remote set-url'
abbr -a grup 'git remote update'
abbr -a grh 'git reset'
abbr -a gru 'git reset --'
abbr -a grhh 'git reset --hard'
abbr -a grhk 'git reset --keep'
abbr -a grhs 'git reset --soft'
abbr -a gpristine 'git reset --hard && git clean --force -dfx'
abbr -a gwipe 'git reset --hard && git clean --force -df'
abbr -a groh 'git reset origin/(git_current_branch) --hard'
abbr -a grs 'git restore'
abbr -a grss 'git restore --source'
abbr -a grst 'git restore --staged'
abbr -a gunwip 'git rev-list --max-count=1 --format="%s" HEAD | grep -q "\--wip--" && git reset HEAD~1'
abbr -a grev 'git revert'
abbr -a greva 'git revert --abort'
abbr -a grevc 'git revert --continue'
abbr -a grm 'git rm'
abbr -a grmc 'git rm --cached'
abbr -a gcount 'git shortlog --summary --numbered'
abbr -a gsh 'git show'
abbr -a gsps 'git show --pretty=short --show-signature'
abbr -a gstall 'git stash --all'
abbr -a gstaa 'git stash apply'
abbr -a gstc 'git stash clear'
abbr -a gstd 'git stash drop'
abbr -a gstl 'git stash list'
abbr -a gstp 'git stash pop'
if __git_version_ge 2.13 $git_version
    abbr -a gsta 'git stash push'
    abbr -a gstu 'git stash push --include-untracked'
else
    abbr -a gsta 'git stash save'
    abbr -a gstu 'git stash save --include-untracked'
end
abbr -a gsts 'git stash show --patch'
abbr -a gst 'git status'
abbr -a gss 'git status --short'
abbr -a gsb 'git status --short --branch'
abbr -a gsi 'git submodule init'
abbr -a gsu 'git submodule update'
abbr -a gsd 'git svn dcommit'
abbr -a git-svn-dcommit-push 'git svn dcommit && git push github (git_main_branch):svntrunk'
abbr -a gsr 'git svn rebase'
abbr -a gsw 'git switch'
abbr -a gswc 'git switch --create'
abbr -a gswd 'git switch (git_develop_branch)'
abbr -a gswm 'git switch (git_main_branch)'
abbr -a gta 'git tag --annotate'
abbr -a gts 'git tag --sign'
abbr -a gtv 'git tag | sort -V'
abbr -a gignore 'git update-index --assume-unchanged'
abbr -a gunignore 'git update-index --no-assume-unchanged'
abbr -a gwch 'git log --patch --abbrev-commit --pretty=medium --raw'
abbr -a gwt 'git worktree'
abbr -a gwta 'git worktree add'
abbr -a gwtls 'git worktree list'
abbr -a gwtmv 'git worktree move'
abbr -a gwtrm 'git worktree remove'
abbr -a gk 'command gitk --all --branches &'
abbr -a gke 'command gitk --all (git log --walk-reflogs --pretty=%h) &'

functions -e __git_version_ge
