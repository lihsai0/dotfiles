# mise
#
# Activates mise, preferring the `mise` command on PATH, then
# ~/.local/bin/mise — same order as the OMZ mise plugin.
#
# NOTE the plugin's zsh completion machinery is not ported: autoload of
# _mise, the _comps binding and the background `mise completion zsh`
# generation into ZSH_CACHE_DIR are zsh-only. (mise supports
# `mise completion fish`, but the migration table says "activate only" —
# keep it out of scope.)
if not contains "mise" $cogs
    return 0
end

set -l mise_bin
if command -q mise
    set mise_bin mise
else if test -x $HOME/.local/bin/mise
    set mise_bin $HOME/.local/bin/mise
end

if not command -q $mise_bin
    echo "[WARNING] mise not found. Please install it." >&2
    return 1
end

if not set -q MISE_SHELL
    $mise_bin activate fish | source
end

if not test -f $__fish_config_dir/completions/mise.fish
    mise completion fish > $__fish_config_dir/completions/mise.fish 2>/dev/null
end
