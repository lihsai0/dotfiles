# mole
if not contains "mole" $cogs
    return 0
end

if not command -q mole
    echo "[WARNING] mole not found. Please install it." >&2
    return 1
end

if not test -f $__fish_config_dir/completions/mole.fish
    mole completion fish > $__fish_config_dir/completions/mole.fish
end
