# rust
if not contains "rust" $cogs
    return 0
end

if command -q rustup
    if not test -f $__fish_config_dir/completions/rustup.fish
        rustup completions fish > $__fish_config_dir/completions/rustup.fish 2>/dev/null
        # the cargo not support for now but fish can suggest by itself
        # rust completions fish cargo > $__fish_config_dir/completions/cargo.fish 2>/dev/null
    end
end
