# exercism — Exercism CLI (from custom OMZ "exercism" plugin)
#
# NOTE: The OMZ "plugin" was completion-only — ~/.oh-my-zsh/custom/plugins/
# exercism/ holds just a handwritten zsh completion function (_exercism), no
# aliases or profile helpers. exercism ships its own completion generator, so
# the fish equivalent is guarded one-time generation.
# Generator verified: `exercism completion fish` on stdout starts with
# "# fish completion for exercism".

if not contains "exercism" $cogs
    return 0
end

if not command -q exercism
    echo "[WARNING] exercism not found. Please install it." >&2
    return 1
end

if not test -f $__fish_config_dir/completions/exercism.fish
    exercism completion fish > $__fish_config_dir/completions/exercism.fish
end
