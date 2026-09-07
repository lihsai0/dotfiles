# gh — GitHub CLI (from Oh My Zsh gh plugin)
#
# NOTE: The OMZ gh plugin defines no aliases — it only sets up completion.
# The zsh plugin writes a generated `_gh` completion file into ZSH_CACHE_DIR
# at startup; the fish equivalent generates gh's native fish completions once
# and caches them in $__fish_config_dir/completions/gh.fish (regenerated only
# after deleting the cached file).
# Generator verified: `gh completion -s fish` on stdout starts with
# "# fish completion for gh".

if not contains "gh" $cogs
    return 0
end

if not command -q gh
    echo "[WARNING] gh not found. Please install it." >&2
    return 1
end

if not test -f $__fish_config_dir/completions/gh.fish
    gh completion -s fish > $__fish_config_dir/completions/gh.fish
end
