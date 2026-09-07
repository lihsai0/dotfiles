# buf - Buf CLI
if not contains "buf" $cogs
    return 0
end

if not type -q buf
    echo "[WARNING] buf not found. Please install it." >&2
    return 1
end

if not test -f $__fish_config_dir/completions/buf.fish
    buf completion fish > $__fish_config_dir/completions/buf.fish
end
